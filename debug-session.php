<?php
require_once __DIR__ . '/config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
header('Content-Type: text/plain');
echo 'sid=' . session_id() . "\n";
echo 'status=' . session_status() . "\n";
echo 'auth=' . (isAuthenticated() ? 'yes' : 'no') . "\n";
echo 'role=' . getCurrentUserRoleKey() . "\n";
echo 'must_pw=' . (isset($_SESSION['must_change_password']) ? $_SESSION['must_change_password'] : 'none') . "\n";
echo 'login_at=' . ($_SESSION['login_at'] ?? 'none') . "\n";
echo 'last_activity=' . ($_SESSION['last_activity'] ?? 'none') . "\n";
echo 'now=' . time() . "\n";
echo 'keys=' . implode(',', array_keys($_SESSION)) . "\n";