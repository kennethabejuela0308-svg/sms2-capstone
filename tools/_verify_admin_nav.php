<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';

$_SESSION['user_role_key'] = 'sms_admin';
$allowed = smsAllowedModuleKeysForRole('sms_admin');
$cradGroups = array_keys($MODULES['crad']['groups'] ?? []);
$visible = getVisibleModules($MODULES);
$adminGroups = array_keys($visible['crad']['groups'] ?? []);

echo "allowed=" . json_encode($allowed) . PHP_EOL;
echo "config_groups=" . json_encode($cradGroups) . PHP_EOL;
echo "visible_groups=" . json_encode($adminGroups) . PHP_EOL;
echo "has_adviser=" . (in_array('A. Adviser Assignment', $adminGroups, true) ? 'yes' : 'no') . PHP_EOL;
echo "has_proposal=" . (in_array('Research Proposal', $adminGroups, true) ? 'yes' : 'no') . PHP_EOL;
