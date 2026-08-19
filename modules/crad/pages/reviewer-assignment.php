<?php
/**
 * SMS 2 - REVIEW & WORKFLOW · Reviewer Assignment
 * Module: CRAD
 *
 * CRAD Officer assigns an evaluator/reviewer to submitted research grant
 * proposals. Proposals with status 'Submitted' (shown as Pending Evaluation)
 * and no active evaluator assignment can be assigned; the save is fully
 * transactional and flips the proposal status to 'Assigned for Review'.
 *
 * All data (proposals, evaluators, summary counts) comes from the database
 * via grant-management.php — nothing is hardcoded.
 */
require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/config/database.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';
require_once __DIR__ . '/../includes/grant-helpers.php';

requireAuth();

$roleKey = getCurrentUserRoleKey();
if (!in_array($roleKey, ['crad_officer', 'superadmin', 'admin'], true)) {
    header('Location: ' . BASE_URL . '/dashboard/index.php');
    exit;
}

$pageTitle             = 'Reviewer Assignment';
$activeModule          = 'crad';
$activePage            = 'reviewer-assignment';
$pageBannerIcon        = 'fa-user-check';
$pageBannerDescription = 'Assign qualified evaluators to submitted research grant proposals.';

$breadcrumbs = [
    ['label' => 'CRAD',                'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Reviewer Assignment', 'url' => null],
];

require_once ROOT_PATH . '/includes/breadcrumbs.php';

// ── Data ──────────────────────────────────────────────────────────────────────
$crad         = cradDb();
$main         = db();
$applications = [];
$evaluators   = [];
$stats        = ['total' => 0, 'pending' => 0, 'assigned' => 0, 'unassigned' => 0];
$dbError      = '';

if ($crad) {
    try {
        grantEnsureTables($crad);
        $applications = grantGetApplications($crad);
        $stats        = grantReviewerAssignmentStats($crad);
        $evaluators   = $main ? grantGetEligibleEvaluators($main) : [];
    } catch (Throwable $e) {
        $dbError = htmlspecialchars($e->getMessage());
        error_log('reviewer-assignment: ' . $e->getMessage());
    }
} else {
    $dbError = 'CRAD database connection unavailable.';
}

require_once ROOT_PATH . '/includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);
?>
<link href="<?= BASE_URL ?>/assets/css/module-process-list.css?v=2" rel="stylesheet">

<?php if ($dbError !== ''): ?>
    <div class="mpl-alert" role="alert" style="background:rgba(239,68,68,0.08);color:#b91c1c;">
        <i class="fas fa-exclamation-triangle me-1"></i><?= $dbError ?>
    </div>
<?php endif; ?>

<div class="mpl" data-mpl data-reviewer-assignment-page>

    <!-- ── Top bar ──────────────────────────────────────────────────────── -->
    <div class="mpl-top">
        <p>Assign qualified evaluators to submitted research grant proposals. Records are sourced directly from the database.</p>
        <div class="mpl-toolbar">
            <a class="mpl-btn mpl-btn-soft"
               href="<?= BASE_URL ?>/modules/crad/pages/proposals-applications.php">
                <i class="fas fa-file-alt" aria-hidden="true"></i>Proposals &amp; Applications
            </a>
        </div>
    </div>

    <?php if ($dbError === ''): ?>

    <!-- ── Stat summary ──────────────────────────────────────────────────── -->
    <section class="mpl-stats" aria-label="Reviewer assignment summary">
        <article class="mpl-stat">
            <div class="mpl-stat-icon blue"><i class="fas fa-file-alt"></i></div>
            <div><span>Total Proposals</span><strong id="raStatTotal"><?= (int) $stats['total'] ?></strong></div>
        </article>
        <article class="mpl-stat">
            <div class="mpl-stat-icon amber"><i class="fas fa-hourglass-half"></i></div>
            <div><span>Pending Evaluation</span><strong id="raStatPending"><?= (int) $stats['pending'] ?></strong></div>
        </article>
        <article class="mpl-stat">
            <div class="mpl-stat-icon green"><i class="fas fa-user-check"></i></div>
            <div><span>Assigned for Review</span><strong id="raStatAssigned"><?= (int) $stats['assigned'] ?></strong></div>
        </article>
        <article class="mpl-stat">
            <div class="mpl-stat-icon purple"><i class="fas fa-user-slash"></i></div>
            <div><span>Unassigned</span><strong id="raStatUnassigned"><?= (int) $stats['unassigned'] ?></strong></div>
        </article>
    </section>

    <!-- ── Filters ────────────────────────────────────────────────────────── -->
    <div class="mpl-filters">
        <label class="mpl-search">
            <i class="fas fa-search"></i>
            <input type="search" id="raSearch"
                   placeholder="Search by reference, proponent, title, college, or grant…"
                   aria-label="Search proposals">
        </label>
        <select id="raStatusFilter" aria-label="Filter by status">
            <option value="">All Status</option>
            <option value="pending evaluation">Pending Evaluation</option>
            <option value="assigned for review">Assigned for Review</option>
        </select>
        <button type="button" class="mpl-btn mpl-btn-ghost mpl-btn-sm" id="raRefreshBtn">
            <i class="fas fa-sync-alt" aria-hidden="true"></i> Refresh
        </button>
    </div>

    <!-- ── Proposals table ───────────────────────────────────────────────── -->
    <section class="mpl-panel">
        <div class="mpl-panel-head">
            <div>
                <h2>Submitted Research Grant Proposals</h2>
                <p>Proposals pending evaluation can be assigned to an eligible evaluator. Assigned proposals display their reviewer.</p>
            </div>
        </div>
        <div class="mpl-table-wrap">
            <table class="mpl-table" id="raTable">
                <thead>
                    <tr>
                        <th>Reference No.</th>
                        <th>Grant Opportunity</th>
                        <th>Research Project Title</th>
                        <th>Lead Proponent</th>
                        <th>College / Dept</th>
                        <th>Requested Budget</th>
                        <th>Date Submitted</th>
                        <th>Status</th>
                        <th style="text-align:center;">Action</th>
                    </tr>
                </thead>
                <tbody id="raTableBody">
                    <tr>
                        <td colspan="9" style="text-align:center;color:var(--sms-text-muted);padding:2.5rem;">
                            Loading proposals…
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </section>

    <?php endif; // $dbError === '' ?>

</div>

<!-- ═══════════════ ASSIGN EVALUATOR MODAL ═══════════════ -->
<div class="modal fade" id="assignEvaluatorModal" tabindex="-1" aria-labelledby="assignEvaluatorModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border:none;border-radius:14px;overflow:hidden;">
            <div class="modal-header" style="background:var(--sms-primary,#1e40af);color:#fff;">
                <h5 class="modal-title" id="assignEvaluatorModalLabel" style="font-weight:800;letter-spacing:.03em;">
                    <i class="fas fa-user-check me-2" aria-hidden="true"></i>ASSIGN EVALUATOR
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding:1.4rem 1.6rem;">
                <div id="assignAlert" role="alert"
                     style="display:none;border-radius:9px;padding:.6rem .9rem;font-size:.83rem;font-weight:600;margin-bottom:1rem;"></div>

                <!-- Proposal summary -->
                <div style="font-size:.63rem;font-weight:800;letter-spacing:.05em;text-transform:uppercase;color:var(--sms-text-muted);margin-bottom:.5rem;">
                    Proposal Details
                </div>
                <div id="assignProposalSummary"
                     style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:.7rem 1.3rem;
                            background:var(--sms-surface-muted,#f8fafc);border:1px solid var(--sms-border,#e2e8f0);
                            border-radius:11px;padding:1rem 1.1rem;margin-bottom:1.25rem;">
                </div>

                <!-- Evaluator selection -->
                <div style="font-size:.63rem;font-weight:800;letter-spacing:.05em;text-transform:uppercase;color:var(--sms-text-muted);margin-bottom:.5rem;">
                    Select Evaluator
                </div>
                <div id="assignEvaluatorList" role="radiogroup" aria-label="Eligible evaluators"
                     style="display:flex;flex-direction:column;gap:.5rem;max-height:260px;overflow-y:auto;">
                </div>
            </div>
            <div class="modal-footer" style="border-top:1px solid var(--sms-border,#e2e8f0);">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"
                        style="border-radius:9px;font-weight:600;">Cancel</button>
                <button type="button" class="btn btn-primary" id="btnAssignEvaluator" disabled
                        style="border-radius:9px;font-weight:700;">
                    <i class="fas fa-user-check me-1" aria-hidden="true"></i>Assign Evaluator
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ═══════════════ CONFIRM ASSIGNMENT MODAL ═══════════════ -->
<div class="modal fade" id="confirmAssignModal" tabindex="-1" aria-labelledby="confirmAssignModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border:none;border-radius:14px;overflow:hidden;">
            <div class="modal-header" style="background:var(--sms-primary,#1e40af);color:#fff;">
                <h5 class="modal-title" id="confirmAssignModalLabel" style="font-weight:800;letter-spacing:.03em;">
                    <i class="fas fa-question-circle me-2" aria-hidden="true"></i>ASSIGN EVALUATOR?
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding:1.4rem 1.6rem;font-size:.92rem;color:var(--sms-text);">
                <p style="margin-bottom:.4rem;">Are you sure you want to assign:</p>
                <p id="confirmEvaluatorName" style="font-weight:800;color:var(--sms-heading);margin-bottom:.6rem;"></p>
                <p style="margin-bottom:.4rem;">to review:</p>
                <p id="confirmProposalTitle" style="font-weight:800;color:var(--sms-heading);margin-bottom:0;"></p>
            </div>
            <div class="modal-footer" style="border-top:1px solid var(--sms-border,#e2e8f0);">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"
                        style="border-radius:9px;font-weight:600;">Cancel</button>
                <button type="button" class="btn btn-primary" id="btnConfirmAssign"
                        style="border-radius:9px;font-weight:700;">
                    <i class="fas fa-check me-1" aria-hidden="true"></i>Confirm Assignment
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ═══════════════ SUCCESS MODAL ═══════════════ -->
<div class="modal fade" id="assignSuccessModal" tabindex="-1" aria-labelledby="assignSuccessModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border:none;border-radius:14px;overflow:hidden;">
            <div class="modal-body" style="padding:2rem 1.6rem;text-align:center;">
                <div style="width:64px;height:64px;border-radius:50%;background:#d1fae5;color:#047857;
                            display:inline-flex;align-items:center;justify-content:center;font-size:1.7rem;margin-bottom:1rem;">
                    <i class="fas fa-check" aria-hidden="true"></i>
                </div>
                <h5 id="assignSuccessModalLabel" style="font-weight:800;color:var(--sms-heading);margin-bottom:.5rem;">Evaluator Assigned</h5>
                <p style="font-size:.9rem;color:var(--sms-text-muted);margin-bottom:.2rem;">
                    <span id="successEvaluatorName" style="font-weight:700;color:var(--sms-heading);"></span>
                    has been assigned to review
                </p>
                <p id="successProposalTitle" style="font-size:.9rem;font-weight:700;color:var(--sms-heading);margin-bottom:.9rem;"></p>
                <span class="mpl-status assigned">Assigned for Review</span>
            </div>
            <div class="modal-footer" style="border-top:1px solid var(--sms-border,#e2e8f0);justify-content:center;">
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal"
                        style="border-radius:9px;font-weight:700;min-width:120px;">Done</button>
            </div>
        </div>
    </div>
</div>

<script>
(function () {
    'use strict';

    var apiBase = <?= json_encode(BASE_URL . '/modules/crad/api/grant-management.php') ?>;

    var state = {
        applications: <?= json_encode($applications) ?>,
        evaluators:   <?= json_encode($evaluators) ?>,
        stats:        <?= json_encode($stats) ?>,
        selectedApp:       null,
        selectedEvaluator: null,
        assignToken:       '',
        saving:            false
    };

    /* ── Utilities ────────────────────────────────────────────────────── */
    function escHtml(s) {
        return String(s == null ? '' : s)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }
    function fmtBudget(v) {
        if (v == null || v === '') return '—';
        return '₱' + Number(v).toLocaleString('en-PH', {maximumFractionDigits: 0});
    }
    function fmtDate(s) {
        if (!s) return '—';
        var d = new Date(String(s).replace(' ', 'T'));
        if (isNaN(d.getTime())) return s;
        return d.toLocaleDateString('en-US', {month:'short', day:'2-digit', year:'numeric'}) +
               ' ' + d.toLocaleTimeString('en-US', {hour:'numeric', minute:'2-digit'});
    }
    function refNo(app) {
        var year = String(app.submitted_at || '').slice(0, 4) || new Date().getFullYear();
        return 'GR-' + year + '-' + String(app.id).padStart(3, '0');
    }
    function statusLabel(status) {
        return status === 'Submitted' ? 'Pending Evaluation' : status;
    }
    function statusBadge(status) {
        var label = statusLabel(status);
        var map = {
            'Pending Evaluation':  'mpl-status pending',
            'Assigned for Review': 'mpl-status assigned',
            'Under Review':        'mpl-status pending',
            'Approved':            'mpl-status completed',
            'Denied':              'mpl-status cancelled',
            'Withdrawn':           'mpl-status cancelled'
        };
        return '<span class="' + (map[label] || 'mpl-status processing') + '">' + escHtml(label) + '</span>';
    }

    /* ── Rendering ────────────────────────────────────────────────────── */
    function renderStats() {
        var s = state.stats || {};
        var set = function (id, v) {
            var el = document.getElementById(id);
            if (el) el.textContent = String(v == null ? 0 : v);
        };
        set('raStatTotal', s.total);
        set('raStatPending', s.pending);
        set('raStatAssigned', s.assigned);
        set('raStatUnassigned', s.unassigned);
    }

    function tableApps() {
        // Reviewer Assignment focuses on the pending → assigned workflow.
        return (state.applications || []).filter(function (a) {
            return a.status === 'Submitted' || a.status === 'Assigned for Review';
        });
    }

    function renderTable() {
        var tbody = document.getElementById('raTableBody');
        if (!tbody) return;

        var term   = (document.getElementById('raSearch')       || {value:''}).value.toLowerCase().trim();
        var status = (document.getElementById('raStatusFilter') || {value:''}).value.toLowerCase();

        var apps = tableApps();
        if (!apps.length) {
            tbody.innerHTML =
                '<tr><td colspan="9" style="text-align:center;color:var(--sms-text-muted);padding:2.5rem;">' +
                'No submitted proposals found. Proposals appear here once researchers submit them via Grant Opportunities.' +
                '</td></tr>';
            return;
        }

        var rows = '';
        var visible = 0;
        apps.forEach(function (app) {
            var label     = statusLabel(app.status);
            var reference = refNo(app);
            var haystack  = [
                reference, app.funding_title, app.applicant_name, app.research_title,
                app.college_dept, label, app.assigned_evaluator_name
            ].join(' ').toLowerCase();

            if (term && haystack.indexOf(term) === -1) return;
            if (status && label.toLowerCase() !== status) return;
            visible++;

            var action;
            if (app.status === 'Submitted' && !app.assigned_evaluator_user_id) {
                action =
                    '<button type="button" class="btn btn-primary btn-sm ra-assign-btn" ' +
                    'style="font-size:.75rem;font-weight:700;padding:.3rem .75rem;border-radius:8px;white-space:nowrap;" ' +
                    'data-app-id="' + Number(app.id) + '">' +
                    '<i class="fas fa-user-plus me-1" aria-hidden="true"></i>Assign Evaluator</button>';
            } else if (app.assigned_evaluator_name) {
                action =
                    '<div style="font-size:.8rem;font-weight:700;color:var(--sms-heading);white-space:nowrap;">' +
                    '<i class="fas fa-user-check me-1" style="color:#047857;" aria-hidden="true"></i>' +
                    escHtml(app.assigned_evaluator_name) + '</div>' +
                    '<div style="font-size:.68rem;color:var(--sms-text-muted);">Assigned Reviewer</div>';
            } else {
                action = '<span style="color:var(--sms-text-muted);font-size:.8rem;">—</span>';
            }

            rows +=
                '<tr>' +
                '<td style="font-weight:700;white-space:nowrap;">' + escHtml(reference) + '</td>' +
                '<td style="font-weight:600;max-width:190px;">' + escHtml(app.funding_title || '—') + '</td>' +
                '<td style="font-size:.86rem;max-width:220px;">' + escHtml(app.research_title || '—') + '</td>' +
                '<td style="font-weight:600;">' + escHtml(app.applicant_name || '—') + '</td>' +
                '<td style="font-size:.84rem;">' + escHtml(app.college_dept || '—') + '</td>' +
                '<td style="font-weight:700;white-space:nowrap;">' + fmtBudget(app.requested_budget) + '</td>' +
                '<td style="font-size:.83rem;white-space:nowrap;">' + escHtml(fmtDate(app.submitted_at)) + '</td>' +
                '<td>' + statusBadge(app.status) + '</td>' +
                '<td style="text-align:center;">' + action + '</td>' +
                '</tr>';
        });

        tbody.innerHTML = visible ? rows :
            '<tr><td colspan="9" style="text-align:center;color:var(--sms-text-muted);padding:2.5rem;">' +
            'No proposals match the current filters.</td></tr>';

        tbody.querySelectorAll('.ra-assign-btn').forEach(function (btn) {
            btn.addEventListener('click', function () {
                openAssignModal(parseInt(this.dataset.appId, 10));
            });
        });
    }

    function renderAll() { renderStats(); renderTable(); }

    /* ── Data refresh (database is the source of truth) ───────────────── */
    function refreshData() {
        return fetch(apiBase + '?action=get_reviewer_assignment_data',
                     {credentials:'same-origin', cache:'no-store', headers:{'Accept':'application/json'}})
            .then(function (r) { return r.ok ? r.json() : null; })
            .then(function (d) {
                if (d && d.success) {
                    state.applications = d.applications || [];
                    state.evaluators   = d.evaluators   || [];
                    state.stats        = d.stats        || state.stats;
                    renderAll();
                }
            })
            .catch(function () {});
    }

    /* ── Assign modal ─────────────────────────────────────────────────── */
    function fetchAssignToken() {
        fetch(apiBase + '?action=generate_assign_token',
              {credentials:'same-origin', cache:'no-store', headers:{'Accept':'application/json'}})
            .then(function (r) { return r.ok ? r.json() : null; })
            .then(function (d) { if (d && d.token) state.assignToken = d.token; })
            .catch(function () {});
    }

    function summaryItem(label, value) {
        return '<div style="display:flex;flex-direction:column;gap:.1rem;min-width:0;">' +
               '<span style="font-size:.62rem;font-weight:800;letter-spacing:.05em;text-transform:uppercase;color:var(--sms-text-muted);">' + escHtml(label) + '</span>' +
               '<span style="font-size:.84rem;font-weight:700;color:var(--sms-heading);overflow-wrap:anywhere;">' + escHtml(value) + '</span>' +
               '</div>';
    }

    function showAssignAlert(msg) {
        var el = document.getElementById('assignAlert');
        if (!el) return;
        el.style.display = '';
        el.style.background = 'rgba(239,68,68,.08)';
        el.style.color = '#b91c1c';
        el.innerHTML = '<i class="fas fa-exclamation-triangle me-1" aria-hidden="true"></i>' + escHtml(msg);
    }

    function openAssignModal(appId) {
        var app = (state.applications || []).find(function (a) { return Number(a.id) === appId; });
        if (!app) return;

        state.selectedApp       = app;
        state.selectedEvaluator = null;
        state.assignToken       = '';

        document.getElementById('assignAlert').style.display = 'none';
        document.getElementById('btnAssignEvaluator').disabled = true;

        document.getElementById('assignProposalSummary').innerHTML =
            summaryItem('Proposal Reference', refNo(app)) +
            summaryItem('Research Project Title', app.research_title || '—') +
            summaryItem('Grant Opportunity', app.funding_title || '—') +
            summaryItem('Lead Proponent', app.applicant_name || '—') +
            summaryItem('College / Department', app.college_dept || '—') +
            summaryItem('Requested Budget', fmtBudget(app.requested_budget)) +
            summaryItem('Date Submitted', fmtDate(app.submitted_at)) +
            summaryItem('Current Status', statusLabel(app.status));

        var list = document.getElementById('assignEvaluatorList');
        var evals = state.evaluators || [];
        if (!evals.length) {
            list.innerHTML =
                '<div style="text-align:center;color:var(--sms-text-muted);font-size:.85rem;padding:1.2rem;">' +
                'No eligible evaluator accounts found. Please register active faculty reviewer accounts first.' +
                '</div>';
        } else {
            list.innerHTML = evals.map(function (ev) {
                return '<label class="ra-eval-option" ' +
                       'style="display:flex;align-items:center;gap:.7rem;border:1px solid var(--sms-border,#e2e8f0);' +
                       'border-radius:10px;padding:.6rem .85rem;cursor:pointer;background:#fff;">' +
                       '<input type="radio" name="raEvaluator" value="' + Number(ev.id) + '" class="form-check-input" style="margin:0;">' +
                       '<span style="display:flex;flex-direction:column;min-width:0;">' +
                       '<span style="font-weight:700;font-size:.87rem;color:var(--sms-heading);">' + escHtml(ev.full_name) + '</span>' +
                       '<span style="font-size:.72rem;color:var(--sms-text-muted);">' + escHtml(ev.role_label || ev.role_key) + ' · Faculty / Research Reviewer</span>' +
                       '</span></label>';
            }).join('');

            list.querySelectorAll('input[name="raEvaluator"]').forEach(function (radio) {
                radio.addEventListener('change', function () {
                    state.selectedEvaluator = evals.find(function (ev) {
                        return Number(ev.id) === parseInt(radio.value, 10);
                    }) || null;
                    document.getElementById('btnAssignEvaluator').disabled = !state.selectedEvaluator;
                    list.querySelectorAll('.ra-eval-option').forEach(function (opt) {
                        opt.style.borderColor = 'var(--sms-border,#e2e8f0)';
                        opt.style.background  = '#fff';
                    });
                    var chosen = radio.closest('.ra-eval-option');
                    if (chosen) {
                        chosen.style.borderColor = 'var(--sms-primary,#1e40af)';
                        chosen.style.background  = 'rgba(30,64,175,.05)';
                    }
                });
            });
        }

        fetchAssignToken();
        new bootstrap.Modal(document.getElementById('assignEvaluatorModal')).show();
    }

    /* ── Confirmation + save ──────────────────────────────────────────── */
    document.getElementById('btnAssignEvaluator').addEventListener('click', function () {
        if (!state.selectedApp || !state.selectedEvaluator) return;
        document.getElementById('confirmEvaluatorName').textContent = state.selectedEvaluator.full_name;
        document.getElementById('confirmProposalTitle').textContent =
            (state.selectedApp.research_title || refNo(state.selectedApp)) + '?';
        bootstrap.Modal.getInstance(document.getElementById('assignEvaluatorModal')).hide();
        new bootstrap.Modal(document.getElementById('confirmAssignModal')).show();
    });

    document.getElementById('btnConfirmAssign').addEventListener('click', function () {
        if (state.saving || !state.selectedApp || !state.selectedEvaluator) return;
        state.saving = true;

        var btn = this;
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Saving…';

        var fd = new FormData();
        fd.set('action', 'assign_evaluator');
        fd.set('token', state.assignToken);
        fd.set('application_id', String(state.selectedApp.id));
        fd.set('evaluator_user_id', String(state.selectedEvaluator.id));

        fetch(apiBase, {method:'POST', credentials:'same-origin', body: fd})
            .then(function (r) { return r.json(); })
            .then(function (data) {
                bootstrap.Modal.getInstance(document.getElementById('confirmAssignModal')).hide();
                if (data.success) {
                    state.applications = data.applications || state.applications;
                    state.stats        = data.stats        || state.stats;
                    renderAll();
                    document.getElementById('successEvaluatorName').textContent = data.evaluator_name || state.selectedEvaluator.full_name;
                    document.getElementById('successProposalTitle').textContent =
                        state.selectedApp.research_title || refNo(state.selectedApp);
                    new bootstrap.Modal(document.getElementById('assignSuccessModal')).show();
                    state.selectedApp = null;
                    state.selectedEvaluator = null;
                } else {
                    refreshData();
                    var modal = new bootstrap.Modal(document.getElementById('assignEvaluatorModal'));
                    modal.show();
                    showAssignAlert(data.message || 'Failed to assign evaluator. Please try again.');
                    fetchAssignToken();
                }
            })
            .catch(function () {
                bootstrap.Modal.getInstance(document.getElementById('confirmAssignModal')).hide();
                var modal = new bootstrap.Modal(document.getElementById('assignEvaluatorModal'));
                modal.show();
                showAssignAlert('Network error. Please check your connection and try again.');
                fetchAssignToken();
            })
            .finally(function () {
                state.saving = false;
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-check me-1" aria-hidden="true"></i>Confirm Assignment';
            });
    });

    /* ── Filters, refresh, polling ────────────────────────────────────── */
    var searchEl = document.getElementById('raSearch');
    var statusEl = document.getElementById('raStatusFilter');
    if (searchEl) searchEl.addEventListener('input',  renderTable);
    if (statusEl) statusEl.addEventListener('change', renderTable);

    var refreshBtn = document.getElementById('raRefreshBtn');
    if (refreshBtn) refreshBtn.addEventListener('click', function () { refreshData(); });

    // Keep the page in sync with the database (same polling approach as
    // the other CRAD grant pages — the database stays the source of truth).
    setInterval(function () {
        var assignOpen  = document.getElementById('assignEvaluatorModal').classList.contains('show');
        var confirmOpen = document.getElementById('confirmAssignModal').classList.contains('show');
        if (!assignOpen && !confirmOpen && !state.saving) refreshData();
    }, 15000);

    renderAll();
})();
</script>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
