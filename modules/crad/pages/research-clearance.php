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
$pageBannerDescription = 'Upload the adviser-signed clearance image, then sign as CRAD.';
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
<link rel="stylesheet" href="<?= BASE_URL ?>/modules/crad/assets/css/research-clearance.css?v=rsc-no-inbox-1">

<div class="glass-dashboard rsc-print-root"
     data-rsc-live
     data-rsc-role="<?= e(getCurrentUserRoleKey()) ?>"
     data-rsc-endpoint="<?= e(BASE_URL . '/modules/crad/api/research-clearance.php') ?>"
     data-rsc-csrf="<?= e(csrfToken()) ?>"
     data-rsc-id="<?= $public ? (int) $public['id'] : '' ?>">
    <div class="rsc-empty" data-rsc-empty <?= $rows ? 'hidden' : '' ?>>Waiting for an adviser-signed Research Services Clearance.</div>

    <div data-rsc-detail <?= $public ? '' : 'hidden' ?>>
        <div class="rsc-toolbar">
            <div>
                <div class="rsc-status" data-rsc-status><?= e($public['status_label'] ?? '') ?></div>
                <small class="text-muted" data-rsc-sync></small>
            </div>
            <div class="d-flex flex-wrap gap-2 align-items-center">
                <?php if (count($rows) > 1): ?>
                    <select class="form-select form-select-sm" style="max-width:280px;" data-rsc-group>
                        <?php foreach ($rows as $item): $itemPublic = rscPublicRow($item); ?>
                            <option value="<?= (int) $itemPublic['id'] ?>"<?= $public && (int) $public['id'] === (int) $itemPublic['id'] ? ' selected' : '' ?>>
                                <?= e($itemPublic['leader_group_no'] ?: ('#' . $itemPublic['id'])) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                <?php endif; ?>
                <input type="file" class="form-control form-control-sm" style="max-width:260px;" data-rsc-file accept=".png,.jpg,.jpeg,image/png,image/jpeg">
                <button type="button" class="btn btn-outline-primary" data-rsc-accept <?= ($public && in_array($public['status'], ['adviser_signed', 'crad_received', 'clearance_done'], true)) ? '' : 'hidden' ?>><?= smsIcon('upload', ['class' => 'me-1']) ?><span data-rsc-upload-label><?= !empty($public['has_upload']) ? 'Re-upload Image' : 'Upload Image' ?></span></button>
                <button type="button" class="btn btn-outline-secondary" data-rsc-print <?= ($public && !empty($public['form_verified'])) ? '' : 'hidden' ?>><?= smsIcon('print', ['class' => 'me-1']) ?>Print</button>
                <button type="button" class="btn btn-success" data-rsc-sign <?= ($public && !empty($public['form_verified']) && !empty($public['has_adviser_signature']) && ($public['status'] ?? '') !== 'clearance_done') ? '' : 'hidden' ?>><?= smsIcon('signature', ['class' => 'me-1']) ?>Sign Clearance</button>
            </div>
        </div>

        <div class="alert alert-warning" data-rsc-upload-gate <?= ($public && empty($public['has_upload'])) ? '' : 'hidden' ?>>
            <?= smsIcon('upload', ['class' => 'me-2']) ?>
            Upload the Research Services Clearance picture that already has the adviser signature. Other photos cannot be signed.
        </div>

        <div class="alert alert-info" data-rsc-mis-aa-note <?= ($public && !empty($public['form_verified']) && ($public['status'] ?? '') !== 'clearance_done') ? '' : 'hidden' ?>>
            <?= smsIcon('info-circle', ['class' => 'me-2']) ?>
            <strong>Note:</strong> CRAD cannot sign if the MIS and AA physical signatures are missing.
            Confirm both signatures on the uploaded form first.
            <div class="d-flex flex-wrap gap-3 mt-2" data-rsc-check-wrap>
                <label class="form-check mb-0">
                    <input class="form-check-input" type="checkbox" data-rsc-check-mis <?= !empty($public['mis_verified']) ? 'checked' : '' ?>>
                    <span class="form-check-label">MIS physical signature is on the form</span>
                </label>
                <label class="form-check mb-0">
                    <input class="form-check-input" type="checkbox" data-rsc-check-aa <?= !empty($public['aa_verified']) ? 'checked' : '' ?>>
                    <span class="form-check-label">AA physical signature is on the form</span>
                </label>
            </div>
        </div>

        <div data-rsc-upload-preview hidden></div>
        <div class="rsc-wrap" data-rsc-form <?= ($public && !empty($public['form_verified'])) ? '' : 'hidden' ?>><?= ($public && !empty($public['form_verified'])) ? ($public['form_html'] ?? '') : '' ?></div>
    </div>
</div>
<?php require __DIR__ . '/../includes/research-clearance-sig-modal.php'; ?>
<script src="<?= BASE_URL ?>/modules/crad/assets/js/research-clearance-live.js?v=rsc-mis-aa-note-1"></script>
<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
