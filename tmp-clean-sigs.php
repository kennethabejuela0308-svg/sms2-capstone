<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$row = $crad->query('SELECT id, mis_signature, aa_signature FROM research_services_clearances ORDER BY id DESC LIMIT 1')->fetch(PDO::FETCH_ASSOC);
if (!$row) {
    echo "NONE\n";
    exit;
}
$mis = rscCleanSignatureDataUrl((string) ($row['mis_signature'] ?? ''));
$aa = rscCleanSignatureDataUrl((string) ($row['aa_signature'] ?? ''));
$crad->prepare(
    'UPDATE research_services_clearances SET mis_signature = ?, aa_signature = ? WHERE id = ?'
)->execute([$mis, $aa, (int) $row['id']]);
echo 'id=' . $row['id'] . "\n";
echo 'mis=' . strlen($mis) . "\n";
echo 'aa=' . strlen($aa) . "\n";
