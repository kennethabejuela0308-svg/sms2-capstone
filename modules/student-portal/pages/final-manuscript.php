<?php
declare(strict_types=1);
$pageTitle    = 'Final Manuscript';
$activeModule = 'student_portal';
$activePage   = 'final-manuscript';
require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';
require_once ROOT_PATH . '/includes/uploads.php';
require_once ROOT_PATH . '/includes/breadcrumbs.php';
require_once ROOT_PATH . '/modules/crad/config/config.php';
require_once ROOT_PATH . '/modules/crad/includes/research-progress-helpers.php';
require_once ROOT_PATH . '/modules/crad/includes/final-phase-helpers.php';
requireAuth();
if (getCurrentUserRoleKey() !== 'student') { http_response_code(403); exit('Forbidden'); }
$crad = cradDb(); finalPhaseEnsureSchema($crad);
$group = rpGetRegisteredResearchGroup($crad, trim((string) ($_SESSION['student_id'] ?? '')), (int) ($_SESSION['user_id'] ?? 0));
$message = ''; $error = ''; $submissions = [];
if (!$group) { $error = 'Your research group is not officially registered yet.'; }
$groupId = (int) ($group['id'] ?? 0);
if ($groupId > 0 && $_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!csrfVerify()) { $error = 'Security check failed. Please refresh and try again.'; }
    elseif (!fpIsRecommendedForFinalDefense($crad, $groupId)) { $error = 'Your adviser must recommend the group for Final Defense before manuscript submission.'; }
    elseif (!isset($_FILES['manuscript_file'])) { $error = 'Please select the full Chapter 1-5 manuscript.'; }
    else {
        $uploadSubdir = 'manuscripts/g' . $groupId;
        $upload = smsSecureUpload($_FILES['manuscript_file'], ['subdir' => $uploadSubdir, 'max_bytes' => 20 * 1024 * 1024, 'allowed' => smsUploadAllowedDocuments(), 'required' => true]);
        if (empty($upload['ok'])) { $error = (string) ($upload['error'] ?? 'Upload failed.'); }
        else {
            $latest = fpGetLatestManuscriptSubmission($crad, $groupId);
            $version = (int) ($latest['version_number'] ?? 0) + 1;
            $token = bin2hex(random_bytes(32));
            $stmt = $crad->prepare("INSERT INTO manuscript_submissions (research_group_id, version_number, status, submitted_by_user, submitted_by_name, submitted_by_email, submission_notes, original_name, stored_subdir, stored_name, file_size, file_mime, submission_token) VALUES (?, ?, 'Submitted', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$groupId, $version, (int) ($_SESSION['user_id'] ?? 0), (string) ($_SESSION['full_name'] ?? $_SESSION['username'] ?? ''), (string) ($_SESSION['user_email'] ?? ''), trim((string) ($_POST['submission_notes'] ?? '')), $upload['original_name'] ?? '', $uploadSubdir, $upload['stored_name'] ?? basename((string) ($upload['path'] ?? '')), (int) ($upload['size'] ?? 0), $upload['mime'] ?? '', $token]);
            $message = 'Final manuscript version ' . $version . ' submitted for review.';
        }
    }
}
if ($groupId > 0) { $stmt = $crad->prepare('SELECT * FROM manuscript_submissions WHERE research_group_id = ? ORDER BY version_number DESC'); $stmt->execute([$groupId]); $submissions = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: []; }
$breadcrumbs = [['label' => 'Student Portal', 'url' => BASE_URL . '/modules/student-portal/pages/dashboard.php'], ['label' => 'Final Manuscript', 'url' => null]];
require_once ROOT_PATH . '/includes/layout-start.php'; renderBreadcrumbs($breadcrumbs);
?>
<div class="glass-dashboard"><div class="glass-board"><div class="glass-panel"><div class="glass-panel-body">
<h5 class="glass-panel-title">Final Chapter 1-5 Manuscript</h5><p class="glass-panel-sub">Submit the consolidated manuscript after adviser recommendation.</p>
<?php if ($message): ?><div class="alert alert-success"><?= e($message) ?></div><?php endif; ?><?php if ($error): ?><div class="alert alert-danger"><?= e($error) ?></div><?php endif; ?>
<?php if ($groupId > 0 && fpIsRecommendedForFinalDefense($crad, $groupId)): ?><form method="post" enctype="multipart/form-data"><?= csrfField() ?><div class="mb-3"><label class="form-label">Full Chapter 1-5 Manuscript</label><input class="form-control" type="file" name="manuscript_file" accept=".pdf,.doc,.docx" required></div><div class="mb-3"><label class="form-label">Submission Notes</label><textarea class="form-control" name="submission_notes" rows="3"></textarea></div><button class="btn btn-primary" type="submit"><i class="fas fa-upload me-1"></i>Submit Manuscript</button></form><?php else: ?><div class="alert alert-warning">Not yet eligible. Final Defense Recommendation is required.</div><?php endif; ?>
<?php if ($submissions): ?><hr><h6>Submission History</h6><div class="table-responsive"><table class="table align-middle"><thead><tr><th>Version</th><th>File</th><th>Status</th><th>Submitted</th><th>Notes</th></tr></thead><tbody><?php foreach ($submissions as $row): ?><tr><td>v<?= (int) $row['version_number'] ?></td><td><?= e((string) $row['original_name']) ?></td><td><?= e((string) $row['status']) ?></td><td><?= e((string) $row['submitted_at']) ?></td><td><?= e((string) ($row['submission_notes'] ?? '')) ?></td></tr><?php endforeach; ?></tbody></table></div><?php endif; ?>
</div></div></div></div>
<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
