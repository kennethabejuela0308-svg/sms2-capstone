<?php
$path = 'F:/xampp/htdocs/sms2_system/uploads/research-clearance/rsc-1-3611ebff6ecc.png';
$im = imagecreatefrompng($path);
$w = imagesx($im);
$h = imagesy($im);
$cols = 10;
$rows = 20;
$cw = (int) floor($w / $cols);
$rh = (int) floor($h / $rows);
echo "w=$w h=$h\n";
for ($r = 0; $r < $rows; $r++) {
    $line = str_pad((string) $r, 2, '0', STR_PAD_LEFT) . ' y=' . str_pad((string) ($r * $rh), 3, ' ', STR_PAD_LEFT) . ' ';
    for ($c = 0; $c < $cols; $c++) {
        $dark = 0;
        $total = 0;
        for ($y = $r * $rh; $y < ($r + 1) * $rh; $y += 2) {
            for ($x = $c * $cw; $x < ($c + 1) * $cw; $x += 2) {
                $rgb = imagecolorat($im, $x, $y);
                $avg = ((($rgb >> 16) & 255) + (($rgb >> 8) & 255) + ($rgb & 255)) / 3;
                $total++;
                if ($avg < 150) {
                    $dark++;
                }
            }
        }
        $pct = $total ? (int) round(100 * $dark / $total) : 0;
        $line .= str_pad((string) $pct, 3, ' ', STR_PAD_LEFT);
    }
    echo $line . "\n";
}
imagedestroy($im);
