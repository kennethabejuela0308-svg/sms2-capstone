<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../modules/student-portal/includes/student-profile.php';

$pdo = db();
if (!$pdo) {
    fwrite(STDERR, "Database unavailable\n");
    exit(1);
}

studentPortalEnsureProfileSchema($pdo);
$students = $pdo->query("SELECT id, student_id, full_name FROM users WHERE role_key = 'student'")->fetchAll();
foreach ($students as $s) {
    studentPortalEnsureProfileForUser((int) $s['id'], (string) $s['student_id'], 'student');
    echo $s['id'] . ' ' . $s['student_id'] . ' ' . $s['full_name'] . PHP_EOL;
}

$rows = $pdo->query('SELECT user_id, student_id, section, mobile, guardian FROM student_profiles ORDER BY id')->fetchAll();
foreach ($rows as $r) {
    echo json_encode($r) . PHP_EOL;
}
