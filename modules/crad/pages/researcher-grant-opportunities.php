<?php
/**
 * SMS 2 - CORE SYSTEM · Grant Opportunities — Researcher View
 * Module: CRAD
 *
 * Browsable researcher Grant Opportunities page for Student researchers and
 * Research Advisers (treated as Faculty researchers).
 *
 * Visibility is strictly database-driven: only grant calls whose
 * researcher_type matches the authenticated researcher
 * (Student → Student/Both, Faculty/Adviser → Faculty/Both) and whose status is
 * 'Open for Application' are shown. No hardcoded grant records, no duplicated
 * tables — the same crad_db.grant_opportunities used by the CRAD Officer.
 *
 * Apply Now opens the BRGFAMS Form 1 proposal modal. Submission is handled by
 * modules/crad/api/grant-management.php (submit_proposal action), which enforces
 * eligibility and one-time tokens server-side.
 */
require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';
require_once __DIR__ . '/../includes/grant-helpers.php';

requireAuth();

$roleKey = getCurrentUserRoleKey();
if (!in_array($roleKey, ['student', 'adviser'], true)) {
    header('Location: ' . BASE_URL . '/dashboard/index.php');
    exit;
}

$isFaculty      = $roleKey === 'adviser';
$activeModule   = $isFaculty ? 'faculty' : 'student_portal';
$activePage     = 'grant-opportunities';

$pageTitle             = 'Grant Opportunities';
$pageBannerIcon        = 'fa-hand-holding-usd';
$pageBannerDescription = $isFaculty
    ? 'Browse research grant calls open for faculty researchers.'
    : 'Browse research grant calls open for student researchers.';

$breadcrumbs = $isFaculty
    ? [
        ['label' => 'Faculty',           'url' => BASE_URL . '/modules/faculty/index.php'],
        ['label' => 'Grant Opportunities', 'url' => null],
    ]
    : [
        ['label' => 'Student Portal',    'url' => BASE_URL . '/modules/student-portal/pages/dashboard.php'],
        ['label' => 'Grant Opportunities', 'url' => null],
    ];

require_once ROOT_PATH . '/includes/breadcrumbs.php';

// Lead proponent pre-fill — use session full name
$sessionUserName = trim((string) ($_SESSION['full_name'] ?? $_SESSION['user_name'] ?? ''));

// ── Data ──────────────────────────────────────────────────────────────────────
$crad            = cradDb();
$opportunities   = [];
$dbError         = '';
$appliedGrantIds = [];

if ($crad) {
    try {
        grantEnsureTables($crad);
        $all = grantGetOpportunities($crad); // runs deadline-expiry sweep

        $allowedTypes = $isFaculty ? ['Faculty', 'Both'] : ['Student', 'Both'];
        foreach ($all as $opp) {
            if (($opp['status'] ?? '') !== 'Open for Application') { continue; }
            if (!in_array((string) ($opp['researcher_type'] ?? 'Both'), $allowedTypes, true)) { continue; }
            $opportunities[] = $opp;
        }

        // Grant calls this researcher has already applied to (DB-driven)
        $myApps = grantGetUserApplications($crad, (int) ($_SESSION['user_id'] ?? 0));
        foreach ($myApps as $app) {
            $appliedGrantIds[(int) $app['grant_opportunity_id']] = true;
        }
    } catch (Throwable $e) {
        $dbError = htmlspecialchars($e->getMessage());
        error_log('researcher-grant-opportunities: ' . $e->getMessage());
    }
} else {
    $dbError = 'CRAD database connection unavailable.';
}

// ── Derived counts ────────────────────────────────────────────────────────────
$total      = count($opportunities);
$cntOpen    = 0; $cntClosed = 0; $cntExpired = 0;
foreach ($opportunities as $o) {
    $s = $o['status'] ?? '';
    if ($s === 'Open for Application') { $cntOpen++; }
    elseif ($s === 'Closed')           { $cntClosed++; }
    elseif ($s === 'Expired')          { $cntExpired++; }
}

if (!function_exists('rgEligibilityCategory')) {
    function rgEligibilityCategory(string $eligibility): array
    {
        if (preg_match('/\b(ched|dost|industry|external|government|nrcp|pcaarrd)\b/i', $eligibility)) {
            return ['cat' => 'external', 'label' => 'CHED / External'];
        }
        $e = strtolower(trim($eligibility));
        return match (true) {
            $e === 'faculty researchers'      => ['cat' => 'faculty',  'label' => 'Faculty Funding'],
            $e === 'student researchers'      => ['cat' => 'student',  'label' => 'Student Funding'],
            $e === 'faculty & student'        => ['cat' => 'open',     'label' => 'Faculty & Student'],
            $e === 'specific college/program' => ['cat' => 'internal', 'label' => 'Internal Funding'],
            $e === 'open'                     => ['cat' => 'open',     'label' => 'Open Funding'],
            default                           => ['cat' => 'other',    'label' => ucwords($eligibility)],
        };
    }
}

if (!function_exists('rgFilterPills')) {
    function rgFilterPills(array $opportunities): array
    {
        $order    = ['faculty', 'student', 'open', 'internal', 'external', 'other'];
        $labelMap = ['faculty'=>'Faculty Research','student'=>'Student Research','open'=>'Faculty & Student',
                     'internal'=>'Internal / Seed','external'=>'CHED / External','other'=>'Other'];
        $counts   = [];
        foreach ($opportunities as $o) {
            $cat = rgEligibilityCategory((string) ($o['eligibility'] ?? ''))['cat'];
            $counts[$cat] = ($counts[$cat] ?? 0) + 1;
        }
        $pills = [];
        foreach ($order as $cat) {
            if (isset($counts[$cat])) {
                $pills[] = ['cat' => $cat, 'label' => $labelMap[$cat] ?? ucwords($cat), 'count' => $counts[$cat]];
            }
        }
        return $pills;
    }
}

$filterPills = rgFilterPills($opportunities);

require_once ROOT_PATH . '/includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);
?>
<link href="<?= BASE_URL ?>/assets/css/module-process-list.css?v=2"       rel="stylesheet">
<link href="<?= BASE_URL ?>/assets/css/grant-opportunities-cards.css?v=2" rel="stylesheet">

<?php if ($dbError !== ''): ?>
<div class="mpl-alert" role="alert" style="background:rgba(239,68,68,.08);color:#b91c1c;margin-bottom:1rem;">
    <i class="fas fa-exclamation-triangle me-1"></i><?= $dbError ?>
</div>
<?php endif; ?>

<div class="mpl" data-mpl data-researcher-grant-opp-page>

<!-- PAGE HEADER -->
<div class="go-page-header">
    <div class="go-page-header-text">
        <h1>
            <i class="fas fa-hand-holding-usd me-2" style="color:var(--sms-primary);font-size:1.1rem;" aria-hidden="true"></i>
            Grant Opportunities &amp; Funding Programs
        </h1>
        <p>Grant calls open for you as a <?= $isFaculty ? 'faculty researcher' : 'student researcher' ?> &mdash; sourced live from the grant database.</p>
    </div>
    <div class="go-page-header-actions">
        <a class="mpl-btn mpl-btn-ghost"
           href="<?= BASE_URL ?>/modules/crad/pages/researcher-proposals-applications.php">
            <i class="fas fa-file-alt" aria-hidden="true"></i>My Proposals &amp; Applications
        </a>
    </div>
</div>

<?php if ($dbError === ''): ?>

<!-- STAT BADGES -->
<div class="go-stat-row" aria-label="Grant opportunity summary">
    <div class="go-stat-badge total">
        <span class="go-stat-badge-icon"><i class="fas fa-layer-group"></i></span>
        Open for&nbsp;You&nbsp;<strong><?= $total ?></strong>
    </div>
    <div class="go-stat-badge open">
        <span class="go-stat-badge-icon"><i class="fas fa-door-open"></i></span>
        Open&nbsp;<strong><?= $cntOpen ?></strong>
    </div>
    <div class="go-stat-badge closed">
        <span class="go-stat-badge-icon"><i class="fas fa-lock"></i></span>
        Closed&nbsp;<strong><?= $cntClosed ?></strong>
    </div>
    <div class="go-stat-badge expired">
        <span class="go-stat-badge-icon"><i class="fas fa-calendar-times"></i></span>
        Expired&nbsp;<strong><?= $cntExpired ?></strong>
    </div>
</div>

<!-- FILTER BAR -->
<div class="go-filter-bar" id="goFilterBar" aria-label="Filter grants">
    <span class="go-filter-label">Filter:</span>
    <div class="go-filter-pills">
        <button type="button" class="go-filter-pill active" data-cat-filter="all" aria-pressed="true">
            All Grants <span class="pill-count"><?= $total ?></span>
        </button>
        <?php foreach ($filterPills as $pill): ?>
        <button type="button" class="go-filter-pill" data-cat-filter="<?= htmlspecialchars($pill['cat']) ?>" aria-pressed="false">
            <?= htmlspecialchars($pill['label']) ?> <span class="pill-count"><?= (int) $pill['count'] ?></span>
        </button>
        <?php endforeach; ?>
    </div>
    <label class="go-filter-search" for="goSearch">
        <i class="fas fa-search" aria-hidden="true"></i>
        <input type="search" id="goSearch" placeholder="Search grant titles…" autocomplete="off" aria-label="Search grant titles or eligibility">
    </label>
</div>

<!-- RESULTS BAR -->
<div class="go-results-bar" id="goResultsBar">
    <span class="go-results-count" id="goResultsCount">
        Showing <strong><?= $total ?></strong> grant<?= $total !== 1 ? 's' : '' ?>
    </span>
    <a class="mpl-btn mpl-btn-ghost mpl-btn-sm" href="?" aria-label="Refresh list">
        <i class="fas fa-sync-alt" aria-hidden="true"></i>&nbsp;Refresh
    </a>
</div>

<?php if (empty($opportunities)): ?>
<!-- EMPTY STATE -->
<div class="go-empty-state">
    <div class="go-empty-icon"><i class="fas fa-hand-holding-usd" aria-hidden="true"></i></div>
    <h3>No Grant Opportunities Available Yet</h3>
    <p>There are currently no open grant calls for <?= $isFaculty ? 'faculty researchers' : 'student researchers' ?>. Check back later.</p>
</div>

<?php else: ?>
<!-- CARD GRID -->
<div class="go-card-grid" id="goCardGrid">
<?php foreach ($opportunities as $opp):
    $catInfo       = rgEligibilityCategory((string) ($opp['eligibility'] ?? ''));
    $cat           = $catInfo['cat'];
    $catLabel      = $catInfo['label'];
    $statusRaw     = (string) ($opp['status'] ?? 'Open for Application');
    $appCount      = (int) ($opp['application_count'] ?? 0);
    $fundingRaw    = (float) $opp['max_funding_cap'];
    $fundingFmt    = '₱' . number_format($fundingRaw, 0);
    $deadlineTs    = strtotime((string) $opp['application_deadline']);
    $deadlineFmt   = date('M j, Y', $deadlineTs);
    $deadlineIso   = date('Y-m-d', $deadlineTs);
    $isPast        = $deadlineTs < mktime(0, 0, 0);
    $isOpen        = ($statusRaw === 'Open for Application') && !$isPast;
    $publishedFmt  = date('M j, Y', strtotime((string) $opp['created_at']));
    $publishedBy   = trim((string) ($opp['created_by_name'] ?? ''));
    $alreadyApplied= isset($appliedGrantIds[(int) $opp['id']]);
    $statusKey     = match ($statusRaw) { 'Open for Application' => 'open', 'Expired' => 'expired', default => 'closed' };
    $catIcon       = match ($cat) { 'faculty' => 'fa-chalkboard-teacher', 'student' => 'fa-user-graduate',
                                    'external' => 'fa-globe', 'internal' => 'fa-university',
                                    'open' => 'fa-users', default => 'fa-tag' };
    $searchData    = strtolower(($opp['funding_title'] ?? '') . ' ' . ($opp['eligibility'] ?? '') . ' ' . ($opp['college_program'] ?? '') . ' ' . $statusRaw);
?>
<article class="go-card" data-cat="<?= htmlspecialchars($cat) ?>" data-status="<?= htmlspecialchars($statusKey) ?>"
         data-search="<?= htmlspecialchars($searchData) ?>" aria-label="<?= htmlspecialchars((string) $opp['funding_title']) ?>">
    <div class="go-card-stripe" aria-hidden="true"></div>
    <div class="go-card-header">
        <span class="go-card-cat-tag">
            <i class="fas <?= $catIcon ?>" aria-hidden="true"></i> <?= htmlspecialchars($catLabel) ?>
        </span>
        <span class="go-card-app-count" title="<?= $appCount ?> application<?= $appCount !== 1 ? 's' : '' ?> submitted">
            <span class="count-num"><?= $appCount ?></span>&nbsp;Applied
        </span>
    </div>
    <div class="go-card-body">
        <h3 class="go-card-title"><?= htmlspecialchars((string) $opp['funding_title']) ?></h3>
        <div class="go-card-meta">
            <div class="go-card-meta-row go-card-meta-row-full">
                <span class="go-card-meta-label">Eligibility</span>
                <span class="go-card-meta-value">
                    <?= htmlspecialchars((string) $opp['eligibility']) ?>
                    <?php if (!empty($opp['college_program'])): ?>
                        &mdash; <span style="opacity:.8;font-size:.9em;"><?= htmlspecialchars((string) $opp['college_program']) ?></span>
                    <?php endif; ?>
                </span>
            </div>
            <div class="go-card-meta-row">
                <span class="go-card-meta-label">Maximum Funding</span>
                <span class="go-card-meta-value funding"><?= $fundingFmt ?></span>
            </div>
            <div class="go-card-meta-row">
                <span class="go-card-meta-label">Application Deadline</span>
                <span class="go-card-meta-value<?= $isPast ? ' deadline-past' : '' ?>">
                    <?php if ($isPast): ?><i class="fas fa-exclamation-circle" aria-hidden="true" style="font-size:.78em;margin-right:2px;"></i><?php endif; ?>
                    <?= htmlspecialchars($deadlineFmt) ?>
                </span>
            </div>
            <div class="go-card-meta-row go-card-meta-row-full">
                <span class="go-card-meta-label">Requirements</span>
                <span class="go-card-meta-value requirements">
                    <?= htmlspecialchars(trim((string) ($opp['requirements'] ?? ''))) ?>
                </span>
            </div>
        </div>
        <div class="go-card-status <?= htmlspecialchars($statusKey) ?>" aria-label="Status: <?= htmlspecialchars($statusRaw) ?>">
            <span class="status-dot" aria-hidden="true"></span>
            <?= htmlspecialchars($statusRaw) ?>
        </div>
    </div>
    <div class="go-card-footer">
        <div class="go-card-published">
            <strong>Published</strong>
            <?= htmlspecialchars($publishedFmt) ?>
            <?php if ($publishedBy !== ''): ?>
                <br><span style="font-size:.68rem;opacity:.75;">by <?= htmlspecialchars($publishedBy) ?></span>
            <?php endif; ?>
        </div>
        <?php if ($alreadyApplied): ?>
            <button type="button" class="go-btn-apply go-btn-disabled" disabled
                    title="You have already applied to this grant call."
                    aria-label="You have already applied to <?= htmlspecialchars((string) $opp['funding_title']) ?>">
                <i class="fas fa-check" aria-hidden="true"></i>Applied
            </button>
        <?php elseif ($isOpen): ?>
            <button type="button" class="go-btn-apply"
                    data-grant-id="<?= (int) $opp['id'] ?>"
                    data-grant-title="<?= htmlspecialchars((string) $opp['funding_title']) ?>"
                    data-grant-funding="<?= htmlspecialchars($fundingFmt) ?>"
                    data-grant-funding-raw="<?= htmlspecialchars((string) $fundingRaw) ?>"
                    data-grant-eligibility="<?= htmlspecialchars((string) $opp['eligibility']) ?>"
                    data-grant-deadline="<?= htmlspecialchars($deadlineFmt) ?>"
                    aria-label="Apply for <?= htmlspecialchars((string) $opp['funding_title']) ?>">
                <i class="fas fa-paper-plane" aria-hidden="true"></i>Apply Now
            </button>
        <?php else: ?>
            <button type="button" class="go-btn-apply go-btn-disabled" disabled
                    aria-label="<?= htmlspecialchars($statusRaw) ?> — applications not accepted"
                    title="<?= htmlspecialchars($statusRaw) ?>">
                <?php if ($statusRaw === 'Expired'): ?>
                    <i class="fas fa-clock" aria-hidden="true"></i>Expired
                <?php else: ?>
                    <i class="fas fa-lock" aria-hidden="true"></i>Closed
                <?php endif; ?>
            </button>
        <?php endif; ?>
    </div>
</article>
<?php endforeach; ?>
</div><!-- /#goCardGrid -->
<nav class="go-pagination" id="goPagination" aria-label="Grant opportunities pages"></nav>
<?php endif; // empty($opportunities) ?>
<?php endif; // $dbError === '' ?>
</div><!-- /.mpl -->


<!-- ═══════════════════════════════════════════════════════════════════════════
     SUBMIT RESEARCH GRANT PROPOSAL — BRGFAMS Form 1
     Full-screen scrollable modal. Opens when user clicks Apply Now.
     grant_opportunity_id is injected from the card's data-grant-id attribute.
     ══════════════════════════════════════════════════════════════════════════ -->
<div class="modal fade" id="proposalModal" tabindex="-1"
     aria-labelledby="proposalModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-xl"
         style="max-width:min(820px,97vw);">
        <div class="modal-content" style="border-radius:14px;overflow:hidden;">

            <!-- ── Header ─────────────────────────────────────────────────── -->
            <div class="modal-header"
                 style="background:linear-gradient(135deg,#1e3a8a,#1e40af,#2563eb);border-bottom:none;padding:1rem 1.5rem;">
                <div>
                    <h5 class="modal-title fw-bold" id="proposalModalTitle"
                        style="color:#fff;font-size:1.05rem;margin:0;line-height:1.2;">
                        <i class="fas fa-file-alt me-2" aria-hidden="true"></i>
                        Submit Research Grant Proposal
                    </h5>
                    <div style="color:rgba(255,255,255,.75);font-size:.78rem;margin-top:.2rem;">
                        BRGFAMS Form 1 &mdash; <span id="proposalModalGrantName" style="font-style:italic;"></span>
                    </div>
                </div>
                <button type="button" class="btn-close btn-close-white ms-auto"
                        data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <!-- ── Selected grant summary bar ──────────────────────────────── -->
            <div id="proposalGrantSummaryBar"
                 style="background:rgba(30,64,175,.06);border-bottom:1px solid var(--sms-border,#e2e8f0);
                        padding:.65rem 1.5rem;display:flex;flex-wrap:wrap;gap:.5rem 1.5rem;font-size:.82rem;">
                <!-- Populated by JS -->
            </div>

            <!-- ── Inline alert ───────────────────────────────────────────── -->
            <div id="proposalAlert" class="mpl-alert"
                 style="display:none;margin:.75rem 1.5rem 0;border-radius:8px;" role="alert"></div>

            <!-- ── Form body ──────────────────────────────────────────────── -->
            <div class="modal-body" style="padding:1.15rem 1.5rem .5rem;">
                <form id="proposalForm" novalidate autocomplete="off" enctype="multipart/form-data">
                    <input type="hidden" id="propGrantId"    name="grant_opportunity_id" value="">
                    <input type="hidden" id="propApplyToken" name="apply_token"           value="">

                    <!-- ROW 1: Grant Program (read-only) + Lead Proponent -->
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <div class="go-form-group">
                                <label class="go-form-label">
                                    Grant Program / Call
                                </label>
                                <input type="text" id="propGrantName" class="go-form-input"
                                       readonly tabindex="-1"
                                       style="background:var(--sms-surface-muted,#f8fafc);
                                              color:var(--sms-text-muted);cursor:default;"
                                       placeholder="Selected grant will appear here">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="go-form-group">
                                <label for="propLeadProponent" class="go-form-label">
                                    Lead Proponent Name <span class="go-required">*</span>
                                </label>
                                <input type="text" id="propLeadProponent" name="lead_proponent"
                                       class="go-form-input" maxlength="200" required
                                       placeholder="Full name of the principal researcher">
                            </div>
                        </div>
                    </div>

                    <!-- ROW 2: Research Project Title (full width) -->
                    <div class="go-form-group mb-3">
                        <label for="propResearchTitle" class="go-form-label">
                            Research Project Title <span class="go-required">*</span>
                        </label>
                        <input type="text" id="propResearchTitle" name="research_title"
                               class="go-form-input" maxlength="500" required
                               placeholder="e.g. AI-Driven Agricultural Crop Disease Detection System">
                    </div>

                    <!-- ROW 3: College / Dept + Requested Budget -->
                    <div class="row g-3 mb-3">
                        <div class="col-md-7">
                            <div class="go-form-group">
                                <label for="propCollegeDept" class="go-form-label">
                                    Academic College / Department <span class="go-required">*</span>
                                </label>
                                <input type="text" id="propCollegeDept" name="college_dept"
                                       class="go-form-input" maxlength="200" required
                                       placeholder="e.g. College of Computer Studies">
                            </div>
                        </div>
                        <div class="col-md-5">
                            <div class="go-form-group">
                                <label for="propRequestedBudget" class="go-form-label">
                                    Requested Budget (PHP) <span class="go-required">*</span>
                                </label>
                                <input type="number" id="propRequestedBudget" name="requested_budget"
                                       class="go-form-input" min="1" step="0.01" required
                                       placeholder="e.g. 280000">
                                <span id="propBudgetHint"
                                      style="font-size:.72rem;color:var(--sms-text-muted);margin-top:.15rem;display:block;">
                                    <!-- JS fills "Max: ₱350,000" -->
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- ROW 4: Executive Abstract -->
                    <div class="go-form-group mb-3">
                        <label for="propAbstract" class="go-form-label">
                            Executive Abstract <span class="go-required">*</span>
                        </label>
                        <textarea id="propAbstract" name="abstract"
                                  class="go-form-input" rows="4" maxlength="5000" required
                                  placeholder="Provide a concise summary of the research project, its significance, and expected outcomes."
                                  style="resize:vertical;"></textarea>
                    </div>

                    <!-- ROW 5: Objectives -->
                    <div class="go-form-group mb-3">
                        <label for="propObjectives" class="go-form-label">
                            Objectives <span class="go-required">*</span>
                        </label>
                        <textarea id="propObjectives" name="objectives"
                                  class="go-form-input" rows="3" maxlength="3000" required
                                  placeholder="List the specific objectives of the research project."
                                  style="resize:vertical;"></textarea>
                    </div>

                    <!-- SECTION DIVIDER -->
                    <div style="border-top:1px solid var(--sms-border,#e2e8f0);margin:.3rem 0 1rem;
                                font-size:.7rem;font-weight:800;letter-spacing:.05em;text-transform:uppercase;
                                color:var(--sms-text-muted);padding-top:.7rem;">
                        <i class="fas fa-paperclip me-1" aria-hidden="true"></i>Document Attachments
                    </div>

                    <!-- ROW 6: Proposal PDF (required) -->
                    <div class="go-form-group mb-3">
                        <label for="propProposalPdf" class="go-form-label">
                            Proposal Document (PDF / DOC / DOCX) <span class="go-required">*</span>
                        </label>
                        <input type="file" id="propProposalPdf" name="proposal_pdf"
                               class="go-form-input go-file-input" required
                               accept=".pdf,.doc,.docx"
                               style="padding:.42rem .875rem;">
                        <span style="font-size:.72rem;color:var(--sms-text-muted);">
                            Required. PDF, DOC, or DOCX &mdash; max 10 MB.
                        </span>
                    </div>

                    <!-- ROW 7 + 8: Supporting + Ethics (2 columns) -->
                    <div class="row g-3 mb-2">
                        <div class="col-md-6">
                            <div class="go-form-group">
                                <label for="propSupportingDocs" class="go-form-label">
                                    Supporting Documents
                                    <span style="font-size:.72rem;font-weight:500;color:var(--sms-text-muted);">(optional)</span>
                                </label>
                                <input type="file" id="propSupportingDocs" name="supporting_docs"
                                       class="go-form-input go-file-input"
                                       accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                                       style="padding:.42rem .875rem;">
                                <span style="font-size:.72rem;color:var(--sms-text-muted);">
                                    Endorsement, CV, budget worksheet, etc. &mdash; max 10 MB.
                                </span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="go-form-group">
                                <label for="propEthicsDoc" class="go-form-label">
                                    Ethics Clearance / Ethics Documents
                                    <span style="font-size:.72rem;font-weight:500;color:var(--sms-text-muted);">(if applicable)</span>
                                </label>
                                <input type="file" id="propEthicsDoc" name="ethics_doc"
                                       class="go-form-input go-file-input"
                                       accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                                       style="padding:.42rem .875rem;">
                                <span style="font-size:.72rem;color:var(--sms-text-muted);">
                                    Upload ethics clearance or related approval if applicable.
                                </span>
                            </div>
                        </div>
                    </div>

                </form>
            </div><!-- /.modal-body -->

            <!-- ── Footer ─────────────────────────────────────────────────── -->
            <div class="modal-footer border-0"
                 style="padding:.7rem 1.5rem 1.1rem;justify-content:flex-end;gap:.5rem;">
                <button type="button" class="btn btn-outline-secondary btn-sm px-4"
                        data-bs-dismiss="modal">Cancel</button>
                <button type="submit" form="proposalForm" id="btnProposalSubmit"
                        class="btn btn-sms-primary btn-sm px-4">
                    <i class="fas fa-paper-plane me-1"></i>Submit Proposal
                </button>
            </div>

        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /#proposalModal -->


<!-- PROPOSAL SUCCESS MODAL -->
<div class="modal fade" id="proposalSuccessModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:420px;">
        <div class="modal-content shadow" style="border-radius:14px;overflow:hidden;">
            <div class="modal-header border-0 pb-0"
                 style="background:rgba(5,150,105,.06);border-bottom:1px solid rgba(16,185,129,.15)!important;padding:.9rem 1.5rem;">
                <h6 class="modal-title fw-bold" style="color:#065f46;">
                    <i class="fas fa-check-circle me-2" style="color:#059669;font-size:1.1rem;"></i>
                    Proposal Submitted Successfully
                </h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding:1.1rem 1.5rem .7rem;">
                <div style="font-size:.88rem;color:var(--sms-text);">
                    Your research grant proposal has been received.
                </div>
                <div style="margin-top:.85rem;padding:.8rem 1rem;background:var(--sms-surface-muted,#f8fafc);
                            border-radius:10px;border:1px solid var(--sms-border,#e2e8f0);font-size:.84rem;">
                    <div style="margin-bottom:.4rem;">
                        <span style="font-size:.63rem;font-weight:800;letter-spacing:.05em;text-transform:uppercase;color:var(--sms-text-muted);">Grant</span><br>
                        <span id="successGrantTitle" style="font-weight:700;color:var(--sms-heading);"></span>
                    </div>
                    <div style="display:flex;gap:1.5rem;flex-wrap:wrap;">
                        <div>
                            <span style="font-size:.63rem;font-weight:800;letter-spacing:.05em;text-transform:uppercase;color:var(--sms-text-muted);">Status</span><br>
                            <span class="go-card-status open" style="width:fit-content;margin-top:.15rem;font-size:.72rem;">
                                <span class="status-dot"></span>Pending Evaluation
                            </span>
                        </div>
                        <div>
                            <span style="font-size:.63rem;font-weight:800;letter-spacing:.05em;text-transform:uppercase;color:var(--sms-text-muted);">Submitted</span><br>
                            <span style="font-size:.84rem;font-weight:600;color:var(--sms-text);" id="successSubmittedAt"></span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 pb-4 justify-content-center gap-2">
                <button type="button" class="btn btn-outline-secondary btn-sm px-4"
                        data-bs-dismiss="modal">Close</button>
                <a href="<?= BASE_URL ?>/modules/crad/pages/researcher-proposals-applications.php"
                   class="btn btn-sms-primary btn-sm px-4">
                    <i class="fas fa-file-alt me-1"></i>View Proposals &amp; Applications
                </a>
            </div>
        </div>
    </div>
</div>


<style>
.go-form-group  { display:flex; flex-direction:column; gap:.3rem; }
.go-form-label  { font-size:.875rem; font-weight:700; color:var(--sms-heading); }
.go-required    { color:#ef4444; }
.go-form-input  {
    border:1.5px solid var(--sms-border);
    border-radius:8px;
    padding:.52rem .875rem;
    font-size:.88rem;
    background:var(--sms-surface-muted,#f8fafc);
    color:var(--sms-text);
    transition:border-color .15s;
    width:100%;
}
.go-form-input:focus {
    outline:none;
    border-color:var(--sms-primary,#2563eb);
    background:var(--sms-card-bg,#fff);
}
textarea.go-form-input { line-height:1.5; }
.go-file-input  { cursor:pointer; }
.go-file-input::-webkit-file-upload-button {
    background:var(--sms-primary,#1e40af);
    color:#fff;
    border:none;
    border-radius:6px;
    padding:.3rem .75rem;
    font-size:.8rem;
    font-weight:700;
    cursor:pointer;
    margin-right:.6rem;
    transition:background .15s;
}
.go-file-input::-webkit-file-upload-button:hover { background:var(--sms-primary-dark,#1e3a8a); }
</style>

<script>
document.addEventListener('DOMContentLoaded', function () {
    'use strict';

    var apiBase = '<?= BASE_URL ?>/modules/crad/api/grant-management.php';

    /* ── utility ────────────────────────────────────────────────────────── */
    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
                        .replace(/"/g,'&quot;').replace(/'/g,'&#039;');
    }
    function fmtCurrency(n) {
        var v = parseFloat(n) || 0;
        return '₱' + v.toLocaleString('en-PH', {minimumFractionDigits:0,maximumFractionDigits:0});
    }
    function nowLabel() {
        return new Date().toLocaleDateString('en-PH', {year:'numeric',month:'short',day:'numeric',hour:'2-digit',minute:'2-digit'});
    }

    /* ── client-side filtering + pagination ────────────────────────────── */
    var CARDS_PER_PAGE = 12, currentPage = 1, activeCat = 'all', searchTerm = '';
    var grid       = document.getElementById('goCardGrid');
    var pagination = document.getElementById('goPagination');
    var countEl    = document.getElementById('goResultsCount');
    var filterBar  = document.getElementById('goFilterBar');
    var searchEl   = document.getElementById('goSearch');

    function allCards()   { return grid ? Array.from(grid.querySelectorAll('.go-card')) : []; }
    function visibleCards(){
        return allCards().filter(function(c){
            return (activeCat === 'all' || c.dataset.cat === activeCat) &&
                   (!searchTerm || (c.dataset.search||'').includes(searchTerm));
        });
    }
    function renderPage(){
        var vis = visibleCards(), total = vis.length;
        var pages = Math.max(1, Math.ceil(total/CARDS_PER_PAGE));
        if (currentPage > pages) currentPage = pages;
        if (currentPage < 1)     currentPage = 1;
        var s = (currentPage-1)*CARDS_PER_PAGE, e = s+CARDS_PER_PAGE;
        allCards().forEach(function(c){c.style.display='none';});
        vis.forEach(function(c,i){c.style.display=(i>=s&&i<e)?'':'none';});
        if (countEl) {
            countEl.innerHTML = total
                ? 'Showing <strong>'+Math.min(CARDS_PER_PAGE,total-s)+'</strong> of <strong>'+total+'</strong> grant'+(total!==1?'s':'')
                : 'No grants match your filters';
        }
        var noRes = grid && grid.querySelector('.go-no-results');
        if (!total && grid) {
            if (!noRes) {
                noRes = document.createElement('div'); noRes.className='go-no-results';
                noRes.innerHTML='<i class="fas fa-search"></i><p>No grants match your filters.<br><small>Try a different category or search.</small></p>';
                grid.appendChild(noRes);
            }
            noRes.style.display='';
        } else if (noRes) { noRes.style.display='none'; }
        buildPagination(total, pages);
    }
    function buildPagination(total, pages){
        if (!pagination) return;
        pagination.innerHTML = '';
        if (pages <= 1) return;
        function btn(lbl, pg, dis, act){
            var b = document.createElement('button');
            b.type='button'; b.className='go-pagination-btn'+(act?' active':'');
            b.innerHTML=lbl; b.disabled=!!dis;
            if (!dis && !act) b.addEventListener('click', function(){ currentPage=pg; renderPage(); if(grid)grid.scrollIntoView({behavior:'smooth',block:'start'}); });
            return b;
        }
        pagination.appendChild(btn('<i class="fas fa-chevron-left"></i>',currentPage-1,currentPage===1,false));
        var range=[];
        if (pages<=7){for(var i=1;i<=pages;i++)range.push(i);}
        else{
            range.push(1);
            if(currentPage>3)range.push('…');
            var lo=Math.max(2,currentPage-1),hi=Math.min(pages-1,currentPage+1);
            for(var j=lo;j<=hi;j++)range.push(j);
            if(currentPage<pages-2)range.push('…');
            range.push(pages);
        }
        range.forEach(function(item){
            if(item==='…'){var sp=document.createElement('span');sp.className='go-pagination-btn';
                sp.style.cssText='cursor:default;pointer-events:none;border-color:transparent;background:transparent;color:var(--sms-text-muted)';
                sp.textContent='…';pagination.appendChild(sp);}
            else pagination.appendChild(btn(item,item,false,item===currentPage));
        });
        pagination.appendChild(btn('<i class="fas fa-chevron-right"></i>',currentPage+1,currentPage===pages,false));
    }

    if (filterBar) {
        filterBar.querySelectorAll('.go-filter-pill').forEach(function(p){
            p.addEventListener('click',function(){
                filterBar.querySelectorAll('.go-filter-pill').forEach(function(x){x.classList.remove('active');x.setAttribute('aria-pressed','false');});
                this.classList.add('active'); this.setAttribute('aria-pressed','true');
                activeCat=this.dataset.catFilter||'all'; currentPage=1; renderPage();
            });
        });
    }
    if (searchEl) { searchEl.addEventListener('input',function(){ searchTerm=this.value.toLowerCase().trim(); currentPage=1; renderPage(); }); }
    if (grid) renderPage();

    /* ═══════════════════════════════════════════════════════════════════════
       SUBMIT RESEARCH GRANT PROPOSAL MODAL
       ════════════════════════════════════════════════════════════════════ */
    // Lazy: create the Bootstrap Modal instance only when first needed.
    var _propModalInstance = null;
    function getPropModal() {
        if (!_propModalInstance) {
            var el = document.getElementById('proposalModal');
            if (el) _propModalInstance = new bootstrap.Modal(el, {backdrop:true,keyboard:true});
        }
        return _propModalInstance;
    }

    function fetchApplyToken(){
        fetch(apiBase+'?action=generate_apply_token',{credentials:'same-origin',cache:'no-store',headers:{'Accept':'application/json'}})
        .then(function(r){return r.ok?r.json():null;})
        .then(function(d){if(d&&d.token)document.getElementById('propApplyToken').value=d.token;})
        .catch(function(){});
    }

    function openProposalModal(btn){
        var propModal = getPropModal();
        if (!propModal) return;
        var grantId    = btn.dataset.grantId     || '';
        var grantTitle = btn.dataset.grantTitle  || '';
        var funding    = btn.dataset.grantFunding || '';
        var fundingRaw = parseFloat(btn.dataset.grantFundingRaw) || 0;
        var eligibility= btn.dataset.grantEligibility || '';
        var deadline   = btn.dataset.grantDeadline   || '';

        // Inject hidden fields
        document.getElementById('propGrantId').value = grantId;

        // Read-only display of grant name
        document.getElementById('propGrantName').value = grantTitle;
        document.getElementById('proposalModalGrantName').textContent = grantTitle;

        // Budget hint
        var hint = document.getElementById('propBudgetHint');
        if (hint) hint.textContent = 'Maximum allowed: ' + funding;

        // Budget max attribute for HTML5 validation
        var budgetInput = document.getElementById('propRequestedBudget');
        if (budgetInput && fundingRaw > 0) budgetInput.setAttribute('max', fundingRaw);

        // Summary bar
        var bar = document.getElementById('proposalGrantSummaryBar');
        if (bar) {
            bar.innerHTML =
                _sumItem('Grant Program', grantTitle) +
                _sumItem('Max Funding', funding) +
                _sumItem('Deadline', deadline) +
                _sumItem('Eligibility', eligibility);
        }

        // Pre-fill lead proponent from session (PHP-injected)
        var propLeadEl = document.getElementById('propLeadProponent');
        if (propLeadEl && !propLeadEl.value.trim()) {
            propLeadEl.value = <?= json_encode($sessionUserName) ?>;
        }

        // Reset state
        document.getElementById('proposalAlert').style.display = 'none';
        document.getElementById('proposalForm').reset();
        document.getElementById('propGrantId').value = grantId;
        document.getElementById('propGrantName').value = grantTitle;
        if (budgetInput && fundingRaw > 0) budgetInput.setAttribute('max', fundingRaw);
        if (hint) hint.textContent = 'Maximum allowed: ' + funding;
        if (propLeadEl) propLeadEl.value = <?= json_encode($sessionUserName) ?>;
        var submitBtn = document.getElementById('btnProposalSubmit');
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-paper-plane me-1"></i>Submit Proposal';

        fetchApplyToken();
        propModal.show();
    }

    function _sumItem(label, value) {
        return '<div style="display:flex;flex-direction:column;gap:.05rem;min-width:0;">' +
               '<span style="font-size:.62rem;font-weight:800;letter-spacing:.05em;text-transform:uppercase;color:var(--sms-text-muted);">' + escHtml(label) + '</span>' +
               '<span style="font-size:.82rem;font-weight:700;color:var(--sms-heading);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:200px;" title="' + escHtml(value) + '">' + escHtml(value) + '</span>' +
               '</div>';
    }

    document.querySelectorAll('.go-btn-apply:not(.go-btn-disabled)').forEach(function(b){
        b.addEventListener('click', function(){ openProposalModal(this); });
    });

    /* ── Proposal form submit ────────────────────────────────────────── */
    var proposalFormEl = document.getElementById('proposalForm');
    if (proposalFormEl) {
        proposalFormEl.addEventListener('submit', function(e){
            e.preventDefault();
            document.getElementById('proposalAlert').style.display = 'none';

            var grantId      = document.getElementById('propGrantId').value;
            var proponent    = document.getElementById('propLeadProponent').value.trim();
            var title        = document.getElementById('propResearchTitle').value.trim();
            var college      = document.getElementById('propCollegeDept').value.trim();
            var budget       = parseFloat(document.getElementById('propRequestedBudget').value);
            var budgetMax    = parseFloat(document.getElementById('propRequestedBudget').getAttribute('max')||'0');
            var abstractVal  = document.getElementById('propAbstract').value.trim();
            var objectives   = document.getElementById('propObjectives').value.trim();
            var pdfInput     = document.getElementById('propProposalPdf');
            var token        = document.getElementById('propApplyToken').value;

            if (!grantId || parseInt(grantId,10)<=0) { showPropAlert('No grant selected. Please close and try again.'); return; }
            if (!proponent)  { showPropAlert('Lead proponent name is required.'); return; }
            if (!title)      { showPropAlert('Research project title is required.'); return; }
            if (!college)    { showPropAlert('Academic college / department is required.'); return; }
            if (isNaN(budget)||budget<=0){ showPropAlert('Requested budget must be greater than zero.'); return; }
            if (budgetMax>0 && budget>budgetMax) {
                showPropAlert('Requested budget cannot exceed the grant funding cap of '+fmtCurrency(budgetMax)+'.'); return;
            }
            if (!abstractVal)  { showPropAlert('Executive abstract is required.'); return; }
            if (!objectives)   { showPropAlert('Research objectives are required.'); return; }
            if (!pdfInput.files||!pdfInput.files.length) { showPropAlert('Proposal document (PDF/DOC/DOCX) is required.'); return; }
            if (!token) { showPropAlert('Submission token missing. Please wait a moment and try again.'); return; }

            var submitBtn = document.getElementById('btnProposalSubmit');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Submitting…';

            var fd = new FormData(proposalFormEl);
            fd.set('action','submit_proposal');

            fetch(apiBase, {method:'POST', credentials:'same-origin', body:fd})
            .then(function(r){return r.json();})
            .then(function(data){
                if (data.success) {
                    getPropModal().hide();
                    // Populate success modal
                    var stEl = document.getElementById('successGrantTitle');
                    var saEl = document.getElementById('successSubmittedAt');
                    if (stEl) stEl.textContent = document.getElementById('proposalModalGrantName').textContent;
                    if (saEl) saEl.textContent = nowLabel();
                    new bootstrap.Modal(document.getElementById('proposalSuccessModal')).show();
                    // Optimistically update application count badge
                    _incrementCardCount(grantId);
                } else {
                    showPropAlert(data.message||'Submission failed. Please try again.');
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = '<i class="fas fa-paper-plane me-1"></i>Submit Proposal';
                    fetchApplyToken();
                }
            })
            .catch(function(){
                showPropAlert('Network error. Please check your connection and try again.');
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="fas fa-paper-plane me-1"></i>Submit Proposal';
            });
        });
    }

    function showPropAlert(msg){
        var el = document.getElementById('proposalAlert');
        el.style.display = '';
        el.style.background = 'rgba(239,68,68,.08)';
        el.style.color      = '#b91c1c';
        el.innerHTML = '<i class="fas fa-exclamation-triangle me-1"></i>' + escHtml(msg);
    }

    function _incrementCardCount(grantId){
        allCards().forEach(function(card){
            var btn = card.querySelector('.go-btn-apply[data-grant-id="'+grantId+'"]');
            if (!btn) return;
            var numEl = card.querySelector('.go-card-app-count .count-num');
            if (numEl) numEl.textContent = (parseInt(numEl.textContent,10)||0)+1;
        });
    }

}); // end DOMContentLoaded
</script>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>