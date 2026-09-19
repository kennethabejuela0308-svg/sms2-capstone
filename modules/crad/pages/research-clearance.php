<?php
require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/breadcrumbs.php';
require_once ROOT_PATH . '/includes/security.php';
require_once ROOT_PATH . '/modules/crad/includes/research-services-clearance.php';

requireAuth();
if (!rscCanManageAsCrad()) {
    http_response_code(403);
    exit('Forbidden');
}

$pageTitle = 'Research Services Clearance';
$activeModule = 'crad';
$activePage = 'research-clearance';
$pageBannerIcon = 'fa-stamp';
$pageBannerDescription = 'Accept the student clearance form and add the CRAD signature.';
$breadcrumbs = [
    ['label' => 'CRAD', 'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Research Services Clearance', 'url' => null],
];

$crad = rscDb();
rscEnsureSchema($crad);
$rows = rscListForCrad($crad);
$selectedId = (int) ($_GET['id'] ?? 0);
$current = $selectedId > 0 ? rscRefreshExisting($crad, rscFindById($crad, $selectedId)) : ($rows[0] ?? null);
$public = $current ? rscPublicRow($current) : null;
$rscSigPadLabel = 'CRAD Signature Pad (Draw Below)';

require_once ROOT_PATH . '/includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);
?>
<link rel="stylesheet" href="<?= BASE_URL ?>/modules/crad/assets/css/research-clearance.css?v=rsc-or-1">

<div class="glass-dashboard rsc-print-root"
     data-rsc-live
     data-rsc-role="<?= e(getCurrentUserRoleKey()) ?>"
     data-rsc-endpoint="<?= e(BASE_URL . '/modules/crad/api/research-clearance.php') ?>"
     data-rsc-csrf="<?= e(csrfToken()) ?>"
     data-rsc-id="<?= $public ? (int) $public['id'] : '' ?>">
    <section class="glass-panel p-4 mb-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="mb-0"><?= smsIcon('stamp', ['class' => 'me-2 text-primary']) ?>Clearance for CRAD</h5>
            <small class="text-muted" data-rsc-sync></small>
        </div>
        <div class="table-responsive">
            <table class="table align-middle mb-0">
                <thead><tr><th>Group</th><th>Title</th><th>O.R. No.</th><th>Status</th><th></th></tr></thead>
                <tbody data-rsc-rows>
                    <?php if (!$rows): ?>
                        <tr><td colspan="5" class="text-muted">No signed clearance forms yet.</td></tr>
                    <?php else: ?>
                        <?php foreach ($rows as $item): $itemPublic = rscPublicRow($item); ?>
                            <tr<?= $public && (int) $public['id'] === (int) $itemPublic['id'] ? ' class="table-active"' : '' ?> data-rsc-open="<?= (int) $itemPublic['id'] ?>">
                                <td><?= e($itemPublic['leader_group_no']) ?></td>
                                <td><?= e($itemPublic['research_title']) ?></td>
                                <td><?= e($itemPublic['or_number']) ?></td>
                                <td><?= e($itemPublic['status_label']) ?></td>
                                <td><button type="button" class="btn btn-sm btn-outline-primary" data-rsc-open="<?= (int) $itemPublic['id'] ?>">Open</button></td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>

    <div class="rsc-toolbar">
        <div class="rsc-status" data-rsc-status><?= e($public['status_label'] ?? '') ?></div>
        <div class="d-flex flex-wrap gap-2 align-items-center">
            <input type="file" class="form-control form-control-sm" style="max-width:240px;" data-rsc-file accept=".pdf,.png,.jpg,.jpeg">
            <button type="button" class="btn btn-outline-primary" data-rsc-accept <?= ($public && in_array($public['status'], ['adviser_signed', 'crad_received'], true)) ? '' : 'hidden' ?>><?= smsIcon('upload', ['class' => 'me-1']) ?>Upload Form</button>
            <button type="button" class="btn btn-outline-secondary" data-rsc-print <?= $public ? '' : 'hidden' ?>><?= smsIcon('print', ['class' => 'me-1']) ?>Print</button>
            <button type="button" class="btn btn-success" data-rsc-sign <?= ($public && !empty($public['can_crad_sign'])) ? '' : 'hidden' ?>><?= smsIcon('signature', ['class' => 'me-1']) ?>Sign Clearance</button>
        </div>
    </div>
    <section class="glass-panel p-3 mb-3" data-rsc-check-wrap <?= $public ? '' : 'hidden' ?>>
        <div class="fw-semibold mb-2">CRAD signature check — MIS and AA are physical signatures, not computerized.</div>
        <label class="d-block mb-1"><input type="checkbox" data-rsc-check-adviser disabled <?= !empty($public['has_adviser_signature']) ? 'checked' : '' ?>> Adviser signature (from the system)</label>
        <label class="d-block mb-1"><input type="checkbox" data-rsc-check-mis <?= !empty($public['mis_verified']) ? 'checked' : '' ?>> MIS signature (physical)</label>
        <label class="d-block mb-1"><input type="checkbox" data-rsc-check-aa <?= !empty($public['aa_verified']) ? 'checked' : '' ?>> AA signature (physical)</label>
        <small class="text-muted" data-rsc-upload-name><?= e($public['uploaded_original'] ?? '') ?></small>
    </section>
    <div class="rsc-empty" data-rsc-empty <?= $public ? 'hidden' : '' ?>>Waiting for an adviser-signed Research Services Clearance.</div>
    <div class="rsc-wrap" data-rsc-form><?= $public['form_html'] ?? '' ?></div>
</div>
<?php require __DIR__ . '/../includes/research-clearance-sig-modal.php'; ?>
<script src="<?= BASE_URL ?>/modules/crad/assets/js/research-clearance-live.js?v=rsc-or-1"></script>
<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
