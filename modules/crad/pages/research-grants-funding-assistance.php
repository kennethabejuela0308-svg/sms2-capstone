<?php
/**
 * SMS 2 - Research Grants & Funding Assistance
 * Module: CRAD
 */
require_once __DIR__ . '/../../../config/config.php';

$pageTitle    = 'Research Grants & Funding Assistance';
$activeModule = 'crad';
$activePage   = 'research-grants-funding-assistance';
$breadcrumbs  = [
    ['label' => 'CRAD', 'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Research Grants & Funding Assistance', 'url' => null],
];

$cradProcess = [
    'kicker' => 'CRAD Officer · Grants Workflow',
    'description' => 'Receive, evaluate, and process research grant or funding assistance requests from approved student and faculty studies.',
    'metrics' => [
        ['label' => 'New Applications', 'value' => '7', 'icon' => 'fa-file-invoice-dollar', 'tone' => 'blue'],
        ['label' => 'Under Evaluation', 'value' => '4', 'icon' => 'fa-search-dollar', 'tone' => 'amber'],
        ['label' => 'Approved Grants', 'value' => '9', 'icon' => 'fa-hand-holding-usd', 'tone' => 'green'],
        ['label' => 'Avg. Decision', 'value' => '5 days', 'icon' => 'fa-clock', 'tone' => 'purple'],
    ],
    'steps' => [
        ['Receive Funding Request', 'Log grant type, amount requested, research reference, and supporting documents.'],
        ['Validate Requirements', 'Check approved title, budget breakdown, liquidation plan, and eligibility.'],
        ['Evaluate & Decide', 'Score merit, SDG contribution, feasibility, and available CRAD fund allocation.'],
        ['Release Funding Status', 'Approve, revise, or deny; notify proponent and prepare disbursement routing.'],
    ],
    'columns' => ['Reference', 'Grant / Study', 'Requested Amount', 'Status', 'Updated'],
    'fields' => ['reference', 'title', 'owner', 'status', 'updated'],
    'records' => [
        [
            'reference' => 'GRN-2026-008',
            'title' => 'IoT Sensor Kits for Flood Study',
            'owner' => '₱18,500',
            'status' => 'Under Evaluation',
            'status_class' => 'evaluation',
            'updated' => 'Jul 17, 2026',
        ],
        [
            'reference' => 'GRN-2026-007',
            'title' => 'Community Survey Printing Support',
            'owner' => '₱6,200',
            'status' => 'Approved',
            'status_class' => 'approved',
            'updated' => 'Jul 15, 2026',
        ],
        [
            'reference' => 'GRN-2026-006',
            'title' => 'Conference Presentation Assistance',
            'owner' => '₱12,000',
            'status' => 'For Review',
            'status_class' => 'pending',
            'updated' => 'Jul 13, 2026',
        ],
        [
            'reference' => 'GRN-2026-005',
            'title' => 'Prototype Fabrication Support',
            'owner' => '₱25,000',
            'status' => 'Denied',
            'status_class' => 'denied',
            'updated' => 'Jul 10, 2026',
        ],
    ],
    'actions' => [
        ['label' => 'New Grant Application', 'process' => 'new', 'icon' => 'fa-plus', 'class' => 'primary'],
        ['label' => 'Validate Documents', 'process' => 'validate', 'icon' => 'fa-clipboard-check', 'class' => 'ghost'],
        ['label' => 'Approve Funding', 'process' => 'approve', 'icon' => 'fa-thumbs-up', 'class' => 'ghost'],
        ['label' => 'Grants Report', 'process' => 'report', 'icon' => 'fa-file-export', 'class' => 'ghost'],
    ],
    'form' => [
        ['label' => 'Application No.', 'type' => 'text', 'name' => 'application_no', 'placeholder' => 'GRN-2026-00X'],
        ['label' => 'Research Title / Purpose', 'type' => 'text', 'name' => 'purpose', 'placeholder' => 'Funding purpose'],
        ['label' => 'Grant Type', 'type' => 'select', 'name' => 'grant_type', 'options' => [
            'Materials / Equipment Support',
            'Survey / Fieldwork Assistance',
            'Publication / Conference Support',
            'Prototype Development Support',
        ]],
        ['label' => 'Requested Amount (PHP)', 'type' => 'number', 'name' => 'amount', 'placeholder' => '0.00'],
        ['label' => 'Proponent', 'type' => 'text', 'name' => 'proponent', 'placeholder' => 'Student group or faculty'],
        ['label' => 'Evaluation Notes', 'type' => 'textarea', 'name' => 'notes', 'placeholder' => 'Budget remarks, conditions, or denial reason...'],
    ],
    'notice' => 'Funding is limited to studies with CRAD-approved titles. Liquidation documents must be submitted within the prescribed period after disbursement.',
];

require_once __DIR__ . '/../../../includes/breadcrumbs.php';
require_once __DIR__ . '/../../../includes/layout-start.php';
?>

<?php renderBreadcrumbs($breadcrumbs); ?>
<?php require_once ROOT_PATH . '/includes/crad-module-process.php'; ?>
<?php require_once __DIR__ . '/../../../includes/layout-end.php'; ?>
