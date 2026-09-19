<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$row = $crad->query('SELECT * FROM research_services_clearances WHERE id = 1')->fetch(PDO::FETCH_ASSOC);
$path = ROOT_PATH . '/uploads/research-clearance/' . basename((string) $row['uploaded_file']);
$extracted = rscExtractPhysicalSignatures($path, $row);
echo 'mis=' . strlen((string) ($extracted['mis'] ?? '')) . "\n";
echo 'aa=' . strlen((string) ($extracted['aa'] ?? '')) . "\n";
$fresh = rscPersistUploadedSignatures($crad, $row);
echo 'saved_mis=' . strlen((string) ($fresh['mis_signature'] ?? '')) . "\n";
echo 'saved_aa=' . strlen((string) ($fresh['aa_signature'] ?? '')) . "\n";
echo 'has_mis_img=' . (str_contains(rscRenderFormHtml($fresh, false), 'alt="MIS signature"') ? '1' : '0') . "\n";
echo 'has_aa_img=' . (str_contains(rscRenderFormHtml($fresh, false), 'alt="AA signature"') ? '1' : '0') . "\n";
echo 'has_crad_img=' . (str_contains(rscRenderFormHtml($fresh, false), 'alt="CRAD signature"') ? '1' : '0') . "\n";
