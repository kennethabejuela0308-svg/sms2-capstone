<?php
/**
 * SMS 2 - REVIEW & WORKFLOW · Reviewer Evaluation Monitoring
 * Module: CRAD
 *
 * Navigation placeholder — the monitoring workflow is not implemented yet.
 */
require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';

requireAuth();

$roleKey = getCurrentUserRoleKey();
if (!in_array($roleKey, ['crad_officer', 'superadmin', 'admin'], true)) {
    header('Location: ' . BASE_URL . '/dashboard/index.php');
    exit;
}

$pageTitle             = 'Reviewer Evaluation Monitoring';
$activeModule          = 'crad';
$activePage            = 'reviewer-evaluation-monitoring';
$pageBannerIcon        = 'fa-binoculars';
$pageBannerDescription = 'Monitor the progress of assigned reviewer evaluations.';

$breadcrumbs = [
    ['label' => 'CRAD',                            'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Reviewer Evaluation Monitoring',  'url' => null],
];

require_once ROOT_PATH . '/includes/breadcrumbs.php';
require_once ROOT_PATH . '/includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);
?>
<link href="<?= BASE_URL ?>/assets/css/module-process-list.css?v=2" rel="stylesheet">

<div class="mpl" data-mpl>
    <section class="mpl-panel">
        <div style="text-align:center;padding:3.5rem 1.5rem;">
            <div style="width:64px;height:64px;border-radius:50%;background:rgba(37,99,235,.1);color:#2563eb;
                        display:inline-flex;align-items:center;justify-content:center;font-size:1.6rem;margin-bottom:1rem;">
                <i class="fas fa-binoculars" aria-hidden="true"></i>
            </div>
            <h2 style="font-size:1.05rem;font-weight:800;color:var(--sms-heading);margin-bottom:.4rem;">Reviewer Evaluation Monitoring</h2>
            <p style="font-size:.88rem;color:var(--sms-text-muted);max-width:460px;margin:0 auto 1.2rem;">
                This module is coming soon. Use Reviewer Assignment to assign evaluators to submitted research grant proposals.
            </p>
            <a class="mpl-btn mpl-btn-soft" href="<?= BASE_URL ?>/modules/crad/pages/reviewer-assignment.php">
                <i class="fas fa-user-check" aria-hidden="true"></i>Go to Reviewer Assignment
            </a>
        </div>
    </section>
</div>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
