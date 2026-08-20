<?php
/**
 * SMS 2 - Research Proposal Submission & Tracking
 * Module: CRAD
 */
require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../config/config.php';

$pageTitle    = 'Research Proposal Submission & Tracking';
$activeModule = 'crad';
$activePage   = 'proposal-submission-tracking';
$breadcrumbs  = [
    ['label' => 'CRAD', 'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Research Proposal Submission & Tracking', 'url' => null],
];

require_once __DIR__ . '/../../../includes/breadcrumbs.php';

// ── Flash message from submit redirect ─────────────────────────────────────
$flashSuccess = '';
if (!empty($_GET['submitted']) && !empty($_GET['ref'])) {
    $flashSuccess = 'Proposal <strong>' . htmlspecialchars($_GET['ref']) 
        . '</strong> has been submitted successfully and is now in the CRAD pipeline.';
}

// ── Status helper (mirrors proposal-review.php logic) ───────────────────────
function pstStatusFromProgress(int $pct, string $storedStatus): string
{
    if ($storedStatus === 'Returned') { return 'Returned'; }
    if ($pct >= 100)                  { return 'Approved'; }
    if ($pct >= 1)                    { return 'In Progress'; }
    return 'Submitted';
}

// ── Fetch proposals from crad_db ────────────────────────────────────────────
$proposals = [];
try {
    $cradPdo = getCradDatabaseConnection();
    $stmt = $cradPdo->query(
        "SELECT
            id, ref_code, research_title, college_department,
            rep_name, status, progress, date_submitted
         FROM research_proposals
         ORDER BY date_submitted DESC, id DESC"
    );
    $rows = $stmt->fetchAll();

    foreach ($rows as $row) {
        $_pct    = (int) $row['progress'];
        $_status = pstStatusFromProgress($_pct, $row['status']);

        $statusCls = match($_status) {
            'Panel Assigned' => 'pst-badge--panel',
            'Submitted'      => 'pst-badge--submitted',
            'Approved'       => 'pst-badge--approved',
            'In Progress'    => 'pst-badge--progress',
            'Returned'       => 'pst-badge--returned',
            default          => 'pst-badge--submitted',
        };
        $proposals[] = [
            'ref'        => $row['ref_code'],
            'title'      => $row['research_title'],
            'lead'       => $row['rep_name'],
            'dept'       => $row['college_department'],
            'status'     => $_status,
            'status_cls' => $statusCls,
            'progress'   => $_pct,
        ];
    }
} catch (Throwable $e) {
    error_log('CRAD tracking error: ' . $e->getMessage());
    // Show empty list if DB unavailable
}

$total         = count($proposals);
$pending       = count(array_filter($proposals, fn($p) => in_array($p['status'], ['Submitted', 'In Progress'])));
$panelAssigned = count(array_filter($proposals, fn($p) => $p['status'] === 'Panel Assigned'));
$approved      = count(array_filter($proposals, fn($p) => $p['status'] === 'Approved'));

$progressSnapshot = array_map(static function (array $p): array {
    return [
        'ref' => $p['ref'],
        'status' => $p['status'],
        'progress' => (int) $p['progress'],
    ];
}, $proposals);
$progressSignature = sha1(json_encode($progressSnapshot));

if (($_GET['ajax'] ?? '') === 'progress') {
    header('Content-Type: application/json');
    echo json_encode([
        'ok' => true,
        'signature' => $progressSignature,
    ]);
    exit;
}
?>

<?php require_once __DIR__ . '/../../../includes/layout-start.php'; ?>

<?php renderBreadcrumbs($breadcrumbs); ?>

<?php if ($flashSuccess !== ''): ?>
<div style="
    display:flex;align-items:center;gap:0.75rem;
    padding:0.85rem 1.1rem;margin-bottom:1rem;
    border:1px solid #bbf7d0;border-radius:12px;
    background:#f0fdf4;color:#166534;font-size:0.88rem;font-weight:600;"
    role="alert">
    <i class="fas fa-check-circle" style="font-size:1.1rem;flex-shrink:0;"></i>
    <span><?= $flashSuccess ?></span>
</div>
<?php endif; ?>

<style>
.pst-wrap { display: flex; flex-direction: column; gap: 1.5rem; }

/* Stat cards */
.pst-stats {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 0.85rem;
}
.pst-stat {
    display: flex; align-items: center; gap: 0.85rem;
    padding: 0.95rem 1rem;
    border: 1px solid var(--sms-border, #e2e8f0);
    border-radius: 14px;
    background: var(--sms-surface-solid, #fff);
    box-shadow: var(--sms-shadow-xs);
}
.pst-stat-icon {
    width: 42px; height: 42px; flex: 0 0 auto;
    display: grid; place-items: center;
    border-radius: 12px; font-size: 1rem;
}
.pst-stat-icon.blue   { color: #2563eb; background: rgba(37,99,235,0.12); }
.pst-stat-icon.amber  { color: #d97706; background: rgba(245,158,11,0.14); }
.pst-stat-icon.purple { color: #7c3aed; background: rgba(139,92,246,0.12); }
.pst-stat-icon.green  { color: #059669; background: rgba(16,185,129,0.12); }
.pst-stat-text span {
    display: block; color: var(--sms-text-muted);
    font-size: 0.72rem; font-weight: 700;
    text-transform: uppercase; letter-spacing: 0.04em;
}
.pst-stat-text strong {
    display: block; margin-top: 0.15rem;
    color: var(--sms-heading); font-size: 1.35rem; font-weight: 800;
}

/* Pipeline card */
.pst-card {
    border: 1px solid var(--sms-border, #e2e8f0);
    border-radius: 16px;
    background: var(--sms-surface-solid, #fff);
    box-shadow: var(--sms-shadow-sm);
    overflow: hidden;
}
.pst-card-head {
    padding: 1rem 1.25rem 0.75rem;
    border-bottom: 1px solid var(--sms-border, #e2e8f0);
}
.pst-card-head h2 {
    margin: 0; font-size: 0.72rem; font-weight: 800;
    letter-spacing: 0.07em; text-transform: uppercase;
    color: var(--sms-text-muted);
}

/* Toolbar */
.pst-pipeline-toolbar {
    display: flex; align-items: center; gap: 0.65rem; flex-wrap: wrap;
    padding: 0.85rem 1.25rem;
    border-bottom: 1px solid var(--sms-border, #e2e8f0);
    background: var(--sms-surface-muted, #f8fafc);
}
.pst-pipeline-search {
    flex: 1 1 200px; display: flex; align-items: center; gap: 0.5rem;
    min-height: 38px; padding: 0.4rem 0.75rem;
    border: 1px solid var(--sms-border, #d7e1ef); border-radius: 10px;
    background: var(--sms-input-bg, #fff); color: var(--sms-text-muted); font-size: 0.8rem;
}
.pst-pipeline-search input {
    border: none; outline: none; background: transparent;
    color: var(--sms-text); font-size: 0.84rem; width: 100%;
}
.pst-pipeline-filter {
    min-height: 38px; padding: 0.4rem 0.75rem;
    border: 1px solid var(--sms-border, #d7e1ef); border-radius: 10px;
    background: var(--sms-input-bg, #fff); color: var(--sms-text); font-size: 0.84rem; outline: none;
}

/* Pipeline rows */
.pst-pipeline { display: flex; flex-direction: column; }
a.pst-pipeline-item {
    display: block; text-decoration: none; color: inherit;
    padding: 1rem 1.25rem;
    border-bottom: 1px solid var(--sms-border, #e2e8f0);
    transition: background 0.12s ease;
    cursor: pointer;
}
a.pst-pipeline-item:last-child { border-bottom: none; }
a.pst-pipeline-item:hover { background: var(--sms-surface-muted, #f8fafc); }

.pst-pipeline-meta {
    display: flex; align-items: center; justify-content: space-between;
    gap: 0.75rem; flex-wrap: wrap; margin-bottom: 0.5rem;
}
.pst-pipeline-ref {
    font-size: 0.72rem; font-weight: 800;
    color: var(--sms-primary, #1e40af);
    background: var(--sms-primary-xlight, #dbeafe);
    padding: 0.2rem 0.6rem; border-radius: 999px; white-space: nowrap;
}
.pst-pipeline-title {
    flex: 1 1 0; min-width: 0;
    font-size: 0.9rem; font-weight: 700;
    color: var(--sms-heading); line-height: 1.35;
}
.pst-pipeline-sub { font-size: 0.78rem; color: var(--sms-text-muted); margin-top: 0.15rem; }
.pst-pipeline-sub span { font-weight: 600; color: var(--sms-text); }

/* Status badges */
.pst-badge {
    display: inline-flex; align-items: center;
    padding: 0.22rem 0.7rem; border-radius: 999px;
    font-size: 0.7rem; font-weight: 800; white-space: nowrap;
}
.pst-badge--panel      { color: #6d28d9; background: #ede9fe; }
.pst-badge--submitted  { color: #b45309; background: #fef3c7; }
.pst-badge--approved   { color: #047857; background: #d1fae5; }
.pst-badge--progress   { color: #0369a1; background: #e0f2fe; }
.pst-badge--returned   { color: #64748b; background: #e2e8f0; }

/* Arrow */
.pst-review-arrow {
    color: var(--sms-text-muted); font-size: 0.75rem;
    transition: transform 0.15s ease, color 0.15s ease;
}
a.pst-pipeline-item:hover .pst-review-arrow {
    transform: translateX(3px); color: var(--sms-primary, #1e40af);
}

/* Progress bar */
a.pst-pipeline-item:focus-visible {
    box-shadow: 0 0 0 3px rgba(37,99,235,0.18);
}
.pst-progress-wrap { margin-top: 0.6rem; cursor: pointer; }
.pst-progress-label {
    display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.3rem;
}
.pst-progress-label span {
    font-size: 0.72rem; font-weight: 700; color: var(--sms-text-muted);
    text-transform: uppercase; letter-spacing: 0.04em;
}
.pst-progress-label strong { font-size: 0.78rem; font-weight: 800; color: var(--sms-heading); }
.pst-progress-bar {
    height: 6px; border-radius: 999px;
    background: var(--sms-border, #e2e8f0); overflow: hidden;
}
.pst-progress-fill { height: 100%; border-radius: 999px; transition: width 0.6s ease; }
.pst-progress-fill.full { background: linear-gradient(90deg, #10b981, #059669); }
.pst-progress-fill.mid  { background: linear-gradient(90deg, #3b82f6, #1e40af); }
.pst-progress-fill.low  { background: linear-gradient(90deg, #f59e0b, #d97706); }
.pst-progress-fill.vlow { background: linear-gradient(90deg, #94a3b8, #64748b); }

/* Dark mode */
[data-theme="dark"] .pst-stat,
[data-theme="dark"] .pst-card {
    background: rgba(15,23,42,0.72); border-color: rgba(148,163,184,0.2);
}
[data-theme="dark"] a.pst-pipeline-item:hover { background: rgba(148,163,184,0.06); }
[data-theme="dark"] .pst-pipeline-toolbar { background: rgba(148,163,184,0.06); border-color: rgba(148,163,184,0.2); }
[data-theme="dark"] .pst-pipeline-search,
[data-theme="dark"] .pst-pipeline-filter {
    background: rgba(15,23,42,0.72); border-color: rgba(148,163,184,0.2); color: #e2e8f0;
}
[data-theme="dark"] .pst-progress-bar { background: rgba(148,163,184,0.18); }

@media (max-width: 991.98px) { .pst-stats { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
@media (max-width: 575.98px) { .pst-stats { grid-template-columns: 1fr; } }
</style>

<div class="pst-wrap">

    <!-- Stat cards -->
    <section class="pst-stats" aria-label="Proposal summary">
        <article class="pst-stat">
            <div class="pst-stat-icon blue"><i class="fas fa-layer-group"></i></div>
            <div class="pst-stat-text"><span>Total Proposals</span><strong><?= $total ?></strong></div>
        </article>
        <article class="pst-stat">
            <div class="pst-stat-icon amber"><i class="fas fa-clock"></i></div>
            <div class="pst-stat-text"><span>Pending Review</span><strong><?= $pending ?></strong></div>
        </article>
        <article class="pst-stat">
            <div class="pst-stat-icon purple"><i class="fas fa-users"></i></div>
            <div class="pst-stat-text"><span>Panel Assigned</span><strong><?= $panelAssigned ?></strong></div>
        </article>
        <article class="pst-stat">
            <div class="pst-stat-icon green"><i class="fas fa-check-circle"></i></div>
            <div class="pst-stat-text"><span>Approved</span><strong><?= $approved ?></strong></div>
        </article>
    </section>

    <!-- Pipeline -->
    <section class="pst-card" aria-labelledby="pst-pipeline-heading">
        <div class="pst-card-head">
            <h2 id="pst-pipeline-heading">Proposal Pipeline Tracking</h2>
        </div>

        <div class="pst-pipeline-toolbar">
            <label class="pst-pipeline-search">
                <i class="fas fa-search"></i>
                <input type="search" id="pstPipelineSearch" placeholder="Search by reference, title, or researcher..." aria-label="Search proposals">
            </label>
            <select id="pstPipelineStatus" class="pst-pipeline-filter" aria-label="Filter by status">
                <option value="">All Status</option>
                <option value="Panel Assigned">Panel Assigned</option>
                <option value="Submitted">Submitted</option>
                <option value="Approved">Approved</option>
                <option value="In Progress">In Progress</option>
                <option value="Returned">Returned</option>
            </select>
            <a href="<?= BASE_URL ?>/modules/crad/pages/register-proposal.php"
               class="pst-pipeline-filter"
               style="
                   display:inline-flex;align-items:center;justify-content:center;gap:0.35rem;
                   padding:0.5rem 0.9rem;text-decoration:none;white-space:nowrap;
                   background:var(--sms-primary,#1e40af);color:#fff;font-weight:700;
                   border:1px solid var(--sms-primary,#1e40af);border-radius:10px;">
                <i class="fas fa-file-signature"></i> Register Proposal
            </a>
        </div>

        <div class="pst-pipeline" id="pstPipelineList">
            <?php foreach ($proposals as $p): ?>
                <?php
                $pct = (int) $p['progress'];
                $fillClass = match(true) {
                    $pct >= 100 => 'full',
                    $pct >= 50  => 'mid',
                    $pct >= 25  => 'low',
                    default     => 'vlow',
                };
                $searchData = strtolower($p['ref'] . ' ' . $p['title'] . ' ' . $p['lead'] . ' ' . $p['dept'] . ' ' . $p['status']);
                $reviewUrl  = BASE_URL . '/modules/crad/pages/proposal-review.php?ref=' . urlencode($p['ref']);
                ?>
                <a href="<?= htmlspecialchars($reviewUrl) ?>"
                   class="pst-pipeline-item"
                   data-search="<?= htmlspecialchars($searchData) ?>"
                   data-status="<?= htmlspecialchars($p['status']) ?>"
                   aria-label="Open tracking progress stage for proposal <?= htmlspecialchars($p['ref']) ?>">
                    <div class="pst-pipeline-meta">
                        <div style="display:flex;align-items:center;gap:0.6rem;flex:1;min-width:0;">
                            <span class="pst-pipeline-ref"><?= htmlspecialchars($p['ref']) ?></span>
                            <div style="min-width:0">
                                <div class="pst-pipeline-title"><?= htmlspecialchars($p['title']) ?></div>
                                <div class="pst-pipeline-sub">
                                    Lead: <span><?= htmlspecialchars($p['lead']) ?></span>
                                    &nbsp;|&nbsp; Dept: <?= htmlspecialchars($p['dept']) ?>
                                </div>
                            </div>
                        </div>
                        <div style="display:flex;align-items:center;gap:0.65rem;flex-shrink:0;">
                            <span class="pst-badge <?= htmlspecialchars($p['status_cls']) ?>"><?= htmlspecialchars($p['status']) ?></span>
                        </div>
                    </div>
                    <div class="pst-progress-wrap">
                        <div class="pst-progress-label">
                            <span>Tracking Progress Stage</span>
                            <strong><?= $pct ?>% <span class="pst-review-arrow"><i class="fas fa-chevron-right"></i></span></strong>
                        </div>
                        <div class="pst-progress-bar" role="progressbar" aria-valuenow="<?= $pct ?>" aria-valuemin="0" aria-valuemax="100">
                            <div class="pst-progress-fill <?= $fillClass ?>" style="width:<?= $pct ?>%"></div>
                        </div>
                    </div>
                </a>
            <?php endforeach; ?>
        </div>

        <div id="pstPipelineEmpty" style="display:<?= $total === 0 ? 'block' : 'none' ?>;padding:2rem 1.25rem;text-align:center;color:var(--sms-text-muted);font-size:0.86rem;">
            <i class="fas fa-inbox" style="font-size:1.5rem;margin-bottom:0.5rem;display:block;opacity:0.4;"></i>
            No proposals match your search.
        </div>
    </section>

</div>

<script>
(function () {
    const search = document.getElementById('pstPipelineSearch');
    const status = document.getElementById('pstPipelineStatus');
    const list   = document.getElementById('pstPipelineList');
    const empty  = document.getElementById('pstPipelineEmpty');
    function filter() {
        const q = search.value.toLowerCase().trim();
        const s = status.value;
        let n = 0;
        list.querySelectorAll('.pst-pipeline-item').forEach(function (row) {
            const show = (q === '' || row.dataset.search.includes(q)) && (s === '' || row.dataset.status === s);
            row.style.display = show ? '' : 'none';
            if (show) n++;
        });
        empty.style.display = n === 0 ? 'block' : 'none';
    }
    search.addEventListener('input', filter);
    status.addEventListener('change', filter);

    const currentProgressSignature = '<?= htmlspecialchars($progressSignature, ENT_QUOTES) ?>';
    let polling = false;
    function checkProgressUpdates() {
        if (polling || document.hidden) {
            return;
        }
        polling = true;
        fetch(window.location.pathname + '?ajax=progress', {
            credentials: 'same-origin',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
            .then(function (res) { return res.ok ? res.json() : null; })
            .then(function (data) {
                if (data && data.ok && data.signature && data.signature !== currentProgressSignature) {
                    window.location.reload();
                }
            })
            .catch(function () {})
            .finally(function () { polling = false; });
    }
    setInterval(checkProgressUpdates, 5000);
    document.addEventListener('visibilitychange', function () {
        if (!document.hidden) {
            checkProgressUpdates();
        }
    });
})();
</script>

<?php require_once __DIR__ . '/../../../includes/layout-end.php'; ?>
