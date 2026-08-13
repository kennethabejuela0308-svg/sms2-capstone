<?php
/**
 * Research Implementation & Progress Monitoring
 * API Endpoint for Student (Researcher) Operations
 * 
 * Handles:
 * - Get research plan and milestones
 * - Submit progress updates
 * - Get progress history
 * - Get adviser feedback
 * 
 * DUPLICATE PREVENTION: Token-based + timestamp validation
 */

declare(strict_types=1);

header('Content-Type: application/json');

require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../../../includes/authentication.php';
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/research-progress-helpers.php';

// Require authentication
requireAuth();

// Only students with research groups can access
$currentRole = getCurrentUserRoleKey();
if ($currentRole !== 'student') {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied. Students only.']);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? $_POST['action'] ?? '';

try {
    $crad = cradDb();
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Database connection failed']);
    exit;
}

// Get current student's research group
$studentId     = trim((string) ($_SESSION['student_id'] ?? ''));
$studentUserId = (int) ($_SESSION['user_id'] ?? 0);
$studentName   = trim((string) ($_SESSION['user_name'] ?? ''));

if (empty($studentId) && $studentUserId <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Student identification required']);
    exit;
}

// Only allow access if the student's group is in the Capstone Group/Student Registry
$researchGroup = rpGetRegisteredResearchGroup($crad, $studentId, $studentUserId);

if (!$researchGroup) {
    http_response_code(403);
    echo json_encode([
        'success' => false,
        'message' => 'Research Development is not available. Your group must be registered in the Capstone Group/Student Registry first.'
    ]);
    exit;
}

$groupId = (int) $researchGroup['id'];

// Route to appropriate handler
switch ($action) {
    case 'get_research_plan':
        handleGetResearchPlan($crad, $groupId, $researchGroup);
        break;
        
    case 'get_milestones':
        handleGetMilestones($crad, $groupId);
        break;
        
    case 'submit_progress':
        if ($method !== 'POST') {
            http_response_code(405);
            echo json_encode(['success' => false, 'message' => 'Method not allowed']);
            exit;
        }
        handleSubmitProgress($crad, $groupId, $researchGroup, $studentUserId, $studentName);
        break;
        
    case 'get_progress_history':
        handleGetProgressHistory($crad, $groupId);
        break;
        
    case 'get_adviser_feedback':
        handleGetAdviserFeedback($crad, $groupId);
        break;
        
    case 'generate_token':
        // Generate submission token for duplicate prevention
        echo json_encode([
            'success' => true,
            'token' => rpGenerateSubmissionToken()
        ]);
        break;
        
    default:
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        exit;
}

/**
 * Get or create research plan with milestones
 */
function handleGetResearchPlan(PDO $crad, int $groupId, array $researchGroup): void
{
    // Get or create plan (idempotent)
    $plan = rpGetOrCreateResearchPlan($crad, $groupId);
    
    if (!$plan) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to get research plan']);
        return;
    }
    
    // Get milestones
    $milestoneStmt = $crad->prepare("
        SELECT * FROM research_milestones 
        WHERE research_plan_id = ?
        ORDER BY milestone_order ASC
    ");
    $milestoneStmt->execute([$plan['id']]);
    $milestones = $milestoneStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get latest progress update
    $latestUpdateStmt = $crad->prepare("
        SELECT * FROM research_progress_updates 
        WHERE research_group_id = ?
        ORDER BY submitted_at DESC
        LIMIT 1
    ");
    $latestUpdateStmt->execute([$groupId]);
    $latestUpdate = $latestUpdateStmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'plan' => $plan,
        'group' => [
            'group_number' => $researchGroup['group_number'],
            'group_name' => $researchGroup['group_name'],
            'research_title' => $researchGroup['research_title'],
            'adviser' => $researchGroup['adviser_name'] ?: $researchGroup['adviser']
        ],
        'milestones' => $milestones,
        'latest_update' => $latestUpdate ?: null
    ]);
}

/**
 * Get all milestones for the research plan
 */
function handleGetMilestones(PDO $crad, int $groupId): void
{
    // Get plan first
    $planStmt = $crad->prepare("SELECT id FROM research_plans WHERE research_group_id = ? LIMIT 1");
    $planStmt->execute([$groupId]);
    $plan = $planStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$plan) {
        echo json_encode(['success' => true, 'milestones' => []]);
        return;
    }
    
    $milestoneStmt = $crad->prepare("
        SELECT * FROM research_milestones 
        WHERE research_plan_id = ?
        ORDER BY milestone_order ASC
    ");
    $milestoneStmt->execute([$plan['id']]);
    $milestones = $milestoneStmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'milestones' => $milestones
    ]);
}

/**
 * Submit progress update with duplicate prevention
 */
function handleSubmitProgress(PDO $crad, int $groupId, array $researchGroup, int $userId, string $userName): void
{
    // Get POST data
    $input = json_decode(file_get_contents('php://input'), true) ?: $_POST;
    
    // Validate required fields
    if (!isset($input['milestone_id']) || !isset($input['new_progress'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields']);
        return;
    }
    
    // Validate submission token (DUPLICATE PREVENTION)
    $submissionToken = $input['submission_token'] ?? '';
    if (empty($submissionToken)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Submission token required']);
        return;
    }
    
    // Check for duplicate token usage
    if (rpIsTokenRecentlyUsed($crad, 'research_progress_updates', $submissionToken, 5)) {
        http_response_code(409);
        echo json_encode([
            'success' => false, 
            'message' => 'Duplicate submission detected. Please wait before submitting again.',
            'is_duplicate' => true
        ]);
        return;
    }
    
    // Get research plan
    $planStmt = $crad->prepare("SELECT * FROM research_plans WHERE research_group_id = ? LIMIT 1");
    $planStmt->execute([$groupId]);
    $plan = $planStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$plan) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Research plan not found']);
        return;
    }
    
    // Get milestone to update
    $milestoneStmt = $crad->prepare("
        SELECT * FROM research_milestones 
        WHERE id = ? AND research_plan_id = ?
        LIMIT 1
    ");
    $milestoneStmt->execute([$input['milestone_id'], $plan['id']]);
    $milestone = $milestoneStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$milestone) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Milestone not found']);
        return;
    }
    
    // Prepare progress update data
    $progressData = [
        'research_plan_id' => $plan['id'],
        'research_group_id' => $groupId,
        'milestone_id' => $input['milestone_id'],
        'submitted_by_user_id' => $userId,
        'submitted_by_name' => $userName,
        'update_title' => $input['update_title'] ?? $milestone['milestone_name'] . ' Progress Update',
        'previous_progress' => (float) $milestone['progress_percentage'],
        'new_progress' => (float) $input['new_progress'],
        'milestone_status' => $input['milestone_status'] ?? 'In Progress',
        'accomplishments' => $input['accomplishments'] ?? null,
        'problems_blockers' => $input['problems_blockers'] ?? null,
        'next_planned_activity' => $input['next_planned_activity'] ?? null,
        'submission_token' => $submissionToken
    ];
    
    // Submit progress update
    $result = rpSubmitProgressUpdate($crad, $progressData);
    
    if (!$result['success']) {
        http_response_code(400);
        echo json_encode($result);
        return;
    }
    
    // Create notification for adviser (with duplicate prevention)
    if (!empty($researchGroup['adviser_user_id'])) {
        rpCreateNotification($crad, [
            'recipient_user_id' => $researchGroup['adviser_user_id'],
            'recipient_email' => $researchGroup['adviser_email'] ?? '',
            'recipient_role' => 'adviser',
            'batch_key' => 'progress_update:' . $result['update_id'],
            'notification_type' => 'progress_update',
            'title' => 'New Progress Update',
            'body' => $researchGroup['group_number'] . ' submitted a progress update for ' . $milestone['milestone_name'],
            'related_entity_type' => 'progress_update',
            'related_entity_id' => $result['update_id'],
            'action_url' => BASE_URL . '/modules/faculty/pages/research-progress.php?group=' . $researchGroup['group_number']
        ]);
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Progress update submitted successfully',
        'update_id' => $result['update_id']
    ]);
}

/**
 * Get progress update history for the research group
 */
function handleGetProgressHistory(PDO $crad, int $groupId): void
{
    $stmt = $crad->prepare("
        SELECT 
            rpu.*,
            rm.milestone_name,
            rm.milestone_order
        FROM research_progress_updates rpu
        LEFT JOIN research_milestones rm ON rm.id = rpu.milestone_id
        WHERE rpu.research_group_id = ?
        ORDER BY rpu.submitted_at DESC
        LIMIT 50
    ");
    $stmt->execute([$groupId]);
    $updates = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'updates' => $updates
    ]);
}

/**
 * Get adviser feedback for the research group
 */
function handleGetAdviserFeedback(PDO $crad, int $groupId): void
{
    $stmt = $crad->prepare("
        SELECT 
            rpf.*,
            rm.milestone_name,
            rpu.update_title,
            rpu.submitted_at as update_submitted_at
        FROM research_progress_feedback rpf
        INNER JOIN research_progress_updates rpu ON rpu.id = rpf.progress_update_id
        LEFT JOIN research_milestones rm ON rm.id = rpf.milestone_id
        WHERE rpu.research_group_id = ?
        ORDER BY rpf.created_at DESC
        LIMIT 50
    ");
    $stmt->execute([$groupId]);
    $feedback = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'feedback' => $feedback
    ]);
}
