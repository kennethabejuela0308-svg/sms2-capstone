<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/navigation-context.php';

$pdo = db();
if (!$pdo instanceof PDO) {
    fwrite(STDERR, "DB unavailable\n");
    exit(1);
}

$pdo->prepare(
    "INSERT INTO roles (role_key, label, description, is_system)
     VALUES ('department_head', 'Department Head', 'Adviser and panel assignment', 1)
     ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description)"
)->execute();
$pdo->prepare(
    "INSERT INTO role_permissions (role_key, module_key, granted)
     VALUES ('department_head', 'crad', 1)
     ON DUPLICATE KEY UPDATE granted = VALUES(granted)"
)->execute();

$hash = password_hash('@Depthead123', PASSWORD_DEFAULT);
$pdo->prepare(
    "INSERT INTO users
        (username, email, password_hash, full_name, role_key, student_id, status, password_changed_at, must_change_password, failed_login_attempts, locked_until)
     VALUES
        ('depthead', 'depthead@bestlink.edu.ph', ?, 'Department Head', 'department_head', NULL, 'active', NOW(), 0, 0, NULL)
     ON DUPLICATE KEY UPDATE
        email = VALUES(email),
        full_name = VALUES(full_name),
        role_key = VALUES(role_key),
        status = 'active',
        must_change_password = 0,
        failed_login_attempts = 0,
        locked_until = NULL"
)->execute([$hash]);

$row = $pdo->query(
    "SELECT id, username, role_key, status FROM users WHERE username = 'depthead'"
)->fetch(PDO::FETCH_ASSOC);

echo "account=" . json_encode($row) . PHP_EOL;

session_start();

$_SESSION['user_role_key'] = 'department_head';
$head = getVisibleModules($MODULES);
$headGroups = array_keys($head['crad']['groups'] ?? []);
echo "head_label=" . ($head['crad']['label'] ?? '') . PHP_EOL;
echo "head_groups=" . json_encode($headGroups) . PHP_EOL;

$_SESSION['user_role_key'] = 'sms_admin';
$admin = getVisibleModules($MODULES);
$adminGroups = array_keys($admin['crad']['groups'] ?? []);
echo "admin_groups=" . json_encode($adminGroups) . PHP_EOL;
echo "admin_has_adviser=" . (in_array('A. Adviser Assignment', $adminGroups, true) ? 'yes' : 'no') . PHP_EOL;
echo "admin_has_panel=" . (in_array('B. Panel Assignment', $adminGroups, true) ? 'yes' : 'no') . PHP_EOL;
echo "can_manage_head=" . (smsCanManageCoordinatorAssignments('department_head') ? 'yes' : 'no') . PHP_EOL;
echo "home=" . smsRoleHomeUrl('department_head') . PHP_EOL;
