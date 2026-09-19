<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
rscEnsureSchema($crad);
$row = $crad->query('SELECT * FROM research_clearance_payments ORDER BY id DESC LIMIT 1')->fetch(PDO::FETCH_ASSOC);
if (!$row) {
    echo "NO_PAYMENT\n";
    exit;
}
$path = ROOT_PATH . '/uploads/college-payment/' . basename((string) $row['uploaded_file']);
echo 'id=' . $row['id'] . "\n";
echo 'file=' . $path . "\n";
echo 'old=' . $row['or_number'] . "\n";
$or = rcpExtractReferenceFromImage($path);
echo 'extracted=' . $or . "\n";
if ($or !== '') {
    $crad->prepare('UPDATE research_clearance_payments SET or_number = ? WHERE id = ?')->execute([$or, (int) $row['id']]);
    echo "saved\n";
}
