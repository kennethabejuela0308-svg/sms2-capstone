<?php
declare(strict_types=1);

require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';
require_once ROOT_PATH . '/modules/crad/includes/research-services-clearance.php';

requireAuth();
header('Content-Type: application/json; charset=utf-8');

$crad = rscDb();
if (!$crad instanceof PDO) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database unavailable']);
    exit;
}
rscEnsureSchema($crad);
$role = getCurrentUserRoleKey();
$action = trim((string) ($_POST['action'] ?? $_GET['action'] ?? ''));

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        requireCsrf(isset($_POST['csrf_token']) ? (string) $_POST['csrf_token'] : null);
        $id = (int) ($_POST['id'] ?? 0);
        $row = rscFindById($crad, $id);
        if (!$row) {
            throw new InvalidArgumentException('Clearance not found.');
        }

        if ($action === 'send_to_adviser') {
            if ($role !== 'student' || !rscStudentCanAccess($crad, $row)) {
                throw new RuntimeException('Forbidden');
            }
            $result = rscSendToAdviser($crad, $row);
            echo json_encode(['ok' => !empty($result['ok']), 'error' => $result['error'] ?? null, 'clearance' => isset($result['clearance']) ? rscPublicRow($result['clearance']) : null]);
            exit;
        }

        if ($action === 'adviser_sign') {
            if ($role !== 'adviser' || !rscAdviserCanAccess($row)) {
                throw new RuntimeException('Forbidden');
            }
            $result = rscAdviserSign($crad, $row, (string) ($_POST['signature'] ?? ''), getCurrentUserName());
            echo json_encode(['ok' => !empty($result['ok']), 'error' => $result['error'] ?? null, 'clearance' => isset($result['clearance']) ? rscPublicRow($result['clearance']) : null]);
            exit;
        }

        if ($action === 'crad_receive') {
            if (!rscCanManageAsCrad()) {
                throw new RuntimeException('Forbidden');
            }
            $file = is_array($_FILES['clearance_file'] ?? null) ? $_FILES['clearance_file'] : [];
            $result = rscCradReceive($crad, $row, $file);
            echo json_encode(['ok' => !empty($result['ok']), 'error' => $result['error'] ?? null, 'clearance' => isset($result['clearance']) ? rscPublicRow($result['clearance']) : null]);
            exit;
        }

        if ($action === 'crad_sign') {
            if (!rscCanManageAsCrad()) {
                throw new RuntimeException('Forbidden');
            }
            $result = rscCradSign($crad, $row, (string) ($_POST['signature'] ?? ''), getCurrentUserName());
            echo json_encode(['ok' => !empty($result['ok']), 'error' => $result['error'] ?? null, 'clearance' => isset($result['clearance']) ? rscPublicRow($result['clearance']) : null]);
            exit;
        }

        throw new InvalidArgumentException('Unknown action.');
    }

    $payload = [
        'ok' => true,
        'server_time' => date('c'),
        'last_sync' => date('M j, Y g:i:s A'),
        'ready' => false,
        'clearance' => null,
        'rows' => [],
    ];

    if ($role === 'student') {
        $group = chapterRegisteredStudentGroup($crad);
        if ($group && rscIsChapterReady($crad, (int) $group['id'])) {
            $row = rscEnsureForReadyGroup($crad, (int) $group['id']);
            $payload['ready'] = true;
            $payload['clearance'] = $row ? rscPublicRow($row) : null;
        }
        echo json_encode($payload);
        exit;
    }

    if ($role === 'adviser') {
        $rows = rscListForAdviser($crad);
        $id = (int) ($_GET['id'] ?? 0);
        $current = $id > 0 ? rscFindById($crad, $id) : ($rows[0] ?? null);
        if ($current && !rscAdviserCanAccess($current)) {
            $current = $rows[0] ?? null;
        }
        $payload['ready'] = $rows !== [];
        $payload['clearance'] = $current ? rscPublicRow($current) : null;
        $payload['rows'] = array_map('rscPublicRow', $rows);
        echo json_encode($payload);
        exit;
    }

    if (rscCanManageAsCrad()) {
        $rows = rscListForCrad($crad);
        $id = (int) ($_GET['id'] ?? 0);
        $current = $id > 0 ? rscFindById($crad, $id) : ($rows[0] ?? null);
        $payload['ready'] = $rows !== [];
        $payload['clearance'] = $current ? rscPublicRow($current) : null;
        $payload['rows'] = array_map('rscPublicRow', $rows);
        echo json_encode($payload);
        exit;
    }

    http_response_code(403);
    echo json_encode(['ok' => false, 'error' => 'Forbidden']);
} catch (Throwable $e) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => $e->getMessage()]);
}
