<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$oldId = 1;
$row = $crad->prepare('SELECT id, status, or_number, research_title FROM research_services_clearances WHERE id = ?');
$row->execute([$oldId]);
$old = $row->fetch(PDO::FETCH_ASSOC);
if (!$old) {
    echo "OLD_GONE\n";
    exit;
}
if ((string) $old['or_number'] !== 'OR-2653610' || (string) $old['status'] !== 'clearance_done') {
    echo "REFUSE\t" . json_encode($old) . "\n";
    exit(1);
}

$crad->prepare('DELETE FROM research_clearance_notifications WHERE clearance_id = ?')->execute([$oldId]);
$crad->prepare('DELETE FROM research_services_clearances WHERE id = ?')->execute([$oldId]);

$left = $crad->query(
    "SELECT id, research_group_id, status, or_number, research_title FROM research_services_clearances ORDER BY id"
)->fetchAll(PDO::FETCH_ASSOC);
echo "deleted_id={$oldId}\n";
foreach ($left as $item) {
    echo implode("\t", $item) . "\n";
}
