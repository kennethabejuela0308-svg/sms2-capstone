<?php
/**
 * SMS 2 - Documentation & Publication Management
 * Module: CRAD
 */
require_once __DIR__ . '/../../../config/config.php';

$pageTitle    = 'Documentation & Publication Management';
$activeModule = 'crad';
$activePage   = 'documentation-publication-management';
$breadcrumbs  = [
    ['label' => 'CRAD', 'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Documentation & Publication Management', 'url' => null],
];

$cradProcess = [
    'kicker' => 'CRAD Officer · Publication Workflow',
    'description' => 'Manage research manuscripts, institutional documentation, ethics clearance attachments, and publication endorsements.',
    'metrics' => [
        ['label' => 'For Formatting', 'value' => '6', 'icon' => 'fa-file-alt', 'tone' => 'blue'],
        ['label' => 'Ethics / Similarity', 'value' => '3', 'icon' => 'fa-shield-alt', 'tone' => 'amber'],
        ['label' => 'Endorsed to Publish', 'value' => '11', 'icon' => 'fa-book-open', 'tone' => 'green'],
        ['label' => 'Avg. Turnaround', 'value' => '4 days', 'icon' => 'fa-clock', 'tone' => 'purple'],
    ],
    'steps' => [
        ['Receive Manuscript / Document', 'Log research paper, abstract, poster, or institutional research document.'],
        ['Check Format & Completeness', 'Validate template, authorship, abstract, keywords, and required attachments.'],
        ['Run Ethics / Similarity Review', 'Confirm ethics clearance and similarity screening before endorsement.'],
        ['Endorse for Publication', 'Approve campus journal, conference, or repository publication routing.'],
    ],
    'columns' => ['Reference', 'Document / Manuscript', 'Target Outlet', 'Status', 'Updated'],
    'fields' => ['reference', 'title', 'owner', 'status', 'updated'],
    'records' => [
        [
            'reference' => 'PUB-2026-021',
            'title' => 'Flood Monitoring Early Warning System',
            'owner' => 'BCP Research Journal',
            'status' => 'For Review',
            'status_class' => 'pending',
            'updated' => 'Jul 18, 2026',
        ],
        [
            'reference' => 'PUB-2026-020',
            'title' => 'Micro-Enterprise Marketing Adaptability',
            'owner' => 'National Research Forum',
            'status' => 'Ethics Check',
            'status_class' => 'evaluation',
            'updated' => 'Jul 16, 2026',
        ],
        [
            'reference' => 'PUB-2026-019',
            'title' => 'Waste Segregation Awareness Output',
            'owner' => 'Campus Poster Exhibit',
            'status' => 'Published',
            'status_class' => 'published',
            'updated' => 'Jul 11, 2026',
        ],
        [
            'reference' => 'PUB-2026-018',
            'title' => 'Mental Health Literacy Baseline Paper',
            'owner' => 'College Research Colloquium',
            'status' => 'Endorsed',
            'status_class' => 'approved',
            'updated' => 'Jul 9, 2026',
        ],
    ],
    'actions' => [
        ['label' => 'New Document Entry', 'process' => 'new', 'icon' => 'fa-plus', 'class' => 'primary'],
        ['label' => 'Validate Format', 'process' => 'validate', 'icon' => 'fa-spell-check', 'class' => 'ghost'],
        ['label' => 'Endorse Publication', 'process' => 'approve', 'icon' => 'fa-stamp', 'class' => 'ghost'],
        ['label' => 'Publication Report', 'process' => 'report', 'icon' => 'fa-file-export', 'class' => 'ghost'],
    ],
    'form' => [
        ['label' => 'Document Reference', 'type' => 'text', 'name' => 'reference', 'placeholder' => 'PUB-2026-00X'],
        ['label' => 'Title', 'type' => 'text', 'name' => 'title', 'placeholder' => 'Manuscript or document title'],
        ['label' => 'Document Type', 'type' => 'select', 'name' => 'doc_type', 'options' => [
            'Full Research Paper',
            'Abstract / Extended Abstract',
            'Poster / Infographic',
            'Institutional Research Report',
        ]],
        ['label' => 'Target Outlet', 'type' => 'select', 'name' => 'outlet', 'options' => [
            'BCP Research Journal',
            'College Research Colloquium',
            'National Research Forum',
            'Campus Poster Exhibit',
        ]],
        ['label' => 'Authors / Proponents', 'type' => 'text', 'name' => 'authors', 'placeholder' => 'Comma-separated names'],
        ['label' => 'Reviewer Remarks', 'type' => 'textarea', 'name' => 'remarks', 'placeholder' => 'Formatting notes, ethics remarks, endorsement conditions...'],
    ],
    'notice' => 'No manuscript is endorsed for external publication without completed ethics documentation and acceptable similarity screening results.',
];

require_once __DIR__ . '/../../../includes/breadcrumbs.php';
require_once __DIR__ . '/../../../includes/layout-start.php';
?>

<?php renderBreadcrumbs($breadcrumbs); ?>
<?php require_once ROOT_PATH . '/includes/crad-module-process.php'; ?>
<?php require_once __DIR__ . '/../../../includes/layout-end.php'; ?>
