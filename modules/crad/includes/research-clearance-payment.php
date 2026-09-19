<?php
declare(strict_types=1);

function rcpEnsureSchema(PDO $crad): void
{
    $crad->exec(
        "CREATE TABLE IF NOT EXISTS research_clearance_payments (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            research_group_id INT UNSIGNED NOT NULL,
            student_user_id INT UNSIGNED DEFAULT NULL,
            uploaded_file VARCHAR(255) NOT NULL DEFAULT '',
            uploaded_original VARCHAR(255) NOT NULL DEFAULT '',
            or_number VARCHAR(80) NOT NULL DEFAULT '',
            remarks VARCHAR(120) NOT NULL DEFAULT '',
            status VARCHAR(20) NOT NULL DEFAULT 'pending',
            approved_by_user_id INT UNSIGNED DEFAULT NULL,
            approved_by_name VARCHAR(160) NOT NULL DEFAULT '',
            approved_at DATETIME DEFAULT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            KEY idx_rcp_group (research_group_id),
            KEY idx_rcp_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );
}

function rcpFindByGroup(PDO $crad, int $groupId): ?array
{
    if ($groupId <= 0) {
        return null;
    }
    $stmt = $crad->prepare(
        "SELECT * FROM research_clearance_payments WHERE research_group_id = ? ORDER BY id DESC LIMIT 1"
    );
    $stmt->execute([$groupId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function rcpFindById(PDO $crad, int $id): ?array
{
    if ($id <= 0) {
        return null;
    }
    $stmt = $crad->prepare('SELECT * FROM research_clearance_payments WHERE id = ? LIMIT 1');
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function rcpIsApproved(PDO $crad, int $groupId): bool
{
    $row = rcpFindByGroup($crad, $groupId);
    return $row && (string) ($row['status'] ?? '') === 'approved';
}

function rcpUploadPublicUrl(array $row): string
{
    $file = basename(str_replace('\\', '/', trim((string) ($row['uploaded_file'] ?? ''))));
    if ($file === '' || $file === '.' || $file === '..') {
        return '';
    }
    $stamp = strtotime((string) ($row['updated_at'] ?? $row['created_at'] ?? '')) ?: time();
    return BASE_URL . '/uploads/college-payment/' . rawurlencode($file) . '?v=' . $stamp;
}

function rcpStatusLabel(string $status): string
{
    return match ($status) {
        'pending' => 'Waiting for Admin approval',
        'approved' => 'Approved',
        'rejected' => 'Returned — upload again',
        default => $status,
    };
}

function rcpPublicRow(array $row): array
{
    return [
        'id' => (int) ($row['id'] ?? 0),
        'research_group_id' => (int) ($row['research_group_id'] ?? 0),
        'status' => (string) ($row['status'] ?? ''),
        'status_label' => rcpStatusLabel((string) ($row['status'] ?? '')),
        'or_number' => (string) ($row['or_number'] ?? ''),
        'remarks' => (string) ($row['remarks'] ?? ''),
        'uploaded_original' => (string) ($row['uploaded_original'] ?? ''),
        'uploaded_url' => rcpUploadPublicUrl($row),
        'has_upload' => trim((string) ($row['uploaded_file'] ?? '')) !== '',
        'approved_by_name' => (string) ($row['approved_by_name'] ?? ''),
        'approved_at' => (string) ($row['approved_at'] ?? ''),
        'updated_at' => (string) ($row['updated_at'] ?? ''),
    ];
}

function rcpParseReferenceNumber(string $text): string
{
    $text = strtoupper(trim(preg_replace('/\s+/', ' ', $text) ?? ''));
    if ($text === '') {
        return '';
    }
    if (preg_match('/\b(HMBP[0-9]{8,})\b/', $text, $m)) {
        return $m[1];
    }
    if (preg_match('/REFERENCE\s*(NO\.?|NUMBER)\s*[:#]?\s*([A-Z0-9]{8,})/', $text, $m)) {
        return $m[2];
    }
    if (preg_match('/\b(OR-[0-9]{4,})\b/', $text, $m)) {
        return $m[1];
    }
    return '';
}

function rcpOcrImageText(string $path): string
{
    $script = ROOT_PATH . '/modules/crad/includes/win-ocr.ps1';
    if ($path === '' || !is_file($path) || !is_file($script)) {
        return '';
    }
    $cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -File '
        . escapeshellarg($script)
        . ' -ImagePath '
        . escapeshellarg($path);
    $out = [];
    $code = 0;
    @exec($cmd, $out, $code);
    return $code === 0 ? trim(implode(' ', $out)) : '';
}

function rcpExtractReferenceFromImage(string $path): string
{
    return rcpParseReferenceNumber(rcpOcrImageText($path));
}

function rcpStoreUpload(int $groupId, array $file): array
{
    $code = (int) ($file['error'] ?? UPLOAD_ERR_NO_FILE);
    if ($code !== UPLOAD_ERR_OK) {
        return ['ok' => false, 'error' => 'Choose a PNG or JPG picture of the college payment.'];
    }
    $tmp = (string) ($file['tmp_name'] ?? '');
    $name = (string) ($file['name'] ?? 'payment.png');
    if ($tmp === '' || !is_uploaded_file($tmp)) {
        return ['ok' => false, 'error' => 'Invalid upload.'];
    }
    $info = @getimagesize($tmp);
    $mime = strtolower((string) ($info['mime'] ?? ''));
    if (!in_array($mime, ['image/png', 'image/jpeg'], true)) {
        return ['ok' => false, 'error' => 'Upload a PNG or JPG picture of the college payment.'];
    }
    $ext = $mime === 'image/png' ? 'png' : 'jpg';
    $dir = ROOT_PATH . '/uploads/college-payment';
    if (!is_dir($dir) && !mkdir($dir, 0775, true) && !is_dir($dir)) {
        return ['ok' => false, 'error' => 'Could not store the college payment picture.'];
    }
    $stored = 'rcp-' . $groupId . '-' . bin2hex(random_bytes(6)) . '.' . $ext;
    $path = $dir . '/' . $stored;
    if (!move_uploaded_file($tmp, $path)) {
        return ['ok' => false, 'error' => 'Could not store the college payment picture.'];
    }
    return ['ok' => true, 'file' => $stored, 'original' => $name, 'path' => $path];
}

function rcpStudentUpload(PDO $crad, int $groupId, array $file, string $orNumber = ''): array
{
    rcpEnsureSchema($crad);
    if ($groupId <= 0) {
        return ['ok' => false, 'error' => 'No research group is registered for this student.'];
    }
    $saved = rcpStoreUpload($groupId, $file);
    if (empty($saved['ok'])) {
        return $saved;
    }
    $existing = rcpFindByGroup($crad, $groupId);
    $or = rcpExtractReferenceFromImage((string) ($saved['path'] ?? ''));
    if ($or === '') {
        $typed = strtoupper(trim($orNumber));
        $or = rcpParseReferenceNumber($typed) ?: $typed;
    }
    if ($existing && (string) ($existing['status'] ?? '') === 'approved') {
        return ['ok' => false, 'error' => 'College payment is already approved.'];
    }
    if ($existing) {
        $old = basename(str_replace('\\', '/', (string) ($existing['uploaded_file'] ?? '')));
        $crad->prepare(
            "UPDATE research_clearance_payments
             SET uploaded_file = :file,
                 uploaded_original = :original,
                 or_number = CASE WHEN :or <> '' THEN :or2 ELSE or_number END,
                 status = 'pending',
                 approved_by_user_id = NULL,
                 approved_by_name = '',
                 approved_at = NULL
             WHERE id = :id"
        )->execute([
            ':file' => (string) $saved['file'],
            ':original' => (string) $saved['original'],
            ':or' => $or,
            ':or2' => $or,
            ':id' => (int) $existing['id'],
        ]);
        if ($old !== '' && $old !== (string) $saved['file']) {
            $oldPath = ROOT_PATH . '/uploads/college-payment/' . $old;
            if (is_file($oldPath)) {
                @unlink($oldPath);
            }
        }
        $fresh = rcpFindById($crad, (int) $existing['id']);
    } else {
        $crad->prepare(
            "INSERT INTO research_clearance_payments
                (research_group_id, student_user_id, uploaded_file, uploaded_original, or_number, remarks, status)
             VALUES
                (:gid, :uid, :file, :original, :or_number, '', 'pending')"
        )->execute([
            ':gid' => $groupId,
            ':uid' => (int) ($_SESSION['user_id'] ?? 0) ?: null,
            ':file' => (string) $saved['file'],
            ':original' => (string) $saved['original'],
            ':or_number' => $or,
        ]);
        $fresh = rcpFindById($crad, (int) $crad->lastInsertId());
    }
    return ['ok' => true, 'payment' => $fresh];
}

function rcpApplyToClearance(PDO $crad, int $groupId, string $orNumber, string $remarks): void
{
    $clearance = function_exists('rscFindByGroup') ? rscFindByGroup($crad, $groupId) : null;
    if (!$clearance) {
        return;
    }
    $members = json_decode((string) ($clearance['members_json'] ?? ''), true) ?: [];
    if (is_array($members)) {
        foreach ($members as &$member) {
            if (is_array($member)) {
                $member['or_number'] = $orNumber;
            }
        }
        unset($member);
    }
    $crad->prepare(
        "UPDATE research_services_clearances
         SET or_number = :or_number,
             members_json = :members
         WHERE id = :id"
    )->execute([
        ':or_number' => $orNumber,
        ':members' => json_encode($members, JSON_UNESCAPED_UNICODE),
        ':id' => (int) $clearance['id'],
    ]);
}

function rcpAdminApprove(PDO $crad, array $payment, string $orNumber, string $remarks): array
{
    $or = trim($orNumber) !== '' ? trim($orNumber) : trim((string) ($payment['or_number'] ?? ''));
    $note = trim($remarks) !== '' ? trim($remarks) : 'HMA';
    if ($or === '') {
        return ['ok' => false, 'error' => 'Enter the O.R. number from the college payment.'];
    }
    $crad->prepare(
        "UPDATE research_clearance_payments
         SET status = 'approved',
             or_number = :or_number,
             remarks = :remarks,
             approved_by_user_id = :uid,
             approved_by_name = :name,
             approved_at = NOW()
         WHERE id = :id"
    )->execute([
        ':or_number' => $or,
        ':remarks' => $note,
        ':uid' => (int) ($_SESSION['user_id'] ?? 0) ?: null,
        ':name' => (string) (function_exists('getCurrentUserName') ? getCurrentUserName() : ''),
        ':id' => (int) $payment['id'],
    ]);
    rcpApplyToClearance($crad, (int) $payment['research_group_id'], $or, $note);
    $fresh = rcpFindById($crad, (int) $payment['id']);
    if (function_exists('rscNotify') && function_exists('rscStudentRecipients')) {
        $clearance = [
            'id' => (int) ($payment['id'] ?? 0),
            'research_group_id' => (int) ($payment['research_group_id'] ?? 0),
        ];
        foreach (rscStudentRecipients($crad, $clearance) as $recipient) {
            rscNotify(
                $crad,
                'clearance-payment:' . (int) $payment['id'],
                0,
                $recipient,
                'payment_approved',
                'College payment approved',
                'Your college payment was approved. The O.R. number and remarks are now on your Research Services Clearance form.',
                function_exists('rscStudentUrl') ? rscStudentUrl() : '#'
            );
        }
    }
    return ['ok' => true, 'payment' => $fresh];
}

function rcpAdminReject(PDO $crad, array $payment): array
{
    $crad->prepare(
        "UPDATE research_clearance_payments
         SET status = 'rejected',
             approved_by_user_id = :uid,
             approved_by_name = :name,
             approved_at = NULL
         WHERE id = :id"
    )->execute([
        ':uid' => (int) ($_SESSION['user_id'] ?? 0) ?: null,
        ':name' => (string) (function_exists('getCurrentUserName') ? getCurrentUserName() : ''),
        ':id' => (int) $payment['id'],
    ]);
    return ['ok' => true, 'payment' => rcpFindById($crad, (int) $payment['id'])];
}

function rcpListForAdmin(PDO $crad): array
{
    rcpEnsureSchema($crad);
    return $crad->query(
        "SELECT p.*,
                rg.group_number,
                rg.research_title,
                rg.group_name
         FROM research_clearance_payments p
         LEFT JOIN research_groups rg ON rg.id = p.research_group_id
         ORDER BY FIELD(p.status, 'pending', 'rejected', 'approved'), p.updated_at DESC"
    )->fetchAll(PDO::FETCH_ASSOC) ?: [];
}

function rcpCanApprove(): bool
{
    return function_exists('smsIsGrantedAdminRole') && smsIsGrantedAdminRole(getCurrentUserRoleKey());
}
