<?php
require __DIR__ . '/config/config.php';
require ROOT_PATH . '/modules/crad/includes/research-services-clearance.php';
$c = rscDb();
rscEnsureSchema($c);
echo "schema_ok\n";
$rows = $c->query('SELECT id, research_group_id, research_stage, status, or_number FROM research_services_clearances')->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $r) {
    echo implode("\t", $r) . "\n";
}
echo "payments:\n";
$pays = $c->query('SELECT id, research_group_id, research_stage, status, or_number FROM research_clearance_payments')->fetchAll(PDO::FETCH_ASSOC);
foreach ($pays as $r) {
    echo implode("\t", $r) . "\n";
}
