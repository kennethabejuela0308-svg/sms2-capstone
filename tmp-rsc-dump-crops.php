<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$row = $crad->query('SELECT mis_signature, aa_signature FROM research_services_clearances WHERE id = 1')->fetch(PDO::FETCH_ASSOC);
foreach (['mis' => $row['mis_signature'], 'aa' => $row['aa_signature']] as $key => $dataUrl) {
    if (preg_match('#^data:image/png;base64,(.+)$#', (string) $dataUrl, $m)) {
        file_put_contents(__DIR__ . '/tmp-rsc-' . $key . '.png', base64_decode($m[1], true));
    }
}
echo "ok\n";
