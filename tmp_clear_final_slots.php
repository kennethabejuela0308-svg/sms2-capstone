<?php
require __DIR__ . '/config/config.php';
require ROOT_PATH . '/modules/crad/config/config.php';

$c = cradDb();
if (!$c) {
    fwrite(STDERR, "no db\n");
    exit(1);
}

echo "=== before ===\n";
$rows = $c->query(
    "SELECT id, research_group_id, group_number, defense_type, status, defense_datetime, venue
     FROM research_defense_schedules
     WHERE group_number = 'RG-2026-068'
        OR research_group_id IN (
            SELECT id FROM research_groups WHERE group_number = 'RG-2026-068'
        )
     ORDER BY id"
)->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $r) {
    echo implode("\t", $r) . "\n";
}

// Remove non-official Final Defense proposals/selections so group returns to Ready for Scheduling.
$stmt = $c->prepare(
    "DELETE FROM research_defense_schedules
     WHERE (group_number = 'RG-2026-068'
            OR research_group_id IN (SELECT id FROM research_groups WHERE group_number = 'RG-2026-068'))
       AND (
            LOWER(TRIM(COALESCE(defense_type, ''))) IN ('final defense', 'final')
            OR defense_type LIKE '%Final%'
       )
       AND LOWER(status) IN ('proposed', 'selected', 'rejected', 'alternative')"
);
$stmt->execute();
echo "deleted=" . $stmt->rowCount() . "\n";

echo "=== after ===\n";
$rows = $c->query(
    "SELECT id, research_group_id, group_number, defense_type, status, defense_datetime, venue
     FROM research_defense_schedules
     WHERE group_number = 'RG-2026-068'
        OR research_group_id IN (
            SELECT id FROM research_groups WHERE group_number = 'RG-2026-068'
        )
     ORDER BY id"
)->fetchAll(PDO::FETCH_ASSOC);
if (!$rows) {
    echo "(none)\n";
}
foreach ($rows as $r) {
    echo implode("\t", $r) . "\n";
}
