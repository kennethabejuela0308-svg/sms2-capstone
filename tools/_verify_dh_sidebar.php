<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/navigation-context.php';

$_SESSION['user_id'] = 1420;
$_SESSION['user_role_key'] = 'department_head';
$_SESSION['user_name'] = 'Department Head';
$_SESSION['user_role'] = 'Department Head';

$activeModule = 'crad';
$activePage = 'retrieve-approved-research';
$MODULES = $GLOBALS['MODULES'] ?? $MODULES;

ob_start();
require ROOT_PATH . '/includes/sidebar.php';
$html = ob_get_clean();

$checks = [
    'Research Management' => str_contains($html, 'Research Management'),
    'A. Adviser Assignment' => str_contains($html, 'A. Adviser Assignment'),
    'B. Panel Assignment' => str_contains($html, 'B. Panel Assignment'),
    'Retrieve Approved Research' => str_contains($html, 'Retrieve Approved Research'),
    'Select Panel Members' => str_contains($html, 'Select Panel Members'),
    'no CRAD label' => !preg_match('/>(?:\s*)CRAD(?:\s*)</', $html),
    'no coordinator management' => !str_contains($html, 'Research Coordinator Management'),
];

$_SESSION['user_role_key'] = 'sms_admin';
$_SESSION['user_id'] = 1;
$activePage = 'research-coordinator-management';
ob_start();
require ROOT_PATH . '/includes/sidebar.php';
$adminHtml = ob_get_clean();

$adminChecks = [
    'admin still research management' => str_contains($adminHtml, 'Research Management'),
    'admin no adviser group' => !str_contains($adminHtml, 'A. Adviser Assignment'),
    'admin no panel group' => !str_contains($adminHtml, 'B. Panel Assignment'),
];

foreach ($checks as $label => $ok) {
    echo ($ok ? 'OK  ' : 'FAIL') . " head {$label}\n";
}
foreach ($adminChecks as $label => $ok) {
    echo ($ok ? 'OK  ' : 'FAIL') . " {$label}\n";
}
