<?php
/**
 * SMS 2 – Save / update / archive / purge user (admin API)
 * Prefer set_status (archive/restore). Hard delete only for already-archived accounts.
 */
declare(strict_types=1);

require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';

header('Content-Type: application/json');

if (!isAuthenticated() || !userCanAccessModule('user-management')) {
    http_response_code(403);
    echo json_encode(['ok' => false, 'error' => 'Forbidden']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'error' => 'Method not allowed']);
    exit;
}

$raw = file_get_contents('php://input');
$data = json_decode($raw ?: '', true);
if (!is_array($data)) {
    // Fallback to form POST
    $data = $_POST;
}

requireCsrf(isset($data['csrf_token']) ? (string) $data['csrf_token'] : null);

$pdo = db();
if (!$pdo) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database unavailable']);
    exit;
}

$action = (string) ($data['action'] ?? 'save');
$validRoles = ['superadmin', 'admission', 'registrar', 'finance', 'hr', 'adviser', 'research_director', 'it_office', 'osa', 'qa', 'crad', 'crad_officer', 'research_coordinator', 'research_grant', 'student'];
$validStatus = ['active', 'inactive', 'locked', 'suspended'];

try {
    if ($action === 'set_status') {
        $id = (int) ($data['user_id'] ?? 0);
        $status = trim((string) ($data['status'] ?? ''));
        if ($id <= 0 || !in_array($status, $validStatus, true)) {
            throw new InvalidArgumentException('Invalid user or status');
        }
        if ($id === getCurrentUserId() && $status !== 'active') {
            throw new InvalidArgumentException('You cannot archive your own account');
        }
        $stmt = $pdo->prepare('UPDATE users SET status = ? WHERE id = ?');
        $stmt->execute([$status, $id]);
        if ($stmt->rowCount() < 1) {
            // still ok if status unchanged
            $check = $pdo->prepare('SELECT id FROM users WHERE id = ? LIMIT 1');
            $check->execute([$id]);
            if (!$check->fetch()) {
                throw new InvalidArgumentException('User not found');
            }
        }
        $label = $status === 'active' ? 'Restored' : 'Archived';
        logActivity('update', $label . ' user #' . $id . ' (status=' . $status . ')', 'user-management');
        echo json_encode(['ok' => true, 'status' => $status]);
        exit;
    }

    if ($action === 'delete') {
        $id = (int) ($data['user_id'] ?? 0);
        if ($id <= 0) {
            throw new InvalidArgumentException('Invalid user');
        }
        if ($id === getCurrentUserId()) {
            throw new InvalidArgumentException('You cannot delete your own account');
        }
        // Permanent delete only from archive (inactive / locked / suspended)
        $stmt = $pdo->prepare('SELECT status FROM users WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if (!$row) {
            throw new InvalidArgumentException('User not found');
        }
        $cur = (string) ($row['status'] ?? '');
        if (!in_array($cur, ['inactive', 'locked', 'suspended'], true)) {
            throw new InvalidArgumentException('Archive the user first. Permanent delete is only allowed for archived accounts.');
        }
        $pdo->prepare('DELETE FROM users WHERE id = ?')->execute([$id]);
        logActivity('delete', 'Permanently deleted archived user #' . $id, 'user-management');
        echo json_encode(['ok' => true]);
        exit;
    }

    if ($action === 'reset_password') {
        $id = (int) ($data['user_id'] ?? 0);
        $temp = (string) ($data['password'] ?? '');
        if ($id <= 0 || strlen($temp) < (int) smsSetting('min_password_length', '8')) {
            throw new InvalidArgumentException('Invalid user or password too short');
        }
        if (!smsSetUserPassword($id, $temp, true)) {
            throw new RuntimeException('Reset failed');
        }
        logActivity('password_reset', 'Admin reset password for user #' . $id, 'user-management');
        echo json_encode(['ok' => true]);
        exit;
    }

    // save (create / update)
    $id = (int) ($data['user_id'] ?? 0);
    $fullName = trim((string) ($data['full_name'] ?? ''));
    $username = strtolower(trim((string) ($data['username'] ?? '')));
    $email = strtolower(trim((string) ($data['email'] ?? '')));
    $role = smsNormalizeRoleKey(trim((string) ($data['role'] ?? '')));
    $status = trim((string) ($data['status'] ?? 'active'));
    $password = (string) ($data['password'] ?? '');
    $notes = trim((string) ($data['notes'] ?? ''));
    $studentId = null;

    if ($fullName === '' || $username === '' || $email === '' || !in_array($role, $validRoles, true)) {
        throw new InvalidArgumentException('Missing or invalid fields');
    }
    if (!in_array($status, $validStatus, true)) {
        $status = 'active';
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new InvalidArgumentException('Invalid email');
    }

    if ($role === 'student' && preg_match('/^s\d+$/i', $username)) {
        $studentId = strtoupper($username);
    }

    if ($id > 0) {
        if ($password !== '') {
            $min = (int) smsSetting('min_password_length', '8');
            if (strlen($password) < $min) {
                throw new InvalidArgumentException("Password must be at least {$min} characters");
            }
            $pdo->prepare(
                'UPDATE users SET full_name=?, username=?, email=?, role_key=?, status=?, notes=?, student_id=?,
                 password_hash=?, password_changed_at=NOW(), must_change_password=0
                 WHERE id=?'
            )->execute([
                $fullName, $username, $email, $role, $status, $notes ?: null, $studentId,
                password_hash($password, PASSWORD_DEFAULT), $id,
            ]);
        } else {
            $pdo->prepare(
                'UPDATE users SET full_name=?, username=?, email=?, role_key=?, status=?, notes=?, student_id=?
                 WHERE id=?'
            )->execute([
                $fullName, $username, $email, $role, $status, $notes ?: null, $studentId, $id,
            ]);
        }
        logActivity('update', 'Updated user ' . $username, 'user-management');
        echo json_encode(['ok' => true, 'updated' => true]);
        exit;
    }

    $min = (int) smsSetting('min_password_length', '8');
    if (strlen($password) < $min) {
        throw new InvalidArgumentException("Password must be at least {$min} characters");
    }

    $pdo->prepare(
        'INSERT INTO users (username, email, password_hash, full_name, role_key, student_id, status, notes, password_changed_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())'
    )->execute([
        $username,
        $email,
        password_hash($password, PASSWORD_DEFAULT),
        $fullName,
        $role,
        $studentId,
        $status,
        $notes !== '' ? $notes : null,
    ]);

    logActivity('create', 'Created user ' . $username, 'user-management');
    echo json_encode(['ok' => true, 'created' => true, 'id' => (int) $pdo->lastInsertId()]);
} catch (PDOException $e) {
    http_response_code(400);
    $msg = 'Could not save user';
    if (str_contains($e->getMessage(), 'Duplicate')) {
        $msg = 'Username or email already exists';
    }
    echo json_encode(['ok' => false, 'error' => $msg]);
} catch (Throwable $e) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => $e->getMessage()]);
}
