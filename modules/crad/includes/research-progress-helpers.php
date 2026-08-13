<?php
/**
 * Research Implementation & Progress Monitoring
 * Helper Functions for Duplicate Prevention and Database Operations
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/config.php';

/**
 * Get the student's research group — but ONLY if it qualifies for the
 * Capstone Group/Student Registry (fully approved title, all three signatures,
 * active coordinator assignment, and an assigned adviser).
 *
 * This is the single authoritative gate used by every Research Development
 * page in the student portal.  If the group does not appear in the Registry,
 * NULL is returned and the calling page must deny access.
 *
 * @param PDO    $crad          CRAD database connection
 * @param string $studentId     Student ID from session  (e.g. "S230000001")
 * @param int    $studentUserId User ID from session     (sms2_db.users.id)
 * @return array|null           research_groups row (+ adviser info) or null
 */
function rpGetRegisteredResearchGroup(PDO $crad, string $studentId, int $studentUserId): ?array
{
    $stmt = $crad->prepare("
        SELECT
            rg.*,
            COALESCE(raa.adviser_user_id, NULL)   AS adviser_user_id,
            COALESCE(raa.adviser_name,   '')       AS adviser_name,
            COALESCE(raa.adviser_email,  '')       AS adviser_email
        FROM research_groups rg

        /* Title Approval must be fully approved with all three signatures */
        JOIN title_approvals t ON t.id = rg.title_approval_id

        /* Active research coordinator assignment */
        JOIN research_coordinator_assignments ca ON ca.id = (
            SELECT ca2.id
            FROM   research_coordinator_assignments ca2
            WHERE  ca2.status = 'Active'
              AND  (
                    ca2.research_group_id = rg.id
                 OR (ca2.research_group_id IS NULL AND ca2.group_number = rg.group_number)
              )
            ORDER BY ca2.updated_at DESC, ca2.id DESC
            LIMIT 1
        )

        /* Adviser assignment (any status — Assigned or Confirmed) */
        LEFT JOIN research_adviser_assignments raa ON raa.id = (
            SELECT aa2.id
            FROM   research_adviser_assignments aa2
            WHERE  (
                    aa2.research_group_id = rg.id
                 OR (aa2.research_group_id IS NULL AND aa2.group_number = rg.group_number)
              )
            ORDER BY (aa2.assignment_status = 'Confirmed') DESC,
                     (aa2.assignment_status = 'Assigned')  DESC,
                     aa2.updated_at DESC, aa2.id DESC
            LIMIT 1
        )

        WHERE rg.title_approval_id IS NOT NULL

          /* All three approval statuses must be 'Approved' */
          AND t.status               = 'Approved'
          AND t.coordinator_status   = 'Approved'
          AND t.crad_status          = 'Approved'

          /* All three digital signatures must be present */
          AND t.adviser_signature_data     IS NOT NULL
          AND t.adviser_signature_data     <> ''
          AND t.coordinator_signature_data IS NOT NULL
          AND t.coordinator_signature_data <> ''
          AND t.crad_signature_data        IS NOT NULL
          AND t.crad_signature_data        <> ''

          /* Non-empty required fields */
          AND TRIM(COALESCE(rg.research_title, '')) <> ''
          AND TRIM(COALESCE(rg.academic_year,  '')) <> ''
          AND (
               TRIM(COALESCE(rg.college_dept, ''))  <> ''
            OR TRIM(COALESCE(t.department,    ''))   <> ''
          )

          /* Must be this student's group (as leader) */
          AND (
               rg.leader_id = ?
            OR rg.leader_id = (
                 SELECT student_id
                 FROM   sms2_db.users
                 WHERE  id = ?
                 LIMIT  1
               )
          )

        ORDER BY rg.date_assigned DESC
        LIMIT 1
    ");

    $stmt->execute([$studentId, $studentUserId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

/**
 * Get or create research plan for a group (idempotent)
 * Returns existing plan if found, creates new one if not exists
 * 
 * @param PDO $crad CRAD database connection
 * @param int $groupId Research group ID
 * @return array|null Research plan record
 */
function rpGetOrCreateResearchPlan(PDO $crad, int $groupId): ?array
{
    if ($groupId <= 0) {
        return null;
    }
    
    // Check for existing plan first (DUPLICATE PREVENTION)
    $stmt = $crad->prepare("SELECT * FROM research_plans WHERE research_group_id = ? LIMIT 1");
    $stmt->execute([$groupId]);
    $existing = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($existing) {
        return $existing;
    }
    
    // Get group details
    $groupStmt = $crad->prepare("
        SELECT rg.*, raa.adviser_user_id, raa.adviser_name, raa.adviser_email
        FROM research_groups rg
        LEFT JOIN research_adviser_assignments raa ON raa.group_number = rg.group_number 
            AND raa.assignment_status = 'Confirmed'
        WHERE rg.id = ?
        LIMIT 1
    ");
    $groupStmt->execute([$groupId]);
    $group = $groupStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$group) {
        return null;
    }
    
    // Create new plan
    $insertStmt = $crad->prepare("
        INSERT INTO research_plans (
            research_group_id, group_number, research_title,
            adviser_id, adviser_name, start_date, status
        ) VALUES (?, ?, ?, ?, ?, CURDATE(), 'Active')
    ");
    
    try {
        $insertStmt->execute([
            $groupId,
            $group['group_number'],
            $group['research_title'],
            $group['adviser_user_id'] ?? null,
            $group['adviser_name'] ?: $group['adviser']
        ]);
        
        $planId = (int) $crad->lastInsertId();
        
        // Initialize default milestones
        rpInitializeDefaultMilestones($crad, $planId);
        
        // Fetch and return the new plan
        $stmt->execute([$groupId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        
    } catch (PDOException $e) {
        // Check for duplicate key error (unique key is `uniq_rp_group`)
        if (strpos($e->getMessage(), 'uniq_rp_group') !== false) {
            // Another process created it, fetch and return
            $stmt->execute([$groupId]);
            return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        }
        throw $e;
    }
}

/**
 * Initialize default milestones for a research plan (idempotent)
 * Uses INSERT IGNORE to prevent duplicates
 * 
 * @param PDO $crad CRAD database connection
 * @param int $planId Research plan ID
 * @return int Number of milestones created
 */
function rpInitializeDefaultMilestones(PDO $crad, int $planId): int
{
    $defaultMilestones = [
        ['name' => 'Chapter 1', 'order' => 1, 'desc' => 'Introduction and Background'],
        ['name' => 'Chapter 2', 'order' => 2, 'desc' => 'Review of Related Literature'],
        ['name' => 'Chapter 3', 'order' => 3, 'desc' => 'Methodology'],
        ['name' => 'System Development', 'order' => 4, 'desc' => 'System Implementation'],
        ['name' => 'Testing', 'order' => 5, 'desc' => 'Testing and Quality Assurance'],
        ['name' => 'Documentation', 'order' => 6, 'desc' => 'Final Documentation and Report']
    ];
    
    // Use INSERT IGNORE to prevent duplicate milestones
    $stmt = $crad->prepare("
        INSERT IGNORE INTO research_milestones (
            research_plan_id, milestone_name, milestone_order, description, status
        ) VALUES (?, ?, ?, ?, 'Not Started')
    ");
    
    $count = 0;
    foreach ($defaultMilestones as $milestone) {
        try {
            $stmt->execute([
                $planId,
                $milestone['name'],
                $milestone['order'],
                $milestone['desc']
            ]);
            $count += $stmt->rowCount();
        } catch (PDOException $e) {
            // Ignore duplicate key errors
            if (strpos($e->getMessage(), 'uniq_rm_plan_name') === false) {
                error_log('Failed to create milestone: ' . $e->getMessage());
            }
        }
    }
    
    return $count;
}

/**
 * Generate unique submission token for duplicate prevention
 * 
 * @return string 32-character hex token
 */
function rpGenerateSubmissionToken(): string
{
    return bin2hex(random_bytes(16));
}

/**
 * Check if submission token was recently used (duplicate detection)
 * 
 * @param PDO $crad CRAD database connection
 * @param string $table Table name (research_progress_updates or research_progress_feedback)
 * @param string $token Submission token
 * @param int $windowMinutes Time window in minutes (default 5)
 * @return bool True if token was recently used
 */
function rpIsTokenRecentlyUsed(PDO $crad, string $table, string $token, int $windowMinutes = 5): bool
{
    if (empty($token)) {
        return false;
    }
    
    $allowedTables = ['research_progress_updates', 'research_progress_feedback'];
    if (!in_array($table, $allowedTables, true)) {
        return false;
    }
    
    $timeColumn = $table === 'research_progress_updates' ? 'submitted_at' : 'created_at';
    
    $stmt = $crad->prepare("
        SELECT COUNT(*) FROM {$table}
        WHERE submission_token = ?
          AND {$timeColumn} >= DATE_SUB(NOW(), INTERVAL ? MINUTE)
    ");
    
    $stmt->execute([$token, $windowMinutes]);
    return (int) $stmt->fetchColumn() > 0;
}

/**
 * Submit progress update with duplicate prevention
 * 
 * @param PDO $crad CRAD database connection
 * @param array $data Progress update data
 * @return array Result with success status and message
 */
function rpSubmitProgressUpdate(PDO $crad, array $data): array
{
    // Validate required fields
    $required = ['research_plan_id', 'research_group_id', 'submitted_by_user_id', 
                 'submitted_by_name', 'new_progress'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return ['success' => false, 'message' => "Missing required field: {$field}"];
        }
    }
    
    // Check for duplicate submission token
    if (!empty($data['submission_token'])) {
        if (rpIsTokenRecentlyUsed($crad, 'research_progress_updates', $data['submission_token'])) {
            return [
                'success' => false, 
                'message' => 'Duplicate submission detected. Please wait before submitting again.',
                'is_duplicate' => true
            ];
        }
    }
    
    // Validate progress range
    $newProgress = (float) $data['new_progress'];
    if ($newProgress < 0 || $newProgress > 100) {
        return ['success' => false, 'message' => 'Progress must be between 0 and 100'];
    }
    
    try {
        $crad->beginTransaction();
        
        // Insert progress update
        $stmt = $crad->prepare("
            INSERT INTO research_progress_updates (
                research_plan_id, research_group_id, milestone_id, 
                submitted_by_user_id, submitted_by_name, update_title,
                previous_progress, new_progress, milestone_status,
                accomplishments, problems_blockers, next_planned_activity,
                attachment_path, attachment_original_name, submission_token
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $data['research_plan_id'],
            $data['research_group_id'],
            $data['milestone_id'] ?? null,
            $data['submitted_by_user_id'],
            $data['submitted_by_name'],
            $data['update_title'] ?? 'Progress Update',
            $data['previous_progress'] ?? 0,
            $newProgress,
            $data['milestone_status'] ?? 'In Progress',
            $data['accomplishments'] ?? null,
            $data['problems_blockers'] ?? null,
            $data['next_planned_activity'] ?? null,
            $data['attachment_path'] ?? null,
            $data['attachment_original_name'] ?? null,
            $data['submission_token'] ?? null
        ]);
        
        $updateId = (int) $crad->lastInsertId();
        
        // Update milestone progress if milestone_id provided
        if (!empty($data['milestone_id'])) {
            $updateMilestone = $crad->prepare("
                UPDATE research_milestones 
                SET progress_percentage = ?,
                    status = ?,
                    updated_at = NOW()
                WHERE id = ?
            ");
            $updateMilestone->execute([
                $newProgress,
                $data['milestone_status'] ?? 'In Progress',
                $data['milestone_id']
            ]);
        }
        
        // Recalculate overall progress
        rpRecalculateOverallProgress($crad, (int) $data['research_plan_id']);
        
        // Log activity
        rpLogActivity($crad, [
            'research_plan_id' => $data['research_plan_id'],
            'research_group_id' => $data['research_group_id'],
            'user_id' => $data['submitted_by_user_id'],
            'user_name' => $data['submitted_by_name'],
            'user_role' => 'student',
            'action' => 'progress_updated',
            'entity_type' => 'progress_update',
            'entity_id' => $updateId,
            'detail' => "Progress updated to {$newProgress}%"
        ]);
        
        $crad->commit();
        
        return [
            'success' => true,
            'message' => 'Progress update submitted successfully',
            'update_id' => $updateId
        ];
        
    } catch (Throwable $e) {
        $crad->rollBack();
        error_log('Progress update submission failed: ' . $e->getMessage());
        return [
            'success' => false,
            'message' => 'Failed to submit progress update. Please try again.'
        ];
    }
}

/**
 * Recalculate overall progress for a research plan
 * Based on average of all milestone progress percentages
 * 
 * @param PDO $crad CRAD database connection
 * @param int $planId Research plan ID
 * @return void
 */
function rpRecalculateOverallProgress(PDO $crad, int $planId): void
{
    $stmt = $crad->prepare("
        SELECT AVG(progress_percentage) as avg_progress
        FROM research_milestones
        WHERE research_plan_id = ?
    ");
    $stmt->execute([$planId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $avgProgress = round((float) ($result['avg_progress'] ?? 0), 2);
    
    $updateStmt = $crad->prepare("
        UPDATE research_plans 
        SET overall_progress = ?,
            updated_at = NOW()
        WHERE id = ?
    ");
    $updateStmt->execute([$avgProgress, $planId]);
}

/**
 * Log activity with duplicate prevention via activity hash
 * 
 * @param PDO $crad CRAD database connection
 * @param array $data Activity data
 * @return void
 */
function rpLogActivity(PDO $crad, array $data): void
{
    // Deduplicate: skip if the same user+action+entity was already logged this minute
    $checkStmt = $crad->prepare("
        SELECT id FROM research_progress_activity_logs
        WHERE user_id    = ?
          AND action     = ?
          AND entity_type = ?
          AND entity_id  = ?
          AND created_at >= DATE_SUB(NOW(), INTERVAL 1 MINUTE)
        LIMIT 1
    ");
    $checkStmt->execute([
        $data['user_id']      ?? null,
        $data['action'],
        $data['entity_type']  ?? '',
        $data['entity_id']    ?? null,
    ]);

    if ($checkStmt->fetch()) {
        return;
    }

    // Log the activity
    // Table columns: research_plan_id, user_id, user_name, user_role,
    //                action, entity_type, entity_id, old_value, new_value, description
    try {
        $stmt = $crad->prepare("
            INSERT INTO research_progress_activity_logs (
                research_plan_id, user_id, user_name, user_role,
                action, entity_type, entity_id, description
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");

        $stmt->execute([
            $data['research_plan_id'],
            $data['user_id']      ?? null,
            $data['user_name']    ?? '',
            $data['user_role']    ?? '',
            $data['action'],
            $data['entity_type']  ?? '',
            $data['entity_id']    ?? null,
            $data['detail']       ?? '',
        ]);
    } catch (PDOException $e) {
        // Silently fail — logging must never break main functionality
        error_log('Activity log failed: ' . $e->getMessage());
    }
}

/**
 * Create notification with duplicate prevention via batch_key
 * 
 * @param PDO $crad CRAD database connection
 * @param array $data Notification data
 * @return bool Success status
 */
function rpCreateNotification(PDO $crad, array $data): bool
{
    // Generate batch key for duplicate prevention
    $batchKey = $data['batch_key'] ?? (
        $data['notification_type'] . ':' . 
        ($data['related_entity_id'] ?? uniqid())
    );
    
    // Check if notification with same batch_key exists for this recipient
    $checkStmt = $crad->prepare("
        SELECT id FROM research_progress_notifications
        WHERE batch_key = ?
          AND (
               (recipient_user_id IS NOT NULL AND recipient_user_id = ?)
            OR (recipient_user_id IS NULL AND recipient_email = ?)
            OR (recipient_user_id IS NULL AND recipient_email = '' AND recipient_role = ?)
          )
        LIMIT 1
    ");
    
    $checkStmt->execute([
        $batchKey,
        $data['recipient_user_id'] ?? null,
        $data['recipient_email'] ?? '',
        $data['recipient_role'] ?? ''
    ]);
    
    if ($checkStmt->fetch()) {
        // Duplicate notification exists
        return false;
    }
    
    // Create notification
    try {
        $stmt = $crad->prepare("
            INSERT INTO research_progress_notifications (
                recipient_user_id, recipient_email, recipient_role, batch_key,
                notification_type, title, body, related_entity_type, related_entity_id,
                action_url, status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'unread')
        ");
        
        $stmt->execute([
            $data['recipient_user_id'] ?? null,
            $data['recipient_email'] ?? '',
            $data['recipient_role'] ?? '',
            $batchKey,
            $data['notification_type'] ?? 'progress_update',
            $data['title'] ?? 'Notification',
            $data['body'] ?? '',
            $data['related_entity_type'] ?? '',
            $data['related_entity_id'] ?? null,
            $data['action_url'] ?? null
        ]);
        
        return true;
    } catch (PDOException $e) {
        error_log('Notification creation failed: ' . $e->getMessage());
        return false;
    }
}
