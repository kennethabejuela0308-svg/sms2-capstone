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

$pageTitle = 'Upload College Payment';
$activeModule = 'student_portal';
$activePage = 'college-payment';
$pageBannerIcon = 'fa-receipt';
$pageBannerDescription = 'Upload your college payment picture. Admin must approve it before the Research Services Clearance form opens.';
$breadcrumbs = [
    ['label' => 'Student Portal', 'url' => BASE_URL . '/modules/student-portal/pages/dashboard.php'],
    ['label' => 'Upload College Payment', 'url' => null],
];

$crad = rscDb();
rscEnsureSchema($crad);
$group = chapterRegisteredStudentGroup($crad);
$payment = $group ? rcpFindByGroup($crad, (int) $group['id']) : null;
$public = $payment ? rcpPublicRow($payment) : null;

require_once ROOT_PATH . '/includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);
?>
<div class="glass-dashboard"
     data-rcp-live
     data-rcp-role="student"
     data-rcp-endpoint="<?= e(BASE_URL . '/modules/crad/api/clearance-payment.php') ?>"
     data-rcp-csrf="<?= e(csrfToken()) ?>">
    <div class="rsc-toolbar d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
        <div>
            <div class="fw-bold" data-rcp-status><?= e($public['status_label'] ?? 'No college payment uploaded yet') ?></div>
            <small class="text-muted" data-rcp-sync></small>
        </div>
    </div>

    <?php if (!$group): ?>
        <div class="alert alert-info">A registered research group is needed before you can upload a college payment.</div>
    <?php else: ?>
        <div class="alert alert-info" data-rcp-gate>
            Upload the college payment picture first. After Admin approves it, the O.R. number and remarks appear on your clearance form and you can open Research Services Clearance.
        </div>

        <section class="glass-panel p-4 mb-3">
            <div class="row g-3 align-items-end">
                <div class="col-md-6">
                    <label class="form-label fw-bold" for="rcpFile">College payment image</label>
                    <input type="file" id="rcpFile" class="form-control" accept=".png,.jpg,.jpeg,image/png,image/jpeg">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold" for="rcpOr">Reference / O.R. Number</label>
                    <input type="text" id="rcpOr" class="form-control" value="<?= e($public['or_number'] ?? '') ?>" placeholder="Taken from the payment picture" readonly>
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-sms-primary w-100" id="rcpUploadBtn" <?= !empty($public['status']) && $public['status'] === 'approved' ? 'disabled' : '' ?>>
                        <?= smsIcon('upload', ['class' => 'me-1']) ?><span data-rcp-upload-label><?= !empty($public['has_upload']) ? 'Re-upload' : 'Upload' ?></span>
                    </button>
                </div>
            </div>
            <div class="small text-muted mt-2" data-rcp-file-name><?= e($public['uploaded_original'] ?? '') ?></div>
        </section>

        <div class="rsc-wrap" data-rcp-preview <?= empty($public['uploaded_url']) ? 'hidden' : '' ?>>
            <?php if (!empty($public['uploaded_url'])): ?>
                <img class="rsc-upload-img" alt="College payment" src="<?= e($public['uploaded_url']) ?>">
            <?php endif; ?>
        </div>
    <?php endif; ?>
</div>
<link rel="stylesheet" href="<?= BASE_URL ?>/modules/crad/assets/css/research-clearance.css?v=rsc-date-1">
<script src="<?= BASE_URL ?>/modules/crad/assets/js/clearance-payment-live.js?v=rcp-or-1"></script>
<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
