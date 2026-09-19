<?php
require __DIR__ . '/config/config.php';
require ROOT_PATH . '/modules/crad/includes/research-services-clearance.php';
$c = rscDb();
rscEnsureSchema($c);
echo "after purge payments:\n";
$rows = $c->query('SELECT id, research_group_id, research_stage, status, or_number FROM research_clearance_payments ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $r) {
    echo implode("\t", $r) . "\n";
}
echo "after purge clearances:\n";
$cl = $c->query('SELECT id, research_group_id, research_stage, status FROM research_services_clearances ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);
foreach ($cl as $r) {
    echo implode("\t", $r) . "\n";
}
echo "admin list:\n";
foreach (rcpListForAdmin($c) as $r) {
    echo ($r['id'] ?? '') . "\t" . ($r['group_number'] ?? '') . "\t" . ($r['research_stage'] ?? '') . "\t" . ($r['status'] ?? '') . "\n";
}
