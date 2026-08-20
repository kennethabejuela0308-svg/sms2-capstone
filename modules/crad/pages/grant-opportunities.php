<?php
/**
 * SMS 2 - CORE SYSTEM · Grant Opportunities
 * Module: CRAD
 *
 * CRAD Officer (grant administrator) view — MANAGES PUBLISHED GRANT CALLS.
 *
 * The CRAD Officer creates and publishes grant calls for eligible researchers.
 * This page intentionally has NO researcher "Apply Now" workflow: the proposal
 * submission flow belongs to eligible Faculty/Student researcher accounts only.
 * All publish logic lives in grant-management.php (publish_opportunity action).
 */
require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';
require_once __DIR__ . '/../includes/grant-helpers.php';

requireAuth();

$roleKey = getCurrentUserRoleKey();
if (!in_array($roleKey, ['crad_officer', 'superadmin', 'admin'], true)) {
    header('Location: ' . BASE_URL . '/dashboard/index.php');
    exit;
}

$pageTitle             = 'Grant Opportunities';
$activeModule          = 'crad';
$activePage            = 'grant-opportunities';
$pageBannerIcon        = 'fa-hand-holding-usd';
$pageBannerDescription = 'Manage and publish research grant calls for eligible faculty and student researchers.';

$breadcrumbs = [
    ['label' => 'CRAD',               'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Grant Opportunities', 'url' => null],
];

require_once ROOT_PATH . '/includes/breadcrumbs.php';

// ── Data ──────────────────────────────────────────────────────────────────────
$crad          = cradDb();
$opportunities = [];
$dbError       = '';

if ($crad) {
    try {
        grantEnsureTables($crad);
        $opportunities = grantGetOpportunities($crad);
    } catch (Throwable $e) {
        $dbError = htmlspecialchars($e->getMessage());
        error_log('grant-opportunities: ' . $e->getMessage());
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

function goEligibilityCategory(string $eligibility): array
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

function goFilterPills(array $opportunities): array
{
    $order    = ['faculty', 'student', 'open', 'internal', 'external', 'other'];
    $labelMap = ['faculty'=>'Faculty Research','student'=>'Student Capstone','open'=>'Faculty & Student',
                 'internal'=>'Internal / Seed','external'=>'CHED / External','other'=>'Other'];
    $counts   = [];
    foreach ($opportunities as $o) {
        $cat = goEligibilityCategory((string) ($o['eligibility'] ?? ''))['cat'];
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

$filterPills = goFilterPills($opportunities);

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

<div class="mpl" data-mpl data-grant-opp-page>

<!-- PAGE HEADER -->
<div class="go-page-header">
    <div class="go-page-header-text">
        <h1>
            <i class="fas fa-hand-holding-usd me-2" style="color:var(--sms-primary);font-size:1.1rem;" aria-hidden="true"></i>
            Grant Opportunities &amp; Funding Programs
        </h1>
        <p>Internal institutional grants and external funding calls &mdash; CHED, DOST, industry, and institutional programs.</p>
    </div>
    <div class="go-page-header-actions">
        <button type="button" class="mpl-btn mpl-btn-primary" id="btnOpenPublishForm">
            <i class="fas fa-plus" aria-hidden="true"></i>Publish New Grant Call
        </button>
    </div>
</div>

<?php if ($dbError === ''): ?>

<!-- STAT BADGES -->
<div class="go-stat-row" aria-label="Grant opportunity summary">
    <div class="go-stat-badge total">
        <span class="go-stat-badge-icon"><i class="fas fa-layer-group"></i></span>
        Total&nbsp;<strong><?= $total ?></strong>
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
    <h3>No Grant Opportunities Yet</h3>
    <p>Publish a new grant call to make research funding opportunities available to eligible researchers.</p>
    <button type="button" class="mpl-btn mpl-btn-primary" id="btnOpenPublishFormEmpty">
        <i class="fas fa-plus" aria-hidden="true"></i>Publish First Grant Call
    </button>
</div>

<?php else: ?>
<!-- CARD GRID -->
<div class="go-card-grid" id="goCardGrid">
<?php foreach ($opportunities as $opp):
    $catInfo      = goEligibilityCategory((string) ($opp['eligibility'] ?? ''));
    $cat          = $catInfo['cat'];
    $catLabel     = $catInfo['label'];
    $statusRaw    = (string) ($opp['status'] ?? 'Open for Application');
    $appCount     = (int) ($opp['application_count'] ?? 0);
    $fundingRaw   = (float) $opp['max_funding_cap'];
    $fundingFmt   = '₱' . number_format($fundingRaw, 0);
    $deadlineTs   = strtotime((string) $opp['application_deadline']);
    $deadlineFmt  = date('M j, Y', $deadlineTs);
    $deadlineIso  = date('Y-m-d', $deadlineTs);
    $isPast       = $deadlineTs < mktime(0, 0, 0);
    $publishedFmt = date('M j, Y', strtotime((string) $opp['created_at']));
    $publishedBy  = trim((string) ($opp['created_by_name'] ?? ''));
    $statusKey    = match ($statusRaw) { 'Open for Application' => 'open', 'Expired' => 'expired', default => 'closed' };
    $catIcon      = match ($cat) { 'faculty' => 'fa-chalkboard-teacher', 'student' => 'fa-user-graduate',
                                   'external' => 'fa-globe', 'internal' => 'fa-university',
                                   'open' => 'fa-users', default => 'fa-tag' };
    $searchData   = strtolower(($opp['funding_title'] ?? '') . ' ' . ($opp['eligibility'] ?? '') . ' ' . ($opp['college_program'] ?? '') . ' ' . $statusRaw);
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
    </div>
</article>
<?php endforeach; ?>
</div><!-- /#goCardGrid -->
<nav class="go-pagination" id="goPagination" aria-label="Grant opportunities pages"></nav>
<?php endif; // empty($opportunities) ?>
<?php endif; // $dbError === '' ?>
</div><!-- /.mpl -->


<!-- PUBLISH NEW GRANT CALL MODAL -->
<div class="modal fade" id="publishFormModal" tabindex="-1" aria-labelledby="publishFormTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:600px;width:min(600px,95vw);">
        <div class="modal-content" style="border-radius:14px;overflow:hidden;">
            <div class="modal-header"
                 style="background:var(--sms-primary,#2563eb);border-bottom:none;padding:1rem 1.5rem;">
                <h5 class="modal-title fw-bold" id="publishFormTitle"
                    style="color:#fff;font-size:1rem;margin:0;">
                    <i class="fas fa-hand-holding-usd me-2" aria-hidden="true"></i>
                    Publish New Funding Program Call
                </h5>
                <button type="button" class="btn-close btn-close-white" id="btnClosePublishForm"
                        data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div id="publishFormAlert" class="mpl-alert"
                 style="display:none;margin:1rem 1.5rem 0;border-radius:8px;" role="alert"></div>
            <div class="modal-body" style="padding:1.25rem 1.5rem .5rem;">
                <form id="publishGrantForm" novalidate autocomplete="off">
                    <input type="hidden" id="publishToken" name="token" value="">
                    <div class="go-form-group mb-3">
                        <label for="fundingTitle" class="go-form-label">Funding Title <span class="go-required">*</span></label>
                        <input type="text" id="fundingTitle" name="funding_title" class="go-form-input"
                               maxlength="300" required placeholder="e.g. BESTLINK Faculty Seed Research Grant 2026">
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-sm-6">
                            <div class="go-form-group">
                                <label for="maxFundingCap" class="go-form-label">Maximum Funding Cap (₱) <span class="go-required">*</span></label>
                                <input type="number" id="maxFundingCap" name="max_funding_cap"
                                       class="go-form-input" min="1" step="0.01" required placeholder="e.g. 350000">
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="go-form-group">
                                <label for="appDeadline" class="go-form-label">Application Deadline <span class="go-required">*</span></label>
                                <input type="date" id="appDeadline" name="application_deadline"
                                       class="go-form-input" required>
                            </div>
                        </div>
                    </div>
                    <div class="go-form-group mb-3">
                        <label for="eligibility" class="go-form-label">Target Eligibility <span class="go-required">*</span></label>
                        <select id="eligibility" name="eligibility" class="go-form-input" required>
                            <option value="Open">Open (All Eligible Researchers)</option>
                            <option value="Faculty Researchers">Faculty Researchers</option>
                            <option value="Student Researchers">Student Researchers</option>
                            <option value="Faculty &amp; Student">Faculty &amp; Student</option>
                            <option value="Specific College/Program">Specific College / Program</option>
                        </select>
                    </div>
                    <div class="go-form-group mb-3" id="collegeProgramGroup" style="display:none;">
                        <label for="collegeProgram" class="go-form-label">College / Program <span class="go-required">*</span></label>
                        <input type="text" id="collegeProgram" name="college_program" class="go-form-input"
                               maxlength="200" placeholder="e.g. College of Computer Studies — BSIT">
                    </div>
                    <div class="go-form-group mb-3">
                        <label for="grantRequirements" class="go-form-label">Requirements <span class="go-required">*</span></label>
                        <textarea id="grantRequirements" name="requirements" class="go-form-input"
                                  rows="4" maxlength="2000" required
                                  placeholder="List the eligibility documents and submission requirements for applicants."></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer border-0" style="padding:.75rem 1.5rem 1.25rem;justify-content:flex-end;gap:.5rem;">
                <button type="button" class="btn btn-outline-secondary btn-sm px-4" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" form="publishGrantForm" id="btnPublishSubmit" class="btn btn-sms-primary btn-sm px-4">
                    <i class="fas fa-paper-plane me-1"></i>Publish Grant Call
                </button>
            </div>
        </div>
    </div>
</div>

<!-- PUBLISH CONFIRMATION MODAL (unchanged) -->
<div class="modal fade" id="publishConfirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" style="max-width:400px;">
        <div class="modal-content shadow" style="border-radius:14px;overflow:hidden;">
            <div class="modal-header border-0 pb-1">
                <h6 class="modal-title fw-bold">
                    <i class="fas fa-hand-holding-usd me-2" style="color:var(--sms-primary);"></i>Publish Grant Call?
                </h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center py-3" style="font-size:.9rem;color:var(--sms-text);">
                Are you sure you want to publish this grant opportunity?<br>
                <span style="font-size:.82rem;color:var(--sms-text-muted);">
                    It will immediately be visible and open for applications.
                </span>
            </div>
            <div class="modal-footer border-0 justify-content-center gap-2 pt-0 pb-4">
                <button type="button" class="btn btn-outline-secondary btn-sm px-4" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-sms-primary btn-sm px-4" id="btnConfirmPublish">
                    <i class="fas fa-paper-plane me-1"></i>Yes, Publish Grant Call
                </button>
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
       PUBLISH NEW GRANT CALL
       ════════════════════════════════════════════════════════════════════ */
    function fetchPublishToken(){
        fetch(apiBase+'?action=generate_token',{credentials:'same-origin',cache:'no-store',headers:{'Accept':'application/json'}})
        .then(function(r){return r.ok?r.json():null;})
        .then(function(d){if(d&&d.token)document.getElementById('publishToken').value=d.token;})
        .catch(function(){});
    }

    // Lazy: create Bootstrap Modal instance only when first needed.
    var _publishModalInstance = null;
    function getPublishModal() {
        if (!_publishModalInstance) {
            var el = document.getElementById('publishFormModal');
            if (el) _publishModalInstance = new bootstrap.Modal(el, {backdrop:true,keyboard:true});
        }
        return _publishModalInstance;
    }

    function openPublishForm(){
        document.getElementById('publishFormAlert').style.display='none';
        document.getElementById('publishGrantForm').reset();
        document.getElementById('collegeProgramGroup').style.display='none';
        document.getElementById('collegeProgram').required=false;
        var b=document.getElementById('btnPublishSubmit');
        b.disabled=false; b.innerHTML='<i class="fas fa-paper-plane me-1"></i>Publish Grant Call';
        fetchPublishToken(); getPublishModal().show();
    }

    document.getElementById('btnOpenPublishForm').addEventListener('click', openPublishForm);
    var btnEmpty = document.getElementById('btnOpenPublishFormEmpty');
    if (btnEmpty) btnEmpty.addEventListener('click', openPublishForm);

    document.getElementById('eligibility').addEventListener('change',function(){
        var show=this.value==='Specific College/Program';
        document.getElementById('collegeProgramGroup').style.display=show?'':'none';
        document.getElementById('collegeProgram').required=show;
    });

    var pendingPublish = null;

    document.getElementById('publishGrantForm').addEventListener('submit',function(e){
        e.preventDefault();
        document.getElementById('publishFormAlert').style.display='none';
        var title=document.getElementById('fundingTitle').value.trim();
        var cap=parseFloat(document.getElementById('maxFundingCap').value);
        var deadline=document.getElementById('appDeadline').value;
        var elig=document.getElementById('eligibility').value;
        var requirements=document.getElementById('grantRequirements').value.trim();
        if (!title)          { showPubAlert('Funding title is required.'); return; }
        if (isNaN(cap)||cap<=0){ showPubAlert('Maximum funding cap must be greater than zero.'); return; }
        if (!deadline)       { showPubAlert('Application deadline is required.'); return; }
        if (new Date(deadline+'T00:00:00')<=new Date()){ showPubAlert('Application deadline must be a future date.'); return; }
        if (elig==='Specific College/Program'&&!document.getElementById('collegeProgram').value.trim()){ showPubAlert('Please specify the college or program.'); return; }
        if (!requirements)   { showPubAlert('Requirements are required.'); return; }
        if (!document.getElementById('publishToken').value){ showPubAlert('Submission token missing. Please wait and try again.'); return; }
        pendingPublish = new FormData(document.getElementById('publishGrantForm'));
        pendingPublish.append('action','publish_opportunity');
        getPublishModal().hide();
        new bootstrap.Modal(document.getElementById('publishConfirmModal')).show();
    });

    document.getElementById('btnConfirmPublish').addEventListener('click',function(){
        bootstrap.Modal.getInstance(document.getElementById('publishConfirmModal')).hide();
        doPublish();
    });

    function doPublish(){
        if (!pendingPublish) return;
        var btn=document.getElementById('btnPublishSubmit');
        btn.disabled=true; btn.innerHTML='<span class="spinner-border spinner-border-sm me-1"></span>Publishing…';
        fetch(apiBase,{method:'POST',credentials:'same-origin',body:pendingPublish})
        .then(function(r){return r.json();})
        .then(function(data){
            if (data.success) { window.location.reload(); }
            else {
                getPublishModal().show();
                showPubAlert(data.message||'Failed to publish. Please try again.');
                btn.disabled=false; btn.innerHTML='<i class="fas fa-paper-plane me-1"></i>Publish Grant Call';
                fetchPublishToken(); pendingPublish=null;
            }
        })
        .catch(function(){
            getPublishModal().show();
            showPubAlert('Network error. Please check your connection and try again.');
            btn.disabled=false; btn.innerHTML='<i class="fas fa-paper-plane me-1"></i>Publish Grant Call';
            pendingPublish=null;
        });
    }

    function showPubAlert(msg){
        var el=document.getElementById('publishFormAlert');
        el.style.display=''; el.style.background='rgba(239,68,68,.08)'; el.style.color='#b91c1c';
        el.innerHTML='<i class="fas fa-exclamation-triangle me-1"></i>'+escHtml(msg);
    }

}); // end DOMContentLoaded
</script>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>