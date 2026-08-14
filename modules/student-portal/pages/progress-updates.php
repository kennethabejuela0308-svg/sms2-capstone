<?php
/**
 * Student Portal - Progress Updates
 * Submit progress updates with duplicate prevention
 */

$pageTitle = 'Progress Updates';
$activeModule = 'student_portal';
$activePage = 'progress-updates';

$pageBannerIcon        = 'fa-chart-line';
$pageBannerDescription = 'Submit your research development progress.';

require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../../../includes/breadcrumbs.php';
require_once __DIR__ . '/../../../modules/crad/config/config.php';
require_once __DIR__ . '/../../../modules/crad/includes/research-progress-helpers.php';

$breadcrumbs = [
    ['label' => 'Student Portal',    'url' => BASE_URL . '/modules/student-portal/pages/dashboard.php'],
    ['label' => 'My Research',       'url' => BASE_URL . '/modules/student-portal/pages/my-research.php'],
    ['label' => 'Progress Updates',  'url' => null],
];

require_once __DIR__ . '/../../../includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);

// Check if module is properly installed
try {
    $crad = cradDb();
    $tablesCheck = $crad->query("SHOW TABLES LIKE 'research_plans'")->fetch();
    if (!$tablesCheck) {
        throw new Exception('Research Progress module not installed.');
    }
} catch (Throwable $e) {
    echo '<div class="alert alert-warning">
        <i class="fas fa-exclamation-triangle me-2"></i>
        <strong>Module Not Installed</strong><br>
        The Research Progress module database tables are not yet installed.
    </div>';
    require_once ROOT_PATH . '/includes/layout-end.php';
    exit;
}

// Get student's research group — only if it is in the Capstone Group/Student Registry
$studentId     = trim((string) ($_SESSION['student_id'] ?? ''));
$studentUserId = (int) ($_SESSION['user_id'] ?? 0);
$studentName   = trim((string) ($_SESSION['full_name'] ?? $_SESSION['username'] ?? ''));

$researchGroup = rpGetRegisteredResearchGroup($crad, $studentId, $studentUserId);

if (!$researchGroup) {
    echo '<div class="alert alert-info">
        <i class="fas fa-info-circle me-2"></i>
        <strong>Research Development is not yet available.</strong><br>
        Your research group must be officially registered in the
        Capstone Group/Student Registry before you can access this section.
        Please ensure your title approval is fully signed and your adviser
        and coordinator assignments are in place.
    </div>';
    require_once ROOT_PATH . '/includes/layout-end.php';
    exit;
}

$groupId = (int) $researchGroup['id'];

// Get or create research plan
$plan = rpGetOrCreateResearchPlan($crad, $groupId);

// Get milestones from Research Development progress only.
$milestones = rpGetMilestonesForPlan($crad, (int) $plan['id'], $groupId);

// Get pre-selected milestone if provided
$selectedMilestoneId = isset($_GET['milestone_id']) ? (int)$_GET['milestone_id'] : null;
$selectedMilestone = null;
if ($selectedMilestoneId) {
    foreach ($milestones as $m) {
        if ((int)$m['id'] === $selectedMilestoneId) {
            $selectedMilestone = $m;
            break;
        }
    }
}

// Get recent progress updates
try {
    $recentUpdatesStmt = $crad->prepare("
        SELECT rpu.*, rm.milestone_name
        FROM research_progress_updates rpu
        LEFT JOIN research_milestones rm ON rm.id = rpu.milestone_id
        WHERE rpu.research_group_id = ?
        ORDER BY rpu.submitted_at DESC
        LIMIT 5
    ");
    $recentUpdatesStmt->execute([$groupId]);
    $recentUpdates = $recentUpdatesStmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    error_log('Recent updates query error: ' . $e->getMessage());
    $recentUpdates = [];
}
?>

<div class="glass-dashboard">
    <div class="glass-board">

        <div class="row g-4">
            <!-- Submit Form -->
            <div class="col-lg-7">
                <div class="glass-panel">
                    <div class="glass-panel-body">
                        <div class="glass-panel-head">
                            <div>
                                <h5 class="glass-panel-title">Submit Progress Update</h5>
                                <p class="glass-panel-sub">Report your research development progress</p>
                            </div>
                        </div>

                        <form id="progressUpdateForm" enctype="multipart/form-data">
                            <input type="hidden" id="submission_token" name="submission_token" value="">
                            <div id="progress_form_alert" class="alert d-none" role="alert"></div>

                            <!-- Milestone Selection -->
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:700;color:var(--sms-heading);">
                                    Milestone <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" id="milestone_id" name="milestone_id" required>
                                    <option value="">-- Select Milestone --</option>
                                    <?php foreach ($milestones as $milestone): ?>
                                        <option value="<?= $milestone['id'] ?>" 
                                                data-current-progress="<?= $milestone['progress_percentage'] ?>"
                                                data-current-status="<?= htmlspecialchars((string) ($milestone['status'] ?? 'Not Started'), ENT_QUOTES) ?>"
                                                data-chapter-number="<?= (int) ($milestone['chapter_number'] ?? 0) ?>"
                                                <?= $selectedMilestone && (int)$milestone['id'] === (int)$selectedMilestone['id'] ? 'selected' : '' ?>>
                                            <?= htmlspecialchars($milestone['milestone_name']) ?> 
                                            (Current: <?= number_format((float)$milestone['progress_percentage'], 1) ?>%)
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                            </div>

                            <!-- Progress Percentage -->
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:700;color:var(--sms-heading);">
                                    New Progress Percentage <span class="text-danger">*</span>
                                </label>
                                <div class="d-flex align-items-center gap-3">
                                    <input type="range" class="form-range flex-grow-1" 
                                           id="new_progress" name="new_progress" 
                                           min="0" max="100" value="<?= $selectedMilestone ? $selectedMilestone['progress_percentage'] : 0 ?>" step="1">
                                    <div style="font-size:1.5rem;font-weight:800;color:var(--sms-primary);min-width:60px;text-align:right;">
                                        <span id="progress_display">0</span>%
                                    </div>
                                </div>
                                <small class="text-muted">Current Progress: <strong id="current_progress_display">0%</strong></small>
                            </div>

                            <!-- Status -->
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:700;color:var(--sms-heading);">
                                    Milestone Status <span class="text-danger">*</span>
                                </label>
                                <select class="form-select" id="milestone_status" name="milestone_status" required>
                                    <option value="Not Started">Not Started</option>
                                    <option value="Submitted for Review">Submitted for Review</option>
                                </select>
                                <small class="text-muted">Select "Submitted for Review" when ready for adviser review</small>
                            </div>

                            <!-- Document -->
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:700;color:var(--sms-heading);">
                                    Document <span class="text-danger d-none" id="document_required_marker">*</span>
                                </label>
                                <input type="file" class="form-control" id="document" name="document" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png">
                                <div class="form-text">Allowed: PDF, DOC, DOCX, JPG, PNG. Max 10 MB.</div>
                            </div>

                            <!-- Update Title -->
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:700;color:var(--sms-heading);">
                                    Update Title <span class="text-danger">*</span>
                                </label>
                                <input type="text" class="form-control" 
                                       id="update_title" name="update_title" 
                                       placeholder="e.g., Completed database design and implementation" 
                                       required maxlength="255">
                            </div>

                            <!-- Accomplishments -->
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:700;color:var(--sms-heading);">
                                    Accomplishments <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" id="accomplishments" name="accomplishments" 
                                          rows="4" required
                                          placeholder="What have you completed? List your achievements and completed tasks."></textarea>
                            </div>

                            <!-- Problems/Blockers -->
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:700;color:var(--sms-heading);">
                                    Problems / Blockers (Optional)
                                </label>
                                <textarea class="form-control" id="problems_blockers" name="problems_blockers" 
                                          rows="3"
                                          placeholder="Any challenges, issues, or roadblocks encountered?"></textarea>
                            </div>

                            <!-- Next Planned Activity -->
                            <div class="mb-3">
                                <label class="form-label" style="font-weight:700;color:var(--sms-heading);">
                                    Next Planned Activity <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" id="next_planned_activity" name="next_planned_activity" 
                                          rows="3" required
                                          placeholder="What will you work on next?"></textarea>
                            </div>

                            <!-- Submit Button -->
                            <div class="d-grid">
                                <button type="submit" id="submitBtn" class="btn btn-primary btn-lg">
                                    <i class="fas fa-paper-plane me-2"></i>Submit Progress Update
                                </button>
                            </div>
                            <div id="submitted_state" class="alert alert-success d-none mt-3" role="status">
                                <div class="d-flex align-items-start gap-2">
                                    <i class="fas fa-check-circle mt-1"></i>
                                    <div>
                                        <strong>Done Sent.</strong>
                                        <div>Your progress update has been submitted and sent to your adviser for review.</div>
                                        <div class="d-flex gap-2 flex-wrap mt-3">
                                            <a class="btn btn-sm btn-success" href="<?= BASE_URL ?>/modules/student-portal/pages/my-research.php">
                                                <i class="fas fa-chart-line me-1"></i>View My Research
                                            </a>
                                            <button type="button" class="btn btn-sm btn-outline-success" id="submitAnotherBtn">
                                                <i class="fas fa-plus me-1"></i>Submit Another Update
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>

                    </div>
                </div>
            </div>

            <!-- Recent Updates -->
            <div class="col-lg-5">
                <div class="glass-panel">
                    <div class="glass-panel-body">
                        <div class="glass-panel-head">
                            <div>
                                <h5 class="glass-panel-title">Recent Updates</h5>
                                <p class="glass-panel-sub">Your submission history</p>
                            </div>
                        </div>

                        <?php if (!empty($recentUpdates)): ?>
                            <?php foreach ($recentUpdates as $update): ?>
                                <div class="mb-3 pb-3" style="border-bottom:1px solid var(--sms-border-soft);">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <div style="flex:1;">
                                            <div style="font-weight:700;color:var(--sms-heading);font-size:0.9rem;">
                                                <?= htmlspecialchars($update['update_title']) ?>
                                            </div>
                                            <?php if ($update['milestone_name']): ?>
                                                <div style="font-size:0.75rem;color:var(--sms-text-muted);">
                                                    <i class="fas fa-bookmark me-1"></i>
                                                    <?= htmlspecialchars($update['milestone_name']) ?>
                                                </div>
                                            <?php endif; ?>
                                        </div>
                                        <div class="text-end ms-3">
                                            <div style="font-size:1.1rem;font-weight:800;color:var(--sms-primary);">
                                                <?= number_format((float)$update['new_progress'], 0) ?>%
                                            </div>
                                        </div>
                                    </div>
                                    <div style="font-size:0.75rem;color:var(--sms-text-muted);">
                                        <i class="fas fa-clock me-1"></i>
                                        <?= date('M d, Y g:i A', strtotime($update['submitted_at'])) ?>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                        <?php else: ?>
                            <p class="text-muted text-center py-4">
                                <i class="fas fa-inbox" style="font-size:2rem;color:var(--sms-border);display:block;margin-bottom:1rem;"></i>
                                No progress updates yet
                            </p>
                        <?php endif; ?>

                    </div>
                </div>

                <!-- Help Card -->
                <div class="glass-panel mt-3">
                    <div class="glass-panel-body">
                        <div style="font-weight:700;color:var(--sms-heading);margin-bottom:1rem;">
                            <i class="fas fa-info-circle me-2" style="color:var(--sms-primary);"></i>
                            Tips for Progress Updates
                        </div>
                        <ul style="font-size:0.85rem;color:var(--sms-text);line-height:1.8;margin:0;padding-left:1.5rem;">
                            <li>Be specific about completed tasks</li>
                            <li>Include measurable achievements</li>
                            <li>Report problems early for assistance</li>
                            <li>Update regularly (weekly recommended)</li>
                            <li>Mark "Submitted for Review" when ready</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
// Generate submission token on page load
let submissionToken = null;

document.addEventListener('DOMContentLoaded', function() {
    // Generate token
    fetch('<?= BASE_URL ?>/modules/crad/api/research-progress.php?action=generate_token')
        .then(r => r.json())
        .then(data => {
            if (data.success && data.token) {
                submissionToken = data.token;
                document.getElementById('submission_token').value = data.token;
            }
        })
        .catch(err => console.error('Token generation failed:', err));
    
    // Update progress display
    const progressInput = document.getElementById('new_progress');
    const progressDisplay = document.getElementById('progress_display');
    const milestoneSelect = document.getElementById('milestone_id');
    const currentProgressDisplay = document.getElementById('current_progress_display');
    const statusSelect = document.getElementById('milestone_status');
    const documentInput = document.getElementById('document');
    const documentRequiredMarker = document.getElementById('document_required_marker');

    progressInput.addEventListener('input', function() {
        progressDisplay.textContent = this.value;
    });
    
    // Update current progress when milestone changes
    milestoneSelect.addEventListener('change', function() {
        const selectedOption = this.options[this.selectedIndex];
        const currentProgress = selectedOption.getAttribute('data-current-progress') || 0;
        const currentStatus = selectedOption.getAttribute('data-current-status') || 'Not Started';
        currentProgressDisplay.textContent = parseFloat(currentProgress).toFixed(1) + '%';
        progressInput.value = Math.ceil(parseFloat(currentProgress));
        progressDisplay.textContent = progressInput.value;
        const allowedStatuses = ['Not Started', 'Submitted for Review'];
        statusSelect.value = allowedStatuses.includes(currentStatus) ? currentStatus : 'Not Started';
        updateDocumentRequirement();
    });

    function selectedChapterNumber() {
        const selectedOption = milestoneSelect.options[milestoneSelect.selectedIndex];
        return parseInt(selectedOption ? (selectedOption.getAttribute('data-chapter-number') || '0') : '0', 10);
    }

    function updateDocumentRequirement() {
        const required = selectedChapterNumber() >= 1 && selectedChapterNumber() <= 3 && statusSelect.value === 'Submitted for Review';
        documentInput.required = required;
        if (documentRequiredMarker) {
            documentRequiredMarker.classList.toggle('d-none', !required);
        }
    }

    statusSelect.addEventListener('change', updateDocumentRequirement);
    
    // Initialize displays
    if (milestoneSelect.value) {
        milestoneSelect.dispatchEvent(new Event('change'));
    } else {
        progressDisplay.textContent = progressInput.value;
    }
    
    // Form submission with DUPLICATE PREVENTION
    const form = document.getElementById('progressUpdateForm');
    const submitBtn = document.getElementById('submitBtn');
    const formAlert = document.getElementById('progress_form_alert');

    function showFormAlert(type, message) {
        formAlert.className = `alert alert-${type}`;
        formAlert.innerHTML = message;
        formAlert.classList.remove('d-none');
        formAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }

    function hideFormAlert() {
        formAlert.className = 'alert d-none';
        formAlert.textContent = '';
    }

    function restoreSubmitButton() {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Submit Progress Update';
    }

    function setSubmittedState() {
        form.querySelectorAll('input, select, textarea').forEach(function (field) {
            field.disabled = true;
        });
        submitBtn.disabled = true;
        submitBtn.classList.remove('btn-primary');
        submitBtn.classList.add('btn-success');
        submitBtn.innerHTML = '<i class="fas fa-check-circle me-2"></i>Done Sent';

        const submittedState = document.getElementById('submitted_state');
        if (submittedState) {
            submittedState.classList.remove('d-none');
            submittedState.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
    }

    async function readJsonResponse(response) {
        const text = await response.text();
        if (!text.trim()) {
            return {};
        }

        try {
            return JSON.parse(text);
        } catch (error) {
            console.error('Unexpected submit response:', text);
            throw new Error(response.ok ? 'invalid_success_response' : 'invalid_error_response');
        }
    }

    const submitAnotherBtn = document.getElementById('submitAnotherBtn');
    if (submitAnotherBtn) {
        submitAnotherBtn.addEventListener('click', function () {
            window.location.reload();
        });
    }
    
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        hideFormAlert();
        
        // Check token
        if (!submissionToken) {
            showFormAlert('warning', '<i class="fas fa-clock me-2"></i>Please wait, initializing submission token...');
            return;
        }
        
        // DUPLICATE PREVENTION: Disable button immediately
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Submitting...';
        
        const formData = new FormData(form);
        formData.set('action', 'submit_progress');
        formData.set('new_progress', progressInput.value);
        formData.set('milestone_status', statusSelect.value);
        
        try {
            const response = await fetch('<?= BASE_URL ?>/modules/crad/api/research-progress.php', {
                method: 'POST',
                credentials: 'same-origin',
                body: formData
            });
            
            const result = await readJsonResponse(response);
            
            // Check for duplicate (HTTP 409)
            if (response.status === 409) {
                showFormAlert('warning', '<i class="fas fa-copy me-2"></i>Duplicate submission detected. This update was already submitted.');
                restoreSubmitButton();
                return;
            }

            if (!response.ok) {
                showFormAlert('danger', '<i class="fas fa-exclamation-triangle me-2"></i>' + (result.message || 'Failed to submit progress update. Please try again.'));
                restoreSubmitButton();
                return;
            }
            
            if (result.success) {
                submissionToken = null;
                showFormAlert('success', '<i class="fas fa-check-circle me-2"></i><strong>Done Sent.</strong> Your adviser can now see this progress update in Submitted Updates.');
                setSubmittedState();
            } else {
                showFormAlert('danger', '<i class="fas fa-exclamation-triangle me-2"></i>' + (result.message || 'Failed to submit progress update. Please try again.'));
                restoreSubmitButton();
            }
        } catch (error) {
            console.error('Submission error:', error);
            const message = error.message === 'invalid_success_response'
                ? '<i class="fas fa-check-circle me-2"></i><strong>Done Sent.</strong> The update was submitted, but the confirmation response could not be read. Please refresh to see the latest record.'
                : '<i class="fas fa-wifi me-2"></i>Network error. Please check your connection and try again.';
            showFormAlert(error.message === 'invalid_success_response' ? 'success' : 'danger', message);
            if (error.message === 'invalid_success_response') {
                setSubmittedState();
                return;
            }
            restoreSubmitButton();
        }
    });
});
</script>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
