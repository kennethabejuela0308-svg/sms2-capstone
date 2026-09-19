<?php
require __DIR__ . '/config/config.php';
require ROOT_PATH . '/modules/crad/config/config.php';
$c = cradDb();
echo "=== payments ===\n";
$rows = $c->query('SELECT id, research_group_id, research_stage, status, or_number, uploaded_file, updated_at FROM research_clearance_payments ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $r) {
    echo implode("\t", $r) . "\n";
}
echo "=== groups for those ids ===\n";
$gids = array_unique(array_column($rows, 'research_group_id'));
foreach ($gids as $gid) {
    $st = $c->prepare('SELECT id, group_number, research_title FROM research_groups WHERE id = ?');
    $st->execute([(int) $gid]);
    $g = $st->fetch(PDO::FETCH_ASSOC);
    echo $gid . " => " . ($g ? json_encode($g) : 'MISSING') . "\n";
}
echo "=== clearances ===\n";
$cl = $c->query('SELECT id, research_group_id, research_stage, status, or_number FROM research_services_clearances ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);
foreach ($cl as $r) {
    echo implode("\t", $r) . "\n";
}
