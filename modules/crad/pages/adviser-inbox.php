<?php
/**
 * CRAD — Adviser Inbox: Title Approval Submissions
 * Shows CRAD Form S2 V3 submissions sent to the logged-in adviser.
 * Polls every 5 s for real-time updates.
 */
declare(strict_types=1);

require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/breadcrumbs.php';

requireAuth();

function aiE(string $v): string
{
    return htmlspecialchars($v, ENT_QUOTES, 'UTF-8');
}

/* Match by adviser_name OR adviser_email for robustness */
function aiRows(PDO $pdo, string $adviserName, string $adviserEmail): array
{
    $stmt = $pdo->prepare(
        "SELECT id, student_id, student_name, submission_date, department,
                proposed_title, discipline_cluster, primary_sdg, research_agenda,
                sdg_justification, members_json, adviser_name, adviser_email,
                coordinator_name, status, adviser_remarks, sent_at, reviewed_at
         FROM title_approvals
         WHERE adviser_name = :name OR (adviser_email != '' AND adviser_email = :email)
         ORDER BY sent_at DESC"
    );
    $stmt->execute([':name' => $adviserName, ':email' => $adviserEmail]);
    return $stmt->fetchAll() ?: [];
}

function aiPayload(PDO $pdo, string $adviserName, string $adviserEmail): array
{
    $rows    = aiRows($pdo, $adviserName, $adviserEmail);
    $pending = count(array_filter($rows, fn($r) => $r['status'] === 'Pending'));
    return [
        'ok'        => true,
        'rows'      => $rows,
        'stats'     => ['total' => count($rows), 'pending' => $pending, 'reviewed' => count($rows) - $pending],
        'last_sync' => date('M j, Y g:i:s A'),
    ];
}

/* Get logged-in user's name and email */
$currentAdviserName  = getCurrentUserName();
$currentAdviserEmail = $_SESSION['user_email'] ?? '';

/* ── AJAX: fetch rows ────────────────────────────────────── */
if (($_GET['ajax'] ?? '') === 'inbox') {
    header('Content-Type: application/json; charset=utf-8');
    try {
        $pdo = getCradDatabaseConnection();
        echo json_encode(aiPayload($pdo, $currentAdviserName, $currentAdviserEmail));
    } catch (Throwable $e) {
        echo json_encode(['ok' => false, 'error' => $e->getMessage(), 'rows' => [], 'stats' => []]);
    }
    exit;
}

/* ── AJAX: update status ─────────────────────────────────── */
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_GET['ajax'] ?? '') === 'update-status') {
    header('Content-Type: application/json; charset=utf-8');
    $body    = json_decode((string) file_get_contents('php://input'), true) ?? [];
    $id      = (int) ($body['id'] ?? 0);
    $status  = in_array($body['status'] ?? '', ['Reviewed', 'Approved', 'Returned'], true)
               ? $body['status'] : null;
    $remarks = trim((string) ($body['remarks'] ?? ''));

    if (!$id || !$status) {
        echo json_encode(['ok' => false, 'error' => 'Invalid input.']);
        exit;
    }
    try {
        $pdo  = getCradDatabaseConnection();
        $stmt = $pdo->prepare(
            "UPDATE title_approvals
             SET status = :status, adviser_remarks = :remarks, reviewed_at = NOW()
             WHERE id = :id
               AND (adviser_name = :name OR (adviser_email != '' AND adviser_email = :email))"
        );
        $stmt->execute([
            ':status'  => $status,
            ':remarks' => $remarks ?: null,
            ':id'      => $id,
            ':name'    => $currentAdviserName,
            ':email'   => $currentAdviserEmail,
        ]);
        echo json_encode(['ok' => true]);
    } catch (Throwable $e) {
        echo json_encode(['ok' => false, 'error' => $e->getMessage()]);
    }
    exit;
}

/* ── page load ───────────────────────────────────────────── */
try {
    $pdo     = getCradDatabaseConnection();
    $payload = aiPayload($pdo, $currentAdviserName, $currentAdviserEmail);
} catch (Throwable $e) {
    $payload = ['ok' => false, 'error' => $e->getMessage(), 'rows' => [], 'stats' => []];
}

$rows  = $payload['rows'];
$stats = $payload['stats'] ?? ['total' => 0, 'pending' => 0, 'reviewed' => 0];

$pageTitle   = 'Adviser Inbox — Title Approvals';
$activeModule = 'crad';
$activePage   = 'adviser-inbox';
$breadcrumbs  = [
    ['label' => 'Research', 'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Adviser Inbox', 'url' => null],
];

require_once ROOT_PATH . '/includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);
?>
<style>
.ai-wrap { display: flex; flex-direction: column; gap: 1rem; }
.ai-header {
    display: flex; align-items: center; justify-content: space-between; gap: 1rem;
    padding: 1.1rem 1.25rem; border: 1px solid var(--sms-border,#e2e8f0);
    border-radius: 8px; background: var(--sms-surface-solid,#fff); box-shadow: var(--sms-shadow-xs);
}
.ai-header h1 { margin: 0; font-size: 1.25rem; font-weight: 850; color: var(--sms-heading); }
.ai-header p  { margin: .25rem 0 0; color: var(--sms-text-muted); font-size: .86rem; }
.ai-sync { color: #2563eb; font-size: .78rem; font-weight: 800; white-space: nowrap; }
.ai-stats { display: grid; grid-template-columns: repeat(3,minmax(0,1fr)); gap: .85rem; }
.ai-stat {
    display: flex; align-items: center; gap: .8rem; padding: .9rem 1rem;
    border: 1px solid var(--sms-border,#e2e8f0); border-radius: 8px;
    background: var(--sms-surface-solid,#fff); box-shadow: var(--sms-shadow-xs);
}
.ai-stat i { width:40px;height:40px;display:grid;place-items:center;border-radius:8px;
    color:#1d4ed8;background:rgba(37,99,235,.12); }
.ai-stat strong { display:block;color:var(--sms-heading);font-size:1.35rem;line-height:1; }
.ai-stat span   { display:block;margin-top:.25rem;color:var(--sms-text-muted);font-size:.72rem;font-weight:800;text-transform:uppercase; }
.ai-card { border:1px solid var(--sms-border,#e2e8f0);border-radius:8px;
    background:var(--sms-surface-solid,#fff);box-shadow:var(--sms-shadow-sm);overflow:hidden; }
.ai-card-head { display:flex;align-items:center;justify-content:space-between;gap:1rem;
    padding:.9rem 1rem;border-bottom:1px solid var(--sms-border,#e2e8f0); }
.ai-card-head h2 { margin:0;color:var(--sms-heading);font-size:.95rem;font-weight:850; }
.ai-search { width:min(320px,100%);min-height:36px;border:1px solid var(--sms-border,#d8e2ef);
    border-radius:8px;padding:.45rem .7rem;background:var(--sms-surface-muted,#f8fafc);
    color:var(--sms-heading);font-size:.84rem; }
.ai-table-wrap { overflow-x:auto; }
.ai-table { width:100%;min-width:900px;border-collapse:collapse; }
.ai-table th,.ai-table td { padding:.82rem .9rem;border-bottom:1px solid var(--sms-border,#e2e8f0);
    text-align:left;vertical-align:top; }
.ai-table th { color:var(--sms-text-muted);background:var(--sms-surface-muted,#f8fafc);
    font-size:.72rem;font-weight:850;text-transform:uppercase; }
.ai-title { color:var(--sms-heading);font-weight:850;line-height:1.35; }
.ai-muted { color:var(--sms-text-muted);font-size:.76rem;font-weight:650; }
.ai-badge { display:inline-flex;align-items:center;gap:.3rem;padding:.26rem .58rem;
    border-radius:999px;font-size:.74rem;font-weight:850;white-space:nowrap; }
.ai-badge-pending  { color:#92400e;background:#fef3c7; }
.ai-badge-reviewed { color:#1e40af;background:#dbeafe; }
.ai-badge-approved { color:#065f46;background:#d1fae5; }
.ai-badge-returned { color:#991b1b;background:#fee2e2; }
.ai-btn-act { display:inline-flex;align-items:center;gap:.3rem;padding:.3rem .7rem;
    border-radius:6px;border:1px solid transparent;font-size:.78rem;font-weight:700;
    cursor:pointer;transition:opacity .15s; }
.ai-btn-approve { color:#065f46;background:#d1fae5;border-color:#6ee7b7; }
.ai-btn-return  { color:#991b1b;background:#fee2e2;border-color:#fca5a5; }
.ai-btn-approve:hover,.ai-btn-return:hover { opacity:.78; }
.ai-empty { padding:2.5rem 1rem;text-align:center;color:var(--sms-text-muted);font-weight:750; }
.ai-new-row { animation:aiFlash 1.6s ease; }
@keyframes aiFlash { 0%,100%{background:transparent} 35%{background:rgba(37,99,235,.09)} }
[data-theme="dark"] .ai-header,[data-theme="dark"] .ai-stat,[data-theme="dark"] .ai-card
    { background:rgba(15,23,42,.74);border-color:rgba(148,163,184,.2); }
[data-theme="dark"] .ai-card-head,[data-theme="dark"] .ai-table th,
[data-theme="dark"] .ai-table td { border-color:rgba(148,163,184,.2); }
[data-theme="dark"] .ai-table th,[data-theme="dark"] .ai-search { background:rgba(148,163,184,.07); }
@media(max-width:767.98px){
    .ai-header,.ai-card-head{align-items:flex-start;flex-direction:column;}
    .ai-stats{grid-template-columns:1fr;}
    .ai-sync,.ai-search{width:100%;}
}
</style>

<div class="ai-wrap"
     data-ai-inbox="<?= aiE(BASE_URL . '/modules/crad/pages/adviser-inbox.php?ajax=inbox') ?>"
     data-ai-update="<?= aiE(BASE_URL . '/modules/crad/pages/adviser-inbox.php?ajax=update-status') ?>">

    <?php if (!($payload['ok'] ?? true)): ?>
    <div style="padding:.8rem 1rem;border:1px solid #fecaca;border-radius:8px;background:#fef2f2;color:#991b1b;font-weight:750;">
        <i class="fas fa-exclamation-circle me-1"></i><?= aiE((string)($payload['error'] ?? 'Error loading data.')) ?>
    </div>
    <?php endif; ?>

    <header class="ai-header">
        <div>
            <h1><i class="fas fa-inbox me-2"></i>Adviser Inbox — Title Approval Forms</h1>
            <p>CRAD Form S2 V3 submissions sent by students assigned to you.</p>
        </div>
        <div class="ai-sync" id="aiLastSync">Synced <?= aiE((string)($payload['last_sync'] ?? '')) ?></div>
    </header>

    <div class="ai-stats">
        <div class="ai-stat"><i class="fas fa-envelope-open-text"></i>
            <div><strong id="aiTotal"><?= (int)$stats['total'] ?></strong><span>Total</span></div></div>
        <div class="ai-stat"><i class="fas fa-clock"></i>
            <div><strong id="aiPending"><?= (int)$stats['pending'] ?></strong><span>Pending</span></div></div>
        <div class="ai-stat"><i class="fas fa-check-double"></i>
            <div><strong id="aiReviewed"><?= (int)$stats['reviewed'] ?></strong><span>Reviewed</span></div></div>
    </div>

    <section class="ai-card">
        <div class="ai-card-head">
            <h2>Incoming Title Approval Submissions</h2>
            <input id="aiSearch" class="ai-search" type="search" placeholder="Search title, student, department…">
        </div>
        <div class="ai-table-wrap">
            <table class="ai-table">
                <thead><tr>
                    <th>Research Title</th><th>Student</th><th>Department</th>
                    <th>SDG / Discipline</th><th>Date Sent</th><th>Status</th><th>Actions</th>
                </tr></thead>
                <tbody id="aiRows"></tbody>
            </table>
        </div>
        <div class="ai-empty" id="aiEmpty" hidden>No title approval submissions yet.</div>
    </section>
</div>

<script>
(() => {
    const root = document.querySelector('[data-ai-inbox]');
    if (!root) return;

    const endpoint  = root.dataset.aiInbox;
    const updateUrl = root.dataset.aiUpdate;
    const tbody     = document.getElementById('aiRows');
    const empty     = document.getElementById('aiEmpty');
    const search    = document.getElementById('aiSearch');
    const lastSync  = document.getElementById('aiLastSync');
    const elTotal   = document.getElementById('aiTotal');
    const elPending = document.getElementById('aiPending');
    const elReviewed= document.getElementById('aiReviewed');

    let rows     = <?= json_encode($rows, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT) ?>;
    let knownIds = new Set(rows.map(r => String(r.id)));

    const esc = v => String(v ?? '').replace(/[&<>"']/g,
        c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#039;'})[c]);

    const fmt = v => {
        if (!v) return '—';
        const d = new Date(String(v).replace(' ','T'));
        return isNaN(d) ? v : d.toLocaleDateString('en-US',{month:'short',day:'numeric',year:'numeric'});
    };

    const badgeCls = s => ({Pending:'ai-badge-pending',Reviewed:'ai-badge-reviewed',
        Approved:'ai-badge-approved',Returned:'ai-badge-returned'})[s] || 'ai-badge-pending';

    const badgeIco = s => ({Pending:'fa-clock',Reviewed:'fa-eye',
        Approved:'fa-check-circle',Returned:'fa-undo'})[s] || 'fa-clock';

    const rowHtml = (r, isNew) => `
        <tr data-row-id="${esc(r.id)}"${isNew?' class="ai-new-row"':''}>
            <td>
                <div class="ai-title">${esc(r.proposed_title)}</div>
                <div class="ai-muted">${esc(r.discipline_cluster||'')}</div>
            </td>
            <td>
                <div class="ai-title">${esc(r.student_name)}</div>
                <div class="ai-muted">${esc(r.student_id)}</div>
            </td>
            <td>${esc(r.department)}</td>
            <td>
                <div>${esc(r.primary_sdg||'—')}</div>
                <div class="ai-muted">${esc(r.research_agenda||'')}</div>
            </td>
            <td>${esc(fmt(r.sent_at))}</td>
            <td>
                <span class="ai-badge ${badgeCls(r.status)}">
                    <i class="fas ${badgeIco(r.status)}"></i> ${esc(r.status)}
                </span>
                ${r.adviser_remarks?`<div class="ai-muted" style="margin-top:.3rem">${esc(r.adviser_remarks)}</div>`:''}
            </td>
            <td>
                ${r.status==='Pending'?`
                <div style="display:flex;gap:.4rem;flex-wrap:wrap;">
                    <button class="ai-btn-act ai-btn-approve" data-id="${esc(r.id)}" data-action="Approved">
                        <i class="fas fa-check"></i> Approve
                    </button>
                    <button class="ai-btn-act ai-btn-return" data-id="${esc(r.id)}" data-action="Returned">
                        <i class="fas fa-undo"></i> Return
                    </button>
                </div>`:'—'}
            </td>
        </tr>`;

    const matches = (r, term) => !term || [
        r.proposed_title, r.student_name, r.student_id,
        r.department, r.primary_sdg, r.discipline_cluster, r.status
    ].join(' ').toLowerCase().includes(term);

    const render = () => {
        const term = (search?.value||'').trim().toLowerCase();
        const vis  = rows.filter(r => matches(r, term));
        tbody.innerHTML = vis.map(r => rowHtml(r, false)).join('');
        empty.hidden = vis.length !== 0;
        bindActions();
    };

    const bindActions = () => {
        tbody.querySelectorAll('[data-action]').forEach(btn => {
            btn.addEventListener('click', async () => {
                const id = btn.dataset.id, action = btn.dataset.action;
                const remarks = action==='Returned'
                    ? (prompt('Remarks for returning this submission (optional):')||'') : '';
                btn.disabled = true;
                try {
                    const res  = await fetch(updateUrl, {
                        method:'POST',
                        headers:{'Content-Type':'application/json','Accept':'application/json'},
                        credentials:'same-origin',
                        body:JSON.stringify({id:parseInt(id),status:action,remarks})
                    });
                    const data = await res.json();
                    if (!data.ok) throw new Error(data.error||'Update failed.');
                    const idx = rows.findIndex(r => String(r.id)===String(id));
                    if (idx!==-1){rows[idx].status=action;rows[idx].adviser_remarks=remarks;}
                    render(); syncStats();
                } catch(err){ alert('Error: '+err.message); btn.disabled=false; }
            });
        });
    };

    const syncStats = () => {
        const p = rows.filter(r=>r.status==='Pending').length;
        elTotal.textContent   = rows.length;
        elPending.textContent = p;
        elReviewed.textContent= rows.length - p;
    };

    const refresh = async () => {
        try {
            const res  = await fetch(endpoint,{headers:{'Accept':'application/json'},cache:'no-store',credentials:'same-origin'});
            const data = await res.json();
            if (!data.ok) throw new Error(data.error||'Sync failed.');
            const incoming  = Array.isArray(data.rows) ? data.rows : [];
            const newIds    = new Set(incoming.map(r=>String(r.id)));
            const addedIds  = [...newIds].filter(id=>!knownIds.has(id));
            rows    = incoming;
            knownIds= newIds;
            const term = (search?.value||'').trim().toLowerCase();
            const vis  = rows.filter(r=>matches(r,term));
            tbody.innerHTML = vis.map(r=>rowHtml(r,addedIds.includes(r.id))).join('');
            empty.hidden = vis.length!==0;
            bindActions();
            elTotal.textContent    = data.stats?.total    ?? rows.length;
            elPending.textContent  = data.stats?.pending  ?? 0;
            elReviewed.textContent = data.stats?.reviewed ?? 0;
            lastSync.textContent   = `Synced ${data.last_sync||'just now'}`;
        } catch { lastSync.textContent='Sync paused'; }
    };

    search?.addEventListener('input', render);
    render();
    window.setInterval(refresh, 5000);
})();
</script>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
