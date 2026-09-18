<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("CLI only\n");
}

require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/config/database.php';

$pdo = db();
if (!$pdo instanceof PDO) {
    fwrite(STDERR, "No database connection.\n");
    exit(1);
}

$sql = "SELECT id, username, email, role_key, status
          FROM users
         WHERE role_key = 'research_director'
            OR username = 'researchdirector'
            OR email IN ('researchdirector@bestlink.edu.ph', 'research.director@bestlink.edu.ph')";
$rows = $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC) ?: [];
echo 'FOUND ' . count($rows) . PHP_EOL;
foreach ($rows as $row) {
    echo json_encode($row) . PHP_EOL;
}

if ($rows !== []) {
    $ids = array_values(array_unique(array_map('intval', array_column($rows, 'id'))));
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    try {
        $del = $pdo->prepare('DELETE FROM users WHERE id IN (' . $placeholders . ')');
        $del->execute($ids);
        echo 'DELETED ' . $del->rowCount() . PHP_EOL;
    } catch (Throwable $e) {
        echo 'DELETE_FAIL ' . $e->getMessage() . PHP_EOL;
        $upd = $pdo->prepare("UPDATE users SET status = 'inactive' WHERE id IN (" . $placeholders . ')');
        $upd->execute($ids);
        echo 'INACTIVATED ' . $upd->rowCount() . PHP_EOL;
    }
}

$left = $pdo->query(
    "SELECT COUNT(*) FROM users
      WHERE role_key = 'research_director' OR username = 'researchdirector'"
)->fetchColumn();
echo 'LEFT ' . $left . PHP_EOL;
