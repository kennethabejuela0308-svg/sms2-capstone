<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$row = $crad->query('SELECT * FROM research_services_clearances ORDER BY id DESC LIMIT 1')->fetch(PDO::FETCH_ASSOC);
if (!$row) {
    echo "NO_ROW\n";
    exit(0);
}
echo 'id=' . $row['id'] . "\n";
echo 'status=' . $row['status'] . "\n";
echo 'form_verified=' . $row['form_verified'] . "\n";
echo 'uploaded=' . $row['uploaded_file'] . "\n";
echo 'has_adviser=' . (trim((string) $row['adviser_signature']) !== '' ? '1' : '0') . "\n";
echo 'has_mis_crop=' . (trim((string) $row['mis_signature']) !== '' ? '1' : '0') . "\n";
echo 'has_aa_crop=' . (trim((string) $row['aa_signature']) !== '' ? '1' : '0') . "\n";
echo 'can_sign=' . (rscCanCradSign($row) ? '1' : '0') . "\n";
echo 'date_slash=' . rscFormatDate('10/19/26') . "\n";
echo 'date_sept=' . rscFormatDate('Sept 26, 2026') . "\n";
$html = rscRenderFormHtml($row, false);
echo 'has_remarks=' . (str_contains($html, 'Remarks') ? '1' : '0') . "\n";
echo 'has_cashier=' . (str_contains($html, 'Cashier') ? '1' : '0') . "\n";
echo 'has_hma=' . (str_contains($html, 'HMA') ? '1' : '0') . "\n";
