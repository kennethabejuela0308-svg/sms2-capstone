<?php
define('RD_AI_OPTIMIZER_TEST', true);
require __DIR__ . '/config/config.php';
require ROOT_PATH . '/modules/crad/config/config.php';
require ROOT_PATH . '/modules/crad/includes/research-progress-helpers.php';
require ROOT_PATH . '/modules/faculty/includes/research-director-panel-assignment.php';
require ROOT_PATH . '/modules/faculty/pages/research-director.php';

$pdo = cradDb();
$result = rdScheduleGenerateOptimizedSlots(
    $pdo,
    71,
    CRAD_DEFENSE_TYPE_FINAL,
    date('Y-m-d'),
    date('Y-m-d', strtotime('+30 days')),
    15
);

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
