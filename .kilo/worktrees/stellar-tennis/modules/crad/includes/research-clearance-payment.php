<?php
declare(strict_types=1);

function rcpNormalizeStage(string $stage): string
{
    return strtolower(trim($stage)) === 'research_2' ? 'research_2' : 'research_1';
}

function rcpStageLabel(string $stage): string
{
    return rcpNormalizeStage($stage) === 'research_2' ? 'Research 2' : 'Research 1';
}

function rcpStageList(): array
{
    return [
        ['key' => 'research_1', 'label' => 'Research 1'],
        ['key' => 'research_2', 'label' => 'Research 2'],
    ];
}

function rcpEnsureSchema(PDO $crad): void
{
    // Schema is deployment-owned by modules/crad/database/crad_db.sql.
    // Do not run CREATE/ALTER TABLE during a web request.
    return;

    $crad->exec(
        "CREATE TABLE IF NOT EXISTS `crad_research_clearance_payments` (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            research_group_id INT UNSIGNED NOT NULL,
            research_stage VARCHAR(20) NOT NULL DEFAULT 'research_1',
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
            UNIQUE KEY uniq_rcp_group_stage (research_group_id, research_stage),
            KEY idx_rcp_group (research_group_id),
            KEY idx_rcp_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );

    try {
        if (!$crad->query("SHOW COLUMNS FROM `crad_research_clearance_payments` LIKE 'research_stage'")->fetch()) {
            $crad->exec(
                "ALTER TABLE `crad_research_clearance_payments`
                 ADD COLUMN research_stage VARCHAR(20) NOT NULL DEFAULT 'research_1' AFTER research_group_id"
            );
        }
        $crad->exec("UPDATE `crad_research_clearance_payments` SET research_stage = 'research_1' WHERE TRIM(COALESCE(research_stage, '')) = ''");
        $indexes = $crad->query("SHOW INDEX FROM `crad_research_clearance_payments`")->fetchAll(PDO::FETCH_ASSOC) ?: [];
        $hasStageUnique = false;
        foreach ($indexes as $idx) {
            if (($idx['Key_name'] ?? '') === 'uniq_rcp_group_stage') {
                $hasStageUnique = true;
                break;
            }
        }
        if (!$hasStageUnique) {
            try {
                $crad->exec('ALTER TABLE `crad_research_clearance_payments` DROP INDEX uniq_rcp_group');
            } catch (Throwable $e) {
                // optional legacy index
            }
            $crad->exec(
                'ALTER TABLE `crad_research_clearance_payments`
                 ADD UNIQUE KEY uniq_rcp_group_stage (research_group_id, research_stage)'
            );
        }
    } catch (Throwable $e) {
        error_log('rcp schema stage: ' . $e->getMessage());
    }
}

function rcpFindByGroup(PDO $crad, int $groupId, string $stage = 'research_1'): ?array
{
    if ($groupId <= 0) {
        return null;
    }
    $stage = rcpNormalizeStage($stage);
    $stmt = $crad->prepare(
        "SELECT * FROM `crad_research_clearance_payments`
         WHERE research_group_id = ? AND research_stage = ?
         ORDER BY id DESC LIMIT 1"
    );
    $stmt->execute([$groupId, $stage]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function rcpFindById(PDO $crad, int $id): ?array
{
    if ($id <= 0) {
        return null;
    }
    $stmt = $crad->prepare('SELECT * FROM `crad_research_clearance_payments` WHERE id = ? LIMIT 1');
    $stmt->execute([$id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function rcpIsApproved(PDO $crad, int $groupId, string $stage = 'research_1'): bool
{
    $row = rcpFindByGroup($crad, $groupId, $stage);
    return $row && (string) ($row['status'] ?? '') === 'approved';
}

function rcpUploadPublicUrl(array $row): string
{
    $file = basename(str_replace('\\', '/', trim((string) ($row['uploaded_file'] ?? ''))));
    if ($file === '' || $file === '.' || $file === '..') {
        return '';
    }
    $stamp = strtotime((string) ($row['updated_at'] ?? $row['created_at'] ?? '')) ?: time();
    return BASE_URL . '/modules/crad/api/clearance-payment-file.php?id=' . (int) ($row['id'] ?? 0) . '&v=' . $stamp;
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
    $stage = rcpNormalizeStage((string) ($row['research_stage'] ?? 'research_1'));
    return [
        'id' => (int) ($row['id'] ?? 0),
        'research_group_id' => (int) ($row['research_group_id'] ?? 0),
        'research_stage' => $stage,
        'stage_label' => rcpStageLabel($stage),
        'status' => (string) ($row['status'] ?? ''),
        'status_label' => rcpStatusLabel((string) ($row['status'] ?? '')),
        'or_number' => (string) ($row['or_number'] ?? ''),
        'receipt_student_name' => (string) ($row['receipt_student_name'] ?? ''),
        'remarks' => (string) ($row['remarks'] ?? ''),
        'uploaded_original' => (string) ($row['uploaded_original'] ?? ''),
        'uploaded_url' => rcpUploadPublicUrl($row),
        'has_upload' => trim((string) ($row['uploaded_file'] ?? '')) !== '',
        'approved_by_name' => (string) ($row['approved_by_name'] ?? ''),
        'approved_at' => (string) ($row['approved_at'] ?? ''),
        'updated_at' => (string) ($row['updated_at'] ?? ''),
        'can_upload' => !empty($row['can_upload']),
        'locked_reason' => (string) ($row['locked_reason'] ?? ''),
    ];
}

/** @return array{reference_number: string, student_name: string} */
function rcpParseReceiptDetails(string $source): array
{
    $text = trim(preg_replace('/\s+/', ' ', trim($source)) ?? '');
    $details = ['reference_number' => '', 'student_name' => ''];
    if ($text === '') return $details;

    // HelloMoney uses "Reference No." instead of "O.R. No.". Requiring one
    // of these labels prevents dates, amounts, and student IDs from matching.
    $normalized = strtoupper(str_ireplace(['0R NO', '0R NUMBER'], ['OR NO', 'OR NUMBER'], $text));
    $label = '(?:O\\s*R|OFFICIAL\\s+RECEIPT|RECEIPT|REFERENCE|TRANSACTION\\s+(?:REFERENCE|NO\\.?|NUMBER|ID))\\s*(?:NO\\.?|NUMBER|#|ID)?';
    if (preg_match('/' . $label . '\\s*[:#-]?\\s*([A-Z0-9][A-Z0-9\\-\\/]{3,79})\\b/i', $normalized, $m)) {
        $candidate = trim($m[1]);
        if (!preg_match('/^\d{1,4}[-\/]\d{1,2}[-\/]\d{1,4}$/', $candidate)
            && !preg_match('/^(?:PHP|USD|\$)/i', $candidate)) {
            $details['reference_number'] = $candidate;
        }
    }
    if ($details['reference_number'] === '' && preg_match('/\b(OR[-\/]\d{4,})\b/i', $normalized, $m)) {
        $details['reference_number'] = strtoupper($m[1]);
    }

    // Receipts commonly place the name on the line after "Student Name".
    $lines = preg_split('/\R/', $source) ?: [];
    foreach ($lines as $index => $line) {
        if (!preg_match('/^\s*STUDENT\s*NAME\s*[:\-]?\s*(.*)$/i', trim($line), $m)) continue;
        $name = trim((string) $m[1]);
        if ($name === '' && isset($lines[$index + 1])) $name = trim((string) $lines[$index + 1]);
        if ($name !== '') {
            $details['student_name'] = $name;
            break;
        }
    }
    if ($details['student_name'] === '' && preg_match('/\bSTUDENT\s*NAME\s*[:\-]?\s*(.+?)(?=\s+(?:STUDENT\s*(?:NUMBER|NO\.?|ID)|PAYMENT\s+FOR|BILLER|AMOUNT|REMARKS)\b|$)/i', $text, $m)) {
        $details['student_name'] = trim($m[1]);
    }
    $details['student_name'] = trim(preg_replace('/[^\p{L} .\'\-]/u', '', $details['student_name']) ?? '');
    if (!preg_match('/\p{L}/u', $details['student_name'])) $details['student_name'] = '';
    return $details;
}

function rcpParseReferenceNumber(string $text): string
{
    return rcpParseReceiptDetails($text)['reference_number'];
}

function rcpOcrImageText(string $path): string
{
    $script = ROOT_PATH . '/modules/crad/includes/win-ocr.ps1';
    if ($path === '' || !is_file($path) || !is_file($script) || !function_exists('exec')) {
        return '';
    }
    $real = realpath($path) ?: $path;
    $tmpDir = sys_get_temp_dir();
    $token = bin2hex(random_bytes(4));
    $outFile = $tmpDir . DIRECTORY_SEPARATOR . 'rcp-ocr-' . $token . '.txt';
    $jobFile = $tmpDir . DIRECTORY_SEPARATOR . 'rcp-ocr-job-' . $token . '.json';
    file_put_contents($jobFile, json_encode(['image' => $real, 'out' => $outFile], JSON_UNESCAPED_SLASHES));
    $out = [];
    $code = 0;
    $text = '';
    if (PHP_OS_FAMILY === 'Windows') {
        $ps = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe';
        if (!is_file($ps)) {
            $ps = 'powershell';
        }
        $cmd = $ps
            . ' -NoProfile -ExecutionPolicy Bypass -File '
            . escapeshellarg($script)
            . ' -JobFile '
            . escapeshellarg($jobFile);
        @exec($cmd, $out, $code);
        $text = is_file($outFile) ? trim((string) @file_get_contents($outFile)) : '';
    } else {
        // Linux production hosts do not provide Windows.Media.Ocr. Reuse the
        // same OCR step through the host's installed Tesseract executable.
        @exec('command -v tesseract 2>/dev/null', $out, $code);
        if ($code === 0 && !empty($out[0])) {
            $out = [];
            @exec(escapeshellcmd(trim((string) $out[0])) . ' ' . escapeshellarg($real) . ' stdout -l eng 2>/dev/null', $out, $code);
            $text = trim(implode("\n", $out));
        }
    }
    @unlink($outFile);
    @unlink($jobFile);
    if ($text === '') {
        $text = trim(implode(' ', $out));
    }
    return $text;
}

function rcpExtractReferenceFromImage(string $path): string
{
    return rcpExtractReceiptDetailsFromImage($path)['reference_number'];
}

/** @return array{reference_number: string, student_name: string} */
function rcpExtractReceiptDetailsFromImage(string $path): array
{
    return rcpParseReceiptDetails(rcpOcrImageText($path));
}

function rcpPaymentImagePath(string $file): ?string
{
    $normalized = str_replace('\\', '/', trim($file));
    $file = basename($normalized);
    if ($file === '' || $file === '.' || $file === '..') {
        return null;
    }
    $candidates = [
        ROOT_PATH . '/storage/uploads/college-payment/' . $file,
        ROOT_PATH . '/uploads/college-payment/' . $file,
    ];
    if (preg_match('#(?:^|/)storage/uploads/college-payment/([^/]+)$#i', $normalized, $match)) {
        $candidates[] = ROOT_PATH . '/storage/uploads/college-payment/' . basename($match[1]);
    }
    if (preg_match('#(?:^|/)uploads/college-payment/([^/]+)$#i', $normalized, $match)) {
        $candidates[] = ROOT_PATH . '/uploads/college-payment/' . basename($match[1]);
    }
    foreach ($candidates as $candidate) {
        if (is_file($candidate)) {
            return $candidate;
        }
    }
    return null;
}

/** @return array{data: string, mime: string}|null */
function rcpPersistentImageData(array $row): ?array
{
    $data = $row['uploaded_blob'] ?? null;
    $mime = strtolower(trim((string) ($row['uploaded_mime'] ?? '')));
    if (!is_string($data) || $data === '' || !in_array($mime, ['image/png', 'image/jpeg'], true)) {
        return null;
    }
    return ['data' => $data, 'mime' => $mime];
}

function rcpEnsureOrFromImage(PDO $crad, array $row): array
{
    $or = trim((string) ($row['or_number'] ?? ''));
    $receiptStudentName = trim((string) ($row['receipt_student_name'] ?? ''));
    if ($or !== '' && !preg_match('/^OR-\d+$/i', $or) && $receiptStudentName !== '') {
        return $row;
    }
    $file = basename(str_replace('\\', '/', (string) ($row['uploaded_file'] ?? '')));
    if ($file === '') {
        return $row;
    }
    $lock = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'rcp-or-lock-' . (int) ($row['id'] ?? 0);
    if (is_file($lock) && (time() - (int) filemtime($lock)) < 30) {
        return $row;
    }
    @touch($lock);
    $imagePath = rcpPaymentImagePath($file);
    $details = $imagePath ? rcpExtractReceiptDetailsFromImage($imagePath) : ['reference_number' => '', 'student_name' => ''];
    $extracted = $details['reference_number'];
    if ($extracted !== '' && strcasecmp($extracted, $or) !== 0) {
        $crad->prepare('UPDATE `crad_research_clearance_payments` SET or_number = ? WHERE id = ?')
            ->execute([$extracted, (int) ($row['id'] ?? 0)]);
        $row['or_number'] = $extracted;
    }
    // This is shown to the approver for validation; it never changes the
    // authenticated student or the assigned research group.
    $row['receipt_student_name'] = $details['student_name'];
    return $row;
}

function rcpIsFinalManuscriptApproved(PDO $crad, int $groupId): bool
{
    if ($groupId <= 0) {
        return false;
    }
    if (function_exists('fpIsManuscriptApproved')) {
        return fpIsManuscriptApproved($crad, $groupId);
    }
    try {
        $stmt = $crad->prepare(
            "SELECT ms.status AS ms_status, me.result AS me_result
             FROM `crad_manuscript_submissions` ms
             LEFT JOIN `crad_manuscript_evaluations` me ON me.id = (
                SELECT me2.id FROM `crad_manuscript_evaluations` me2
                WHERE me2.submission_id = ms.id
                ORDER BY me2.id DESC
                LIMIT 1
             )
             WHERE ms.research_group_id = ?
             ORDER BY ms.version_number DESC, ms.id DESC
             LIMIT 1"
        );
        $stmt->execute([$groupId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        return (string) ($row['ms_status'] ?? '') === 'Approved'
            && strtoupper(trim((string) ($row['me_result'] ?? ''))) === 'APPROVED';
    } catch (Throwable $e) {
        return false;
    }
}

function rcpCanUploadStage(PDO $crad, int $groupId, string $stage): array
{
    $stage = rcpNormalizeStage($stage);
    if ($stage === 'research_1') {
        return ['ok' => true, 'reason' => ''];
    }
    if (!function_exists('rscClearanceDoneExists') || !rscClearanceDoneExists($crad, $groupId, 'research_1')) {
        return [
            'ok' => false,
            'reason' => 'Finish Research 1 clearance (Pre-Oral) before uploading Research 2 collage payment.',
        ];
    }
    if (!rcpIsFinalManuscriptApproved($crad, $groupId)) {
        return [
            'ok' => false,
            'reason' => 'Final Manuscript must be approved before uploading Research 2 collage payment.',
        ];
    }
    return ['ok' => true, 'reason' => ''];
}

function rcpStoreUpload(int $groupId, array $file): array
{
    $code = (int) ($file['error'] ?? UPLOAD_ERR_NO_FILE);
    if ($code !== UPLOAD_ERR_OK) {
        return ['ok' => false, 'error' => 'Choose a PNG or JPG picture of the collage payment.'];
    }
    $tmp = (string) ($file['tmp_name'] ?? '');
    $name = (string) ($file['name'] ?? 'payment.png');
    if ($tmp === '' || !is_uploaded_file($tmp)) {
        return ['ok' => false, 'error' => 'Invalid upload.'];
    }
    $info = @getimagesize($tmp);
    $mime = strtolower((string) ($info['mime'] ?? ''));
    if (!in_array($mime, ['image/png', 'image/jpeg'], true)) {
        return ['ok' => false, 'error' => 'Upload a PNG or JPG picture of the collage payment.'];
    }
    $ext = $mime === 'image/png' ? 'png' : 'jpg';
    $data = @file_get_contents($tmp);
    if (!is_string($data) || $data === '') {
        return ['ok' => false, 'error' => 'The payment image could not be read.'];
    }
    $stored = 'rcp-' . $groupId . '-' . bin2hex(random_bytes(6)) . '.' . $ext;
    return ['ok' => true, 'file' => $stored, 'original' => $name, 'path' => $tmp, 'data' => $data, 'mime' => $mime, 'size' => strlen($data)];
}

function rcpStudentUpload(PDO $crad, int $groupId, array $file, string $orNumber = '', string $stage = 'research_1'): array
{
    rcpEnsureSchema($crad);
    $stage = rcpNormalizeStage($stage);
    if ($groupId <= 0) {
        return ['ok' => false, 'error' => 'No research group is registered for this student.'];
    }
    $gate = rcpCanUploadStage($crad, $groupId, $stage);
    if (empty($gate['ok'])) {
        return ['ok' => false, 'error' => (string) ($gate['reason'] ?? 'This payment stage is locked.')];
    }
    $saved = rcpStoreUpload($groupId, $file);
    if (empty($saved['ok'])) {
        return $saved;
    }
    $existing = rcpFindByGroup($crad, $groupId, $stage);
    $details = rcpExtractReceiptDetailsFromImage((string) ($saved['path'] ?? ''));
    $or = $details['reference_number'];
    if ($or === '') {
        $typed = strtoupper(trim($orNumber));
        $or = rcpParseReferenceNumber($typed) ?: $typed;
    }
    if ($existing && (string) ($existing['status'] ?? '') === 'approved') {
        return ['ok' => false, 'error' => rcpStageLabel($stage) . ' collage payment is already approved.'];
    }
    if ($existing) {
        $old = basename(str_replace('\\', '/', (string) ($existing['uploaded_file'] ?? '')));
        $crad->prepare(
            "UPDATE `crad_research_clearance_payments`
             SET uploaded_file = :file,
                 uploaded_blob = :blob,
                 uploaded_mime = :mime,
                 uploaded_size = :size,
                 uploaded_original = :original,
                 or_number = :or_number,
                 research_stage = :stage,
                 status = 'pending',
                 approved_by_user_id = NULL,
                 approved_by_name = '',
                 approved_at = NULL
             WHERE id = :id"
        )->execute([
            ':file' => (string) $saved['file'],
            ':blob' => (string) $saved['data'],
            ':mime' => (string) $saved['mime'],
            ':size' => (int) $saved['size'],
            ':original' => (string) $saved['original'],
            ':or_number' => $or,
            ':stage' => $stage,
            ':id' => (int) $existing['id'],
        ]);
        if ($old !== '' && $old !== (string) $saved['file']) {
            foreach ([
                ROOT_PATH . '/storage/uploads/college-payment/' . $old,
                ROOT_PATH . '/uploads/college-payment/' . $old,
            ] as $oldPath) {
                if (is_file($oldPath)) {
                    @unlink($oldPath);
                }
            }
        }
        $fresh = rcpFindById($crad, (int) $existing['id']);
    } else {
        $crad->prepare(
            "INSERT INTO `crad_research_clearance_payments`
                (research_group_id, research_stage, student_user_id, uploaded_file, uploaded_blob, uploaded_mime, uploaded_size, uploaded_original, or_number, remarks, status)
             VALUES
                (:gid, :stage, :uid, :file, :blob, :mime, :size, :original, :or_number, '', 'pending')"
        )->execute([
            ':gid' => $groupId,
            ':stage' => $stage,
            ':uid' => (int) ($_SESSION['user_id'] ?? 0) ?: null,
            ':file' => (string) $saved['file'],
            ':blob' => (string) $saved['data'],
            ':mime' => (string) $saved['mime'],
            ':size' => (int) $saved['size'],
            ':original' => (string) $saved['original'],
            ':or_number' => $or,
        ]);
        $fresh = rcpFindById($crad, (int) $crad->lastInsertId());
    }
    if ($fresh) {
        // Send the OCR result back immediately after upload. On later page
        // loads it is safely re-read from the original payment image.
        $fresh['receipt_student_name'] = $details['student_name'];
    }
    if (function_exists('logActivity')) {
        logActivity(
            'create',
            'Submitted ' . rcpStageLabel($stage) . ' collage payment for research group #' . $groupId,
            'crad'
        );
    }
    return ['ok' => true, 'payment' => $fresh];
}

function rcpStudentUpdateOr(PDO $crad, int $groupId, string $stage, string $orNumber): array
{
    $row = rcpFindByGroup($crad, $groupId, $stage);
    $orNumber = trim($orNumber);
    if (!$row || (string) ($row['status'] ?? '') === 'approved') {
        return ['ok' => false, 'error' => 'This payment can no longer be updated.'];
    }
    if ($orNumber === '' || strlen($orNumber) > 80) {
        return ['ok' => false, 'error' => 'Enter the O.R. number exactly as printed on the receipt.'];
    }
    $crad->prepare('UPDATE `crad_research_clearance_payments` SET or_number = ? WHERE id = ?')
        ->execute([$orNumber, (int) $row['id']]);
    if (function_exists('logActivity')) {
        logActivity(
            'update',
            'Updated ' . rcpStageLabel($stage) . ' payment reference number for research group #' . $groupId,
            'crad'
        );
    }
    return ['ok' => true, 'payment' => rcpFindById($crad, (int) $row['id'])];
}

function rcpApplyToClearance(PDO $crad, int $groupId, string $orNumber, string $remarks, string $stage = 'research_1'): void
{
    $stage = rcpNormalizeStage($stage);
    $clearance = function_exists('rscFindByGroup') ? rscFindByGroup($crad, $groupId, $stage) : null;
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
        "UPDATE `crad_research_services_clearances`
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
    $stage = rcpNormalizeStage((string) ($payment['research_stage'] ?? 'research_1'));
    if ($or === '') {
        return ['ok' => false, 'error' => 'Enter the O.R. number from the college payment.'];
    }
    $crad->prepare(
        "UPDATE `crad_research_clearance_payments`
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
    rcpApplyToClearance($crad, (int) $payment['research_group_id'], $or, $note, $stage);
    if (function_exists('rscEnsureForReadyGroup')) {
        rscEnsureForReadyGroup($crad, (int) $payment['research_group_id'], $stage);
        rcpApplyToClearance($crad, (int) $payment['research_group_id'], $or, $note, $stage);
    }
    $fresh = rcpFindById($crad, (int) $payment['id']);
    if (function_exists('logActivity')) {
        logActivity(
            'update',
            'Approved ' . rcpStageLabel($stage) . ' collage payment for research group #'
                . (int) $payment['research_group_id'] . ' (reference ' . $or . ')',
            'crad'
        );
    }
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
                rcpStageLabel($stage) . ' collage payment approved',
                'Your ' . rcpStageLabel($stage) . ' collage payment was approved. The O.R. number and remarks are now on that Research Services Clearance form.',
                function_exists('rscStudentUrl') ? rscStudentUrl() : '#'
            );
        }
    }
    return ['ok' => true, 'payment' => $fresh];
}

function rcpAdminReject(PDO $crad, array $payment): array
{
    $crad->prepare(
        "UPDATE `crad_research_clearance_payments`
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
    if (function_exists('logActivity')) {
        logActivity(
            'update',
            'Returned ' . rcpStageLabel((string) ($payment['research_stage'] ?? 'research_1'))
                . ' collage payment for research group #' . (int) $payment['research_group_id'],
            'crad'
        );
    }
    return ['ok' => true, 'payment' => rcpFindById($crad, (int) $payment['id'])];
}

function rcpCanApprove(): bool
{
    return function_exists('smsIsGrantedAdminRole') && smsIsGrantedAdminRole(getCurrentUserRoleKey());
}

/**
 * Remove collage-payment rows whose research group no longer exists.
 * Also deletes stored payment images. Safe to call on every live poll.
 */
function rcpPurgeDisconnectedPayments(PDO $crad): int
{
    rcpEnsureSchema($crad);
    $requiredTables = ['crad_research_clearance_payments', 'crad_research_groups'];
    foreach ($requiredTables as $table) {
        try {
            $tableCheck = $crad->prepare('SHOW TABLES LIKE ?');
            $tableCheck->execute([$table]);
            if (!$tableCheck->fetchColumn()) {
                error_log('RCP cleanup skipped; missing table: ' . $table);
                return 0;
            }
        } catch (Throwable $e) {
            error_log('RCP cleanup table check failed: ' . $e->getMessage());
            return 0;
        }
    }
    $orphans = $crad->query(
        "SELECT p.id, p.uploaded_file
         FROM `crad_research_clearance_payments` p
         LEFT JOIN `crad_research_groups` rg ON rg.id = p.research_group_id
         WHERE p.research_group_id IS NULL
            OR p.research_group_id < 1
            OR rg.id IS NULL"
    )->fetchAll(PDO::FETCH_ASSOC) ?: [];

    if ($orphans === []) {
        return 0;
    }

    $ids = [];
    foreach ($orphans as $row) {
        $ids[] = (int) ($row['id'] ?? 0);
        $file = basename(str_replace('\\', '/', (string) ($row['uploaded_file'] ?? '')));
        if ($file !== '' && $file !== '.' && $file !== '..') {
            $path = rcpPaymentImagePath($file);
            if ($path !== null) {
                @unlink($path);
            }
        }
    }
    $ids = array_values(array_filter($ids, static fn(int $id): bool => $id > 0));
    if ($ids === []) {
        return 0;
    }
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $crad->prepare("DELETE FROM `crad_research_clearance_payments` WHERE id IN ($placeholders)");
    $stmt->execute($ids);

    return $stmt->rowCount();
}

function rcpListForAdmin(PDO $crad): array
{
    rcpEnsureSchema($crad);
    rcpPurgeDisconnectedPayments($crad);

    return $crad->query(
        "SELECT p.*,
                rg.group_number,
                rg.research_title,
                rg.group_name
         FROM `crad_research_clearance_payments` p
         INNER JOIN `crad_research_groups` rg ON rg.id = p.research_group_id
         ORDER BY FIELD(p.status, 'pending', 'rejected', 'approved'), p.updated_at DESC"
    )->fetchAll(PDO::FETCH_ASSOC) ?: [];
}

function rcpStudentInbox(PDO $crad, int $groupId): array
{
    rcpEnsureSchema($crad);
    $rows = [];
    foreach (rcpStageList() as $item) {
        $stage = $item['key'];
        $row = rcpFindByGroup($crad, $groupId, $stage);
        $gate = rcpCanUploadStage($crad, $groupId, $stage);
        if (!$row) {
            $row = [
                'id' => 0,
                'research_group_id' => $groupId,
                'research_stage' => $stage,
                'status' => '',
                'or_number' => '',
                'remarks' => '',
                'uploaded_file' => '',
                'uploaded_original' => '',
                'updated_at' => '',
            ];
        }
        $row['can_upload'] = !empty($gate['ok']) && (string) ($row['status'] ?? '') !== 'approved';
        $row['locked_reason'] = empty($gate['ok']) ? (string) ($gate['reason'] ?? '') : '';
        if (!empty($row['id']) && !empty($row['uploaded_file'])) {
            $row = rcpEnsureOrFromImage($crad, $row);
        }
        $public = rcpPublicRow($row);
        if ($public['locked_reason'] !== '' && $public['status'] === '') {
            $public['status_label'] = 'Locked';
        }
        $rows[] = $public;
    }
    return $rows;
}
