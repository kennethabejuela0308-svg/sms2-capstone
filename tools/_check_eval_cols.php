<?php
require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/modules/crad/includes/chapter-evaluation-workflow.php';
$crad = chapterDb();
$cols = $crad->query("SHOW COLUMNS FROM chapter_evaluations")->fetchAll(PDO::FETCH_COLUMN);
echo implode("\n", $cols) . PHP_EOL;
