<?php
declare(strict_types=1);
require_once __DIR__ . '/../../config/config.php';
require_once ROOT_PATH . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
if (!$crad instanceof PDO) {
    fwrite(STDERR, "no db\n");
    exit(1);
}

$rows = $crad->query('SELECT id, research_group_id, or_number, members_json, leader_group_no, research_title FROM research_services_clearances')->fetchAll() ?: [];
echo "before=" . count($rows) . PHP_EOL;
foreach ($rows as $row) {
    echo "id={$row['id']} gid={$row['research_group_id']} or={$row['or_number']} group={$row['leader_group_no']} members={$row['members_json']}" . PHP_EOL;
    $fresh = rscEnsureForReadyGroup($crad, (int) $row['research_group_id']);
    if ($fresh) {
        echo "after or={$fresh['or_number']} members={$fresh['members_json']}" . PHP_EOL;
    } else {
        echo "after=null" . PHP_EOL;
    }
}
