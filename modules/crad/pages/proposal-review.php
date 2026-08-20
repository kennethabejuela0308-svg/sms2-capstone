<?php
/**
 * SMS 2 - Proposal Review (CRAD Officer)
 * Module: CRAD — reads live data from crad_db
 */
require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/breadcrumbs.php';
require_once ROOT_PATH . '/includes/security.php';

$ref    = trim($_GET['ref'] ?? '');
$action = $_POST['action'] ?? ($_GET['action'] ?? '');

// ── Fetch from crad_db ────────────────────────────────────────────────────────
$proposal  = null;
$members   = [];
$documents = [];

// ── Status helper: derive status label from progress % ───────────────────────
// Rules:
//   0%           → 'Submitted'
//   1 – 99%      → 'In Progress'
//   100%         → 'Approved'
//   'Returned'   → always stays 'Returned' (set explicitly by CRAD action)
function statusFromProgress(int $pct, string $storedStatus): string
{
    if ($storedStatus === 'Returned') { return 'Returned'; }
    if ($pct >= 100)                  { return 'Approved'; }
    if ($pct >= 1)                    { return 'In Progress'; }
    return 'Submitted';
}

$statusClsMap = [
    'Panel Assigned' => 'pst-badge--panel',
    'Submitted'      => 'pst-badge--submitted',
    'Approved'       => 'pst-badge--approved',
    'In Progress'    => 'pst-badge--progress',
    'Returned'       => 'pst-badge--returned',
];

try {
    $cradPdo = getCradDatabaseConnection();

    // Main proposal row
    $stmtP = $cradPdo->prepare(
        "SELECT * FROM research_proposals WHERE ref_code = :ref LIMIT 1"
    );
    $stmtP->execute([':ref' => $ref]);
    $row = $stmtP->fetch();

    if ($row) {
        $_progress   = (int) $row['progress'];
        $_status     = statusFromProgress($_progress, $row['status']);

        $proposal = [
            'ref'        => $row['ref_code'],
            'title'      => $row['research_title'],
            'program'    => $row['program_course'],
            'section'    => $row['year_section'],
            'dept'       => $row['college_department'],
            'adviser'    => $row['research_adviser'],
            'acad_year'  => $row['academic_year'],
            'status'     => $_status,
            'status_cls' => $statusClsMap[$_status] ?? 'pst-badge--submitted',
            'progress'   => $_progress,
            'rep'        => [
                'name'    => $row['rep_name'],
                'id'      => $row['rep_id'],
                'email'   => $row['rep_email'],
                'contact' => $row['rep_contact'],
            ],
            'submitted_on'   => date('F j, Y', strtotime($row['date_submitted'])),
            'signature_data' => $row['signature_data'] ?? '',
            'remarks'        => $row['notes'] ?? '',
            'proposal_id'    => (int) $row['id'],
        ];

        // Members
        $stmtM = $cradPdo->prepare(
            "SELECT * FROM proposal_members WHERE proposal_id = :pid ORDER BY sort_order ASC"
        );
        $stmtM->execute([':pid' => $proposal['proposal_id']]);
        foreach ($stmtM->fetchAll() as $m) {
            $members[] = [
                'id'      => $m['student_id'],
                'name'    => $m['student_name'],
                'email'   => $m['email'],
                'contact' => $m['contact'],
            ];
        }

        // Documents
        $stmtD = $cradPdo->prepare(
            "SELECT * FROM proposal_documents WHERE proposal_id = :pid ORDER BY id ASC"
        );
        $stmtD->execute([':pid' => $proposal['proposal_id']]);
        $dbDocs = [];
        foreach ($stmtD->fetchAll() as $d) {
            $dbDocs[$d['doc_key']] = $d;
        }

        // Merge with full document slot list so empty slots still show
        $allSlots = [
            ['key' => 'manuscript',             'title' => 'Research Manuscript',                           'required' => true],
            ['key' => 'approval',               'title' => 'Approval Sheet',                                'required' => true],
            ['key' => 'abstract',               'title' => 'Abstract',                                      'required' => true],
            ['key' => 'certificate_adviser',    'title' => 'Certificate of Technical Adviser & Grammarian', 'required' => true],
            ['key' => 'certificate_originality','title' => 'Certificate of Originality',                    'required' => true],
            ['key' => 'supporting',             'title' => 'Supporting Documents',                          'required' => false],
            ['key' => 'receipt_screenshot',     'title' => 'Screenshot of the Receipt',                     'required' => true],
        ];
        foreach ($allSlots as $slot) {
            $dbDoc = $dbDocs[$slot['key']] ?? null;
            $documents[] = [
                'key'           => $slot['key'],
                'title'         => $slot['title'],
                'required'      => $slot['required'],
                'original_name' => $dbDoc ? $dbDoc['original_name'] : '',
                'stored_name'   => $dbDoc ? $dbDoc['stored_name']   : '',
                'file_size'     => $dbDoc ? (int) $dbDoc['file_size'] : 0,
                'uploaded_at'   => $dbDoc ? $dbDoc['uploaded_at']   : '',
            ];
        }
    }
} catch (Throwable $e) {
    error_log('CRAD review fetch error: ' . $e->getMessage());
}

if (!$proposal) {
    header('Location: ' . BASE_URL . '/modules/crad/pages/proposal-submission-tracking.php');
    exit;
}

// Handle action feedback
$actionDone = '';
$reviewError = '';

function prvApprovalValidationErrors(array $documents): array
{
    $errors = [];
    $rawVerdicts = (string) ($_POST['doc_verdicts_json'] ?? '');
    $verdicts = json_decode($rawVerdicts, true);

    if (!is_array($verdicts)) {
        $verdicts = [];
    }

    foreach ($documents as $doc) {
        $title = (string) ($doc['title'] ?? 'Document');
        $key = (string) ($doc['key'] ?? '');
        $hasFile = !empty($doc['stored_name']);
        $isRequired = !empty($doc['required']);
        $verdict = strtolower(trim((string) ($verdicts[$key] ?? '')));

        if ($isRequired && !$hasFile) {
            $errors[] = $title . ' is required but has no uploaded file.';
            continue;
        }

        if ($hasFile && !in_array($verdict, ['correct', 'wrong'], true)) {
            $errors[] = 'Please mark ' . $title . ' as Correct or Wrong.';
            continue;
        }

        if ($hasFile && $verdict === 'wrong') {
            $errors[] = $title . ' is marked Wrong. Return the proposal for revision before approval.';
        }
    }

    if (empty($_POST['approval_declaration'])) {
        $errors[] = 'Please check the final certification before approval.';
    }

    $signatureData = trim((string) ($_POST['approval_signature_data'] ?? ''));
    if ($signatureData === '' || strlen($signatureData) < 200) {
        $errors[] = 'Please complete the signature pad before approval.';
    }

    return $errors;
}

if (in_array($action, ['approve', 'return', 'save_progress'], true) && $proposal) {
    try {
        $cradPdo = getCradDatabaseConnection();

        if ($action === 'approve') {
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                throw new RuntimeException('Invalid approval request. Please use the Approve Proposal button.');
            }

            $approvalErrors = prvApprovalValidationErrors($documents);
            if ($approvalErrors) {
                throw new RuntimeException('Please complete the missing review requirements before approval: ' . implode(' ', $approvalErrors));
            }

            // Approve: set progress = 100, status = 'Approved'
            $columns = [
                'approved_at' => "ALTER TABLE research_proposals ADD approved_at DATETIME NULL AFTER progress",
                'registration_status' => "ALTER TABLE research_proposals ADD registration_status ENUM('Pending','Registered') NOT NULL DEFAULT 'Pending' AFTER approved_at",
            ];
            foreach ($columns as $column => $sql) {
                $exists = $cradPdo->query("SHOW COLUMNS FROM research_proposals LIKE " . $cradPdo->quote($column))->fetch();
                if (!$exists) {
                    $cradPdo->exec($sql);
                }
            }

            $upd = $cradPdo->prepare(
                "UPDATE research_proposals
                 SET status = 'Approved',
                     progress = 100,
                     approved_at = COALESCE(approved_at, NOW()),
                     updated_at = NOW()
                 WHERE ref_code = :ref LIMIT 1"
            );
            $upd->execute([':ref' => $ref]);

            // Audit log
            $log = $cradPdo->prepare(
                "INSERT INTO proposal_status_logs
                    (proposal_id, old_status, new_status, changed_by, remarks)
                 VALUES
                    (:pid, :old, 'Approved', NULL, 'CRAD Officer approved proposal')"
            );
            $log->execute([':pid' => $proposal['proposal_id'], ':old' => $proposal['status']]);

            $proposal['status']     = 'Approved';
            $proposal['progress']   = 100;
            $proposal['status_cls'] = 'pst-badge--approved';
            $actionDone = 'approved';

        } elseif ($action === 'return') {
            if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
                throw new RuntimeException('Invalid return request. Please use the Return Proposal button.');
            }

            $returnRemarks = trim((string) ($_POST['return_remarks'] ?? $proposal['remarks']));
            if ($returnRemarks === '') {
                throw new RuntimeException('Please add CRAD remarks before returning the proposal.');
            }

            // Return: status = 'Returned', keep progress as-is
            $upd = $cradPdo->prepare(
                "UPDATE research_proposals
                 SET status = 'Returned', notes = :notes, updated_at = NOW()
                 WHERE ref_code = :ref LIMIT 1"
            );
            $upd->execute([':notes' => $returnRemarks, ':ref' => $ref]);

            // Audit log
            $log = $cradPdo->prepare(
                "INSERT INTO proposal_status_logs
                    (proposal_id, old_status, new_status, changed_by, remarks)
                 VALUES
                    (:pid, :old, 'Returned', NULL, :remarks)"
            );
            $log->execute([
                ':pid' => $proposal['proposal_id'],
                ':old' => $proposal['status'],
                ':remarks' => $returnRemarks,
            ]);

            $proposal['status']     = 'Returned';
            $proposal['status_cls'] = 'pst-badge--returned';
            $proposal['remarks']    = $returnRemarks;
            $actionDone = 'returned';

        } elseif ($action === 'save_progress') {
            // Save progress from document verdict marking.
            // Correct count sent as GET param; max allowed via this path is 85%
            // (100% is reserved for explicit Approve)
            $correctCount = max(0, (int) ($_GET['correct'] ?? 0));
            $totalDocs    = 7; // total document slots
            // Each correct doc adds ~12% (85/7 ≈ 12.14), capped at 85
            $newProgress  = (int) min(85, round(($correctCount / $totalDocs) * 85));
            // Only increase, never decrease progress
            $newProgress  = max($proposal['progress'], $newProgress);

            if ($newProgress > $proposal['progress']) {
                $derivedStatus = statusFromProgress($newProgress, $proposal['status']);
                $upd = $cradPdo->prepare(
                    "UPDATE research_proposals
                     SET progress = :pct, status = :st, updated_at = NOW()
                     WHERE ref_code = :ref LIMIT 1"
                );
                $upd->execute([':pct' => $newProgress, ':st' => $derivedStatus, ':ref' => $ref]);

                $log = $cradPdo->prepare(
                    "INSERT INTO proposal_status_logs
                        (proposal_id, old_status, new_status, changed_by, remarks)
                     VALUES
                        (:pid, :old, :new, NULL, :note)"
                );
                $log->execute([
                    ':pid'  => $proposal['proposal_id'],
                    ':old'  => $proposal['status'],
                    ':new'  => $derivedStatus,
                    ':note' => "Progress updated to {$newProgress}% after document review ({$correctCount}/{$totalDocs} correct)",
                ]);
            }

            $isAsyncProgressSave =
                ($_GET['ajax'] ?? '') === '1'
                || strtolower((string) ($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '')) === 'xmlhttprequest';

            if ($isAsyncProgressSave) {
                header('Content-Type: application/json');
                echo json_encode([
                    'ok' => true,
                    'progress' => $newProgress,
                    'status' => statusFromProgress($newProgress, $proposal['status']),
                ]);
                exit;
            }

            // Redirect to pipeline after saving
            header('Location: ' . BASE_URL . '/modules/crad/pages/proposal-submission-tracking.php');
            exit;
        }
    } catch (Throwable $e) {
        error_log('CRAD action error: ' . $e->getMessage());
        $reviewError = $e->getMessage();
    }
}

$pageTitle    = 'Proposal Review — ' . $proposal['ref'];
$activeModule = 'crad';
$activePage   = 'proposal-submission-tracking';
$breadcrumbs  = [
    ['label' => 'CRAD', 'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Research Proposal Submission & Tracking', 'url' => BASE_URL . '/modules/crad/pages/proposal-submission-tracking.php'],
    ['label' => $proposal['ref'], 'url' => null],
];

require_once ROOT_PATH . '/includes/layout-start.php';
?>
<?php renderBreadcrumbs($breadcrumbs); ?>

<style>
/* ============================================================
   PRV — Proposal Review (CRAD Officer) scoped styles
   ============================================================ */
.prv-wrap { max-width: 100%; margin: 0; padding: 0 0.25rem; }

.prv-form {
    --doc-bg: #12151a;
    --doc-panel: #181c22;
    --doc-input: #222831;
    --doc-line: rgba(148,163,184,0.2);
    --doc-purple: #7c3aed;
    --doc-purple-2: #8b5cf6;
    overflow: hidden;
    border: 1px solid rgba(148,163,184,0.14);
    border-radius: 18px;
    background: linear-gradient(180deg, #171a20 0%, var(--doc-bg) 40%);
    color: #f8fafc;
    box-shadow: 0 18px 40px rgba(0,0,0,0.28);
}
.prv-header {
    display: flex; align-items: flex-start; justify-content: space-between; gap: 1rem;
    padding: 1.35rem 2rem 1.1rem;
    background: linear-gradient(135deg, #2e1065 0%, #4c1d95 45%, #111827 100%);
}
.prv-kicker {
    display: inline-block; margin-bottom: 0.35rem; color: #c4b5fd;
    font-size: 0.72rem; font-weight: 800; letter-spacing: 0.08em; text-transform: uppercase;
}
.prv-header h1 { margin: 0; color: #fff; font-size: 1.45rem; font-weight: 800; }
.prv-header p  { margin: 0.35rem 0 0; color: #ddd6fe; font-size: 0.9rem; }
.prv-header-actions { display: flex; gap: 0.65rem; flex-shrink: 0; flex-wrap: wrap; align-items: flex-start; }

.prv-section {
    padding: 1.4rem 2rem;
    border-bottom: 1px solid var(--doc-line);
}
.prv-section h2 {
    display: flex; align-items: center; gap: 0.55rem;
    margin: 0 0 1rem; color: #fff; font-size: 0.98rem; font-weight: 800;
}
.prv-section h2 span {
    width: 8px; height: 8px; border-radius: 50%; background: var(--doc-purple-2); flex-shrink: 0;
}
.prv-section h2 small { color: #94a3b8; font-size: 0.78rem; font-weight: 600; }
.prv-hint { margin: -0.35rem 0 1rem; color: #94a3b8; font-size: 0.82rem; }

.prv-grid-2 { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 0.9rem; }
.prv-field { display: grid; gap: 0.4rem; margin-bottom: 0.9rem; }
.prv-field label {
    color: #cbd5e1; font-size: 0.72rem; font-weight: 700;
    letter-spacing: 0.04em; text-transform: uppercase;
}
.prv-field .prv-value {
    min-height: 42px; padding: 0.65rem 0.8rem;
    border: 1px solid var(--doc-line); border-radius: 10px;
    background: var(--doc-input); color: #fff; font-size: 0.9rem;
    display: flex; align-items: center;
}
.prv-field-half { max-width: 50%; }

.prv-members-table {
    overflow: hidden; border: 1px solid var(--doc-line); border-radius: 12px; background: var(--doc-panel);
}
.prv-members-head, .prv-members-row {
    display: grid;
    grid-template-columns: 36px 1.2fr 1.6fr 1.8fr 1.2fr;
    gap: 0.55rem; align-items: center;
}
.prv-members-head {
    padding: 0.7rem 0.75rem; background: #1f2430; color: #94a3b8;
    font-size: 0.68rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.04em;
}
.prv-members-row {
    padding: 0.65rem 0.75rem; border-top: 1px solid var(--doc-line);
    color: #f8fafc; font-size: 0.88rem;
}
.prv-members-row .prv-num { color: #a78bfa; font-weight: 800; text-align: center; }

.prv-upload-grid {
    display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 1rem;
}
.prv-doc-card {
    display: flex; flex-direction: column; gap: 0.45rem; padding: 0.95rem;
    border: 1px dashed rgba(167,139,250,0.35); border-radius: 12px;
    background: var(--doc-panel);
}
.prv-doc-card strong { color: #fff; font-size: 0.88rem; }
.prv-doc-card small  { color: #94a3b8; font-size: 0.75rem; line-height: 1.35; }
.prv-tag {
    display: inline-flex; width: fit-content; padding: 0.18rem 0.45rem; border-radius: 999px;
    font-size: 0.62rem; font-weight: 800; letter-spacing: 0.04em;
}
.prv-tag.required { color: #fecaca; background: rgba(239,68,68,0.16); }
.prv-tag.optional { color: #cbd5e1; background: rgba(148,163,184,0.16); }
.prv-doc-file {
    display: inline-flex; align-items: center; gap: 0.4rem;
    min-height: 38px; margin-top: 0.25rem; padding: 0 0.75rem;
    border-radius: 9px; font-size: 0.78rem; font-weight: 700;
}
.prv-doc-file.has-file {
    background: rgba(16,185,129,0.14); color: #6ee7b7;
    border: 1px solid rgba(16,185,129,0.25);
}
.prv-doc-file.no-file {
    background: rgba(148,163,184,0.1); color: #64748b;
    border: 1px solid rgba(148,163,184,0.2);
}

.prv-rep-grid { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 0.9rem; }

/* Action buttons */
.prv-btn {
    display: inline-flex; align-items: center; justify-content: center; gap: 0.45rem;
    min-height: 44px; padding: 0.6rem 1.35rem; border-radius: 10px;
    border: 1px solid transparent; font-size: 0.9rem; font-weight: 700;
    text-decoration: none; cursor: pointer; white-space: nowrap;
    transition: background 0.15s ease, box-shadow 0.15s ease;
}
.prv-btn-ghost {
    color: #e2e8f0; background: rgba(15,23,42,0.28); border-color: rgba(226,232,240,0.28);
}
.prv-btn-approve {
    color: #fff; background: linear-gradient(135deg, #059669, #10b981);
    box-shadow: 0 6px 16px rgba(16,185,129,0.3);
}
.prv-btn-approve:hover {
    background: linear-gradient(135deg, #047857, #059669);
    color: #fff;
}
.prv-btn-return {
    color: #fff; background: linear-gradient(135deg, #dc2626, #ef4444);
    box-shadow: 0 6px 16px rgba(220,38,38,0.28);
}
.prv-btn-return:hover {
    background: linear-gradient(135deg, #b91c1c, #dc2626);
    color: #fff;
}

/* Status badge (reused from tracking page) */
.pst-badge {
    display: inline-flex; align-items: center; padding: 0.22rem 0.7rem;
    border-radius: 999px; font-size: 0.7rem; font-weight: 800; white-space: nowrap;
}
.pst-badge--panel      { color: #6d28d9; background: #ede9fe; }
.pst-badge--submitted  { color: #b45309; background: #fef3c7; }
.pst-badge--approved   { color: #047857; background: #d1fae5; }
.pst-badge--progress   { color: #0369a1; background: #e0f2fe; }
.pst-badge--returned   { color: #64748b; background: #e2e8f0; }

/* Alert */
.prv-alert {
    display: flex; align-items: center; gap: 0.6rem;
    padding: 0.9rem 1rem; border-radius: 12px;
    font-size: 0.86rem; font-weight: 600; margin-bottom: 1rem;
}
.prv-alert.success {
    border: 1px solid rgba(16,185,129,0.25);
    background: rgba(16,185,129,0.1); color: #6ee7b7;
}
.prv-alert.danger {
    border: 1px solid rgba(220,38,38,0.25);
    background: rgba(220,38,38,0.1); color: #fca5a5;
}

/* Final declaration checkbox */
.prv-check {
    display: flex; align-items: flex-start; gap: 0.7rem; margin-bottom: 1rem;
    color: #cbd5e1; font-size: 0.86rem; line-height: 1.45; cursor: pointer;
}
.prv-check input {
    margin-top: 0.2rem; accent-color: var(--doc-purple);
}

/* Signature row */
.prv-sig-row {
    display: grid; grid-template-columns: minmax(0,1fr) 220px; gap: 1rem; align-items: start;
}
.prv-sig-pad-wrap {
    overflow: hidden; border: 1px solid var(--doc-line); border-radius: 12px; background: #0b0d11;
}
.prv-sig-label {
    display: flex; align-items: center; justify-content: space-between; gap: 0.75rem;
    padding: 0.65rem 0.85rem; border-bottom: 1px solid var(--doc-line);
    color: #94a3b8; font-size: 0.75rem; font-weight: 700; text-transform: uppercase;
}
.prv-sig-label button {
    border: 0; background: transparent; color: #c4b5fd;
    font-size: 0.75rem; font-weight: 700; cursor: pointer;
}
.prv-sig-label button:hover { color: #ede9fe; }

/* View file button on doc cards */
.prv-doc-view-btn {
    display: inline-flex; align-items: center; justify-content: center; gap: 0.4rem;
    min-height: 34px; margin-top: 0.35rem; padding: 0 0.75rem;
    border: 1px solid rgba(124,58,237,0.3); border-radius: 9px;
    background: rgba(124,58,237,0.12); color: #c4b5fd;
    font-size: 0.75rem; font-weight: 700; text-decoration: none;
    transition: background 0.15s ease, border-color 0.15s ease;
}
.prv-doc-view-btn:hover {
    background: rgba(124,58,237,0.18); border-color: rgba(124,58,237,0.45);
    color: #ddd6fe;
}

/* Doc card review verdict row */
.prv-doc-verdict {
    display: flex; gap: 0.45rem; margin-top: auto; padding-top: 0.6rem;
}
.prv-verdict-btn {
    flex: 1; display: inline-flex; align-items: center; justify-content: center; gap: 0.35rem;
    min-height: 34px; border-radius: 8px; border: 1.5px solid transparent;
    font-size: 0.75rem; font-weight: 800; cursor: pointer;
    letter-spacing: 0.03em; transition: all 0.15s ease;
    background: transparent;
}
.prv-verdict-btn.correct {
    color: #6ee7b7; border-color: rgba(16,185,129,0.35);
    background: rgba(16,185,129,0.08);
}
.prv-verdict-btn.correct:hover,
.prv-verdict-btn.correct.active {
    background: rgba(16,185,129,0.22); border-color: #10b981; color: #fff;
    box-shadow: 0 0 0 3px rgba(16,185,129,0.18);
}
.prv-verdict-btn.wrong {
    color: #fca5a5; border-color: rgba(239,68,68,0.35);
    background: rgba(239,68,68,0.08);
}
.prv-verdict-btn.wrong:hover,
.prv-verdict-btn.wrong.active {
    background: rgba(239,68,68,0.22); border-color: #ef4444; color: #fff;
    box-shadow: 0 0 0 3px rgba(239,68,68,0.18);
}
[data-theme="light"] .prv-verdict-btn.correct { color: #047857; border-color: rgba(16,185,129,0.4); background: rgba(16,185,129,0.06); }
[data-theme="light"] .prv-verdict-btn.correct:hover,
[data-theme="light"] .prv-verdict-btn.correct.active { background: rgba(16,185,129,0.18); border-color: #059669; color: #065f46; }
[data-theme="light"] .prv-verdict-btn.wrong { color: #b91c1c; border-color: rgba(239,68,68,0.35); background: rgba(239,68,68,0.06); }
[data-theme="light"] .prv-verdict-btn.wrong:hover,
[data-theme="light"] .prv-verdict-btn.wrong.active { background: rgba(239,68,68,0.18); border-color: #dc2626; color: #7f1d1d; }

/* Remarks area */
.prv-remarks {
    width: 100%; min-height: 90px; padding: 0.75rem 0.85rem;
    border: 1px solid var(--doc-line); border-radius: 10px;
    background: var(--doc-input); color: #fff; font-size: 0.88rem;
    resize: vertical; outline: none;
}
.prv-remarks:focus { border-color: #a78bfa; box-shadow: 0 0 0 3px rgba(124,58,237,0.18); }

/* Status select dropdown */
.prv-status-select {
    width: 100%; min-height: 42px; padding: 0.65rem 0.8rem;
    border: 1px solid var(--doc-line); border-radius: 10px;
    background: var(--doc-input); color: #fff; font-size: 0.9rem;
    outline: none; appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath fill='%23f8fafc' d='M1 1l5 5 5-5'/%3E%3C/svg%3E");
    background-repeat: no-repeat; background-position: right 0.9rem center; padding-right: 2.2rem;
}
.prv-status-select:focus { border-color: #a78bfa; box-shadow: 0 0 0 3px rgba(124,58,237,0.18); }
[data-theme="light"] .prv-status-select {
    background-color: #fff; color: #0f172a; border-color: #d7e1ef;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath fill='%2364748b' d='M1 1l5 5 5-5'/%3E%3C/svg%3E");
}

/* Footer actions */
.prv-footer {
    display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 0.7rem;
    padding: 1.1rem 2rem 1.4rem;
    background: rgba(0,0,0,0.12);
    border-top: 1px solid var(--doc-line);
}
.prv-footer-right { display: flex; gap: 0.65rem; flex-wrap: wrap; }

/* Confirmation modal */
.prv-modal-backdrop {
    position: fixed; inset: 0; z-index: 3000;
    display: none; align-items: center; justify-content: center;
    padding: 1.25rem;
    background: rgba(2,6,23,0.72);
    backdrop-filter: blur(8px);
}
.prv-modal-backdrop.is-open { display: flex; }
.prv-modal {
    width: min(460px, 100%);
    overflow: hidden;
    border: 1px solid rgba(167,139,250,0.28);
    border-radius: 18px;
    background: #111827;
    color: #f8fafc;
    box-shadow: 0 24px 70px rgba(0,0,0,0.45);
}
.prv-modal-head {
    display: flex; align-items: flex-start; gap: 0.85rem;
    padding: 1.25rem 1.3rem 0.8rem;
}
.prv-modal-icon {
    width: 42px; height: 42px; flex: 0 0 auto;
    display: grid; place-items: center;
    border-radius: 12px;
    background: rgba(16,185,129,0.14);
    color: #6ee7b7;
    font-size: 1rem;
}
.prv-modal-icon.return {
    background: rgba(239,68,68,0.14);
    color: #fca5a5;
}
.prv-modal-title { margin: 0; font-size: 1rem; font-weight: 850; color: #fff; }
.prv-modal-text { margin: 0.35rem 0 0; color: #cbd5e1; font-size: 0.86rem; line-height: 1.45; }
.prv-modal-body {
    margin: 0 1.3rem 1rem;
    padding: 0.8rem 0.9rem;
    border: 1px solid rgba(148,163,184,0.18);
    border-radius: 12px;
    background: rgba(15,23,42,0.7);
}
.prv-modal-body span {
    display: block; color: #94a3b8; font-size: 0.68rem; font-weight: 800;
    text-transform: uppercase; letter-spacing: 0.06em;
}
.prv-modal-body strong {
    display: block; margin-top: 0.22rem; color: #ede9fe; font-size: 0.9rem; line-height: 1.35;
}
.prv-modal-actions {
    display: flex; justify-content: flex-end; gap: 0.65rem;
    padding: 1rem 1.3rem 1.25rem;
    border-top: 1px solid rgba(148,163,184,0.16);
    background: rgba(15,23,42,0.52);
}
.prv-modal-btn {
    display: inline-flex; align-items: center; justify-content: center; gap: 0.4rem;
    min-height: 40px; padding: 0.55rem 1rem;
    border-radius: 10px; border: 1px solid transparent;
    font-size: 0.84rem; font-weight: 800;
    cursor: pointer; text-decoration: none;
}
.prv-modal-cancel { color: #e2e8f0; background: rgba(255,255,255,0.06); border-color: rgba(226,232,240,0.2); }
.prv-modal-confirm { color: #fff; background: linear-gradient(135deg, #059669, #10b981); }
.prv-modal-confirm.return { background: linear-gradient(135deg, #dc2626, #ef4444); }
</style>

<!-- Light mode overrides -->
<style>
[data-theme="light"] .prv-form {
    --doc-bg: #ffffff; --doc-panel: #f8fafc; --doc-input: #ffffff; --doc-line: #d7e1ef;
    background: #ffffff; border-color: #dbe3ef; color: #0f172a;
    box-shadow: 0 10px 28px rgba(15,33,88,0.08);
}
[data-theme="light"] .prv-header {
    background: linear-gradient(135deg, #5b21b6 0%, #7c3aed 48%, #6d28d9 100%);
}
[data-theme="light"] .prv-section h2 { color: #0f172a; }
[data-theme="light"] .prv-field label { color: #475569; }
[data-theme="light"] .prv-field .prv-value {
    background: #fff; color: #0f172a; border-color: #d7e1ef;
}
[data-theme="light"] .prv-members-table { background: #fff; border-color: #d7e1ef; }
[data-theme="light"] .prv-members-head  { background: #f1f5f9; color: #64748b; }
[data-theme="light"] .prv-members-row   { border-top-color: #e2e8f0; color: #0f172a; }
[data-theme="light"] .prv-members-row .prv-num { color: #7c3aed; }
[data-theme="light"] .prv-doc-card { background: #fff; border-color: #c4b5fd; }
[data-theme="light"] .prv-doc-card strong { color: #0f172a; }
[data-theme="light"] .prv-doc-card small  { color: #64748b; }
[data-theme="light"] .prv-tag.required { color: #b91c1c; background: rgba(239,68,68,0.1); }
[data-theme="light"] .prv-tag.optional { color: #475569; background: rgba(100,116,139,0.12); }
[data-theme="light"] .prv-doc-file.has-file { background: rgba(16,185,129,0.1); color: #047857; }
[data-theme="light"] .prv-doc-file.no-file  { background: #f1f5f9; color: #94a3b8; }
[data-theme="light"] .prv-btn-ghost { color: #334155; background: #fff; border-color: #cbd5e1; }
[data-theme="light"] .prv-remarks { background: #fff; color: #0f172a; border-color: #d7e1ef; }
[data-theme="light"] .prv-alert.success { color: #047857; }
[data-theme="light"] .prv-alert.danger  { color: #b91c1c; }
[data-theme="light"] .prv-footer { background: #f1f5f9; border-top-color: #e2e8f0; }

[data-theme="light"] .prv-check { color: #334155; }
[data-theme="light"] .prv-sig-pad-wrap {
    background: #f8fafc; border-color: #d7e1ef;
}
[data-theme="light"] .prv-sig-label {
    color: #64748b; border-bottom-color: #e2e8f0;
}
[data-theme="light"] .prv-sig-label button { color: #6d28d9; }
[data-theme="light"] .prv-sig-label button:hover { color: #5b21b6; }

/* Canvas background: white in light mode, dark in dark mode */
#prvSignaturePad {
    background: #0b0d11; /* dark mode default */
}
[data-theme="light"] #prvSignaturePad {
    background: #ffffff;
}
[data-theme="light"] .prv-doc-view-btn {
    background: rgba(124,58,237,0.08); border-color: rgba(124,58,237,0.25); color: #6d28d9;
}
[data-theme="light"] .prv-doc-view-btn:hover {
    background: rgba(124,58,237,0.14); border-color: rgba(124,58,237,0.4); color: #5b21b6;
}

@media (max-width: 1199.98px) {
    .prv-upload-grid { grid-template-columns: repeat(3,minmax(0,1fr)); }
}
@media (max-width: 991.98px) {
    .prv-grid-2, .prv-rep-grid, .prv-upload-grid,
    .prv-members-head, .prv-members-row,
    .prv-sig-row { grid-template-columns: 1fr; }
    .prv-field-half { max-width: none; }
    .prv-members-head { display: none; }
    .prv-upload-grid { grid-template-columns: repeat(2,minmax(0,1fr)); }
    .prv-section { padding: 1.2rem 1.4rem; }
    .prv-header { padding: 1.2rem 1.4rem 1rem; }
    .prv-footer  { padding: 0.9rem 1.4rem 1.1rem; }
}
@media (max-width: 767.98px) {
    .prv-header, .prv-footer, .prv-header-actions { flex-direction: column; align-items: stretch; }
    .prv-btn { width: 100%; justify-content: center; }
    .prv-upload-grid { grid-template-columns: 1fr; }
}
</style>

<div class="prv-wrap">

    <?php if ($actionDone === 'approved'): ?>
        <div class="prv-alert success" role="alert">
            <i class="fas fa-check-circle"></i>
            Proposal <strong><?= $ref ?></strong> has been marked as <strong>Approved</strong>.
        </div>
    <?php elseif ($actionDone === 'returned'): ?>
        <div class="prv-alert danger" role="alert">
            <i class="fas fa-undo"></i>
            Proposal <strong><?= $ref ?></strong> has been <strong>Returned</strong> to the lead researcher.
        </div>
    <?php endif; ?>
    <?php if ($reviewError !== ''): ?>
        <div class="prv-alert danger" role="alert">
            <i class="fas fa-exclamation-triangle"></i>
            <?= htmlspecialchars($reviewError) ?>
        </div>
    <?php endif; ?>
    <div class="prv-alert danger" id="prvReviewGuardAlert" role="alert" style="display:none;">
        <i class="fas fa-exclamation-triangle"></i>
        <span id="prvReviewGuardText">Please complete the missing review requirements before approval.</span>
    </div>

    <div class="prv-form">

        <!-- ── Header ── -->
        <header class="prv-header">
            <div>
                <span class="prv-kicker">CRAD Officer · Proposal Review</span>
                <h1>Research Document Review</h1>
                <p>
                    Reviewing submitted documents for proposal
                    <strong style="color:#ede9fe"><?= htmlspecialchars($proposal['ref']) ?></strong>
                    &nbsp;&nbsp;
                    <span class="pst-badge <?= htmlspecialchars($proposal['status_cls']) ?>"><?= htmlspecialchars($proposal['status']) ?></span>
                </p>
            </div>
        </header>

        <!-- ── Research Information ── -->
        <section class="prv-section">
            <h2><span></span>Research Information</h2>
            <div class="prv-field">
                <label>Research Title</label>
                <div class="prv-value"><?= htmlspecialchars($proposal['title']) ?></div>
            </div>
            <div class="prv-grid-2">
                <div class="prv-field">
                    <label>Program / Course</label>
                    <div class="prv-value"><?= htmlspecialchars($proposal['program']) ?></div>
                </div>
                <div class="prv-field">
                    <label>Year &amp; Section</label>
                    <div class="prv-value"><?= htmlspecialchars($proposal['section']) ?></div>
                </div>
            </div>
            <div class="prv-grid-2">
                <div class="prv-field">
                    <label>College / Department</label>
                    <div class="prv-value"><?= htmlspecialchars($proposal['dept']) ?></div>
                </div>
                <div class="prv-field">
                    <label>Research Adviser</label>
                    <div class="prv-value"><?= htmlspecialchars($proposal['adviser']) ?></div>
                </div>
            </div>
            <div class="prv-field prv-field-half">
                <label>Academic Year</label>
                <div class="prv-value"><?= htmlspecialchars($proposal['acad_year']) ?></div>
            </div>
        </section>

        <!-- ── Group Members ── -->
        <section class="prv-section">
            <h2><span></span>Group Members <small>(Maximum 5)</small></h2>
            <div class="prv-members-table">
                <div class="prv-members-head">
                    <span>#</span>
                    <span>Student ID</span>
                    <span>Student Name</span>
                    <span>Email Address</span>
                    <span>Contact Number</span>
                </div>
                <?php foreach ($members as $i => $member): ?>
                    <div class="prv-members-row">
                        <span class="prv-num"><?= $i + 1 ?></span>
                        <span><?= htmlspecialchars($member['id']) ?></span>
                        <span><?= htmlspecialchars($member['name']) ?></span>
                        <span><?= htmlspecialchars($member['email']) ?></span>
                        <span><?= htmlspecialchars($member['contact']) ?></span>
                    </div>
                <?php endforeach; ?>
                <?php for ($i = count($members); $i < 5; $i++): ?>
                    <div class="prv-members-row" style="opacity:0.35;">
                        <span class="prv-num"><?= $i + 1 ?></span>
                        <span>—</span><span>—</span><span>—</span><span>—</span>
                    </div>
                <?php endfor; ?>
            </div>
        </section>

        <!-- ── Document Attachments ── -->
        <section class="prv-section">
            <h2><span></span>Document Attachments</h2>
            <p class="prv-hint">Documents submitted by the lead researcher. Read-only view.</p>
            <div class="prv-upload-grid">
                <?php foreach ($documents as $doc): ?>
                    <div class="prv-doc-card">
                        <span class="prv-tag <?= $doc['required'] ? 'required' : 'optional' ?>">
                            <?= $doc['required'] ? 'REQUIRED' : 'OPTIONAL' ?>
                        </span>
                        <strong><?= htmlspecialchars($doc['title']) ?></strong>
                        <?php if ($doc['stored_name'] !== ''): ?>
                            <div class="prv-doc-file has-file" style="background:transparent;border:none;padding:0;justify-content:flex-start;">
                                <i class="fas fa-paperclip" style="color:#94a3b8;font-size:0.85rem;"></i>
                                <span style="color:#cbd5e1;font-size:0.82rem;"><?= htmlspecialchars($doc['original_name']) ?></span>
                            </div>
                            <small style="color:#94a3b8;font-size:0.72rem;margin-top:0.25rem;">
                                <?= number_format($doc['file_size'] / 1024, 1) ?> KB
                            </small>
                            <?php
                                $fileExt    = strtolower(pathinfo($doc['stored_name'], PATHINFO_EXTENSION));
                                $viewUrl    = BASE_URL . '/modules/crad/file-view.php?pid=' . $proposal['proposal_id'] . '&key=' . urlencode($doc['key']);
                                $docTitle   = htmlspecialchars(addslashes($doc['title']));
                            ?>
                            <a href="#"
                               class="prv-doc-view-btn"
                               onclick="prvShowFile(event, '<?= $docTitle ?>', '<?= $viewUrl ?>', '<?= $fileExt ?>')">
                                <i class="fas fa-eye"></i> View File
                            </a>
                            <!-- Verdict: correct / wrong -->
                            <div class="prv-doc-verdict">
                                <button type="button"
                                        class="prv-verdict-btn correct"
                                        data-doc="<?= htmlspecialchars($doc['key']) ?>"
                                        data-verdict="correct"
                                        onclick="prvSetVerdict(this, 'correct')"
                                        title="Mark as correct">
                                    <i class="fas fa-check"></i> Correct
                                </button>
                                <button type="button"
                                        class="prv-verdict-btn wrong"
                                        data-doc="<?= htmlspecialchars($doc['key']) ?>"
                                        data-verdict="wrong"
                                        onclick="prvSetVerdict(this, 'wrong')"
                                        title="Mark as wrong / needs revision">
                                    <i class="fas fa-times"></i> Wrong
                                </button>
                            </div>
                        <?php else: ?>
                            <div class="prv-doc-file no-file">
                                <i class="fas fa-times-circle"></i>
                                No file submitted
                            </div>
                        <?php endif; ?>
                    </div>
                <?php endforeach; ?>
            </div>
        </section>

        <!-- ── Group Representative ── -->
        <section class="prv-section">
            <h2><span></span>Group Representative</h2>
            <div class="prv-rep-grid">
                <div class="prv-field">
                    <label>Representative Name</label>
                    <div class="prv-value"><?= htmlspecialchars($proposal['rep']['name']) ?></div>
                </div>
                <div class="prv-field">
                    <label>Student ID</label>
                    <div class="prv-value"><?= htmlspecialchars($proposal['rep']['id']) ?></div>
                </div>
                <div class="prv-field">
                    <label>Email Address</label>
                    <div class="prv-value"><?= htmlspecialchars($proposal['rep']['email']) ?></div>
                </div>
                <div class="prv-field">
                    <label>Contact Number</label>
                    <div class="prv-value"><?= htmlspecialchars($proposal['rep']['contact']) ?></div>
                </div>
            </div>
        </section>

        <!-- ── Final Declaration & Representative Signature ── -->
        <section class="prv-section">
            <h2><span></span>Final Declaration &amp; Representative Signature</h2>
            <label class="prv-check">
                <input type="checkbox" id="prvDeclarationCheck" name="declaration" value="1" required>
                <span>We certify that the information provided is true and correct. We further certify that all uploaded documents are authentic, complete, and submitted on behalf of all members of the research group.</span>
            </label>
            <div class="prv-sig-row">
                <div class="prv-sig-pad-wrap">
                    <div class="prv-sig-label">
                        <span>Representative Signature Pad (Draw Below):</span>
                        <button type="button" id="prvClearPadBtn">Clear Pad</button>
                    </div>
                    <canvas id="prvSignaturePad" width="760" height="180" aria-label="Signature pad" style="display:block;width:100%;height:180px;cursor:crosshair;touch-action:none;"></canvas>
                    <input type="hidden" name="signature_data" id="prvSignatureData">
                </div>
                <div class="prv-field">
                    <label>Date Submitted</label>
                    <div class="prv-value"><?= date('F j, Y') ?></div>
                </div>
            </div>
        </section>

        <!-- ── Submission Info ── -->
        <section class="prv-section">
            <h2><span></span>Submission Details</h2>
            <div class="prv-field prv-field-half">
                <label>Date Submitted</label>
                <div class="prv-value"><?= htmlspecialchars($proposal['submitted_on']) ?></div>
            </div>
            <div class="prv-field">
                <label>CRAD Officer Remarks</label>
                <textarea
                    class="prv-remarks"
                    name="remarks"
                    placeholder="Add remarks or notes for this proposal (optional)…"
                ><?= htmlspecialchars($proposal['remarks']) ?></textarea>
            </div>
        </section>

        <!-- Footer Actions -->
        <footer class="prv-footer">
            <div class="prv-footer-right">
                <a class="prv-btn prv-btn-return"
                   href="#"
                   data-prv-confirm="return"
                   data-submit-form="prvReturnForm"
                   data-title="Return Proposal"
                   data-message="Return this proposal to the lead researcher for revision?"
                   data-confirm-label="Return Proposal">
                    <i class="fas fa-undo"></i> Return Proposal
                </a>
                <a class="prv-btn prv-btn-approve"
                   href="#"
                   data-prv-confirm="approve"
                   data-submit-form="prvApproveForm"
                   data-title="Approve Proposal"
                   data-message="Approve this research proposal and move it to Register Proposal?"
                   data-confirm-label="Approve Proposal">
                    <i class="fas fa-check-circle"></i> Approve Proposal
                </a>
            </div>
        </footer>

    </div><!-- /.prv-form -->
    <form id="prvApproveForm" method="post" action="?ref=<?= urlencode($ref) ?>" style="display:none;">
        <?= csrfField() ?>
        <input type="hidden" name="action" value="approve">
        <input type="hidden" name="doc_verdicts_json" id="prvDocVerdictsJson" value="{}">
        <input type="hidden" name="approval_declaration" id="prvApprovalDeclaration" value="">
        <input type="hidden" name="approval_signature_data" id="prvApprovalSignatureData" value="">
    </form>
    <form id="prvReturnForm" method="post" action="?ref=<?= urlencode($ref) ?>" style="display:none;">
        <?= csrfField() ?>
        <input type="hidden" name="action" value="return">
        <input type="hidden" name="return_remarks" id="prvReturnRemarks" value="">
    </form>
</div><!-- /.prv-wrap -->

<div class="prv-modal-backdrop" id="prvConfirmModal" aria-hidden="true">
    <div class="prv-modal" role="dialog" aria-modal="true" aria-labelledby="prvConfirmTitle">
        <div class="prv-modal-head">
            <div class="prv-modal-icon" id="prvConfirmIcon"><i class="fas fa-check-circle"></i></div>
            <div>
                <h2 class="prv-modal-title" id="prvConfirmTitle">Approve Proposal</h2>
                <p class="prv-modal-text" id="prvConfirmMessage">Approve this research proposal?</p>
            </div>
        </div>
        <div class="prv-modal-body">
            <span>Proposal</span>
            <strong><?= htmlspecialchars($proposal['ref']) ?> · <?= htmlspecialchars($proposal['title']) ?></strong>
        </div>
        <div class="prv-modal-actions">
            <button type="button" class="prv-modal-btn prv-modal-cancel" id="prvConfirmCancel">
                Cancel
            </button>
            <a href="#" class="prv-modal-btn prv-modal-confirm" id="prvConfirmAction">
                <i class="fas fa-check-circle"></i> Approve Proposal
            </a>
        </div>
    </div>
</div>


<script>
// ── Document verdict (correct / wrong) toggles ──────────────────────────────
var _prvCsrfToken = '<?= addslashes(csrfToken()) ?>';
// Custom confirmation modal for final CRAD actions
(function () {
    var modal = document.getElementById('prvConfirmModal');
    var title = document.getElementById('prvConfirmTitle');
    var message = document.getElementById('prvConfirmMessage');
    var icon = document.getElementById('prvConfirmIcon');
    var cancel = document.getElementById('prvConfirmCancel');
    var action = document.getElementById('prvConfirmAction');
    if (!modal || !title || !message || !icon || !cancel || !action) return;
    var pendingFormId = '';

    function closeModal() {
        modal.classList.remove('is-open');
        modal.setAttribute('aria-hidden', 'true');
        action.href = '#';
        pendingFormId = '';
        action.removeAttribute('data-submit-form');
    }

    document.querySelectorAll('[data-prv-confirm]').forEach(function (btn) {
        btn.addEventListener('click', function (event) {
            event.preventDefault();

            var type = btn.getAttribute('data-prv-confirm') || 'approve';
            if (type === 'approve' && !prvValidateApprovalReady(true)) {
                return;
            }
            if (type === 'return') {
                prvSyncReturnFields();
                var remarks = document.getElementById('prvReturnRemarks');
                if (!remarks || remarks.value.trim() === '') {
                    prvShowReviewGuard(['Add CRAD remarks before returning the proposal.']);
                    return;
                }
            }

            var confirmLabel = btn.getAttribute('data-confirm-label') || 'Continue';
            pendingFormId = btn.getAttribute('data-submit-form') || '';
            title.textContent = btn.getAttribute('data-title') || confirmLabel;
            message.textContent = btn.getAttribute('data-message') || 'Continue with this action?';
            action.href = pendingFormId ? '#' : btn.href;
            if (pendingFormId) {
                action.setAttribute('data-submit-form', pendingFormId);
            } else {
                action.removeAttribute('data-submit-form');
            }
            action.innerHTML = type === 'return'
                ? '<i class="fas fa-undo"></i> ' + confirmLabel
                : '<i class="fas fa-check-circle"></i> ' + confirmLabel;
            action.classList.toggle('return', type === 'return');
            icon.classList.toggle('return', type === 'return');
            icon.innerHTML = type === 'return'
                ? '<i class="fas fa-undo"></i>'
                : '<i class="fas fa-check-circle"></i>';

            modal.classList.add('is-open');
            modal.setAttribute('aria-hidden', 'false');
            cancel.focus();
        });
    });

    action.addEventListener('click', function (event) {
        var formId = action.getAttribute('data-submit-form') || '';
        if (!formId) {
            return;
        }

        event.preventDefault();
        if (formId === 'prvApproveForm' && !prvValidateApprovalReady(true)) {
            closeModal();
            return;
        }
        if (formId === 'prvReturnForm') {
            prvSyncReturnFields();
        }

        var form = document.getElementById(formId);
        if (form) {
            var csrfInput = form.querySelector('input[name="csrf_token"]');
            if (csrfInput) {
                csrfInput.value = _prvCsrfToken;
            }
            HTMLFormElement.prototype.submit.call(form);
        }
    });

    cancel.addEventListener('click', closeModal);
    modal.addEventListener('click', function (event) {
        if (event.target === modal) {
            closeModal();
        }
    });
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && modal.classList.contains('is-open')) {
            closeModal();
        }
    });
})();

var _prvCorrectCount = 0;
var _prvRef          = '<?= addslashes($ref) ?>';
var _prvBaseUrl      = '<?= addslashes(BASE_URL) ?>';
var _prvSaveBase     = '?ref=' + encodeURIComponent(_prvRef) + '&action=save_progress&correct=';
var _prvDocVerdicts  = {};
var _prvProgressSaveTimer = null;
var _prvDocumentRules = <?= json_encode(array_map(static function ($doc) {
    return [
        'key' => $doc['key'],
        'title' => $doc['title'],
        'required' => (bool) $doc['required'],
        'hasFile' => $doc['stored_name'] !== '',
    ];
}, $documents), JSON_UNESCAPED_SLASHES) ?>;

function prvSyncApprovalFields() {
    var verdictJson = document.getElementById('prvDocVerdictsJson');
    var declarationSource = document.getElementById('prvDeclarationCheck');
    var declarationTarget = document.getElementById('prvApprovalDeclaration');
    var signatureSource = document.getElementById('prvSignatureData');
    var signatureTarget = document.getElementById('prvApprovalSignatureData');

    if (verdictJson) {
        verdictJson.value = JSON.stringify(_prvDocVerdicts);
    }
    if (declarationTarget) {
        declarationTarget.value = declarationSource && declarationSource.checked ? '1' : '';
    }
    if (signatureTarget) {
        signatureTarget.value = signatureSource ? signatureSource.value : '';
    }
}

function prvSyncReturnFields() {
    var remarksSource = document.querySelector('.prv-remarks');
    var remarksTarget = document.getElementById('prvReturnRemarks');
    if (remarksTarget) {
        remarksTarget.value = remarksSource ? remarksSource.value : '';
    }
}

function prvPersistProgress() {
    if (_prvCorrectCount <= 0) {
        return;
    }

    var url = _prvSaveBase + encodeURIComponent(_prvCorrectCount) + '&ajax=1';
    fetch(url, {
        method: 'GET',
        credentials: 'same-origin',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        keepalive: true
    }).catch(function () {});
}

function prvQueueProgressSave() {
    if (_prvProgressSaveTimer) {
        clearTimeout(_prvProgressSaveTimer);
    }
    _prvProgressSaveTimer = setTimeout(prvPersistProgress, 350);
}

function prvShowReviewGuard(issues) {
    var alertBox = document.getElementById('prvReviewGuardAlert');
    var alertText = document.getElementById('prvReviewGuardText');
    if (!alertBox || !alertText) return;

    if (!issues.length) {
        alertBox.style.display = 'none';
        alertText.textContent = '';
        return;
    }

    alertText.innerHTML = 'Please complete the missing review requirements before approval: ' + issues.map(function (issue) {
        return '<span style="display:block;margin-top:0.25rem;">- ' + issue + '</span>';
    }).join('');
    alertBox.style.display = '';
    alertBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function prvValidateApprovalReady(showNote) {
    var issues = [];
    var declaration = document.getElementById('prvDeclarationCheck');
    var signature = document.getElementById('prvSignatureData');
    var missingDeclaration = !declaration || !declaration.checked;

    _prvDocumentRules.forEach(function (doc) {
        var verdict = _prvDocVerdicts[doc.key] || '';

        if (doc.required && !doc.hasFile) {
            issues.push(doc.title + ' is required but has no uploaded file.');
            return;
        }

        if (doc.hasFile && verdict !== 'correct' && verdict !== 'wrong') {
            issues.push('Mark ' + doc.title + ' as Correct or Wrong.');
            return;
        }

        if (doc.hasFile && verdict === 'wrong') {
            issues.push(doc.title + ' is marked Wrong. Return the proposal for revision before approval.');
        }
    });

    if (missingDeclaration) {
        issues.push('Check the final certification.');
    }
    if (!signature || signature.value.length < 200) {
        issues.push('Complete the signature pad.');
    }

    prvSyncApprovalFields();
    if (showNote) {
        if (missingDeclaration && issues.length === 1 && declaration && typeof declaration.reportValidity === 'function') {
            prvShowReviewGuard([]);
            declaration.focus();
            declaration.reportValidity();
            return false;
        }
        prvShowReviewGuard(issues);
        if (missingDeclaration && declaration && typeof declaration.reportValidity === 'function') {
            declaration.reportValidity();
        }
    }

    return issues.length === 0;
}

function prvSetVerdict(btn, verdict) {
    var card     = btn.closest('.prv-doc-card');
    var isActive = btn.classList.contains('active');
    var wasCorrect = card.querySelector('.prv-verdict-btn.correct.active') !== null;
    var docKey = btn.getAttribute('data-doc') || '';

    // Clear all in this card
    card.querySelectorAll('.prv-verdict-btn').forEach(function (b) {
        b.classList.remove('active');
    });

    // Update correct count based on previous and new state
    if (wasCorrect) { _prvCorrectCount = Math.max(0, _prvCorrectCount - 1); }

    if (!isActive) {
        btn.classList.add('active');
        if (verdict === 'correct') { _prvCorrectCount++; }
        if (docKey) { _prvDocVerdicts[docKey] = verdict; }
    } else if (docKey) {
        delete _prvDocVerdicts[docKey];
    }

    // Update card border
    card.style.borderStyle = 'solid';
    if (!isActive && verdict === 'correct') {
        card.style.borderColor = 'rgba(16,185,129,0.6)';
    } else if (!isActive && verdict === 'wrong') {
        card.style.borderColor = 'rgba(239,68,68,0.6)';
    } else {
        card.style.borderColor = '';
        card.style.borderStyle = 'dashed';
    }

    prvSyncApprovalFields();
    prvQueueProgressSave();
    prvValidateApprovalReady(false);
}

prvSyncApprovalFields();

window.addEventListener('pagehide', function () {
    if (_prvProgressSaveTimer) {
        clearTimeout(_prvProgressSaveTimer);
        _prvProgressSaveTimer = null;
    }
    prvPersistProgress();
});

var _prvDeclaration = document.getElementById('prvDeclarationCheck');
if (_prvDeclaration) {
    _prvDeclaration.addEventListener('change', function () {
        prvSyncApprovalFields();
        prvValidateApprovalReady(false);
    });
}
</script>

<script>
// Signature pad
(function () {
    var canvas = document.getElementById('prvSignaturePad');
    if (!canvas) return;
    var ctx = canvas.getContext('2d');
    var drawing = false;

    function getStrokeColor() {
        var theme = document.documentElement.getAttribute('data-theme') || 'light';
        return theme === 'light' ? '#0f172a' : '#ffffff';
    }

    function applyStrokeStyle() {
        ctx.strokeStyle = getStrokeColor();
        ctx.lineWidth   = 2;
        ctx.lineCap     = 'round';
    }

    function resizeCanvas() {
        var ratio = Math.max(window.devicePixelRatio || 1, 1);
        var rect  = canvas.getBoundingClientRect();
        canvas.width  = Math.floor(rect.width  * ratio);
        canvas.height = Math.floor(180          * ratio);
        ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
        applyStrokeStyle();
    }

    function pos(e) {
        var rect = canvas.getBoundingClientRect();
        var pt   = e.touches ? e.touches[0] : e;
        return { x: pt.clientX - rect.left, y: pt.clientY - rect.top };
    }

    canvas.addEventListener('mousedown', function (e) {
        applyStrokeStyle();
        drawing = true; var p = pos(e); ctx.beginPath(); ctx.moveTo(p.x, p.y);
    });
    canvas.addEventListener('mousemove', function (e) {
        if (!drawing) return; var p = pos(e); ctx.lineTo(p.x, p.y); ctx.stroke();
        document.getElementById('prvSignatureData').value = canvas.toDataURL('image/png');
        if (typeof prvSyncApprovalFields === 'function') { prvSyncApprovalFields(); }
    });
    ['mouseup', 'mouseleave'].forEach(function (n) {
        canvas.addEventListener(n, function () { drawing = false; });
    });
    canvas.addEventListener('touchstart', function (e) {
        e.preventDefault();
        applyStrokeStyle();
        drawing = true; var p = pos(e); ctx.beginPath(); ctx.moveTo(p.x, p.y);
    }, { passive: false });
    canvas.addEventListener('touchmove', function (e) {
        e.preventDefault(); if (!drawing) return; var p = pos(e); ctx.lineTo(p.x, p.y); ctx.stroke();
        document.getElementById('prvSignatureData').value = canvas.toDataURL('image/png');
        if (typeof prvSyncApprovalFields === 'function') { prvSyncApprovalFields(); }
    }, { passive: false });
    canvas.addEventListener('touchend', function () { drawing = false; });

    document.getElementById('prvClearPadBtn').addEventListener('click', function () {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        document.getElementById('prvSignatureData').value = '';
        if (typeof prvSyncApprovalFields === 'function') { prvSyncApprovalFields(); }
    });

    // Re-apply stroke color whenever the theme attribute changes on <html>
    var themeObserver = new MutationObserver(function (mutations) {
        mutations.forEach(function (m) {
            if (m.attributeName === 'data-theme') {
                applyStrokeStyle();
            }
        });
    });
    themeObserver.observe(document.documentElement, { attributes: true });

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
})();
</script>

<!-- ── File preview modal ── -->
<div id="prvFileModal" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,0.85);backdrop-filter:blur(4px);align-items:center;justify-content:center;padding:1.5rem;">
    <div style="background:#181c22;border:1px solid rgba(148,163,184,0.2);border-radius:18px;width:100%;max-width:90vw;max-height:90vh;overflow:hidden;box-shadow:0 24px 60px rgba(0,0,0,0.5);display:flex;flex-direction:column;">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:1rem 1.25rem;background:linear-gradient(135deg,#2e1065,#4c1d95,#111827);color:#fff;flex-shrink:0;">
            <div>
                <div style="font-size:0.7rem;font-weight:800;letter-spacing:0.06em;text-transform:uppercase;color:#c4b5fd;margin-bottom:0.2rem;">Document Preview</div>
                <div id="prvFileModalTitle" style="font-size:1rem;font-weight:800;"></div>
            </div>
            <button onclick="document.getElementById('prvFileModal').style.display='none'" style="background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);border-radius:8px;color:#fff;width:34px;height:34px;cursor:pointer;font-size:1rem;display:flex;align-items:center;justify-content:center;">&times;</button>
        </div>
        <div id="prvFileModalBody" style="flex:1;overflow:auto;background:#0f1318;display:flex;align-items:center;justify-content:center;">
            <!-- File content loads here -->
        </div>
    </div>
</div>

<script>
function prvShowFile(e, title, fileUrl, ext) {
    e.preventDefault();
    document.getElementById('prvFileModalTitle').textContent = title;
    var body = document.getElementById('prvFileModalBody');
    body.innerHTML = '<div style="color:#94a3b8;padding:2rem;text-align:center;"><i class="fas fa-spinner fa-spin" style="font-size:2rem;"></i><p style="margin-top:0.75rem;">Loading…</p></div>';

    var modal = document.getElementById('prvFileModal');
    modal.style.display = 'flex';

    ext = (ext || '').toLowerCase();
    var absUrl = window.location.origin + (fileUrl.startsWith('/') ? '' : '/') + fileUrl;

    setTimeout(function () {
        if (['jpg','jpeg','png','gif','webp','bmp'].indexOf(ext) !== -1) {
            // ── Image ─────────────────────────────────────────────────────
            body.innerHTML = '';
            var wrap = document.createElement('div');
            wrap.style.cssText = 'width:100%;height:100%;display:flex;align-items:center;justify-content:center;padding:1.5rem;overflow:auto;background:#0f1318;';
            var img = document.createElement('img');
            img.src = absUrl;
            img.style.cssText = 'max-width:100%;max-height:75vh;object-fit:contain;border-radius:8px;box-shadow:0 4px 20px rgba(0,0,0,0.5);';
            img.onerror = function () {
                wrap.innerHTML = '<div style="text-align:center;padding:2rem;color:#f87171;"><i class="fas fa-exclamation-circle" style="font-size:2rem;display:block;margin-bottom:0.75rem;"></i>Image could not be loaded.</div>';
            };
            wrap.appendChild(img);
            body.appendChild(wrap);

        } else if (ext === 'pdf') {
            // ── PDF ───────────────────────────────────────────────────────
            body.innerHTML = '';
            var obj = document.createElement('object');
            obj.data = absUrl + '#toolbar=1&navpanes=0';
            obj.type = 'application/pdf';
            obj.style.cssText = 'width:100%;height:78vh;border:0;background:#fff;display:block;';
            // Fallback for browsers that can't embed PDFs
            var fallback = document.createElement('div');
            fallback.style.cssText = 'text-align:center;padding:2.5rem 2rem;';
            fallback.innerHTML = '<i class="fas fa-file-pdf" style="font-size:3.5rem;color:#ef4444;display:block;margin-bottom:1rem;"></i>'
                + '<p style="color:#94a3b8;font-size:0.9rem;margin-bottom:1.5rem;">Your browser cannot display this PDF inline.</p>'
                + '<a href="' + absUrl + '" target="_blank" style="display:inline-flex;align-items:center;gap:0.5rem;padding:0.75rem 1.75rem;background:#7c3aed;color:#fff;text-decoration:none;border-radius:10px;font-weight:700;">'
                + '<i class="fas fa-external-link-alt"></i> Open PDF</a>';
            obj.appendChild(fallback);
            body.appendChild(obj);

        } else if (['doc','docx','xls','xlsx','ppt','pptx'].indexOf(ext) !== -1) {
            // ── Office files ─────────────────────────────────────────────
            var iconMap = { doc:'fa-file-word', docx:'fa-file-word', xls:'fa-file-excel', xlsx:'fa-file-excel', ppt:'fa-file-powerpoint', pptx:'fa-file-powerpoint' };
            var icon = iconMap[ext] || 'fa-file-alt';
            var colorMap = { doc:'#2b579a', docx:'#2b579a', xls:'#1d6f42', xlsx:'#1d6f42', ppt:'#c55a11', pptx:'#c55a11' };
            var color = colorMap[ext] || '#7c3aed';
            body.innerHTML = '<div style="text-align:center;padding:3rem 2rem;">'
                + '<i class="fas ' + icon + '" style="font-size:4rem;color:' + color + ';display:block;margin-bottom:1.25rem;"></i>'
                + '<h3 style="margin:0 0 0.5rem;font-size:1.05rem;font-weight:700;color:#fff;">' + title + '</h3>'
                + '<p style="margin:0 0 1.75rem;font-size:0.85rem;color:#94a3b8;max-width:360px;margin-left:auto;margin-right:auto;">Office documents cannot be previewed inline.<br>Click below to open the file — it will open in your Office app.</p>'
                + '<a href="' + absUrl + '" target="_blank" style="display:inline-flex;align-items:center;gap:0.6rem;padding:0.8rem 1.75rem;background:' + color + ';color:#fff;text-decoration:none;border-radius:10px;font-weight:700;font-size:0.9rem;">'
                + '<i class="fas fa-external-link-alt"></i> Open File'
                + '</a>'
                + '</div>';

        } else {
            body.innerHTML = '<div style="text-align:center;padding:3rem 2rem;">'
                + '<i class="fas fa-file" style="font-size:3rem;color:#64748b;display:block;margin-bottom:1rem;"></i>'
                + '<p style="color:#94a3b8;font-size:0.9rem;margin-bottom:1.5rem;">Cannot preview this file type inline.</p>'
                + '<a href="' + absUrl + '" target="_blank" style="display:inline-flex;align-items:center;gap:0.5rem;padding:0.7rem 1.5rem;background:#7c3aed;color:#fff;text-decoration:none;border-radius:10px;font-weight:700;">'
                + '<i class="fas fa-external-link-alt"></i> Open File'
                + '</a></div>';
        }
    }, 100);

    modal.addEventListener('click', function handler(ev) {
        if (ev.target === modal) {
            modal.style.display = 'none';
            body.innerHTML = '';
            modal.removeEventListener('click', handler);
        }
    });
}
</script>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
