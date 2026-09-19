<?php
require __DIR__ . '/config/config.php';
require ROOT_PATH . '/modules/crad/config/config.php';
$c = cradDb();
$n = $c->exec(
    "DELETE FROM research_defense_schedules
     WHERE research_group_id IS NOT NULL
       AND research_group_id > 0
       AND research_group_id NOT IN (SELECT id FROM research_groups)"
);
echo "orphan_schedules_deleted=" . (int) $n . "\n";

$rows = $c->query(
    "SELECT id, research_group_id, group_number, defense_type, status, defense_datetime
     FROM research_defense_schedules
     WHERE group_number = 'RG-2026-068'
     ORDER BY id"
)->fetchAll(PDO::FETCH_ASSOC);
echo "remaining RG-2026-068:\n";
foreach ($rows as $r) {
    echo implode("\t", $r) . "\n";
}
