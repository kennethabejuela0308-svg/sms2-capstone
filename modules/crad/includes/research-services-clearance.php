<?php
/**
 * Research Services Clearance — after Grammarian scores Chapter 1-3,
 * before panel assignment.
 */
declare(strict_types=1);

require_once ROOT_PATH . '/modules/crad/config/config.php';
require_once ROOT_PATH . '/modules/crad/includes/chapter-evaluation-workflow.php';

function rscDb(): ?PDO
{
    return function_exists('cradDb') ? cradDb() : getCradDatabaseConnection();
}

function rscEnsureSchema(?PDO $crad = null): void
{
    $crad = $crad ?: rscDb();
    if (!$crad instanceof PDO) {
        return;
    }

    $crad->exec(
        "CREATE TABLE IF NOT EXISTS research_services_clearances (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            research_group_id INT UNSIGNED NOT NULL,
            title_approval_id INT UNSIGNED DEFAULT NULL,
            status VARCHAR(40) NOT NULL DEFAULT 'draft',
            or_number VARCHAR(40) NOT NULL DEFAULT '',
            leader_student_no VARCHAR(40) NOT NULL DEFAULT '',
            leader_group_no VARCHAR(40) NOT NULL DEFAULT '',
            program VARCHAR(200) NOT NULL DEFAULT '',
            section VARCHAR(80) NOT NULL DEFAULT '',
            research_title VARCHAR(255) NOT NULL DEFAULT '',
            members_json LONGTEXT DEFAULT NULL,
            grammarian_name VARCHAR(160) NOT NULL DEFAULT '',
            statistician_name VARCHAR(160) NOT NULL DEFAULT '',
            adviser_name VARCHAR(160) NOT NULL DEFAULT '',
            adviser_user_id INT UNSIGNED DEFAULT NULL,
            adviser_email VARCHAR(190) NOT NULL DEFAULT '',
            adviser_signature LONGTEXT DEFAULT NULL,
            adviser_signed_at DATETIME DEFAULT NULL,
            crad_name VARCHAR(160) NOT NULL DEFAULT '',
            crad_user_id INT UNSIGNED DEFAULT NULL,
            crad_signature LONGTEXT DEFAULT NULL,
            crad_signed_at DATETIME DEFAULT NULL,
            uploaded_file VARCHAR(255) DEFAULT NULL,
            uploaded_original VARCHAR(255) DEFAULT NULL,
            uploaded_at DATETIME DEFAULT NULL,
            sent_at DATETIME DEFAULT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY uniq_rsc_group (research_group_id),
            KEY idx_rsc_status (status),
            KEY idx_rsc_adviser (adviser_user_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );

    foreach ([
        'mis_verified' => "ALTER TABLE research_services_clearances ADD COLUMN mis_verified TINYINT(1) NOT NULL DEFAULT 0 AFTER uploaded_at",
        'aa_verified' => "ALTER TABLE research_services_clearances ADD COLUMN aa_verified TINYINT(1) NOT NULL DEFAULT 0 AFTER mis_verified",
        'mis_verified_at' => "ALTER TABLE research_services_clearances ADD COLUMN mis_verified_at DATETIME DEFAULT NULL AFTER aa_verified",
        'aa_verified_at' => "ALTER TABLE research_services_clearances ADD COLUMN aa_verified_at DATETIME DEFAULT NULL AFTER mis_verified_at",
    ] as $column => $sql) {
        try {
            if (!$crad->query("SHOW COLUMNS FROM research_services_clearances LIKE " . $crad->quote($column))->fetch()) {
                $crad->exec($sql);
            }
        } catch (Throwable $e) {
            error_log('rsc schema column ' . $column . ': ' . $e->getMessage());
        }
    }

    $crad->exec(
        "CREATE TABLE IF NOT EXISTS research_clearance_notifications (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            event_key VARCHAR(190) NOT NULL,
            recipient_user_id INT UNSIGNED DEFAULT NULL,
            recipient_role VARCHAR(40) NOT NULL DEFAULT '',
            recipient_email VARCHAR(190) NOT NULL DEFAULT '',
            clearance_id INT UNSIGNED DEFAULT NULL,
            type VARCHAR(40) NOT NULL DEFAULT '',
            title VARCHAR(190) NOT NULL DEFAULT '',
            body TEXT DEFAULT NULL,
            url VARCHAR(255) NOT NULL DEFAULT '',
            is_read TINYINT(1) NOT NULL DEFAULT 0,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY uniq_rsc_notif_event (event_key),
            KEY idx_rsc_notif_recipient (recipient_user_id, recipient_role)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );
}

function rscStudentUrl(): string
{
    return BASE_URL . '/modules/student-portal/pages/research-clearance.php';
}

function rscAdviserUrl(?int $id = null): string
{
    $url = BASE_URL . '/modules/faculty/pages/research-clearance.php';
    return $id ? $url . '?id=' . $id : $url;
}

function rscCradUrl(?int $id = null): string
{
    $url = BASE_URL . '/modules/crad/pages/research-clearance.php';
    return $id ? $url . '?id=' . $id : $url;
}

function rscIsChapterReady(PDO $crad, int $groupId): bool
{
    if ($groupId <= 0) {
        return false;
    }
    try {
        $stmt = $crad->prepare(
            "SELECT 1
             FROM research_groups rg
             INNER JOIN chapter_submissions ch1 ON ch1.id = (
                SELECT cs1.id FROM chapter_submissions cs1
                WHERE cs1.research_group_id = rg.id AND cs1.chapter_number = 1
                ORDER BY cs1.version_number DESC, cs1.id DESC LIMIT 1
             )
             INNER JOIN chapter_evaluations ce1 ON ce1.submission_id = ch1.id
             INNER JOIN chapter_submissions ch2 ON ch2.id = (
                SELECT cs2.id FROM chapter_submissions cs2
                WHERE cs2.research_group_id = rg.id AND cs2.chapter_number = 2
                ORDER BY cs2.version_number DESC, cs2.id DESC LIMIT 1
             )
             INNER JOIN chapter_evaluations ce2 ON ce2.submission_id = ch2.id
             INNER JOIN chapter_submissions ch3 ON ch3.id = (
                SELECT cs3.id FROM chapter_submissions cs3
                WHERE cs3.research_group_id = rg.id AND cs3.chapter_number = 3
                ORDER BY cs3.version_number DESC, cs3.id DESC LIMIT 1
             )
             INNER JOIN chapter_evaluations ce3 ON ce3.submission_id = ch3.id
             WHERE rg.id = :gid
               AND ch1.status = 'Accepted'
               AND ch2.status = 'Accepted'
               AND ch3.status = 'Accepted'
               AND UPPER(REPLACE(ce1.result, ' ', '_')) IN ('APPROVED', 'APPROVED_WITH_REVISION')
               AND UPPER(REPLACE(ce2.result, ' ', '_')) IN ('APPROVED', 'APPROVED_WITH_REVISION')
               AND UPPER(REPLACE(ce3.result, ' ', '_')) IN ('APPROVED', 'APPROVED_WITH_REVISION')
             LIMIT 1"
        );
        $stmt->execute([':gid' => $groupId]);
        return (bool) $stmt->fetchColumn();
    } catch (Throwable $e) {
        error_log('rscIsChapterReady: ' . $e->getMessage());
        return false;
    }
}

function rscSplitName(string $fullName): array
{
    $fullName = trim(preg_replace('/\s+/', ' ', $fullName) ?? '');
    if ($fullName === '') {
        return ['last' => '', 'first' => ''];
    }
    if (str_contains($fullName, ',')) {
        [$last, $first] = array_pad(array_map('trim', explode(',', $fullName, 2)), 2, '');
        return ['last' => $last, 'first' => $first];
    }
    $parts = array_values(array_filter(preg_split('/\s+/', $fullName) ?: [], static fn($p) => $p !== ''));
    if (count($parts) === 1) {
        return ['last' => $parts[0], 'first' => ''];
    }
    $particles = ['de', 'del', 'dela', 'da', 'das', 'do', 'dos', 'la', 'las', 'los', 'van', 'von', 'san', 'santa', 'sta', 'sto'];
    $lastParts = [array_pop($parts)];
    while ($parts !== [] && in_array(strtolower((string) $parts[count($parts) - 1]), $particles, true)) {
        array_unshift($lastParts, array_pop($parts));
    }
    return ['last' => implode(' ', $lastParts), 'first' => implode(' ', $parts)];
}

function rscNameFingerprint(string $name): string
{
    $parts = preg_split('/\s+/', strtolower(trim(preg_replace('/[^a-z0-9\s]/', ' ', $name) ?? '')), -1, PREG_SPLIT_NO_EMPTY);
    if (!is_array($parts) || $parts === []) {
        return '';
    }
    sort($parts);
    return implode('', $parts);
}

function rscMemberKeys(string $name, string $studentId = ''): array
{
    $keys = [];
    $id = strtoupper(preg_replace('/\s+/', '', $studentId) ?? '');
    if ($id !== '' && preg_match('/^S?\d+/i', $id)) {
        $keys[] = 'id:' . $id;
    }
    $print = rscNameFingerprint($name);
    if ($print !== '') {
        $keys[] = 'name:' . $print;
    }
    return $keys;
}

function rscExtractOrNumber(string $value): string
{
    $value = strtoupper(trim($value));
    return preg_match('/^OR-[\w-]+$/', $value) ? $value : '';
}

function rscExtractStudentId(string $value): string
{
    $value = trim($value);
    if ($value === '' || rscExtractOrNumber($value) !== '') {
        return '';
    }
    return preg_match('/^S?\d+/i', $value) ? $value : '';
}

function rscAddUniqueMember(array &$roster, string $name, string $studentId = '', string $orNumber = ''): void
{
    $name = trim(preg_replace('/\s+/', ' ', $name) ?? '');
    $studentId = rscExtractStudentId($studentId);
    $orNumber = rscExtractOrNumber($orNumber);
    if ($name === '' || preg_match('/^(n\/?a|none|tbd|-)$/i', $name)) {
        return;
    }
    $newKeys = rscMemberKeys($name, $studentId);
    if ($newKeys === []) {
        return;
    }
    foreach ($roster as $i => $row) {
        $existingKeys = rscMemberKeys((string) $row['name'], (string) $row['student_id']);
        if (array_intersect($newKeys, $existingKeys) !== []) {
            if ($studentId !== '' && trim((string) $row['student_id']) === '') {
                $roster[$i]['student_id'] = $studentId;
            }
            if ($orNumber !== '' && rscExtractOrNumber((string) $row['or_number']) === '') {
                $roster[$i]['or_number'] = $orNumber;
            }
            return;
        }
    }
    $roster[] = ['name' => $name, 'student_id' => $studentId, 'or_number' => $orNumber];
}

function rscDedupeMembers(array $members): array
{
    $roster = [];
    foreach ($members as $member) {
        if (!is_array($member)) {
            continue;
        }
        $third = trim((string) ($member['or_number'] ?? $member['student_id'] ?? $member[2] ?? ''));
        rscAddUniqueMember(
            $roster,
            (string) ($member['name'] ?? $member[0] ?? ''),
            (string) ($member['student_id'] ?? (rscExtractStudentId($third) !== '' ? $third : '')),
            (string) ($member['or_number'] ?? (rscExtractOrNumber($third) !== '' ? $third : ''))
        );
    }
    return $roster;
}

function rscMembersFromGroup(PDO $crad, array $group): array
{
    $roster = [];
    $proposalId = (int) ($group['proposal_id'] ?? 0);
    if ($proposalId > 0) {
        try {
            $stmt = $crad->prepare(
                "SELECT student_id, student_name FROM proposal_members
                 WHERE proposal_id = ? ORDER BY sort_order ASC, id ASC"
            );
            $stmt->execute([$proposalId]);
            foreach ($stmt->fetchAll() ?: [] as $m) {
                rscAddUniqueMember($roster, (string) ($m['student_name'] ?? ''), (string) ($m['student_id'] ?? ''));
            }
        } catch (Throwable $e) {
            $roster = [];
        }
    }

    $json = trim((string) ($group['members_json'] ?? ''));
    if ($json !== '') {
        $decoded = json_decode($json, true);
        if (is_array($decoded)) {
            foreach ($decoded as $entry) {
                if (!is_array($entry)) {
                    continue;
                }
                $name = trim((string) ($entry[0] ?? $entry['name'] ?? ''));
                $third = trim((string) ($entry[2] ?? $entry['student_id'] ?? $entry['or_number'] ?? ''));
                rscAddUniqueMember(
                    $roster,
                    $name,
                    (string) ($entry['student_id'] ?? ''),
                    (string) ($entry['or_number'] ?? $third)
                );
            }
        }
    }

    rscAddUniqueMember(
        $roster,
        (string) ($group['leader_name'] ?? $group['title_student_name'] ?? ''),
        (string) ($group['leader_id'] ?? $group['title_student_id'] ?? '')
    );

    return $roster;
}

function rscLoadGroupContext(PDO $crad, int $groupId): ?array
{
    $stmt = $crad->prepare(
        "SELECT rg.*, t.members_json, t.department AS title_department, t.student_id AS title_student_id,
                t.student_name AS title_student_name, t.student_user_id,
                aa.adviser_user_id, aa.adviser_name, aa.adviser_email
         FROM research_groups rg
         LEFT JOIN title_approvals t ON t.id = rg.title_approval_id
         LEFT JOIN research_adviser_assignments aa ON aa.id = (
            SELECT aa2.id FROM research_adviser_assignments aa2
            WHERE (aa2.research_group_id = rg.id
                OR (aa2.group_number IS NOT NULL AND aa2.group_number <> '' AND aa2.group_number = rg.group_number))
            ORDER BY (aa2.assignment_status IN ('Assigned','Confirmed')) DESC, aa2.updated_at DESC, aa2.id DESC
            LIMIT 1
         )
         WHERE rg.id = ?
         LIMIT 1"
    );
    $stmt->execute([$groupId]);
    $group = $stmt->fetch() ?: null;
    if (!$group) {
        return null;
    }

    $grammarian = '';
    try {
        $gStmt = $crad->prepare(
            "SELECT evaluator_name FROM chapter_evaluations
             WHERE research_group_id = ? AND TRIM(evaluator_name) <> ''
             ORDER BY id DESC LIMIT 1"
        );
        $gStmt->execute([$groupId]);
        $grammarian = trim((string) $gStmt->fetchColumn());
    } catch (Throwable $e) {
        $grammarian = '';
    }

    $program = trim((string) ($group['college_dept'] ?? ''));
    if ($program === '') {
        $program = trim((string) ($group['title_department'] ?? ''));
    }
    $section = '';
    $sms = function_exists('db') ? db() : null;
    $leaderId = trim((string) ($group['leader_id'] ?? $group['title_student_id'] ?? ''));
    if ($sms instanceof PDO && $leaderId !== '') {
        try {
            if (!function_exists('studentPortalEnsureProfileSchema')) {
                require_once ROOT_PATH . '/modules/student-portal/includes/student-profile.php';
            }
            studentPortalEnsureProfileSchema($sms);
            $pStmt = $sms->prepare('SELECT program, section FROM student_profiles WHERE student_id = ? LIMIT 1');
            $pStmt->execute([$leaderId]);
            $profile = $pStmt->fetch() ?: null;
            if ($profile) {
                if ($program === '') {
                    $program = trim((string) ($profile['program'] ?? ''));
                }
                $section = trim((string) ($profile['section'] ?? ''));
            }
        } catch (Throwable $e) {
            // keep blanks
        }
    }

    $group['resolved_program'] = $program;
    $group['resolved_section'] = $section;
    $group['resolved_grammarian'] = $grammarian;
    $group['resolved_members'] = rscMembersFromGroup($crad, $group);
    return $group;
}

function rscGenerateOrNumber(int $groupId, string $groupNumber = ''): string
{
    $fromGroup = strtoupper(preg_replace('/[^A-Z0-9]/', '', $groupNumber) ?? '');
    $fromGroup = preg_replace('/^RG/', '', $fromGroup) ?? '';
    if ($fromGroup !== '') {
        return 'OR-' . $fromGroup;
    }
    return 'OR-' . date('y') . str_pad((string) max(1, $groupId), 5, '0', STR_PAD_LEFT);
}

function rscResolveGroupOrNumber(int $groupId, string $groupNumber, array $members): string
{
    foreach ($members as $member) {
        if (!is_array($member)) {
            continue;
        }
        $or = rscExtractOrNumber((string) ($member['or_number'] ?? ''));
        if ($or !== '') {
            return $or;
        }
    }
    return rscGenerateOrNumber($groupId, $groupNumber);
}

function rscEnsureForReadyGroup(PDO $crad, int $groupId): ?array
{
    rscEnsureSchema($crad);
    if ($groupId <= 0) {
        return null;
    }

    $existing = rscFindByGroup($crad, $groupId);
    if (!$existing && !rscIsChapterReady($crad, $groupId)) {
        return null;
    }

    $ctx = rscLoadGroupContext($crad, $groupId);
    if (!$ctx) {
        return $existing;
    }

    $members = $ctx['resolved_members'] ?? [];
    $payload = [
        'title_approval_id' => (int) ($ctx['title_approval_id'] ?? 0) ?: null,
        'leader_student_no' => trim((string) ($ctx['leader_id'] ?? $ctx['title_student_id'] ?? '')),
        'leader_group_no' => trim((string) ($ctx['group_number'] ?? '')),
        'program' => (string) ($ctx['resolved_program'] ?? ''),
        'section' => (string) ($ctx['resolved_section'] ?? ''),
        'research_title' => trim((string) ($ctx['research_title'] ?? '')),
        'members_json' => json_encode($members, JSON_UNESCAPED_UNICODE),
        'grammarian_name' => (string) ($ctx['resolved_grammarian'] ?? ''),
        'adviser_name' => trim((string) ($ctx['adviser_name'] ?? $ctx['adviser'] ?? '')),
        'adviser_user_id' => (int) ($ctx['adviser_user_id'] ?? 0) ?: null,
        'adviser_email' => strtolower(trim((string) ($ctx['adviser_email'] ?? ''))),
    ];

    $or = rscResolveGroupOrNumber($groupId, (string) ($ctx['group_number'] ?? ''), $members);
    $payload['or_number'] = $or;

    if (!$existing) {
        $stmt = $crad->prepare(
            "INSERT INTO research_services_clearances
                (research_group_id, title_approval_id, status, or_number, leader_student_no, leader_group_no,
                 program, section, research_title, members_json, grammarian_name, adviser_name,
                 adviser_user_id, adviser_email)
             VALUES
                (:gid, :tid, 'draft', :or_number, :leader_student_no, :leader_group_no,
                 :program, :section, :research_title, :members_json, :grammarian_name, :adviser_name,
                 :adviser_user_id, :adviser_email)"
        );
        $stmt->execute([
            ':gid' => $groupId,
            ':tid' => $payload['title_approval_id'],
            ':or_number' => $or,
            ':leader_student_no' => $payload['leader_student_no'],
            ':leader_group_no' => $payload['leader_group_no'],
            ':program' => $payload['program'],
            ':section' => $payload['section'],
            ':research_title' => $payload['research_title'],
            ':members_json' => $payload['members_json'],
            ':grammarian_name' => $payload['grammarian_name'],
            ':adviser_name' => $payload['adviser_name'],
            ':adviser_user_id' => $payload['adviser_user_id'],
            ':adviser_email' => $payload['adviser_email'],
        ]);
        return rscFindByGroup($crad, $groupId);
    }

    $crad->prepare(
        "UPDATE research_services_clearances
         SET title_approval_id = :tid,
             or_number = :or_number,
             leader_student_no = :leader_student_no,
             leader_group_no = :leader_group_no,
             program = :program,
             section = :section,
             research_title = :research_title,
             members_json = :members_json,
             grammarian_name = :grammarian_name,
             adviser_name = :adviser_name,
             adviser_user_id = :adviser_user_id,
             adviser_email = :adviser_email
         WHERE id = :id"
    )->execute([
        ':tid' => $payload['title_approval_id'],
        ':or_number' => $or,
        ':leader_student_no' => $payload['leader_student_no'],
        ':leader_group_no' => $payload['leader_group_no'],
        ':program' => $payload['program'],
        ':section' => $payload['section'],
        ':research_title' => $payload['research_title'],
        ':members_json' => $payload['members_json'],
        ':grammarian_name' => $payload['grammarian_name'],
        ':adviser_name' => $payload['adviser_name'],
        ':adviser_user_id' => $payload['adviser_user_id'],
        ':adviser_email' => $payload['adviser_email'],
        ':id' => (int) $existing['id'],
    ]);
    return rscFindById($crad, (int) $existing['id']);
}

function rscFindByGroup(PDO $crad, int $groupId): ?array
{
    if ($groupId <= 0) {
        return null;
    }
    $stmt = $crad->prepare('SELECT * FROM research_services_clearances WHERE research_group_id = ? LIMIT 1');
    $stmt->execute([$groupId]);
    $row = $stmt->fetch() ?: null;
    return $row ?: null;
}

function rscFindById(PDO $crad, int $id): ?array
{
    if ($id <= 0) {
        return null;
    }
    $stmt = $crad->prepare('SELECT * FROM research_services_clearances WHERE id = ? LIMIT 1');
    $stmt->execute([$id]);
    $row = $stmt->fetch() ?: null;
    return $row ?: null;
}

function rscNotify(PDO $crad, string $eventKey, int $clearanceId, array $recipient, string $type, string $title, string $body, string $url): void
{
    rscEnsureSchema($crad);
    $stmt = $crad->prepare(
        "INSERT IGNORE INTO research_clearance_notifications
            (event_key, recipient_user_id, recipient_role, recipient_email, clearance_id, type, title, body, url)
         VALUES
            (:event_key, :user_id, :role, :email, :clearance_id, :type, :title, :body, :url)"
    );
    $stmt->execute([
        ':event_key' => $eventKey,
        ':user_id' => (int) ($recipient['id'] ?? 0) ?: null,
        ':role' => (string) ($recipient['role_key'] ?? $recipient['role'] ?? ''),
        ':email' => strtolower(trim((string) ($recipient['email'] ?? ''))),
        ':clearance_id' => $clearanceId,
        ':type' => $type,
        ':title' => $title,
        ':body' => $body,
        ':url' => $url,
    ]);
}

function rscNormalizeSignature(string $signature): string
{
    $signature = trim($signature);
    if ($signature === '' || !preg_match('#^data:image/(png|jpeg);base64,#i', $signature)) {
        return '';
    }
    if (strlen($signature) > 900000) {
        return '';
    }
    return $signature;
}

function rscSendToAdviser(PDO $crad, array $clearance): array
{
    if ((string) ($clearance['status'] ?? '') !== 'draft') {
        return ['ok' => false, 'error' => 'Clearance was already sent to the adviser.'];
    }
    $id = (int) $clearance['id'];
    $crad->prepare("UPDATE research_services_clearances SET status = 'sent_to_adviser', sent_at = NOW() WHERE id = ?")
        ->execute([$id]);

    $recipient = [
        'id' => (int) ($clearance['adviser_user_id'] ?? 0),
        'role_key' => 'adviser',
        'email' => (string) ($clearance['adviser_email'] ?? ''),
    ];
    rscNotify(
        $crad,
        'clearance-sent:' . $id,
        $id,
        $recipient,
        'sent_to_adviser',
        'Research Services Clearance',
        'A student sent a Research Services Clearance form for your signature.',
        rscAdviserUrl($id)
    );
    return ['ok' => true, 'clearance' => rscFindById($crad, $id)];
}

function rscAdviserSign(PDO $crad, array $clearance, string $signature, string $signerName): array
{
    if ((string) ($clearance['status'] ?? '') !== 'sent_to_adviser') {
        return ['ok' => false, 'error' => 'This clearance is not waiting for the adviser signature.'];
    }
    $sig = rscNormalizeSignature($signature);
    if ($sig === '') {
        return ['ok' => false, 'error' => 'Please provide your signature before approving.'];
    }
    $crad->prepare(
        "UPDATE research_services_clearances
         SET status = 'adviser_signed',
             adviser_signature = :sig,
             adviser_signed_at = NOW(),
             adviser_name = CASE WHEN TRIM(adviser_name) = '' THEN :name ELSE adviser_name END
         WHERE id = :id"
    )->execute([
        ':sig' => $sig,
        ':name' => $signerName,
        ':id' => (int) $clearance['id'],
    ]);

    $fresh = rscFindById($crad, (int) $clearance['id']);
    $sms = function_exists('db') ? db() : null;
    if ($sms instanceof PDO) {
        $officers = $sms->query("SELECT id, email, role_key FROM users WHERE role_key = 'crad_officer' AND status = 'active'")->fetchAll() ?: [];
        foreach ($officers as $officer) {
            rscNotify(
                $crad,
                'clearance-adviser:' . (int) $clearance['id'] . ':u' . (int) $officer['id'],
                (int) $clearance['id'],
                $officer,
                'adviser_signed',
                'Clearance ready for CRAD',
                'An adviser signed a Research Services Clearance. Upload the form and confirm the MIS and AA signatures before signing.',
                rscCradUrl((int) $clearance['id'])
            );
        }
    }
    return ['ok' => true, 'clearance' => $fresh];
}

function rscCradReceive(PDO $crad, array $clearance, array $file = []): array
{
    $status = (string) ($clearance['status'] ?? '');
    if (!in_array($status, ['adviser_signed', 'crad_received'], true)) {
        return ['ok' => false, 'error' => 'The adviser must sign first before CRAD can accept this clearance.'];
    }

    $hasNewFile = $file !== [] && (int) ($file['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_OK;
    $stored = (string) ($clearance['uploaded_file'] ?? '');
    $original = (string) ($clearance['uploaded_original'] ?? '');
    if ($hasNewFile) {
        $saved = rscStoreUpload((int) $clearance['id'], $file);
        if (empty($saved['ok'])) {
            return $saved;
        }
        $stored = (string) $saved['file'];
        $original = (string) $saved['original'];
    }
    if ($stored === '') {
        return ['ok' => false, 'error' => 'Upload the signed clearance form first so you can check the MIS and AA signatures.'];
    }

    $crad->prepare(
        "UPDATE research_services_clearances
         SET status = 'crad_received',
             uploaded_file = :file,
             uploaded_original = :original,
             uploaded_at = NOW()
         WHERE id = :id"
    )->execute([
        ':file' => $stored,
        ':original' => $original !== '' ? $original : null,
        ':id' => (int) $clearance['id'],
    ]);
    return ['ok' => true, 'clearance' => rscFindById($crad, (int) $clearance['id'])];
}

function rscCradVerifyMarks(PDO $crad, array $clearance, bool $mis, bool $aa): array
{
    $status = (string) ($clearance['status'] ?? '');
    if (!in_array($status, ['adviser_signed', 'crad_received'], true)) {
        return ['ok' => false, 'error' => 'Upload the adviser-signed clearance first.'];
    }
    if (trim((string) ($clearance['adviser_signature'] ?? '')) === '') {
        return ['ok' => false, 'error' => 'The adviser signature is missing.'];
    }
    $crad->prepare(
        "UPDATE research_services_clearances
         SET mis_verified = :mis,
             aa_verified = :aa,
             mis_verified_at = CASE WHEN :mis2 = 1 THEN COALESCE(mis_verified_at, NOW()) ELSE NULL END,
             aa_verified_at = CASE WHEN :aa2 = 1 THEN COALESCE(aa_verified_at, NOW()) ELSE NULL END,
             status = CASE WHEN status = 'adviser_signed' THEN 'crad_received' ELSE status END
         WHERE id = :id"
    )->execute([
        ':mis' => $mis ? 1 : 0,
        ':aa' => $aa ? 1 : 0,
        ':mis2' => $mis ? 1 : 0,
        ':aa2' => $aa ? 1 : 0,
        ':id' => (int) $clearance['id'],
    ]);
    return ['ok' => true, 'clearance' => rscFindById($crad, (int) $clearance['id'])];
}

function rscCanCradSign(array $clearance): bool
{
    return trim((string) ($clearance['adviser_signature'] ?? '')) !== ''
        && (int) ($clearance['mis_verified'] ?? 0) === 1
        && (int) ($clearance['aa_verified'] ?? 0) === 1
        && trim((string) ($clearance['uploaded_file'] ?? '')) !== ''
        && in_array((string) ($clearance['status'] ?? ''), ['adviser_signed', 'crad_received'], true);
}

function rscCradSign(PDO $crad, array $clearance, string $signature, string $signerName): array
{
    if (!rscCanCradSign($clearance)) {
        return ['ok' => false, 'error' => 'Confirm the Adviser, MIS, and AA signatures on the uploaded form before CRAD can sign.'];
    }
    $sig = rscNormalizeSignature($signature);
    if ($sig === '') {
        return ['ok' => false, 'error' => 'Please provide your signature before approving.'];
    }
    $crad->prepare(
        "UPDATE research_services_clearances
         SET status = 'clearance_done',
             crad_signature = :sig,
             crad_signed_at = NOW(),
             crad_name = :name,
             crad_user_id = :uid
         WHERE id = :id"
    )->execute([
        ':sig' => $sig,
        ':name' => $signerName,
        ':uid' => (int) ($_SESSION['user_id'] ?? 0) ?: null,
        ':id' => (int) $clearance['id'],
    ]);

    $fresh = rscFindById($crad, (int) $clearance['id']);
    $ctx = rscLoadGroupContext($crad, (int) $clearance['research_group_id']);
    $studentRecipients = [];
    if ($ctx) {
        $studentRecipients[] = [
            'id' => (int) ($ctx['student_user_id'] ?? 0),
            'role_key' => 'student',
            'email' => strtolower(trim((string) ($ctx['leader_email'] ?? ''))),
        ];
        $sms = function_exists('db') ? db() : null;
        $leaderId = trim((string) ($ctx['leader_id'] ?? $ctx['title_student_id'] ?? ''));
        if ($sms instanceof PDO && $leaderId !== '' && (int) ($studentRecipients[0]['id'] ?? 0) <= 0) {
            try {
                $uStmt = $sms->prepare("SELECT id, email, role_key FROM users WHERE student_id = ? AND role_key = 'student' LIMIT 1");
                $uStmt->execute([$leaderId]);
                $user = $uStmt->fetch() ?: null;
                if ($user) {
                    $studentRecipients[0] = $user;
                }
            } catch (Throwable $e) {
                // keep fallback recipient
            }
        }
    }
    foreach ($studentRecipients as $recipient) {
        rscNotify(
            $crad,
            'clearance-done:' . (int) $clearance['id'],
            (int) $clearance['id'],
            $recipient,
            'clearance_done',
            'Clearance done',
            'Your Research Services Clearance is complete. The latest CRAD signature is now on your form.',
            rscStudentUrl()
        );
    }
    return ['ok' => true, 'clearance' => $fresh];
}

function rscStoreUpload(int $clearanceId, array $file): array
{
    if ((int) ($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
        return ['ok' => false, 'error' => 'Upload failed. Please try again.'];
    }
    $tmp = (string) ($file['tmp_name'] ?? '');
    $name = (string) ($file['name'] ?? 'clearance.pdf');
    if ($tmp === '' || !is_uploaded_file($tmp)) {
        return ['ok' => false, 'error' => 'Invalid upload.'];
    }
    $ext = strtolower(pathinfo($name, PATHINFO_EXTENSION));
    if (!in_array($ext, ['pdf', 'png', 'jpg', 'jpeg'], true)) {
        return ['ok' => false, 'error' => 'Upload a PDF or image of the clearance form.'];
    }
    $dir = ROOT_PATH . '/uploads/research-clearance';
    if (!is_dir($dir) && !mkdir($dir, 0775, true) && !is_dir($dir)) {
        return ['ok' => false, 'error' => 'Could not store the uploaded clearance.'];
    }
    $stored = 'rsc-' . $clearanceId . '-' . bin2hex(random_bytes(6)) . '.' . $ext;
    if (!move_uploaded_file($tmp, $dir . '/' . $stored)) {
        return ['ok' => false, 'error' => 'Could not store the uploaded clearance.'];
    }
    return ['ok' => true, 'file' => $stored, 'original' => $name];
}

function rscStatusLabel(string $status): string
{
    return match ($status) {
        'draft' => 'Ready to send',
        'sent_to_adviser' => 'Sent to Adviser',
        'adviser_signed' => 'Adviser signed',
        'crad_received' => 'Received by CRAD',
        'clearance_done' => 'Clearance done',
        default => $status,
    };
}

function rscPublicRow(array $row): array
{
    $members = rscDedupeMembers(json_decode((string) ($row['members_json'] ?? ''), true) ?: []);
    return [
        'id' => (int) $row['id'],
        'research_group_id' => (int) $row['research_group_id'],
        'status' => (string) $row['status'],
        'status_label' => rscStatusLabel((string) $row['status']),
        'or_number' => (string) $row['or_number'],
        'member_count' => count($members),
        'leader_student_no' => (string) $row['leader_student_no'],
        'leader_group_no' => (string) $row['leader_group_no'],
        'program' => (string) $row['program'],
        'section' => (string) $row['section'],
        'research_title' => (string) $row['research_title'],
        'members' => $members,
        'grammarian_name' => (string) $row['grammarian_name'],
        'statistician_name' => (string) $row['statistician_name'],
        'adviser_name' => (string) $row['adviser_name'],
        'adviser_signature' => (string) ($row['adviser_signature'] ?? ''),
        'adviser_signed_at' => (string) ($row['adviser_signed_at'] ?? ''),
        'crad_name' => (string) ($row['crad_name'] ?? ''),
        'crad_signature' => (string) ($row['crad_signature'] ?? ''),
        'crad_signed_at' => (string) ($row['crad_signed_at'] ?? ''),
        'uploaded_original' => (string) ($row['uploaded_original'] ?? ''),
        'has_upload' => trim((string) ($row['uploaded_file'] ?? '')) !== '',
        'has_adviser_signature' => trim((string) ($row['adviser_signature'] ?? '')) !== '',
        'mis_verified' => (int) ($row['mis_verified'] ?? 0) === 1,
        'aa_verified' => (int) ($row['aa_verified'] ?? 0) === 1,
        'can_crad_sign' => rscCanCradSign($row),
        'updated_at' => (string) ($row['updated_at'] ?? ''),
        'form_html' => rscRenderFormHtml($row),
    ];
}

function rscFormatDate(?string $value): string
{
    $ts = $value ? strtotime($value) : false;
    return $ts ? date('M j, Y') : '';
}

function rscRenderFormHtml(array $row, bool $duplicate = true): string
{
    $copy = static function (array $row): string {
        $e = static fn($v) => htmlspecialchars((string) $v, ENT_QUOTES, 'UTF-8');
        $members = rscDedupeMembers(json_decode((string) ($row['members_json'] ?? ''), true) ?: []);
        $fallbackOr = trim((string) ($row['or_number'] ?? ''));
        $memberRows = '';
        foreach ($members as $member) {
            $split = rscSplitName((string) ($member['name'] ?? ''));
            $memberOr = rscExtractOrNumber((string) ($member['or_number'] ?? '')) ?: $fallbackOr;
            $memberRows .= '<tr>'
                . '<td>' . $e($split['last']) . '</td>'
                . '<td>' . $e($split['first']) . '</td>'
                . '<td>' . $e($memberOr) . '</td>'
                . '<td></td>'
                . '</tr>';
        }
        $adviserSig = trim((string) ($row['adviser_signature'] ?? ''));
        $cradSig = trim((string) ($row['crad_signature'] ?? ''));
        $adviserImg = $adviserSig !== '' ? '<img src="' . $e($adviserSig) . '" alt="Adviser signature">' : '';
        $cradImg = $cradSig !== '' ? '<img src="' . $e($cradSig) . '" alt="CRAD signature">' : '';
        $adviserDate = rscFormatDate($row['adviser_signed_at'] ?? null);
        $cradDate = rscFormatDate($row['crad_signed_at'] ?? null);

        return '<div class="rsc-sheet">'
            . '<div class="rsc-meta">Leader Student No.: <strong>' . $e($row['leader_student_no'] ?? '') . '</strong>'
            . ' &nbsp; Leader Group No.: <strong>' . $e($row['leader_group_no'] ?? '') . '</strong></div>'
            . '<div class="rsc-letterhead">'
            . '<div class="rsc-seal"><img src="' . $e(BASE_URL . '/images/bcp-crest.png?v=rsc-logo-1') . '" alt="Bestlink College of the Philippines logo"></div>'
            . '<div class="rsc-heading">'
            . '<div class="rsc-school">BESTLINK COLLEGE OF THE PHILIPPINES</div>'
            . '<div class="rsc-address">#1071 Brgy. Kaligayahan, Quirino Highway, Novaliches, Quezon City</div>'
            . '<div class="rsc-center">CENTER FOR RESEARCH AND DEVELOPMENT</div>'
            . '<div class="rsc-title">Research Services Clearance</div>'
            . '</div>'
            . '<div class="rsc-seal rsc-seal--right">CRD</div>'
            . '</div>'
            . '<table class="rsc-table"><tbody>'
            . '<tr><th style="width:18%">Program</th><td style="width:47%">' . $e($row['program'] ?? '') . '</td>'
            . '<th style="width:15%">Section</th><td>' . $e($row['section'] ?? '') . '</td></tr>'
            . '<tr><th>Research Title</th><td colspan="3">' . $e($row['research_title'] ?? '') . '</td></tr>'
            . '</tbody></table>'
            . '<table class="rsc-table rsc-table--members"><thead><tr>'
            . '<th>Last Name</th><th>First Name</th><th>Research / Defense O.R. No.</th><th>Remarks</th>'
            . '</tr></thead><tbody>' . $memberRows . '</tbody></table>'
            . '<table class="rsc-table rsc-table--tasks"><thead><tr>'
            . '<th style="width:48%">Task</th><th>Name and Signature</th><th style="width:18%">Date</th>'
            . '</tr></thead><tbody>'
            . '<tr><td>1. Submitted OR Copy to Research Adviser</td>'
            . '<td>Adviser: ' . $e($row['adviser_name'] ?? '') . $adviserImg . '</td>'
            . '<td>' . $e($adviserDate) . '</td></tr>'
            . '<tr><td>2. OR no. Verified by Accounting / MIS</td><td>MIS: ' . ((int) ($row['mis_verified'] ?? 0) === 1 ? '<span class="rsc-physical">Physical signature verified</span>' : '') . '</td><td>' . $e(rscFormatDate($row['mis_verified_at'] ?? null)) . '</td></tr>'
            . '<tr><td>3. Turnitin username and Password Released by AAI / AA</td><td>AA: ' . ((int) ($row['aa_verified'] ?? 0) === 1 ? '<span class="rsc-physical">Physical signature verified</span>' : '') . '</td><td>' . $e(rscFormatDate($row['aa_verified_at'] ?? null)) . '</td></tr>'
            . '<tr><td>4. Research Services Personnel Assignment<br>'
            . 'Grammarian: ' . $e($row['grammarian_name'] ?? '') . '<br>'
            . 'Statistician / Technical Adviser: ' . $e($row['statistician_name'] ?? '') . '</td>'
            . '<td>CRAD: ' . $e($row['crad_name'] ?? '') . $cradImg . '</td>'
            . '<td>' . $e($cradDate) . '</td></tr>'
            . '</tbody></table></div>';
    };

    $html = '<div class="rsc-print-set">' . $copy($row);
    if ($duplicate) {
        $html .= $copy($row);
    }
    return $html . '</div>';
}

function rscStudentCanAccess(PDO $crad, array $clearance): bool
{
    $group = chapterRegisteredStudentGroup($crad);
    return $group && (int) $group['id'] === (int) ($clearance['research_group_id'] ?? 0);
}

function rscAdviserCanAccess(array $clearance): bool
{
    $uid = (int) ($_SESSION['user_id'] ?? 0);
    $email = strtolower(trim((string) ($_SESSION['user_email'] ?? '')));
    $name = strtolower(trim((string) ($_SESSION['user_name'] ?? '')));
    if ($uid > 0 && $uid === (int) ($clearance['adviser_user_id'] ?? 0)) {
        return true;
    }
    if ($email !== '' && $email === strtolower(trim((string) ($clearance['adviser_email'] ?? '')))) {
        return true;
    }
    return $name !== '' && $name === strtolower(trim((string) ($clearance['adviser_name'] ?? '')));
}

function rscCanManageAsCrad(): bool
{
    $role = getCurrentUserRoleKey();
    return $role === 'crad_officer' || smsIsGrantedAdminRole($role);
}

function rscRefreshExisting(PDO $crad, ?array $row): ?array
{
    if (!$row) {
        return null;
    }
    $fresh = rscEnsureForReadyGroup($crad, (int) ($row['research_group_id'] ?? 0));
    return $fresh ?: $row;
}

function rscRefreshRows(PDO $crad, array $rows): array
{
    $out = [];
    foreach ($rows as $row) {
        $fresh = rscRefreshExisting($crad, is_array($row) ? $row : null);
        if ($fresh) {
            $out[] = $fresh;
        }
    }
    return $out;
}

function rscListForAdviser(PDO $crad): array
{
    rscEnsureSchema($crad);
    $uid = (int) ($_SESSION['user_id'] ?? 0);
    $email = strtolower(trim((string) ($_SESSION['user_email'] ?? '')));
    $name = strtolower(trim((string) ($_SESSION['user_name'] ?? '')));
    $stmt = $crad->prepare(
        "SELECT * FROM research_services_clearances
         WHERE status IN ('sent_to_adviser','adviser_signed','crad_received','clearance_done')
           AND (
                (:uid > 0 AND adviser_user_id = :uid_match)
             OR (:email <> '' AND LOWER(TRIM(adviser_email)) = :email_match)
             OR (:name <> '' AND LOWER(TRIM(adviser_name)) = :name_match)
           )
         ORDER BY updated_at DESC, id DESC"
    );
    $stmt->execute([
        ':uid' => $uid,
        ':uid_match' => $uid,
        ':email' => $email,
        ':email_match' => $email,
        ':name' => $name,
        ':name_match' => $name,
    ]);
    return rscRefreshRows($crad, $stmt->fetchAll() ?: []);
}

function rscListForCrad(PDO $crad): array
{
    rscEnsureSchema($crad);
    $stmt = $crad->query(
        "SELECT * FROM research_services_clearances
         WHERE status IN ('adviser_signed','crad_received','clearance_done')
         ORDER BY FIELD(status,'adviser_signed','crad_received','clearance_done'), updated_at DESC"
    );
    return rscRefreshRows($crad, $stmt->fetchAll() ?: []);
}

function rscClearanceDoneExists(PDO $crad, int $groupId): bool
{
    rscEnsureSchema($crad);
    $stmt = $crad->prepare(
        "SELECT 1 FROM research_services_clearances
         WHERE research_group_id = ? AND status = 'clearance_done' LIMIT 1"
    );
    $stmt->execute([$groupId]);
    return (bool) $stmt->fetchColumn();
}
