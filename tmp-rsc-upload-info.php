<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$row = $crad->query('SELECT id, status, uploaded_file, CHAR_LENGTH(mis_signature) AS mis_len, CHAR_LENGTH(aa_signature) AS aa_len, CHAR_LENGTH(adviser_signature) AS adv_len, CHAR_LENGTH(crad_signature) AS crad_len FROM research_services_clearances WHERE id = 1')->fetch(PDO::FETCH_ASSOC);
print_r($row);
$file = ROOT_PATH . '/uploads/research-clearance/' . basename((string) ($row['uploaded_file'] ?? ''));
echo "path=$file\n";
if (is_file($file)) {
    $info = getimagesize($file);
    echo 'w=' . ($info[0] ?? 0) . ' h=' . ($info[1] ?? 0) . ' mime=' . ($info['mime'] ?? '') . ' bytes=' . filesize($file) . "\n";
}
