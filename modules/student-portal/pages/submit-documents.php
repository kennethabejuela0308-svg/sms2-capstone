<?php
/**
 * SMS 2 - Research Document Attachment Form
 * Student Portal — CRD Document Vault (secure uploads)
 */
require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/breadcrumbs.php';
require_once ROOT_PATH . '/includes/security.php';
require_once ROOT_PATH . '/includes/uploads.php';
require_once ROOT_PATH . '/modules/crad/config/config.php';

requireAuth();

// ── Research Forum payment gate ──────────────────────────────────────────────
// Check if student has paid the Research Forum fee before allowing access.
// In production, replace this with a real DB query against the payment table.
$_gatePayments = [
    ['description' => 'Tuition Down Payment',  'status' => 'Paid'],
    ['description' => 'Registration Fee',       'status' => 'Paid'],
    ['description' => 'Laboratory Fee',         'status' => 'Paid'],
    ['description' => 'Research Forum',         'status' => 'Paid'],
];
$_researchForumPaid = false;
foreach ($_gatePayments as $_txn) {
    if (
        stripos($_txn['description'], 'Research Forum') !== false &&
        strtolower($_txn['status']) === 'paid'
    ) {
        $_researchForumPaid = true;
        break;
    }
}
if (!$_researchForumPaid) {
    // Redirect to payment history with a notice
    header('Location: ' . '/SMS2_system/modules/student-portal/pages/payment-history.php?notice=research-forum-required');
    exit;
}
unset($_gatePayments, $_txn, $_researchForumPaid);

$studentId = $_SESSION['student_id'] ?? 'S230000001';
$studentName = $_SESSION['user_name'] ?? 'Juan Dela Cruz';
$studentEmail = strtolower(trim((string) ($_SESSION['user_email'] ?? '')));
$studentNameForMatch = strtolower(trim((string) $studentName));
$userId = (int) ($_SESSION['user_id'] ?? 0);
$nameParts = array_values(array_filter(preg_split('/\s+/', trim($studentName)) ?: []));
if (count($nameParts) >= 3) {
    $lastName = $nameParts[count($nameParts) - 2] . ' ' . $nameParts[count($nameParts) - 1];
    $firstNames = implode(' ', array_slice($nameParts, 0, -2));
} elseif (count($nameParts) === 2) {
    $lastName = $nameParts[1];
    $firstNames = $nameParts[0];
} else {
    $lastName = $nameParts[0] ?? 'Dela Cruz';
    $firstNames = 'Juan';
}
$defaultMemberName = $lastName . ', ' . $firstNames . ' A.';

$uploadError = '';
$submitted = false;
$sentRef = trim((string) ($_GET['sent_ref'] ?? ''));
$sentMode = trim((string) ($_GET['sent_mode'] ?? 'new'));
$sentAtRaw = trim((string) ($_GET['sent_at'] ?? ''));
$sentAtTime = $sentAtRaw !== '' ? strtotime($sentAtRaw) : false;
$sentAt = $sentAtTime ? date('F j, Y h:i A', $sentAtTime) : date('F j, Y h:i A');
$sentToCrad = $sentRef !== '';
$showDrafts = (($_GET['view'] ?? '') === 'drafts');
$revisionRef = trim((string) ($_POST['revision_ref'] ?? ($_GET['revision_ref'] ?? '')));
$revisionProposal = null;
$revisionMembers = [];
$savedDraftData = [];
$savedDraftUpdatedAt = '';
$savedDraftRevisionRef = '';
$draftList = [];
$currentSubmission = null;
$latestTitleApproval = null;
$canSubmitDocumentPacket = false;
$documentPacketBlockNote = 'Bawal pa mag-submit ng document packet. Tapusin muna ang Title Approval process bago magsend sa CRAD.';

$documentSlots = [
    ['key' => 'manuscript', 'title' => 'Research Manuscript', 'desc' => 'Complete research paper manuscript.', 'required' => true],
    ['key' => 'approval', 'title' => 'Approval Sheet', 'desc' => 'Signed title/approval sheet.', 'required' => true],
    ['key' => 'abstract', 'title' => 'Abstract', 'desc' => 'Formal research abstract page.', 'required' => true],
    ['key' => 'certificate_adviser', 'title' => 'Certificate of Technical Adviser and Grammarian', 'desc' => 'Signed adviser and grammarian certificate.', 'required' => true],
    ['key' => 'certificate_originality', 'title' => 'Certificate of Originality', 'desc' => 'Signed originality certification.', 'required' => true],
    ['key' => 'supporting', 'title' => 'Supporting Documents', 'desc' => 'Optional annexes and attachments.', 'required' => false],
    ['key' => 'receipt_screenshot', 'title' => 'Screenshot of the Receipt', 'desc' => 'Screenshot or photo of the payment receipt.', 'required' => true],
];

try {
    $titleGatePdo = getCradDatabaseConnection();
    $titleGateStmt = $titleGatePdo->prepare(
        "SELECT id, proposed_title, status, coordinator_status, crad_status, sent_at, crad_reviewed_at
         FROM title_approvals
         WHERE student_id = :student_id
         ORDER BY id DESC
         LIMIT 1"
    );
    $titleGateStmt->execute([':student_id' => $studentId]);
    $latestTitleApproval = $titleGateStmt->fetch() ?: null;
    $canSubmitDocumentPacket = $latestTitleApproval
        && strcasecmp((string) ($latestTitleApproval['status'] ?? ''), 'Approved') === 0
        && strcasecmp((string) ($latestTitleApproval['coordinator_status'] ?? ''), 'Approved') === 0
        && strcasecmp((string) ($latestTitleApproval['crad_status'] ?? ''), 'Approved') === 0;

    if ($latestTitleApproval) {
        $documentPacketBlockNote = 'Bawal pa mag-submit ng document packet. Nasa Title Approval process pa ang title mo; hintayin muna ma-approve ng Adviser, Coordinator, at CRAD.';
    }
} catch (Throwable $e) {
    error_log('Document packet title gate check failed: ' . $e->getMessage());
}

function ensureProposalDraftsTable(PDO $pdo): void
{
    $pdo->exec(
        "CREATE TABLE IF NOT EXISTS proposal_drafts (
            id int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
            student_id varchar(50) NOT NULL,
            user_id int(10) UNSIGNED DEFAULT NULL,
            revision_ref varchar(30) NOT NULL DEFAULT '',
            draft_data longtext NOT NULL,
            signature_data mediumtext DEFAULT NULL,
            created_at datetime NOT NULL DEFAULT current_timestamp(),
            updated_at datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (id),
            UNIQUE KEY uniq_proposal_draft_student (student_id),
            KEY idx_proposal_draft_user (user_id),
            KEY idx_proposal_draft_updated (updated_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );
}

function collectProposalDraftPayload(array $source): array
{
    return [
        'research_title' => trim((string) ($source['research_title'] ?? '')),
        'program_course' => trim((string) ($source['program_course'] ?? '')),
        'year_section' => trim((string) ($source['year_section'] ?? '')),
        'college_department' => trim((string) ($source['college_department'] ?? '')),
        'research_adviser' => trim((string) ($source['research_adviser'] ?? '')),
        'academic_year' => trim((string) ($source['academic_year'] ?? '')),
        'member_id' => array_values(array_map('trim', is_array($source['member_id'] ?? null) ? $source['member_id'] : [])),
        'member_name' => array_values(array_map('trim', is_array($source['member_name'] ?? null) ? $source['member_name'] : [])),
        'member_email' => array_values(array_map('trim', is_array($source['member_email'] ?? null) ? $source['member_email'] : [])),
        'member_contact' => array_values(array_map('trim', is_array($source['member_contact'] ?? null) ? $source['member_contact'] : [])),
        'rep_name' => trim((string) ($source['rep_name'] ?? '')),
        'rep_id' => trim((string) ($source['rep_id'] ?? '')),
        'rep_email' => trim((string) ($source['rep_email'] ?? '')),
        'rep_contact' => trim((string) ($source['rep_contact'] ?? '')),
        'declaration' => !empty($source['declaration']) ? '1' : '',
        'date_submitted' => trim((string) ($source['date_submitted'] ?? date('Y-m-d'))),
        'signature_data' => (string) ($source['signature_data'] ?? ''),
    ];
}

function getStudentLatestProposal(PDO $pdo, string $studentId, string $studentEmail, string $studentName, int $userId, string $refCode = ''): ?array
{
    $whereRef = $refCode !== '' ? ' AND ref_code = :ref_code' : '';
    $stmt = $pdo->prepare(
        "SELECT ref_code, research_title, status, progress, date_submitted, created_at, updated_at, notes
         FROM research_proposals
         WHERE (
                (:student_id_value <> '' AND rep_id = :student_id_rep)
             OR (:student_email_value <> '' AND LOWER(rep_email) = :student_email_rep)
             OR (:student_name_value <> '' AND LOWER(TRIM(rep_name)) = :student_name_rep)
             OR (:user_id_value > 0 AND submitted_by_user = :user_id_match)
         )
         $whereRef
         ORDER BY updated_at DESC, id DESC
         LIMIT 1"
    );
    $params = [
        ':student_id_value' => $studentId,
        ':student_id_rep' => $studentId,
        ':student_email_value' => $studentEmail,
        ':student_email_rep' => $studentEmail,
        ':student_name_value' => $studentName,
        ':student_name_rep' => $studentName,
        ':user_id_value' => $userId,
        ':user_id_match' => $userId,
    ];
    if ($refCode !== '') {
        $params[':ref_code'] = $refCode;
    }
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row ?: null;
}

if (($_GET['ajax'] ?? '') === 'status') {
    header('Content-Type: application/json');
    try {
        $cradPdo = getCradDatabaseConnection();
        $statusRef = trim((string) ($_GET['status_ref'] ?? ''));
        $proposal = getStudentLatestProposal($cradPdo, $studentId, $studentEmail, $studentNameForMatch, $userId, $statusRef);
        if (!$proposal) {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => 'No submitted document packet found.']);
            exit;
        }
        $updatedTime = strtotime((string) ($proposal['updated_at'] ?? ''));
        echo json_encode([
            'ok' => true,
            'ref_code' => (string) $proposal['ref_code'],
            'title' => (string) $proposal['research_title'],
            'status' => (string) $proposal['status'],
            'progress' => (int) $proposal['progress'],
            'updated_at' => $updatedTime ? date('F j, Y h:i A', $updatedTime) : '',
        ]);
        exit;
    } catch (Throwable $e) {
        http_response_code(500);
        echo json_encode(['ok' => false, 'error' => 'Unable to load current status.']);
        exit;
    }
}

if ($revisionRef !== '') {
    try {
        $cradPdo = getCradDatabaseConnection();
        $stmt = $cradPdo->prepare(
            "SELECT *
             FROM research_proposals
             WHERE ref_code = :ref
               AND status = 'Returned'
               AND (
                    (:student_id_value <> '' AND rep_id = :student_id_rep)
                 OR (:student_email_value <> '' AND LOWER(rep_email) = :student_email_rep)
                 OR (:student_name_value <> '' AND LOWER(TRIM(rep_name)) = :student_name_rep)
                 OR (:user_id_value > 0 AND submitted_by_user = :user_id_match)
               )
             LIMIT 1"
        );
        $stmt->execute([
            ':ref' => $revisionRef,
            ':student_id_value' => $studentId,
            ':student_id_rep' => $studentId,
            ':student_email_value' => $studentEmail,
            ':student_email_rep' => $studentEmail,
            ':student_name_value' => $studentNameForMatch,
            ':student_name_rep' => $studentNameForMatch,
            ':user_id_value' => $userId,
            ':user_id_match' => $userId,
        ]);
        $revisionProposal = $stmt->fetch() ?: null;

        if ($revisionProposal) {
            $memberStmt = $cradPdo->prepare("SELECT * FROM proposal_members WHERE proposal_id = :pid ORDER BY sort_order ASC");
            $memberStmt->execute([':pid' => (int) $revisionProposal['id']]);
            $revisionMembers = $memberStmt->fetchAll() ?: [];
        } else {
            $uploadError = 'Returned proposal not found or you are not assigned as its representative.';
            $revisionRef = '';
        }
    } catch (Throwable $e) {
        error_log('Returned proposal load error: ' . $e->getMessage());
        $uploadError = 'Unable to load the returned proposal. Please try again.';
        $revisionRef = '';
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && (($_POST['process'] ?? '') === 'save-draft')) {
    header('Content-Type: application/json');

    if (!csrfVerify()) {
        http_response_code(403);
        echo json_encode(['ok' => false, 'error' => 'Security check failed. Please refresh the page and try again.']);
        exit;
    }

    try {
        $cradPdo = getCradDatabaseConnection();
        ensureProposalDraftsTable($cradPdo);

        $draftData = collectProposalDraftPayload($_POST);
        $revisionDraftRef = trim((string) ($_POST['revision_ref'] ?? ''));
        $signatureData = $draftData['signature_data'] !== '' ? $draftData['signature_data'] : null;
        $draftJson = json_encode($draftData, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        if ($draftJson === false) {
            throw new RuntimeException('Unable to encode draft data.');
        }

        $cradPdo->prepare("DELETE FROM proposal_drafts WHERE student_id = :student_id")
            ->execute([':student_id' => $studentId]);

        $stmt = $cradPdo->prepare(
            "INSERT INTO proposal_drafts
                (student_id, user_id, revision_ref, draft_data, signature_data)
             VALUES
                (:student_id, :user_id, :revision_ref, :draft_data, :signature_data)
             ON DUPLICATE KEY UPDATE
                user_id = VALUES(user_id),
                revision_ref = VALUES(revision_ref),
                draft_data = VALUES(draft_data),
                signature_data = VALUES(signature_data),
                updated_at = NOW()"
        );
        $stmt->execute([
            ':student_id' => $studentId,
            ':user_id' => $userId ?: null,
            ':revision_ref' => $revisionDraftRef,
            ':draft_data' => $draftJson,
            ':signature_data' => $signatureData,
        ]);

        echo json_encode([
            'ok' => true,
            'message' => 'Draft saved to database.',
            'saved_at' => date('F j, Y h:i A'),
        ]);
        exit;
    } catch (Throwable $e) {
        error_log('Proposal draft save error: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['ok' => false, 'error' => 'Unable to save draft. Please try again.']);
        exit;
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && (($_POST['process'] ?? '') === 'submit-documents')) {
    if (!csrfVerify()) {
        $uploadError = 'Security check failed. Please try again.';
    } elseif (!$canSubmitDocumentPacket) {
        $uploadError = $documentPacketBlockNote;
    } else {
        $subdir = 'student_docs/u' . max(0, $userId);
        $allowed = [
            'pdf'  => ['application/pdf'],
            'doc'  => ['application/msword', 'application/octet-stream'],
            'docx' => [
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'application/zip',
                'application/octet-stream',
            ],
            'jpg'  => ['image/jpeg'],
            'jpeg' => ['image/jpeg'],
            'png'  => ['image/png'],
        ];
        $saved = [];
        foreach ($documentSlots as $slot) {
            $key = $slot['key'];
            $file = $_FILES[$key] ?? ['error' => UPLOAD_ERR_NO_FILE];
            $result = smsSecureUpload(is_array($file) ? $file : [], [
                'subdir' => $subdir,
                'max_bytes' => 10 * 1024 * 1024,
                'allowed' => $allowed,
                'required' => !empty($slot['required']),
            ]);
            if (empty($result['ok'])) {
                $uploadError = ($slot['title'] ?? $key) . ': ' . ($result['error'] ?: 'Upload failed.');
                break;
            }
            if (!empty($result['stored_name'])) {
                $saved[$key] = [
                    'stored' => $result['stored_name'],
                    'original' => $result['original_name'],
                    'size' => $result['size'],
                ];
            }
        }
        if ($uploadError === '') {
            // ── Save to crad_db ───────────────────────────────────────────
            try {
                $cradPdo = getCradDatabaseConnection();

                $isRevision = $revisionRef !== '' && is_array($revisionProposal);
                if ($isRevision) {
                    $proposalId = (int) $revisionProposal['id'];
                    $refCode = (string) $revisionProposal['ref_code'];
                    $stmt = $cradPdo->prepare(
                        "UPDATE research_proposals
                         SET research_title = :research_title,
                             program_course = :program_course,
                             year_section = :year_section,
                             college_department = :college_department,
                             research_adviser = :research_adviser,
                             academic_year = :academic_year,
                             rep_name = :rep_name,
                             rep_id = :rep_id,
                             rep_email = :rep_email,
                             rep_contact = :rep_contact,
                             status = 'Submitted',
                             progress = 0,
                             date_submitted = :date_submitted,
                             signature_data = :signature_data,
                             updated_at = NOW()
                         WHERE id = :proposal_id
                         LIMIT 1"
                    );
                    $stmt->execute([
                        ':research_title'     => trim($_POST['research_title']  ?? ''),
                        ':program_course'     => trim($_POST['program_course']  ?? ''),
                        ':year_section'       => trim($_POST['year_section']    ?? ''),
                        ':college_department' => trim($_POST['college_department'] ?? ''),
                        ':research_adviser'   => trim($_POST['research_adviser'] ?? ''),
                        ':academic_year'      => trim($_POST['academic_year']   ?? ''),
                        ':rep_name'           => trim($_POST['rep_name']        ?? ''),
                        ':rep_id'             => trim($_POST['rep_id']          ?? ''),
                        ':rep_email'          => trim($_POST['rep_email']       ?? ''),
                        ':rep_contact'        => trim($_POST['rep_contact']     ?? ''),
                        ':date_submitted'     => trim($_POST['date_submitted']  ?? date('Y-m-d')),
                        ':signature_data'     => $_POST['signature_data']       ?? null,
                        ':proposal_id'        => $proposalId,
                    ]);
                    $cradPdo->prepare("DELETE FROM proposal_members WHERE proposal_id = :pid")->execute([':pid' => $proposalId]);
                    $cradPdo->prepare("DELETE FROM proposal_documents WHERE proposal_id = :pid")->execute([':pid' => $proposalId]);
                } else {
                    // Generate unique reference code: CRD-YYYY-NNNNN
                    $year    = date('Y');
                    $lastRow = $cradPdo->query(
                        "SELECT MAX(id) AS max_id FROM research_proposals"
                    )->fetch();
                    $nextSeq = (int) ($lastRow['max_id'] ?? 0) + 1;
                    $refCode = 'CRD-' . $year . '-' . str_pad((string) $nextSeq, 5, '0', STR_PAD_LEFT);

                    // Insert main proposal record
                    $stmt = $cradPdo->prepare(
                        "INSERT INTO research_proposals
                            (ref_code, research_title, program_course, year_section,
                             college_department, research_adviser, academic_year,
                             rep_name, rep_id, rep_email, rep_contact,
                             status, progress, date_submitted, signature_data, submitted_by_user)
                         VALUES
                            (:ref_code, :research_title, :program_course, :year_section,
                             :college_department, :research_adviser, :academic_year,
                             :rep_name, :rep_id, :rep_email, :rep_contact,
                             'Submitted', 0, :date_submitted, :signature_data, :submitted_by_user)"
                    );
                    $stmt->execute([
                        ':ref_code'           => $refCode,
                        ':research_title'     => trim($_POST['research_title']  ?? ''),
                        ':program_course'     => trim($_POST['program_course']  ?? ''),
                        ':year_section'       => trim($_POST['year_section']    ?? ''),
                        ':college_department' => trim($_POST['college_department'] ?? ''),
                        ':research_adviser'   => trim($_POST['research_adviser'] ?? ''),
                        ':academic_year'      => trim($_POST['academic_year']   ?? ''),
                        ':rep_name'           => trim($_POST['rep_name']        ?? ''),
                        ':rep_id'             => trim($_POST['rep_id']          ?? ''),
                        ':rep_email'          => trim($_POST['rep_email']       ?? ''),
                        ':rep_contact'        => trim($_POST['rep_contact']     ?? ''),
                        ':date_submitted'     => trim($_POST['date_submitted']  ?? date('Y-m-d')),
                        ':signature_data'     => $_POST['signature_data']       ?? null,
                        ':submitted_by_user'  => $userId ?: null,
                    ]);
                    $proposalId = (int) $cradPdo->lastInsertId();
                }

                // Insert group members
                $memberIds      = $_POST['member_id']      ?? [];
                $memberNames    = $_POST['member_name']    ?? [];
                $memberEmails   = $_POST['member_email']   ?? [];
                $memberContacts = $_POST['member_contact'] ?? [];
                $memberStmt = $cradPdo->prepare(
                    "INSERT INTO proposal_members
                        (proposal_id, sort_order, student_id, student_name, email, contact)
                     VALUES
                        (:proposal_id, :sort_order, :student_id, :student_name, :email, :contact)"
                );
                foreach ($memberIds as $i => $mid) {
                    $mid = trim($mid);
                    if ($mid === '') { continue; }
                    $memberStmt->execute([
                        ':proposal_id'  => $proposalId,
                        ':sort_order'   => $i + 1,
                        ':student_id'   => $mid,
                        ':student_name' => trim($memberNames[$i]    ?? ''),
                        ':email'        => trim($memberEmails[$i]   ?? ''),
                        ':contact'      => trim($memberContacts[$i] ?? ''),
                    ]);
                }

                // Insert uploaded document records
                if (!empty($saved)) {
                    $docSlotTitles = array_column($documentSlots, 'title', 'key');
                    $docStmt = $cradPdo->prepare(
                        "INSERT INTO proposal_documents
                            (proposal_id, doc_key, doc_title, original_name, stored_name, file_size)
                         VALUES
                            (:proposal_id, :doc_key, :doc_title, :original_name, :stored_name, :file_size)"
                    );
                    foreach ($saved as $docKey => $docInfo) {
                        $docStmt->execute([
                            ':proposal_id'  => $proposalId,
                            ':doc_key'      => $docKey,
                            ':doc_title'    => $docSlotTitles[$docKey] ?? $docKey,
                            ':original_name'=> $docInfo['original'],
                            ':stored_name'  => $docInfo['stored'],
                            ':file_size'    => $docInfo['size'],
                        ]);
                    }
                }

                // Log initial status
                $logStmt = $cradPdo->prepare(
                    "INSERT INTO proposal_status_logs
                        (proposal_id, old_status, new_status, changed_by, remarks)
                     VALUES
                        (:proposal_id, :old_status, 'Submitted', :changed_by, :remarks)"
                );
                $logStmt->execute([
                    ':proposal_id' => $proposalId,
                    ':old_status' => $isRevision ? 'Returned' : null,
                    ':changed_by'  => $userId ?: null,
                    ':remarks' => $isRevision
                        ? 'Student resubmitted revised document attachments after CRAD return remarks'
                        : 'Initial submission via Student Portal',
                ]);

                try {
                    ensureProposalDraftsTable($cradPdo);
                    $deleteDraft = $cradPdo->prepare(
                        "DELETE FROM proposal_drafts
                         WHERE student_id = :student_id
                           AND revision_ref = :revision_ref"
                    );
                    $deleteDraft->execute([
                        ':student_id' => $studentId,
                        ':revision_ref' => $revisionRef,
                    ]);
                } catch (Throwable $draftDeleteError) {
                    error_log('Proposal draft cleanup error: ' . $draftDeleteError->getMessage());
                }

                if (function_exists('logActivity')) {
                    logActivity(
                        'create',
                        ($isRevision ? 'Resubmitted revised research document packet ref:' : 'Submitted research document packet ref:')
                            . $refCode . ' (' . count($saved) . ' files)',
                        'student_portal'
                    );
                }

                // Return to the student portal with a visible sent-to-CRAD confirmation.
                $successUrl = BASE_URL
                    . '/modules/student-portal/pages/submit-documents.php'
                    . '?sent_ref=' . urlencode($refCode)
                    . '&sent_mode=' . urlencode($isRevision ? 'revision' : 'new')
                    . '&sent_at=' . urlencode(date('Y-m-d H:i:s'));
                header('Location: ' . $successUrl);
                exit;

            } catch (Throwable $e) {
                error_log('CRAD submit error: ' . $e->getMessage());
                $uploadError = 'Submission saved but could not be recorded in the CRAD database. Please contact the CRAD officer. (' . htmlspecialchars($e->getMessage()) . ')';
            }
        }
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && !$sentToCrad) {
    try {
        $cradPdo = getCradDatabaseConnection();
        ensureProposalDraftsTable($cradPdo);
        $draftStmt = $cradPdo->prepare(
            "SELECT draft_data, signature_data, updated_at
             FROM proposal_drafts
             WHERE student_id = :student_id
               AND revision_ref = :revision_ref
             LIMIT 1"
        );
        $draftStmt->execute([
            ':student_id' => $studentId,
            ':revision_ref' => $revisionRef,
        ]);
        $draftRow = $draftStmt->fetch() ?: null;
        if ($draftRow) {
            $decodedDraft = json_decode((string) $draftRow['draft_data'], true);
            if (is_array($decodedDraft)) {
                $savedDraftData = $decodedDraft;
                $savedDraftRevisionRef = (string) ($draftRow['revision_ref'] ?? '');
                if (!empty($draftRow['signature_data'])) {
                    $savedDraftData['signature_data'] = (string) $draftRow['signature_data'];
                }
                $draftTime = strtotime((string) $draftRow['updated_at']);
                $savedDraftUpdatedAt = $draftTime ? date('F j, Y h:i A', $draftTime) : '';
            }
        }
    } catch (Throwable $e) {
        error_log('Proposal draft load error: ' . $e->getMessage());
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $showDrafts) {
    try {
        $cradPdo = getCradDatabaseConnection();
        ensureProposalDraftsTable($cradPdo);
        $listStmt = $cradPdo->prepare(
            "SELECT id, revision_ref, draft_data, updated_at
             FROM proposal_drafts
             WHERE student_id = :student_id
             ORDER BY updated_at DESC"
        );
        $listStmt->execute([':student_id' => $studentId]);
        foreach (($listStmt->fetchAll() ?: []) as $draftRow) {
            $decodedDraft = json_decode((string) $draftRow['draft_data'], true);
            if (!is_array($decodedDraft)) {
                $decodedDraft = [];
            }
            $draftList[] = [
                'id' => (int) $draftRow['id'],
                'revision_ref' => (string) $draftRow['revision_ref'],
                'title' => trim((string) ($decodedDraft['research_title'] ?? 'Untitled research draft')),
                'program_course' => trim((string) ($decodedDraft['program_course'] ?? '')),
                'date_submitted' => trim((string) ($decodedDraft['date_submitted'] ?? '')),
                'updated_at' => (string) $draftRow['updated_at'],
            ];
        }
    } catch (Throwable $e) {
        error_log('Proposal draft list error: ' . $e->getMessage());
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && !$showDrafts && $revisionRef === '') {
    try {
        $cradPdo = getCradDatabaseConnection();
        $currentSubmission = getStudentLatestProposal($cradPdo, $studentId, $studentEmail, $studentNameForMatch, $userId, $sentRef);
        if ($currentSubmission) {
            $sentToCrad = true;
            $sentRef = (string) $currentSubmission['ref_code'];
            $sentMode = $sentMode !== '' ? $sentMode : 'new';
            $sentTime = strtotime((string) ($currentSubmission['created_at'] ?? ''));
            $sentAt = $sentTime ? date('F j, Y h:i A', $sentTime) : $sentAt;
        }
    } catch (Throwable $e) {
        error_log('Student document status load error: ' . $e->getMessage());
    }
}

$pageTitle = 'Submit Documents';
$activeModule = 'student_portal';
$activePage = 'submit-documents';
$breadcrumbs = [
    ['label' => 'Student Portal', 'url' => BASE_URL . '/modules/student-portal/pages/my-profile.php'],
    ['label' => 'Submit Documents', 'url' => null],
];

$departments = [
    'College of Computer Studies',
    'College of Business Administration',
    'College of Education',
    'College of Criminal Justice',
    'College of Hospitality & Tourism Management',
    'College of Nursing and Health Sciences',
];

$academicYears = [
    'A.Y. 2025-2026',
    'A.Y. 2026-2027',
    'A.Y. 2027-2028',
];

require_once ROOT_PATH . '/includes/layout-start.php';
?>

<?php renderBreadcrumbs($breadcrumbs); ?>

<div class="student-portal doc-vault-wrap">
    <?php if ($uploadError !== ''): ?>
        <div class="alert alert-danger student-process-alert" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i><?= e($uploadError) ?>
        </div>
    <?php endif; ?>
    <?php if ($submitted): ?>
        <div class="alert alert-success student-process-alert" role="alert">
            <i class="fas fa-check-circle me-2"></i>Document packet has been submitted securely to the CRD Document Vault for review.
        </div>
    <?php endif; ?>

    <?php if ($showDrafts): ?>
        <section class="doc-drafts-card">
            <header class="doc-drafts-header">
                <div>
                    <span class="doc-vault-kicker">Saved Drafts</span>
                    <h1>Research Document Drafts</h1>
                    <p>Only one active draft is kept for your student account. Saving again replaces the previous draft.</p>
                </div>
                <a class="doc-btn doc-btn-ghost" href="<?= BASE_URL ?>/modules/student-portal/pages/submit-documents.php">
                    <i class="fas fa-file-upload me-2"></i>New Form
                </a>
            </header>
            <?php if (empty($draftList)): ?>
                <div class="doc-empty-drafts">
                    <i class="fas fa-folder-open"></i>
                    <strong>No saved draft yet.</strong>
                    <span>Use Save Draft on the document form to store your current work in the CRAD draft database.</span>
                </div>
            <?php else: ?>
                <div class="doc-draft-list">
                    <?php foreach ($draftList as $draft): ?>
                        <?php
                            $draftUpdated = strtotime((string) $draft['updated_at']);
                            $continueUrl = BASE_URL . '/modules/student-portal/pages/submit-documents.php';
                            if ($draft['revision_ref'] !== '') {
                                $continueUrl .= '?revision_ref=' . urlencode($draft['revision_ref']);
                            }
                        ?>
                        <article class="doc-draft-item">
                            <div>
                                <span class="doc-draft-type"><?= $draft['revision_ref'] !== '' ? 'Revision Draft' : 'New Submission Draft' ?></span>
                                <h2><?= htmlspecialchars($draft['title'] !== '' ? $draft['title'] : 'Untitled research draft') ?></h2>
                                <p>
                                    <?= htmlspecialchars($draft['program_course'] !== '' ? $draft['program_course'] : 'No program set yet') ?>
                                    <?php if ($draft['revision_ref'] !== ''): ?>
                                        · <?= htmlspecialchars($draft['revision_ref']) ?>
                                    <?php endif; ?>
                                </p>
                            </div>
                            <div class="doc-draft-meta">
                                <span>Last Saved</span>
                                <strong><?= htmlspecialchars($draftUpdated ? date('F j, Y h:i A', $draftUpdated) : 'Unknown') ?></strong>
                            </div>
                            <a class="doc-btn doc-btn-purple" href="<?= htmlspecialchars($continueUrl) ?>">
                                <i class="fas fa-pen-to-square me-2"></i>Continue Draft
                            </a>
                        </article>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </section>
    <?php elseif ($sentToCrad): ?>
        <?php
            $displayStatus = (string) ($currentSubmission['status'] ?? 'Submitted');
            $displayTitle = trim((string) ($currentSubmission['research_title'] ?? 'Research document packet'));
            $displayProgress = (int) ($currentSubmission['progress'] ?? 0);
            $updatedTime = strtotime((string) ($currentSubmission['updated_at'] ?? ''));
            $displayUpdated = $updatedTime ? date('F j, Y h:i A', $updatedTime) : $sentAt;
        ?>
        <section class="doc-sent-card" role="status" aria-live="polite" data-status-ref="<?= htmlspecialchars($sentRef) ?>">
            <div class="doc-sent-icon"><i class="fas fa-paper-plane"></i></div>
            <div class="doc-sent-body">
                <span class="doc-vault-kicker">Sent to CRAD Officer</span>
                <h1><?= $sentMode === 'revision' ? 'Revised document packet sent' : 'Document packet sent' ?></h1>
                <p>Your research document packet was submitted successfully and is now queued for CRAD review.</p>
                <div class="doc-sent-grid">
                    <div>
                        <span>Research Title</span>
                        <strong id="docStatusTitle"><?= htmlspecialchars($displayTitle) ?></strong>
                    </div>
                    <div>
                        <span>Current Status</span>
                        <strong id="docLiveStatus"><?= htmlspecialchars($displayStatus) ?></strong>
                    </div>
                    <div>
                        <span>Last Updated</span>
                        <strong id="docStatusUpdated"><?= htmlspecialchars($displayUpdated) ?></strong>
                    </div>
                </div>
                <div class="doc-status-track">
                    <div>
                        <span>Tracking Progress</span>
                        <strong id="docStatusProgressText"><?= $displayProgress ?>%</strong>
                    </div>
                    <div class="doc-status-bar"><span id="docStatusProgressBar" style="width: <?= max(0, min(100, $displayProgress)) ?>%;"></span></div>
                </div>
            </div>
            <div class="doc-sent-actions">
                <a class="doc-btn doc-btn-purple" href="<?= BASE_URL ?>/modules/student-portal/pages/dashboard.php">
                    <i class="fas fa-chart-line me-2"></i>Dashboard
                </a>
            </div>
        </section>
    <?php else: ?>

    <form class="doc-vault-form" id="docVaultForm" method="post" action="" enctype="multipart/form-data">
        <?= csrfField() ?>
        <input type="hidden" name="process" value="submit-documents" id="docProcessField">
        <input type="hidden" name="revision_ref" value="<?= htmlspecialchars($revisionRef) ?>">

        <header class="doc-vault-header">
            <div>
                <span class="doc-vault-kicker">CRD Document Vault Sub-Module</span>
                <h1><?= $revisionProposal ? 'Update Returned Document Attachments' : 'Research Document Attachment Form' ?></h1>
                <p><?= $revisionProposal ? 'Resubmit revised files for ' . htmlspecialchars((string) $revisionProposal['ref_code']) . ' after reviewing CRAD remarks.' : 'Formal system submission and storage matching program checklist guidelines.' ?></p>
            </div>
            <a class="doc-btn doc-btn-ghost" href="<?= BASE_URL ?>/modules/student-portal/pages/submit-documents.php?view=drafts">
                <i class="fas fa-folder-open me-2"></i>Drafts
            </a>
        </header>

        <div class="doc-draft-alert-wrap">
            <div id="docDraftStatus" class="doc-draft-alert" style="display:none;" role="status" aria-live="polite">
                <i class="fas fa-save"></i>
                <div>
                    <strong id="docDraftTitle">Draft saved.</strong>
                    <span id="docDraftText">Your form details were saved to the CRAD draft database.</span>
                </div>
            </div>
        </div>

        <div class="doc-requirement-note-wrap">
            <div id="docRequirementNotice" class="doc-requirement-note<?= ($uploadError !== '' || !$canSubmitDocumentPacket) ? ' is-error' : '' ?>" role="status" aria-live="polite">
                <i id="docRequirementIcon" class="fas <?= ($uploadError !== '' || !$canSubmitDocumentPacket) ? 'fa-triangle-exclamation' : 'fa-circle-info' ?>"></i>
                <div>
                    <strong id="docRequirementTitle"><?= $uploadError !== '' ? 'Form packet was not submitted.' : (!$canSubmitDocumentPacket ? 'Bawal pa mag-submit.' : 'Before sending to CRAD') ?></strong>
                    <span id="docRequirementText">
                        <?php if ($uploadError !== ''): ?>
                            Please fix this issue first: <?= e($uploadError) ?>
                        <?php elseif (!$canSubmitDocumentPacket): ?>
                            <?= e($documentPacketBlockNote) ?>
                        <?php else: ?>
                            Complete all required fields, upload valid required documents, check the declaration, and draw the representative signature before submitting. If any requirement is missing or invalid, the packet will not be sent to CRAD.
                        <?php endif; ?>
                    </span>
                </div>
            </div>
        </div>

        <?php if ($revisionProposal): ?>
            <div class="alert alert-danger m-3 mb-0" role="alert">
                <div class="fw-bold mb-1"><i class="fas fa-undo me-2"></i>CRAD returned this proposal for revision.</div>
                <div class="small mb-2">Returned on <?= htmlspecialchars(date('F j, Y h:i A', strtotime((string) $revisionProposal['updated_at']))) ?></div>
                <div><?= nl2br(htmlspecialchars((string) ($revisionProposal['notes'] ?: 'Returned for revision. Please review the required corrections.'))) ?></div>
            </div>
        <?php endif; ?>

        <section class="doc-section">
            <h2><span></span>Research Information</h2>
            <div class="doc-field">
                <label for="researchTitle">Research Title <em>*</em></label>
                <input type="text" id="researchTitle" name="research_title" placeholder="ENTER COMPLETE APPROVED RESEARCH TITLE" value="<?= htmlspecialchars((string) ($revisionProposal['research_title'] ?? '')) ?>" required>
            </div>
            <div class="doc-grid-2">
                <div class="doc-field">
                    <label for="programCourse">Program / Course <em>*</em></label>
                    <input type="text" id="programCourse" name="program_course" value="<?= htmlspecialchars((string) ($revisionProposal['program_course'] ?? 'BS in Information Technology')) ?>" required>
                </div>
                <div class="doc-field">
                    <label for="yearSection">Year &amp; Section <em>*</em></label>
                    <input type="text" id="yearSection" name="year_section" value="<?= htmlspecialchars((string) ($revisionProposal['year_section'] ?? 'BSIT 4101')) ?>" required>
                </div>
            </div>
            <div class="doc-grid-2">
                <div class="doc-field">
                    <label for="collegeDept">College / Department <em>*</em></label>
                    <select id="collegeDept" name="college_department" required>
                        <?php foreach ($departments as $dept): ?>
                            <option value="<?= htmlspecialchars($dept) ?>" <?= $dept === ($revisionProposal['college_department'] ?? 'College of Computer Studies') ? 'selected' : '' ?>>
                                <?= htmlspecialchars($dept) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="doc-field">
                    <label for="researchAdviser">Research Adviser <em>*</em></label>
                    <input type="text" id="researchAdviser" name="research_adviser" placeholder="Instructor / Doctor Name" value="<?= htmlspecialchars((string) ($revisionProposal['research_adviser'] ?? 'Dr. Roberto M. Santos')) ?>" required>
                </div>
            </div>
            <div class="doc-field doc-field-half">
                <label for="academicYear">Academic Year <em>*</em></label>
                <select id="academicYear" name="academic_year" required>
                    <?php foreach ($academicYears as $year): ?>
                        <option value="<?= htmlspecialchars($year) ?>" <?= $year === ($revisionProposal['academic_year'] ?? 'A.Y. 2026-2027') ? 'selected' : '' ?>>
                            <?= htmlspecialchars($year) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
        </section>

        <section class="doc-section">
            <h2><span></span>Group Members <small>(Maximum 5)</small></h2>
            <div class="doc-members-table">
                <div class="doc-members-head">
                    <span>#</span>
                    <span>Student ID *</span>
                    <span>Student Name *</span>
                    <span>Email Address *</span>
                    <span>Contact Number *</span>
                </div>
                <?php for ($i = 1; $i <= 5; $i++): ?>
                    <?php $revisionMember = $revisionMembers[$i - 1] ?? null; ?>
                    <div class="doc-members-row">
                        <span><?= $i ?></span>
                        <input type="text" name="member_id[]" placeholder="e.g. 2022-0451" value="<?= htmlspecialchars((string) ($revisionMember['student_id'] ?? ($i === 1 ? $studentId : ''))) ?>" <?= $i === 1 ? 'required' : '' ?>>
                        <input type="text" name="member_name[]" placeholder="e.g. Dela Cruz, Juan A." value="<?= htmlspecialchars((string) ($revisionMember['student_name'] ?? ($i === 1 ? $defaultMemberName : ''))) ?>" <?= $i === 1 ? 'required' : '' ?>>
                        <input type="email" name="member_email[]" placeholder="e.g. student@bcp.edu.ph" value="<?= htmlspecialchars((string) ($revisionMember['email'] ?? ($i === 1 ? 's' . preg_replace('/\D+/', '', $studentId) . '@bcp.edu.ph' : ''))) ?>" <?= $i === 1 ? 'required' : '' ?>>
                        <input type="text" name="member_contact[]" placeholder="e.g. 09XXXXXXXXX" value="<?= htmlspecialchars((string) ($revisionMember['contact'] ?? ($i === 1 ? '09171234567' : ''))) ?>" <?= $i === 1 ? 'required' : '' ?>>
                    </div>
                <?php endfor; ?>
            </div>
        </section>

        <section class="doc-section">
            <h2><span></span>Document Attachments</h2>
            <div class="doc-attach-notice" id="docAttachNotice">
                <i class="fas fa-info-circle"></i>
                <div>
                    <strong>All required documents must be uploaded before submitting.</strong>
                    <span>Upload each file marked <em>REQUIRED</em> to enable the Submit Form Packet button. Allowed formats: PDF, DOCX, JPG, or PNG. Max 10MB per file.</span>
                </div>
            </div>
            <div id="docMissingAlert" class="doc-missing-alert" style="display:none;">
                <i class="fas fa-exclamation-triangle"></i>
                <span id="docMissingText">Please upload all required documents before submitting.</span>
            </div>
            <div class="doc-upload-grid">
                <?php foreach ($documentSlots as $slot): ?>
                    <label class="doc-upload-card" for="file_<?= htmlspecialchars($slot['key']) ?>">
                        <span class="doc-tag <?= $slot['required'] ? 'required' : 'optional' ?>">
                            <?= $slot['required'] ? 'REQUIRED' : 'OPTIONAL' ?>
                        </span>
                        <strong><?= htmlspecialchars($slot['title']) ?></strong>
                        <small><?= htmlspecialchars($slot['desc']) ?></small>
                        <span class="doc-upload-btn"><i class="fas fa-cloud-upload-alt"></i> Upload Document File</span>
                        <input type="file" id="file_<?= htmlspecialchars($slot['key']) ?>" name="<?= htmlspecialchars($slot['key']) ?>" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png" <?= $slot['required'] ? 'required' : '' ?>>
                        <em class="doc-file-name" data-file-label>No file selected</em>
                    </label>
                <?php endforeach; ?>
            </div>
        </section>

        <section class="doc-section">
            <div class="doc-section-head">
                <div>
                    <h2><span></span>Group Representative</h2>
                    <p class="doc-hint">Primary point of contact for CRD response routing.</p>
                </div>
                <button type="button" class="doc-btn doc-btn-purple-soft" id="autoFillRepBtn">← Auto-fill from Member 1</button>
            </div>
            <div class="doc-grid-2">
                <div class="doc-field">
                    <label for="repName">Representative Name <em>*</em></label>
                    <input type="text" id="repName" name="rep_name" value="<?= htmlspecialchars((string) ($revisionProposal['rep_name'] ?? $defaultMemberName)) ?>" required>
                </div>
                <div class="doc-field">
                    <label for="repId">Student ID <em>*</em></label>
                    <input type="text" id="repId" name="rep_id" value="<?= htmlspecialchars((string) ($revisionProposal['rep_id'] ?? $studentId)) ?>" required>
                </div>
                <div class="doc-field">
                    <label for="repEmail">Email Address <em>*</em></label>
                    <input type="email" id="repEmail" name="rep_email" value="<?= htmlspecialchars((string) ($revisionProposal['rep_email'] ?? ('s' . preg_replace('/\D+/', '', $studentId) . '@bcp.edu.ph'))) ?>" required>
                </div>
                <div class="doc-field">
                    <label for="repContact">Contact Number <em>*</em></label>
                    <input type="text" id="repContact" name="rep_contact" value="<?= htmlspecialchars((string) ($revisionProposal['rep_contact'] ?? '09171234567')) ?>" required>
                </div>
            </div>
        </section>

        <section class="doc-section">
            <h2><span></span>Final Declaration &amp; Representative Signature</h2>
            <div id="signatureMissingAlert" class="doc-signature-alert" style="display:none;">
                <i class="fas fa-pen-nib"></i>
                <div>
                    <strong>Representative signature is required.</strong>
                    <span>Please draw the representative signature before submitting the document packet.</span>
                </div>
            </div>
            <label class="doc-check">
                <input type="checkbox" id="declarationCheck" name="declaration" value="1" required>
                <span>We certify that the information provided is true and correct. We further certify that all uploaded documents are authentic, complete, and submitted on behalf of all members of the research group.</span>
            </label>
            <div class="doc-signature-row">
                <div class="doc-signature-pad-wrap">
                    <div class="doc-signature-label">
                        <span>Representative Signature Pad (Draw Below):</span>
                        <button type="button" id="clearPadBtn">Clear Pad</button>
                    </div>
                    <canvas id="signaturePad" width="760" height="180" aria-label="Signature pad"></canvas>
                    <input type="hidden" name="signature_data" id="signatureData">
                </div>
                <div class="doc-field">
                    <label for="dateSubmitted">Date Submitted <em>*</em></label>
                    <input type="date" id="dateSubmitted" name="date_submitted" value="<?= htmlspecialchars((string) ($revisionProposal['date_submitted'] ?? date('Y-m-d'))) ?>" required>
                </div>
            </div>
        </section>

        <footer class="doc-form-footer">
            <button type="button" class="doc-btn doc-btn-muted" id="saveDraftBtn">Save Draft</button>
            <button type="button" class="doc-btn doc-btn-purple" id="submitPacketBtn"><i class="fas fa-file-upload me-2"></i><?= $revisionProposal ? 'Submit Revised Attachments' : 'Submit Form Packet' ?></button>
            <a class="doc-btn doc-btn-ghost" href="<?= BASE_URL ?>/modules/student-portal/pages/my-profile.php">Cancel</a>
        </footer>
    </form>
    <?php endif; ?>
</div>

<style>
.doc-vault-wrap {
    --doc-purple: #7c3aed;
    --doc-purple-2: #8b5cf6;
    max-width: 100%;
    margin: 0;
    padding: 0 0.25rem;
}
.doc-sent-card {
    display: grid;
    grid-template-columns: auto 1fr auto;
    gap: 1rem;
    align-items: center;
    padding: 1.25rem;
    border: 1px solid rgba(34,197,94,0.35);
    border-radius: 16px;
    background: linear-gradient(135deg, rgba(16,185,129,0.15), rgba(124,58,237,0.12));
    color: #f8fafc;
    box-shadow: 0 18px 40px rgba(0,0,0,0.18);
}
.doc-sent-icon {
    width: 54px;
    height: 54px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 16px;
    background: rgba(16,185,129,0.18);
    color: #34d399;
    font-size: 1.35rem;
}
.doc-sent-body h1 {
    margin: 0 0 0.35rem;
    font-size: 1.45rem;
    font-weight: 800;
}
.doc-sent-body p {
    margin: 0 0 0.9rem;
    color: #cbd5e1;
}
.doc-sent-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(160px, 1fr));
    gap: 0.75rem;
}
.doc-sent-grid div {
    padding: 0.85rem;
    border: 1px solid rgba(148,163,184,0.18);
    border-radius: 12px;
    background: rgba(15,23,42,0.45);
}
.doc-sent-grid span {
    display: block;
    margin-bottom: 0.3rem;
    color: #94a3b8;
    font-size: 0.72rem;
    font-weight: 800;
    text-transform: uppercase;
}
.doc-sent-grid strong {
    display: block;
    color: #f8fafc;
    font-size: 0.95rem;
}
.doc-status-track {
    margin-top: 0.85rem;
    padding: 0.85rem;
    border: 1px solid rgba(148,163,184,0.18);
    border-radius: 12px;
    background: rgba(15,23,42,0.32);
}
.doc-status-track > div:first-child {
    display: flex;
    justify-content: space-between;
    gap: 1rem;
    margin-bottom: 0.55rem;
}
.doc-status-track span {
    color: #94a3b8;
    font-size: 0.72rem;
    font-weight: 800;
    text-transform: uppercase;
}
.doc-status-track strong {
    color: #f8fafc;
    font-size: 0.9rem;
}
.doc-status-bar {
    height: 9px;
    overflow: hidden;
    border-radius: 999px;
    background: rgba(148,163,184,0.22);
}
.doc-status-bar span {
    display: block;
    height: 100%;
    border-radius: inherit;
    background: linear-gradient(90deg, #22c55e, #8b5cf6);
    transition: width 0.35s ease;
}
.doc-sent-actions {
    display: flex;
    gap: 0.65rem;
    align-items: center;
    justify-content: flex-end;
    flex-wrap: wrap;
}
.doc-drafts-card {
    overflow: hidden;
    border: 1px solid rgba(148,163,184,0.14);
    border-radius: 18px;
    background: linear-gradient(180deg, #171a20 0%, #12151a 45%);
    color: #f8fafc;
    box-shadow: 0 18px 40px rgba(0,0,0,0.28);
}
.doc-drafts-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 1rem;
    padding: 1.35rem 1.4rem 1.1rem;
    background: linear-gradient(135deg, #2e1065 0%, #4c1d95 45%, #111827 100%);
}
.doc-drafts-header h1 {
    margin: 0;
    color: #fff;
    font-size: 1.45rem;
    font-weight: 800;
}
.doc-drafts-header p {
    margin: 0.35rem 0 0;
    color: #ddd6fe;
    font-size: 0.9rem;
}
.doc-empty-drafts {
    display: grid;
    gap: 0.35rem;
    justify-items: center;
    padding: 3rem 1rem;
    color: #94a3b8;
    text-align: center;
}
.doc-empty-drafts i {
    color: #a78bfa;
    font-size: 1.7rem;
}
.doc-empty-drafts strong {
    color: #f8fafc;
    font-size: 1rem;
}
.doc-draft-list {
    display: grid;
    gap: 0.85rem;
    padding: 1rem;
}
.doc-draft-item {
    display: grid;
    grid-template-columns: minmax(0,1fr) 220px auto;
    gap: 1rem;
    align-items: center;
    padding: 1rem;
    border: 1px solid rgba(148,163,184,0.18);
    border-radius: 12px;
    background: rgba(15,23,42,0.42);
}
.doc-draft-item h2 {
    margin: 0.2rem 0;
    color: #f8fafc;
    font-size: 1rem;
    font-weight: 800;
}
.doc-draft-item p {
    margin: 0;
    color: #94a3b8;
    font-size: 0.84rem;
}
.doc-draft-type,
.doc-draft-meta span {
    color: #a78bfa;
    font-size: 0.7rem;
    font-weight: 800;
    letter-spacing: 0.04em;
    text-transform: uppercase;
}
.doc-draft-meta strong {
    display: block;
    margin-top: 0.25rem;
    color: #f8fafc;
    font-size: 0.86rem;
}
.doc-vault-form {
    --doc-bg: #12151a;
    --doc-panel: #181c22;
    --doc-input: #222831;
    --doc-line: rgba(148,163,184,0.2);
    --doc-purple: #7c3aed;
    --doc-purple-2: #8b5cf6;
    overflow: hidden; border: 1px solid rgba(148,163,184,0.14); border-radius: 18px;
    background: linear-gradient(180deg, #171a20 0%, var(--doc-bg) 40%);
    color: #f8fafc; box-shadow: 0 18px 40px rgba(0,0,0,0.28);
}
.doc-vault-header {
    display: flex; align-items: flex-start; justify-content: space-between; gap: 1rem;
    padding: 1.35rem 1.4rem 1.1rem;
    background: linear-gradient(135deg, #2e1065 0%, #4c1d95 45%, #111827 100%);
}
.doc-vault-kicker {
    display: inline-block; margin-bottom: 0.35rem; color: #c4b5fd;
    font-size: 0.72rem; font-weight: 800; letter-spacing: 0.08em; text-transform: uppercase;
}
.doc-vault-header h1 { margin: 0; color: #fff; font-size: 1.45rem; font-weight: 800; }
.doc-vault-header p { margin: 0.35rem 0 0; color: #ddd6fe; font-size: 0.9rem; }
.doc-section {
    padding: 1.2rem 1.4rem; border-bottom: 1px solid var(--doc-line);
}
.doc-section h2 {
    display: flex; align-items: center; gap: 0.55rem;
    margin: 0 0 1rem; color: #fff; font-size: 0.98rem; font-weight: 800;
}
.doc-section h2 span {
    width: 8px; height: 8px; border-radius: 50%; background: var(--doc-purple-2);
}
.doc-section h2 small { color: #94a3b8; font-size: 0.78rem; font-weight: 600; }
.doc-section-head {
    display: flex; align-items: flex-start; justify-content: space-between; gap: 1rem; margin-bottom: 0.85rem;
}
.doc-section-head h2 { margin-bottom: 0.25rem; }
.doc-hint { margin: -0.35rem 0 1rem; color: #94a3b8; font-size: 0.82rem; }
.doc-field { display: grid; gap: 0.4rem; margin-bottom: 0.9rem; }
.doc-field label {
    color: #cbd5e1; font-size: 0.72rem; font-weight: 700;
    letter-spacing: 0.04em; text-transform: uppercase;
}
.doc-field label em { color: #f87171; font-style: normal; }
.doc-field input,
.doc-field select,
.doc-members-row input {
    width: 100%; min-height: 42px; padding: 0.65rem 0.8rem;
    border: 1px solid var(--doc-line); border-radius: 10px;
    background: var(--doc-input); color: #fff; font-size: 0.9rem; outline: none;
}
.doc-field select {
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath fill='%94a3b8' d='M1 1l5 5 5-5'/%3E%3C/svg%3E");
    background-repeat: no-repeat; background-position: right 0.9rem center; padding-right: 2.2rem;
}
.doc-field input:focus,
.doc-field select:focus,
.doc-members-row input:focus {
    border-color: #a78bfa; box-shadow: 0 0 0 3px rgba(124,58,237,0.18);
}
.doc-grid-2 { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 0.9rem; }
.doc-field-half { max-width: 50%; }
.doc-members-table {
    overflow: hidden; border: 1px solid var(--doc-line); border-radius: 12px; background: var(--doc-panel);
}
.doc-members-head, .doc-members-row {
    display: grid; grid-template-columns: 36px 1fr 1.2fr 1.2fr 1fr; gap: 0.55rem; align-items: center;
}
.doc-members-head {
    padding: 0.7rem 0.75rem; background: #1f2430; color: #94a3b8;
    font-size: 0.68rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.04em;
}
.doc-members-row { padding: 0.55rem 0.75rem; border-top: 1px solid var(--doc-line); }
.doc-members-row > span { color: #a78bfa; font-weight: 800; text-align: center; }
.doc-upload-grid { display: grid; grid-template-columns: repeat(3,minmax(0,1fr)); gap: 0.85rem; }
.doc-upload-card {
    display: grid; gap: 0.45rem; padding: 0.95rem;
    border: 1px dashed rgba(167,139,250,0.35); border-radius: 12px;
    background: var(--doc-panel); cursor: pointer;
}
.doc-upload-card strong { color: #fff; font-size: 0.88rem; }
.doc-upload-card small { color: #94a3b8; font-size: 0.78rem; line-height: 1.35; }
.doc-tag {
    display: inline-flex; width: fit-content; padding: 0.18rem 0.45rem; border-radius: 999px;
    font-size: 0.62rem; font-weight: 800; letter-spacing: 0.04em;
}
.doc-tag.required { color: #fecaca; background: rgba(239,68,68,0.16); }
.doc-tag.optional { color: #cbd5e1; background: rgba(148,163,184,0.16); }
.doc-upload-btn {
    display: inline-flex; align-items: center; justify-content: center; gap: 0.4rem;
    min-height: 38px; margin-top: 0.25rem; border-radius: 9px;
    background: rgba(124,58,237,0.16); color: #c4b5fd; font-size: 0.78rem; font-weight: 700;
}
.doc-upload-card input { display: none; }
.doc-file-name { color: #64748b; font-size: 0.72rem; font-style: normal; }
.doc-check {
    display: flex; align-items: flex-start; gap: 0.7rem; margin-bottom: 1rem;
    color: #cbd5e1; font-size: 0.86rem; line-height: 1.45;
}
.doc-check input { margin-top: 0.2rem; accent-color: var(--doc-purple); }
.doc-signature-row {
    display: grid; grid-template-columns: minmax(0,1fr) 220px; gap: 1rem; align-items: start;
}
.doc-signature-pad-wrap {
    overflow: hidden; border: 1px solid var(--doc-line); border-radius: 12px; background: #0b0d11;
}
.doc-signature-label {
    display: flex; align-items: center; justify-content: space-between; gap: 0.75rem;
    padding: 0.65rem 0.85rem; border-bottom: 1px solid var(--doc-line);
    color: #94a3b8; font-size: 0.75rem; font-weight: 700; text-transform: uppercase;
}
.doc-signature-label button {
    border: 0; background: transparent; color: #c4b5fd; font-size: 0.75rem; font-weight: 700; cursor: pointer;
}
#signaturePad { display: block; width: 100%; height: 180px; cursor: crosshair; touch-action: none; }
.doc-btn {
    display: inline-flex; align-items: center; justify-content: center; gap: 0.35rem;
    min-height: 42px; padding: 0.55rem 1rem; border-radius: 10px;
    border: 1px solid transparent; font-size: 0.88rem; font-weight: 700;
    text-decoration: none; cursor: pointer;
}
.doc-btn-ghost { color: #e2e8f0; background: rgba(15,23,42,0.28); border-color: rgba(226,232,240,0.28); }
.doc-btn-muted { color: #e2e8f0; background: #2a303a; border-color: #3f4654; }
.doc-btn-purple { color: #fff; background: var(--doc-purple); border-color: var(--doc-purple); box-shadow: 0 8px 20px rgba(124,58,237,0.35); }
.doc-btn-purple-soft { color: #ede9fe; background: rgba(124,58,237,0.22); border-color: rgba(167,139,250,0.35); }
.doc-form-footer {
    display: flex; justify-content: flex-end; flex-wrap: wrap; gap: 0.7rem;
    padding: 1rem 1.4rem 1.35rem;
}
/* ── Document attachment notice & validation UI ── */
.doc-attach-notice {
    display: flex; align-items: flex-start; gap: 0.75rem;
    padding: 0.85rem 1rem; margin-bottom: 1rem;
    border: 1px solid rgba(99,179,237,0.35); border-radius: 10px;
    background: rgba(99,179,237,0.08); color: #7dd3fc;
    font-size: 0.83rem; line-height: 1.5;
}
.doc-attach-notice i { margin-top: 0.1rem; flex-shrink: 0; font-size: 1rem; color: #38bdf8; }
.doc-attach-notice strong { display: block; margin-bottom: 0.2rem; font-weight: 700; color: #e0f2fe; font-size: 0.85rem; }
.doc-attach-notice em { font-style: normal; font-weight: 700; color: #fca5a5; }
.doc-attach-notice span { color: #94a3b8; }

.doc-missing-alert {
    display: flex; align-items: center; gap: 0.65rem;
    padding: 0.8rem 1rem; margin-bottom: 1rem;
    border: 1px solid rgba(239,68,68,0.35); border-radius: 10px;
    background: rgba(239,68,68,0.1); color: #fca5a5;
    font-size: 0.84rem; font-weight: 600;
}
.doc-missing-alert i { flex-shrink: 0; font-size: 1rem; }
.doc-signature-alert {
    display: flex; align-items: flex-start; gap: 0.75rem;
    padding: 0.85rem 1rem; margin-bottom: 1rem;
    border: 1px solid rgba(245,158,11,0.4); border-radius: 10px;
    background: rgba(245,158,11,0.12); color: #fde68a;
    font-size: 0.84rem; line-height: 1.45;
}
.doc-signature-alert i { margin-top: 0.12rem; flex-shrink: 0; color: #fbbf24; font-size: 1rem; }
.doc-signature-alert strong { display: block; margin-bottom: 0.2rem; color: #fef3c7; font-weight: 800; }
.doc-signature-alert span { color: #fde68a; font-weight: 600; }
.doc-draft-alert-wrap {
    display: flex;
    justify-content: center;
    padding: 1.1rem 1rem 0;
}
.doc-draft-alert {
    display: flex; align-items: flex-start; gap: 0.85rem;
    width: min(760px, 100%);
    padding: 1rem 1.1rem;
    border: 1px solid rgba(34,197,94,0.38); border-radius: 14px;
    background:
        linear-gradient(135deg, rgba(34,197,94,0.16), rgba(14,165,233,0.08)),
        rgba(15,23,42,0.72);
    color: #bbf7d0;
    font-size: 0.86rem; line-height: 1.45;
    box-shadow: 0 14px 32px rgba(15,23,42,0.22);
}
.doc-draft-alert i {
    width: 38px;
    height: 38px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    border-radius: 12px;
    background: rgba(34,197,94,0.18);
    color: #4ade80;
    font-size: 1rem;
}
.doc-draft-alert strong { display: block; margin-bottom: 0.2rem; color: #dcfce7; font-weight: 900; font-size: 0.95rem; }
.doc-draft-alert span { color: #bbf7d0; font-weight: 650; }
.doc-draft-alert.is-error {
    border-color: rgba(239,68,68,0.35);
    background:
        linear-gradient(135deg, rgba(239,68,68,0.14), rgba(245,158,11,0.08)),
        rgba(15,23,42,0.72);
    color: #fecaca;
}
.doc-draft-alert.is-error i { background: rgba(239,68,68,0.16); }
.doc-draft-alert.is-error i,
.doc-draft-alert.is-error strong,
.doc-draft-alert.is-error span { color: #fecaca; }
.doc-requirement-note-wrap {
    display: flex;
    justify-content: center;
    padding: 0.9rem 1rem 0;
}
.doc-requirement-note {
    display: flex; align-items: flex-start; gap: 0.85rem;
    width: min(900px, 100%);
    padding: 1rem 1.1rem;
    border: 1px solid rgba(124,58,237,0.32); border-radius: 14px;
    background:
        linear-gradient(135deg, rgba(124,58,237,0.13), rgba(14,165,233,0.08)),
        rgba(15,23,42,0.72);
    color: #ddd6fe;
    font-size: 0.86rem; line-height: 1.45;
    box-shadow: 0 14px 32px rgba(15,23,42,0.2);
}
.doc-requirement-note i {
    width: 38px;
    height: 38px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    border-radius: 12px;
    background: rgba(124,58,237,0.18);
    color: #c4b5fd;
    font-size: 1rem;
}
.doc-requirement-note strong { display: block; margin-bottom: 0.2rem; color: #f5f3ff; font-weight: 900; font-size: 0.95rem; }
.doc-requirement-note span { color: #ddd6fe; font-weight: 650; }
.doc-requirement-note.is-error {
    border-color: rgba(239,68,68,0.42);
    background:
        linear-gradient(135deg, rgba(239,68,68,0.15), rgba(245,158,11,0.08)),
        rgba(15,23,42,0.72);
    color: #fecaca;
}
.doc-requirement-note.is-error i { background: rgba(239,68,68,0.16); }
.doc-requirement-note.is-error i,
.doc-requirement-note.is-error strong,
.doc-requirement-note.is-error span { color: #fecaca; }

/* Card state when required file is missing and submit was attempted */
.doc-upload-card--missing {
    border-color: rgba(239,68,68,0.65) !important;
    background: rgba(239,68,68,0.06) !important;
}
.doc-upload-card--missing .doc-upload-btn {
    background: rgba(239,68,68,0.18);
    color: #fca5a5;
}
.doc-upload-card--missing .doc-file-name {
    color: #f87171;
}

/* Submit button disabled state */
.doc-btn-purple:disabled,
.doc-btn-purple[aria-disabled="true"] {
    opacity: 0.5; cursor: not-allowed; box-shadow: none;
}

/* Light mode overrides for notice/alert */
[data-theme="light"] .doc-attach-notice {
    background: rgba(14,165,233,0.07); border-color: rgba(14,165,233,0.3); color: #0369a1;
}
[data-theme="light"] .doc-attach-notice strong { color: #0c4a6e; }
[data-theme="light"] .doc-attach-notice span { color: #475569; }
[data-theme="light"] .doc-attach-notice i { color: #0ea5e9; }
[data-theme="light"] .doc-missing-alert {
    background: rgba(239,68,68,0.07); border-color: rgba(239,68,68,0.3); color: #b91c1c;
}
[data-theme="light"] .doc-signature-alert {
    background: rgba(245,158,11,0.09); border-color: rgba(245,158,11,0.35); color: #92400e;
}
[data-theme="light"] .doc-signature-alert i,
[data-theme="light"] .doc-signature-alert strong,
[data-theme="light"] .doc-signature-alert span { color: #92400e; }
[data-theme="light"] .doc-draft-alert {
    background: linear-gradient(135deg, rgba(34,197,94,0.1), rgba(14,165,233,0.06)), #ffffff;
    border-color: rgba(34,197,94,0.35);
    color: #166534;
    box-shadow: 0 14px 30px rgba(15,33,88,0.1);
}
[data-theme="light"] .doc-draft-alert i {
    background: rgba(34,197,94,0.12);
}
[data-theme="light"] .doc-draft-alert i,
[data-theme="light"] .doc-draft-alert strong,
[data-theme="light"] .doc-draft-alert span { color: #166534; }
[data-theme="light"] .doc-draft-alert.is-error {
    background: linear-gradient(135deg, rgba(239,68,68,0.08), rgba(245,158,11,0.06)), #ffffff;
    border-color: rgba(239,68,68,0.3);
    color: #b91c1c;
}
[data-theme="light"] .doc-draft-alert.is-error i {
    background: rgba(239,68,68,0.1);
}
[data-theme="light"] .doc-draft-alert.is-error i,
[data-theme="light"] .doc-draft-alert.is-error strong,
[data-theme="light"] .doc-draft-alert.is-error span { color: #b91c1c; }
[data-theme="light"] .doc-requirement-note {
    background: linear-gradient(135deg, rgba(124,58,237,0.08), rgba(14,165,233,0.05)), #ffffff;
    border-color: rgba(124,58,237,0.28);
    color: #4c1d95;
    box-shadow: 0 14px 30px rgba(15,33,88,0.1);
}
[data-theme="light"] .doc-requirement-note i {
    background: rgba(124,58,237,0.1);
}
[data-theme="light"] .doc-requirement-note i,
[data-theme="light"] .doc-requirement-note strong,
[data-theme="light"] .doc-requirement-note span { color: #4c1d95; }
[data-theme="light"] .doc-requirement-note.is-error {
    background: linear-gradient(135deg, rgba(239,68,68,0.08), rgba(245,158,11,0.06)), #ffffff;
    border-color: rgba(239,68,68,0.32);
    color: #b91c1c;
}
[data-theme="light"] .doc-requirement-note.is-error i {
    background: rgba(239,68,68,0.1);
}
[data-theme="light"] .doc-requirement-note.is-error i,
[data-theme="light"] .doc-requirement-note.is-error strong,
[data-theme="light"] .doc-requirement-note.is-error span { color: #b91c1c; }
[data-theme="light"] .doc-upload-card--missing {
    border-color: rgba(239,68,68,0.5) !important;
    background: rgba(239,68,68,0.04) !important;
}

@media (max-width: 991.98px) {
    .doc-grid-2, .doc-upload-grid, .doc-signature-row, .doc-members-head, .doc-members-row { grid-template-columns: 1fr; }
    .doc-sent-card { grid-template-columns: 1fr; align-items: flex-start; }
    .doc-sent-grid { grid-template-columns: 1fr; }
    .doc-sent-actions { justify-content: flex-start; }
    .doc-draft-item { grid-template-columns: 1fr; align-items: flex-start; }
    .doc-field-half { max-width: none; }
    .doc-members-head { display: none; }
    .doc-members-row { gap: 0.45rem; }
}
@media (max-width: 767.98px) {
    .doc-vault-header, .doc-drafts-header, .doc-section-head, .doc-form-footer { flex-direction: column; align-items: stretch; }
    .doc-btn { width: 100%; }
}

/* Light mode support */
[data-theme="light"] .doc-sent-card {
    background: #ffffff;
    border-color: rgba(34,197,94,0.35);
    color: #0f172a;
    box-shadow: 0 10px 28px rgba(15,33,88,0.08);
}
[data-theme="light"] .doc-sent-icon {
    background: rgba(16,185,129,0.12);
    color: #059669;
}
[data-theme="light"] .doc-sent-body h1,
[data-theme="light"] .doc-sent-grid strong {
    color: #0f172a;
}
[data-theme="light"] .doc-sent-body p {
    color: #64748b;
}
[data-theme="light"] .doc-sent-grid div {
    background: #f8fafc;
    border-color: #d7e1ef;
}
[data-theme="light"] .doc-sent-grid span {
    color: #64748b;
}
[data-theme="light"] .doc-status-track {
    background: #f8fafc;
    border-color: #d7e1ef;
}
[data-theme="light"] .doc-status-track span {
    color: #64748b;
}
[data-theme="light"] .doc-status-track strong {
    color: #0f172a;
}
[data-theme="light"] .doc-status-bar {
    background: #e2e8f0;
}
[data-theme="light"] .doc-drafts-card {
    background: #ffffff;
    border-color: #dbe3ef;
    color: #0f172a;
    box-shadow: 0 10px 28px rgba(15,33,88,0.08);
}
[data-theme="light"] .doc-drafts-header {
    background: linear-gradient(135deg, #5b21b6 0%, #7c3aed 48%, #6d28d9 100%);
}
[data-theme="light"] .doc-drafts-header h1,
[data-theme="light"] .doc-empty-drafts strong,
[data-theme="light"] .doc-draft-item h2,
[data-theme="light"] .doc-draft-meta strong {
    color: #0f172a;
}
[data-theme="light"] .doc-drafts-header h1 {
    color: #fff;
}
[data-theme="light"] .doc-drafts-header p {
    color: #ddd6fe;
}
[data-theme="light"] .doc-empty-drafts,
[data-theme="light"] .doc-draft-item p {
    color: #64748b;
}
[data-theme="light"] .doc-draft-item {
    background: #f8fafc;
    border-color: #d7e1ef;
}
[data-theme="light"] .doc-draft-type,
[data-theme="light"] .doc-draft-meta span {
    color: #5b21b6;
}
[data-theme="light"] .doc-vault-form {
    --doc-bg: #ffffff;
    --doc-panel: #f8fafc;
    --doc-input: #ffffff;
    --doc-line: #d7e1ef;
    background: #ffffff;
    border-color: #dbe3ef;
    color: #0f172a;
    box-shadow: 0 10px 28px rgba(15,33,88,0.08);
}
[data-theme="light"] .doc-vault-header {
    background: linear-gradient(135deg, #5b21b6 0%, #7c3aed 48%, #6d28d9 100%);
}
[data-theme="light"] .doc-vault-kicker { color: #ede9fe; }
[data-theme="light"] .doc-vault-header h1 { color: #fff; }
[data-theme="light"] .doc-vault-header p { color: #ddd6fe; }
[data-theme="light"] .doc-section {
    border-bottom-color: #e2e8f0;
}
[data-theme="light"] .doc-section h2 { color: #0f172a; }
[data-theme="light"] .doc-section h2 small,
[data-theme="light"] .doc-hint,
[data-theme="light"] .doc-file-name { color: #64748b; }
[data-theme="light"] .doc-field label { color: #475569; }
[data-theme="light"] .doc-field input,
[data-theme="light"] .doc-field select,
[data-theme="light"] .doc-members-row input {
    background: #fff;
    color: #0f172a;
    border-color: #d7e1ef;
    color-scheme: light;
}
[data-theme="light"] .doc-members-table {
    background: #fff;
    border-color: #d7e1ef;
}
[data-theme="light"] .doc-members-head {
    background: #f1f5f9;
    color: #64748b;
}
[data-theme="light"] .doc-members-row {
    border-top-color: #e2e8f0;
}
[data-theme="light"] .doc-members-row > span { color: #7c3aed; }
[data-theme="light"] .doc-upload-card {
    background: #fff;
    border-color: #c4b5fd;
}
[data-theme="light"] .doc-upload-card strong { color: #0f172a; }
[data-theme="light"] .doc-upload-card small { color: #64748b; }
[data-theme="light"] .doc-tag.required {
    color: #b91c1c;
    background: rgba(239,68,68,0.1);
}
[data-theme="light"] .doc-tag.optional {
    color: #475569;
    background: rgba(100,116,139,0.12);
}
[data-theme="light"] .doc-upload-btn {
    background: rgba(124,58,237,0.1);
    color: #6d28d9;
}
[data-theme="light"] .doc-check { color: #334155; }
[data-theme="light"] .doc-signature-pad-wrap {
    background: #f8fafc;
    border-color: #d7e1ef;
}
[data-theme="light"] .doc-signature-label {
    color: #64748b;
    border-bottom-color: #e2e8f0;
}
[data-theme="light"] .doc-signature-label button { color: #6d28d9; }
[data-theme="light"] #signaturePad {
    background: #fff;
}
[data-theme="light"] .doc-btn-ghost {
    color: #334155;
    background: #fff;
    border-color: #cbd5e1;
}
[data-theme="light"] .doc-btn-muted {
    color: #334155;
    background: #f1f5f9;
    border-color: #cbd5e1;
}
[data-theme="light"] .doc-btn-purple-soft {
    color: #5b21b6;
    background: rgba(124,58,237,0.1);
    border-color: rgba(124,58,237,0.25);
}
[data-theme="light"] .doc-form-footer {
    background: #f8fafc;
}
</style>

<script>
(function () {
    var statusCard = document.querySelector('.doc-sent-card[data-status-ref]');
    if (!statusCard) return;

    var statusRef = statusCard.getAttribute('data-status-ref') || '';
    var titleNode = document.getElementById('docStatusTitle');
    var statusNode = document.getElementById('docLiveStatus');
    var updatedNode = document.getElementById('docStatusUpdated');
    var progressText = document.getElementById('docStatusProgressText');
    var progressBar = document.getElementById('docStatusProgressBar');

    function refreshDocumentStatus() {
        var url = new URL(window.location.href);
        url.searchParams.set('ajax', 'status');
        if (statusRef) {
            url.searchParams.set('status_ref', statusRef);
        }

        fetch(url.toString(), { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function (response) { return response.ok ? response.json() : null; })
            .then(function (data) {
                if (!data || !data.ok) return;
                if (titleNode) titleNode.textContent = data.title || 'Research document packet';
                if (statusNode) statusNode.textContent = data.status || 'Submitted';
                if (updatedNode) updatedNode.textContent = data.updated_at || '';
                if (progressText) progressText.textContent = (data.progress || 0) + '%';
                if (progressBar) progressBar.style.width = Math.max(0, Math.min(100, data.progress || 0)) + '%';
            })
            .catch(function () {});
    }

    refreshDocumentStatus();
    window.setInterval(refreshDocumentStatus, 10000);
})();

(function () {
    var form = document.getElementById('docVaultForm');
    var canvas = document.getElementById('signaturePad');
    if (!form || !canvas) return;
    var ctx = canvas.getContext('2d');
    var drawing = false;
    var hasStroke = false;
    var signatureAlert = document.getElementById('signatureMissingAlert');
    var signatureInput = document.getElementById('signatureData');
    var currentSignatureData = '';
    var savedDraft = <?= json_encode($savedDraftData, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
    var savedDraftUpdatedAt = <?= json_encode($savedDraftUpdatedAt) ?>;
    var draftStatus = document.getElementById('docDraftStatus');
    var draftTitle = document.getElementById('docDraftTitle');
    var draftText = document.getElementById('docDraftText');
    var requirementNotice = document.getElementById('docRequirementNotice');
    var requirementIcon = document.getElementById('docRequirementIcon');
    var requirementTitle = document.getElementById('docRequirementTitle');
    var requirementText = document.getElementById('docRequirementText');
    var canSubmitDocumentPacket = <?= $canSubmitDocumentPacket ? 'true' : 'false' ?>;
    var documentPacketBlockNote = <?= json_encode($documentPacketBlockNote) ?>;

    function showDraftStatus(title, text, isError) {
        if (!draftStatus) return;
        draftStatus.classList.toggle('is-error', !!isError);
        draftTitle.textContent = title;
        draftText.textContent = text;
        draftStatus.style.display = 'flex';
    }

    function showRequirementNotice(title, text, isError) {
        if (!requirementNotice) return;
        requirementNotice.classList.toggle('is-error', !!isError);
        if (requirementIcon) {
            requirementIcon.className = isError ? 'fas fa-triangle-exclamation' : 'fas fa-circle-info';
        }
        if (requirementTitle) requirementTitle.textContent = title;
        if (requirementText) requirementText.textContent = text;
    }

    function scrollRequirementNotice() {
        if (requirementNotice) {
            requirementNotice.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function drawSignatureData(dataUrl) {
        if (!dataUrl) return;
        var image = new Image();
        image.onload = function () {
            var rect = canvas.getBoundingClientRect();
            ctx.clearRect(0, 0, rect.width, 180);
            ctx.drawImage(image, 0, 0, rect.width, 180);
            hasStroke = true;
            currentSignatureData = dataUrl;
            signatureInput.value = dataUrl;
        };
        image.src = dataUrl;
    }

    function resizeCanvas() {
        var ratio = Math.max(window.devicePixelRatio || 1, 1);
        var rect = canvas.getBoundingClientRect();
        canvas.width = Math.floor(rect.width * ratio);
        canvas.height = Math.floor(180 * ratio);
        ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
        ctx.lineWidth = 2;
        ctx.lineCap = 'round';
        var theme = document.documentElement.getAttribute('data-theme') || 'light';
        ctx.strokeStyle = theme === 'light' ? '#0f172a' : '#ffffff';
        if (currentSignatureData) {
            drawSignatureData(currentSignatureData);
        }
    }

    function pointerPos(event) {
        var rect = canvas.getBoundingClientRect();
        var point = event.touches ? event.touches[0] : event;
        return { x: point.clientX - rect.left, y: point.clientY - rect.top };
    }

    canvas.addEventListener('mousedown', function (event) {
        drawing = true;
        var pos = pointerPos(event);
        ctx.beginPath();
        ctx.moveTo(pos.x, pos.y);
    });
    canvas.addEventListener('mousemove', function (event) {
        if (!drawing) return;
        var pos = pointerPos(event);
        ctx.lineTo(pos.x, pos.y);
        ctx.stroke();
        hasStroke = true;
        currentSignatureData = '';
        if (signatureAlert) signatureAlert.style.display = 'none';
    });
    ['mouseup', 'mouseleave'].forEach(function (name) {
        canvas.addEventListener(name, function () {
            drawing = false;
            if (hasStroke) {
                currentSignatureData = canvas.toDataURL('image/png');
                signatureInput.value = currentSignatureData;
            }
        });
    });
    canvas.addEventListener('touchstart', function (event) {
        event.preventDefault();
        drawing = true;
        var pos = pointerPos(event);
        ctx.beginPath();
        ctx.moveTo(pos.x, pos.y);
    }, { passive: false });
    canvas.addEventListener('touchmove', function (event) {
        event.preventDefault();
        if (!drawing) return;
        var pos = pointerPos(event);
        ctx.lineTo(pos.x, pos.y);
        ctx.stroke();
        hasStroke = true;
        currentSignatureData = '';
        if (signatureAlert) signatureAlert.style.display = 'none';
    }, { passive: false });
    canvas.addEventListener('touchend', function () {
        drawing = false;
        if (hasStroke) {
            currentSignatureData = canvas.toDataURL('image/png');
            signatureInput.value = currentSignatureData;
        }
    });

    document.getElementById('clearPadBtn').addEventListener('click', function () {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        hasStroke = false;
        currentSignatureData = '';
        signatureInput.value = '';
    });

    document.querySelectorAll('.doc-upload-card input[type="file"]').forEach(function (input) {
        input.addEventListener('change', function () {
            var card  = input.closest('.doc-upload-card');
            var label = card.querySelector('[data-file-label]');
            var hasFile = input.files && input.files[0];
            label.textContent = hasFile ? input.files[0].name : 'No file selected';
            // Clear the missing highlight once a file is chosen
            if (hasFile) {
                card.classList.remove('doc-upload-card--missing');
            }
            // Re-check overall completeness to update the notice
            checkRequiredDocs();
        });
    });

    // Returns array of required upload cards that have no file selected
    function getMissingRequiredCards() {
        var missing = [];
        document.querySelectorAll('.doc-upload-card input[type="file"][required]').forEach(function (input) {
            if (!input.files || !input.files[0]) {
                missing.push(input.closest('.doc-upload-card'));
            }
        });
        return missing;
    }

    function checkRequiredDocs() {
        var missing = getMissingRequiredCards();
        var notice  = document.getElementById('docAttachNotice');
        var alert   = document.getElementById('docMissingAlert');
        var btn     = document.getElementById('submitPacketBtn');

        if (missing.length === 0) {
            // All required docs uploaded — green state
            notice.style.borderColor  = 'rgba(16,185,129,0.4)';
            notice.style.background   = 'rgba(16,185,129,0.08)';
            notice.style.color        = '#6ee7b7';
            notice.querySelector('i').style.color    = '#34d399';
            notice.querySelector('strong').style.color = '#d1fae5';
            notice.querySelector('strong').textContent = 'All required documents uploaded — ready to submit.';
            notice.querySelector('span').textContent  = 'You may now proceed to sign and submit the form packet.';
            alert.style.display = 'none';
            showRequirementNotice(
                'Documents completed.',
                'Required documents are uploaded. Complete the remaining fields, check the declaration, and draw the representative signature before sending to CRAD.',
                false
            );
        } else {
            var n = missing.length;
            notice.style.borderColor  = '';
            notice.style.background   = '';
            notice.style.color        = '';
            notice.querySelector('i').style.color    = '';
            notice.querySelector('strong').style.color = '';
            notice.querySelector('strong').textContent = 'All required documents must be uploaded before submitting.';
            notice.querySelector('span').textContent  = 'Upload each file marked REQUIRED to enable the Submit Form Packet button. Allowed formats: PDF, DOCX, JPG, or PNG. Max 10MB per file.';
        }
    }

    // Run once on page load
    checkRequiredDocs();

    function fieldNodes(name) {
        return Array.prototype.filter.call(form.elements, function (field) {
            return field.name === name;
        });
    }

    function setFieldValue(name, value) {
        var nodes = fieldNodes(name);
        if (!nodes.length) return;
        if (Array.isArray(value)) {
            value.forEach(function (item, index) {
                if (nodes[index]) nodes[index].value = item || '';
            });
            return;
        }
        if (nodes[0].type === 'checkbox') {
            nodes[0].checked = value === true || value === '1' || value === 1;
            return;
        }
        nodes[0].value = value || '';
    }

    function applySavedDraft() {
        if (!savedDraft || Object.keys(savedDraft).length === 0) return;
        [
            'research_title',
            'program_course',
            'year_section',
            'college_department',
            'research_adviser',
            'academic_year',
            'member_id',
            'member_name',
            'member_email',
            'member_contact',
            'rep_name',
            'rep_id',
            'rep_email',
            'rep_contact',
            'declaration',
            'date_submitted'
        ].forEach(function (name) {
            if (Object.prototype.hasOwnProperty.call(savedDraft, name)) {
                setFieldValue(name, savedDraft[name]);
            }
        });
        if (savedDraft.signature_data) {
            currentSignatureData = savedDraft.signature_data;
            drawSignatureData(currentSignatureData);
        }
        checkRequiredDocs();
        showDraftStatus(
            'Draft loaded from database.',
            savedDraftUpdatedAt
                ? 'Last saved on ' + savedDraftUpdatedAt + '. Please upload document files again before submitting.'
                : 'Please upload document files again before submitting.',
            false
        );
    }

    document.getElementById('autoFillRepBtn').addEventListener('click', function () {
        var ids = document.querySelectorAll('input[name="member_id[]"]');
        var names = document.querySelectorAll('input[name="member_name[]"]');
        var emails = document.querySelectorAll('input[name="member_email[]"]');
        var contacts = document.querySelectorAll('input[name="member_contact[]"]');
        document.getElementById('repId').value = ids[0].value;
        document.getElementById('repName').value = names[0].value;
        document.getElementById('repEmail').value = emails[0].value;
        document.getElementById('repContact').value = contacts[0].value;
    });

    document.getElementById('saveDraftBtn').addEventListener('click', function () {
        var saveBtn = this;
        var originalText = saveBtn.textContent;
        var payload = new FormData();

        Array.prototype.forEach.call(form.elements, function (field) {
            if (!field.name || field.type === 'file' || field.name === 'process') return;
            if (field.type === 'checkbox') {
                if (field.checked) payload.append(field.name, field.value || '1');
                return;
            }
            if (field.name === 'signature_data') {
                payload.append(field.name, hasStroke ? canvas.toDataURL('image/png') : (currentSignatureData || field.value || ''));
                return;
            }
            payload.append(field.name, field.value || '');
        });
        payload.append('process', 'save-draft');

        saveBtn.disabled = true;
        saveBtn.textContent = 'Saving...';

        fetch(form.getAttribute('action') || window.location.href, {
            method: 'POST',
            body: payload,
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
            .then(function (response) {
                return response.json().then(function (data) {
                    if (!response.ok || !data.ok) {
                        throw new Error(data.error || 'Unable to save draft.');
                    }
                    return data;
                });
            })
            .then(function (data) {
                showDraftStatus(
                    'Draft saved to database.',
                    (data.saved_at ? 'Saved on ' + data.saved_at + '. ' : '') + 'Document files are not stored in drafts, so upload them again before final submit.',
                    false
                );
            })
            .catch(function (error) {
                showDraftStatus('Draft not saved.', error.message || 'Unable to save draft. Please try again.', true);
            })
            .finally(function () {
                saveBtn.disabled = false;
                saveBtn.textContent = originalText;
            });
    });

    document.getElementById('submitPacketBtn').addEventListener('click', function () {
        if (!canSubmitDocumentPacket) {
            showRequirementNotice(
                'Bawal pa mag-submit.',
                documentPacketBlockNote,
                true
            );
            scrollRequirementNotice();
            return;
        }

        // 1. Check required file uploads first
        var missingCards = getMissingRequiredCards();
        if (missingCards.length > 0) {
            // Highlight each missing card
            document.querySelectorAll('.doc-upload-card').forEach(function (c) {
                c.classList.remove('doc-upload-card--missing');
            });
            missingCards.forEach(function (card) {
                card.classList.add('doc-upload-card--missing');
            });
            // Show the red alert with count
            var alertEl  = document.getElementById('docMissingAlert');
            var alertTxt = document.getElementById('docMissingText');
            alertTxt.textContent = missingCards.length === 1
                ? '1 required document is still missing. Please upload it before submitting.'
                : missingCards.length + ' required documents are still missing. Please upload them before submitting.';
            alertEl.style.display = 'flex';
            showRequirementNotice(
                'Form packet was not submitted.',
                missingCards.length === 1
                    ? 'The packet was not sent to CRAD because 1 required document is missing. Upload the required file first, then submit again.'
                    : 'The packet was not sent to CRAD because ' + missingCards.length + ' required documents are missing. Upload all required files first, then submit again.',
                true
            );
            scrollRequirementNotice();
            return;
        }

        // 2. Standard HTML5 form validation (text fields, etc.)
        if (!form.reportValidity()) {
            showRequirementNotice(
                'Form packet was not submitted.',
                'The packet was not sent to CRAD because one or more required form fields are incomplete or invalid. Please complete the highlighted fields first.',
                true
            );
            scrollRequirementNotice();
            return;
        }

        // 3. Signature required
        if (!hasStroke) {
            if (signatureAlert) {
                signatureAlert.style.display = 'flex';
            }
            showRequirementNotice(
                'Form packet was not submitted.',
                'The packet was not sent to CRAD because the representative signature is missing. Please draw the signature first, then submit again.',
                true
            );
            scrollRequirementNotice();
            return;
        }

        signatureInput.value = canvas.toDataURL('image/png');
        form.submit();
    });

    resizeCanvas();
    applySavedDraft();
    window.addEventListener('resize', resizeCanvas);
})();
</script>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
