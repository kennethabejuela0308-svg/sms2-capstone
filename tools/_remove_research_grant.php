<?php
require_once __DIR__ . '/../config/database.php';
$pdo = db();
if (!$pdo) {
    fwrite(STDERR, "no db\n");
    exit(1);
}
$pdo->exec(
    "UPDATE users
     SET status = 'inactive'
     WHERE role_key = 'research_grant'
        OR username = 'researchgrant'
        OR email = 'researchgrant@bestlink.edu.ph'"
);
try {
    $deleted = $pdo->exec(
        "DELETE FROM users
         WHERE role_key = 'research_grant'
            OR username = 'researchgrant'
            OR email = 'researchgrant@bestlink.edu.ph'"
    );
    echo "deleted=$deleted\n";
} catch (Throwable $e) {
    echo "delete failed: " . $e->getMessage() . "\n";
}
$rows = $pdo->query(
    "SELECT id, username, full_name, role_key, status
     FROM users
     WHERE role_key = 'research_grant' OR username = 'researchgrant'"
)->fetchAll();
echo json_encode($rows) . PHP_EOL;
