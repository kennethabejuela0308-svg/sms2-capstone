<?php
declare(strict_types=1);
require_once __DIR__ . '/../../config/config.php';
require_once ROOT_PATH . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$fresh = rscEnsureForReadyGroup($crad, 70);
echo json_encode([
    'or_number' => $fresh['or_number'] ?? null,
    'members' => $fresh['members_json'] ?? null,
    'group' => $fresh['leader_group_no'] ?? null,
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT), PHP_EOL;
