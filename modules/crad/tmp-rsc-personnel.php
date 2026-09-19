<?php
declare(strict_types=1);
require_once __DIR__ . '/../../config/config.php';
require_once ROOT_PATH . '/config/database.php';

$sms = db();
$crad = function_exists('cradDb') ? cradDb() : getCradDatabaseConnection();

echo "USERS:\n";
$rows = $sms->query("SELECT id, full_name, username, role_key, status FROM users WHERE role_key IN ('grammarian','panel','adviser','statistician','technical_adviser') OR username LIKE '%gram%' OR username LIKE '%stat%' OR username LIKE '%tech%' OR full_name LIKE '%Gramm%' OR full_name LIKE '%Stat%' OR full_name LIKE '%Tech%' ORDER BY role_key, id")->fetchAll();
foreach ($rows as $r) {
    echo json_encode($r), PHP_EOL;
}

echo "\nEVALS:\n";
$evals = $crad->query("SELECT research_group_id, evaluator_user_id, evaluator_name FROM chapter_evaluations ORDER BY id DESC LIMIT 8")->fetchAll();
foreach ($evals as $r) {
    echo json_encode($r), PHP_EOL;
}
