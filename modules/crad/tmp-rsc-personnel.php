<?php
declare(strict_types=1);
require_once __DIR__ . '/../../config/config.php';
require_once ROOT_PATH . '/config/database.php';
require_once ROOT_PATH . '/modules/crad/config/config.php';

$sms = db();
$rows = $sms->query("SELECT id, full_name, username, role_key, status FROM users WHERE role_key <> 'student' ORDER BY role_key, id")->fetchAll();
foreach ($rows as $r) {
    echo json_encode($r), PHP_EOL;
}
