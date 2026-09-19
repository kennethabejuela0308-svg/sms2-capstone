<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$row = $crad->query('SELECT mis_signature, aa_signature FROM research_services_clearances WHERE id = 2')->fetch(PDO::FETCH_ASSOC);
foreach (['mis', 'aa'] as $key) {
    $raw = (string) $row[$key . '_signature'];
    if (!preg_match('#base64,(.+)$#s', $raw, $m)) {
        echo $key . "=NO\n";
        continue;
    }
    $im = imagecreatefromstring(base64_decode($m[1], true));
    echo $key . ' size=' . imagesx($im) . 'x' . imagesy($im) . ' same=' . (hash('sha1', $raw) === hash('sha1', (string) $row['aa_signature']) ? 'yes' : 'no') . "\n";
    imagepng($im, __DIR__ . '/tmp-' . $key . '.png');
    imagedestroy($im);
}
