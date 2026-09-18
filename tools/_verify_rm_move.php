<?php
declare(strict_types=1);
require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';

$_SESSION['user_role_key'] = 'sms_admin';
$admin = getVisibleModules($MODULES);
$adminGroups = array_keys($admin['crad']['groups'] ?? []);
echo 'admin_groups=' . json_encode($adminGroups) . PHP_EOL;
echo 'admin_has_research_management=' . (isset($admin['crad']['groups']['Research Management']) ? 'yes' : 'no') . PHP_EOL;
echo 'admin_has_rcm=' . (in_array('research-coordinator-management', array_column($admin['crad']['pages'] ?? [], 'slug'), true) ? 'yes' : 'no') . PHP_EOL;

$_SESSION['user_role_key'] = 'department_head';
$head = getVisibleModules($MODULES);
echo 'head_label=' . ($head['crad']['label'] ?? '') . PHP_EOL;
echo 'head_groups=' . json_encode(array_keys($head['crad']['groups'] ?? [])) . PHP_EOL;
echo 'head_has_rcm=' . (in_array('research-coordinator-management', array_column($head['crad']['pages'] ?? [], 'slug'), true) ? 'yes' : 'no') . PHP_EOL;
echo 'head_ungrouped=' . (!empty($head['crad']['show_ungrouped_pages']) ? 'yes' : 'no') . PHP_EOL;
