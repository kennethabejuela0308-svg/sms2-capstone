<?php
declare(strict_types=1);
require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';

$_SESSION['user_role_key'] = 'crad_officer';
$officer = getVisibleModules($MODULES);
$officerGroups = array_keys($officer['crad']['groups'] ?? []);
echo 'officer_has_core=' . (isset($officer['crad']['groups']['Core System']) ? 'yes' : 'no') . PHP_EOL;
echo 'officer_groups=' . json_encode($officerGroups) . PHP_EOL;

$_SESSION['user_role_key'] = 'sms_admin';
$admin = getVisibleModules($MODULES);
$adminGroups = array_keys($admin['crad']['groups'] ?? []);
echo 'admin_has_core=' . (isset($admin['crad']['groups']['Core System']) ? 'yes' : 'no') . PHP_EOL;
echo 'admin_core=' . json_encode($admin['crad']['groups']['Core System'] ?? []) . PHP_EOL;
echo 'admin_groups=' . json_encode($adminGroups) . PHP_EOL;
