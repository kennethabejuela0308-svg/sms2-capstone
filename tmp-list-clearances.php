<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$rows = $crad->query(
    "SELECT id, research_group_id, title_approval_id, status, or_number, research_title, leader_group_no, updated_at
     FROM research_services_clearances
     ORDER BY id"
)->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $row) {
    echo implode("\t", [
        $row['id'],
        $row['research_group_id'],
        $row['title_approval_id'],
        $row['status'],
        $row['or_number'],
        $row['leader_group_no'],
        $row['research_title'],
        $row['updated_at'],
    ]) . "\n";
}
