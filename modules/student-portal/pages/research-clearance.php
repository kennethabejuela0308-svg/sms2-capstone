<?php
require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/breadcrumbs.php';
require_once ROOT_PATH . '/includes/security.php';
require_once ROOT_PATH . '/modules/crad/includes/research-services-clearance.php';

requireAuth();
if (getCurrentUserRoleKey() !== 'student') {
    http_response_code(403);
    exit('Forbidden');
}

$pageTitle = 'Research Services Clearance';
$activeModule = 'student_portal';
$activePage = 'research-clearance';
$pageBannerIcon = 'fa-stamp';
$pageBannerDescription = 'Complete Research Services Clearance after Chapter 1-3 scoring and before panel assignment.';
$breadcrumbs = [
    ['label' => 'Student Portal', 'url' => BASE_URL . '/modules/student-portal/pages/dashboard.php'],
    ['label' => 'Research Services Clearance', 'url' => null],
];

$crad = rscDb();
rscEnsureSchema($crad);
$group = chapterRegisteredStudentGroup($crad);
$ready = $group && rscIsChapterReady($crad, (int) $group['id']);
$row = $ready ? rscEnsureForReadyGroup($crad, (int) $group['id']) : null;
$public = $row ? rscPublicRow($row) : null;

require_once ROOT_PATH . '/includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);
?>
<link rel="stylesheet" href="<?= BASE_URL ?>/modules/crad/assets/css/research-clearance.css?v=rsc-inbox-1">

<div class="glass-dashboard rsc-print-root"
     data-rsc-live
     data-rsc-role="student"
     data-rsc-endpoint="<?= e(BASE_URL . '/modules/crad/api/research-clearance.php') ?>"
     data-rsc-csrf="<?= e(csrfToken()) ?>"
     data-rsc-id="<?= $public ? (int) $public['id'] : '' ?>">
    <div class="rsc-toolbar">
        <div>
            <div class="rsc-status" data-rsc-status><?= e($public['status_label'] ?? 'Not available yet') ?></div>
            <small class="text-muted" data-rsc-sync></small>
        </div>
        <div class="d-flex flex-wrap gap-2">
            <button type="button" class="btn btn-outline-secondary" data-rsc-print <?= $public ? '' : 'hidden' ?>><?= smsIcon('print', ['class' => 'me-1']) ?>Print</button>
            <button type="button" class="btn btn-sms-primary" data-rsc-send <?= ($public && $public['status'] === 'draft') ? '' : 'hidden' ?>><?= smsIcon('paper-plane', ['class' => 'me-1']) ?>Send to Adviser</button>
        </div>
    </div>

    <?php if (!$ready): ?>
        <div class="alert alert-info" data-rsc-empty>
            <?= smsIcon('info-circle', ['class' => 'me-2']) ?>
            Research Services Clearance opens after the Grammarian scores and accepts Chapter 1, Chapter 2, and Chapter 3.
        </div>
    <?php endif; ?>

    <div class="rsc-wrap" data-rsc-form><?= $public['form_html'] ?? '' ?></div>
</div>

<script src="<?= BASE_URL ?>/modules/crad/assets/js/research-clearance-live.js?v=rsc-no-inbox-1"></script>
<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
