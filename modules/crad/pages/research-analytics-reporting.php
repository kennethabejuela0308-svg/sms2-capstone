<?php
/**
 * SMS 2 - Research Analytics & Reporting
 * Module: CRAD
 */
require_once __DIR__ . '/../../../config/config.php';

$pageTitle    = 'Research Analytics & Reporting';
$activeModule = 'crad';
$activePage   = 'research-analytics-reporting';
$breadcrumbs  = [
    ['label' => 'CRAD', 'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Research Analytics & Reporting', 'url' => null],
];

$cradProcess = [
    'kicker' => 'CRAD Officer · Analytics & Reporting Workflow',
    'description' => 'Monitor research productivity, proposal acceptance rates, grants disbursed, defense outcomes, and publication counts across all colleges.',
    'metrics' => [
        ['label' => 'Active Studies', 'value' => '24', 'icon' => 'fa-flask', 'tone' => 'blue'],
        ['label' => 'Approval Rate', 'value' => '78%', 'icon' => 'fa-percent', 'tone' => 'green'],
        ['label' => 'Grants Released', 'value' => '₱486K', 'icon' => 'fa-hand-holding-usd', 'tone' => 'amber'],
        ['label' => 'Publications', 'value' => '31', 'icon' => 'fa-book-open', 'tone' => 'purple'],
    ],
    'steps' => [
        ['Define Report Scope', 'Select the time period, college, and research metric for the report.'],
        ['Gather Research Data', 'Pull proposal, adviser, grant, defense, and publication records from each workflow.'],
        ['Analyze Performance', 'Compute acceptance rates, pass rates, grant utilization, and productivity trends.'],
        ['Generate & Export Report', 'Produce the institutional research analytics report and export for stakeholders.'],
    ],
    'columns' => ['Reference', 'Research Metric', 'College / Office', 'Status', 'Updated'],
    'fields' => ['reference', 'title', 'owner', 'status', 'updated'],
    'records' => [
        [
            'reference' => 'RAN-001',
            'title' => 'Proposal Submission Rate',
            'owner' => 'CCS',
            'detail' => '18 proposals / term',
            'status' => 'On Track',
            'status_class' => 'completed',
            'updated' => 'Jul 18, 2026',
        ],
        [
            'reference' => 'RAN-002',
            'title' => 'Defense Pass Rate',
            'owner' => 'CBA',
            'detail' => '92% pass rate',
            'status' => 'On Track',
            'status_class' => 'completed',
            'updated' => 'Jul 18, 2026',
        ],
        [
            'reference' => 'RAN-003',
            'title' => 'Grant Utilization',
            'owner' => 'COE',
            'detail' => '₱148,500 utilized',
            'status' => 'Monitoring',
            'status_class' => 'pending',
            'updated' => 'Jul 17, 2026',
        ],
        [
            'reference' => 'RAN-004',
            'title' => 'Publication Output',
            'owner' => 'Criminology',
            'detail' => '12 outputs this year',
            'status' => 'On Track',
            'status_class' => 'completed',
            'updated' => 'Jul 16, 2026',
        ],
        [
            'reference' => 'RAN-005',
            'title' => 'Adviser Workload Balance',
            'owner' => 'All Colleges',
            'detail' => 'Avg. 4.5 advisees / adviser',
            'status' => 'Needs Attention',
            'status_class' => 'cancelled',
            'updated' => 'Jul 14, 2026',
        ],
    ],
    'actions' => [
        ['label' => 'Generate Report', 'process' => 'report', 'icon' => 'fa-file-export', 'class' => 'primary'],
        ['label' => 'Filter by College', 'process' => 'validate', 'icon' => 'fa-filter', 'class' => 'ghost'],
        ['label' => 'Export Dashboard', 'process' => 'approve', 'icon' => 'fa-download', 'class' => 'ghost'],
        ['label' => 'View Historical Trends', 'process' => 'view', 'icon' => 'fa-chart-line', 'class' => 'ghost'],
    ],
    'form' => [
        ['label' => 'Report Reference', 'type' => 'text', 'name' => 'reference', 'placeholder' => 'RAN-2026-00X'],
        ['label' => 'Report Title', 'type' => 'text', 'name' => 'title', 'placeholder' => 'Research performance report'],
        ['label' => 'College / Office', 'type' => 'select', 'name' => 'college', 'options' => [
            'All Colleges',
            'College of Computer Studies',
            'College of Business Administration',
            'College of Criminology',
            'College of Education',
            'College of Hospitality & Tourism Management',
        ]],
        ['label' => 'Time Period', 'type' => 'select', 'name' => 'period', 'options' => [
            'This Term',
            'This Academic Year',
            'Last 12 Months',
            'Custom Range',
        ]],
        ['label' => 'Report Type', 'type' => 'select', 'name' => 'report_type', 'options' => [
            'Proposal Analytics',
            'Adviser & Panel Report',
            'Grants & Funding Report',
            'Defense Outcomes Report',
            'Publication & Repository Report',
        ]],
        ['label' => 'Report Notes', 'type' => 'textarea', 'name' => 'notes', 'placeholder' => 'Trend highlights, anomalies, recommendations...'],
    ],
    'notice' => 'Research analytics reports are generated from live workflow data. Reports should be reviewed by the CRAD Director before release to college deans or external partners.',
];

require_once __DIR__ . '/../../../includes/breadcrumbs.php';
require_once __DIR__ . '/../../../includes/layout-start.php';
?>

<?php renderBreadcrumbs($breadcrumbs); ?>
<?php require_once ROOT_PATH . '/includes/crad-module-process.php'; ?>
<?php require_once __DIR__ . '/../../../includes/layout-end.php'; ?>