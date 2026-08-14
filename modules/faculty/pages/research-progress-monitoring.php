<?php
/**
 * Faculty Module - Research Progress Monitoring
 * Detailed progress monitoring for a specific assigned research group
 */

$pageTitle = 'Research Progress Monitoring';
$activeModule = 'faculty';
$activePage = 'research-progress-monitoring';

$pageBannerIcon        = 'fa-chart-line';
$pageBannerDescription = 'Detailed progress monitoring for your assigned research group.';
$hideModulePageBanner  = true;

require_once __DIR__ . '/../../../config/config.php';
require_once __DIR__ . '/../../../includes/breadcrumbs.php';
require_once __DIR__ . '/../../../modules/crad/config/config.php';
require_once __DIR__ . '/../../../modules/crad/includes/research-progress-helpers.php';

$breadcrumbs = [
    ['label' => 'Faculty',                      'url' => BASE_URL . '/modules/faculty/index.php'],
    ['label' => 'My Research Groups',           'url' => BASE_URL . '/modules/faculty/pages/my-research-groups.php'],
    ['label' => 'Research Progress Monitoring', 'url' => null],
];

require_once __DIR__ . '/../../../includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);

// Module check
try {
    $crad = cradDb();
    $tablesCheck = $crad->query("SHOW TABLES LIKE 'research_plans'")->fetch();
    if (!$tablesCheck) throw new Exception('Not installed.');
} catch (Throwable $e) {
    echo '<div class="alert alert-warning m-3"><i class="fas fa-exclamation-triangle me-2"></i><strong>Module Not Installed</strong><br>The Research Progress module is not yet installed.</div>';
    require_once ROOT_PATH . '/includes/layout-end.php';
    exit;
}

// No group param
$groupNumber = $_GET['group'] ?? '';
if (empty($groupNumber)) { ?>
<div class="glass-dashboard"><div class="glass-board">
    <div class="glass-panel"><div class="glass-panel-body rm-empty">
        <div class="rm-empty-icon"><i class="fas fa-exclamation-triangle" style="color:#f59e0b;"></i></div>
        <h6>No Research Group Specified</h6>
        <p>Please select a research group to view its progress monitoring details.</p>
        <a href="<?= BASE_URL ?>/modules/faculty/pages/my-research-groups.php" class="btn btn-primary mt-3">
            <i class="fas fa-users me-2"></i>View My Research Groups
        </a>
    </div></div>
</div></div>
<?php require_once ROOT_PATH . '/includes/layout-end.php'; exit; }

$adviserUserId = (int) ($_SESSION['user_id'] ?? 0);
$adviserEmail  = rpCurrentUserEmail();

// Verify adviser
try {
    $researchGroup = rpGetAssignedResearchGroupForAdviser($crad, $adviserUserId, $adviserEmail, $groupNumber);
} catch (PDOException $e) {
    error_log('Group query error: ' . $e->getMessage());
    $researchGroup = null;
}

if (!$researchGroup) { ?>
<div class="glass-dashboard"><div class="glass-board">
    <div class="glass-panel"><div class="glass-panel-body rm-empty">
        <div class="rm-empty-icon"><i class="fas fa-ban" style="color:#ef4444;"></i></div>
        <h6>Access Denied</h6>
        <p>This research group is not assigned to you or does not exist.</p>
        <a href="<?= BASE_URL ?>/modules/faculty/pages/my-research-groups.php" class="btn btn-primary mt-3">
            <i class="fas fa-users me-2"></i>View My Research Groups
        </a>
    </div></div>
</div></div>
<?php require_once ROOT_PATH . '/includes/layout-end.php'; exit; }

$groupId = (int) $researchGroup['id'];
$plan    = rpGetResearchPlan($crad, $groupId);

// Milestones
try {
    if (!empty($plan['id'])) {
        $milestonesStmt = $crad->prepare("
            SELECT rm.*,
                   (SELECT COUNT(*) FROM research_progress_updates rpu
                    WHERE rpu.milestone_id = rm.id
                      AND rpu.milestone_status = 'Submitted for Review') AS pending_count
            FROM research_milestones rm
            WHERE rm.research_plan_id = ?
            ORDER BY rm.milestone_order ASC
        ");
        $milestonesStmt->execute([(int) $plan['id']]);
        $milestones = $milestonesStmt->fetchAll(PDO::FETCH_ASSOC);
    } else {
        $milestones = rpGetMilestonesForPlan($crad, null);
    }
} catch (PDOException $e) { $milestones = []; }

// Recent updates (last 5)
try {
    $recentUpdatesStmt = $crad->prepare("
        SELECT rpu.*, rm.milestone_name
        FROM research_progress_updates rpu
        LEFT JOIN research_milestones rm ON rm.id = rpu.milestone_id
        WHERE rpu.research_group_id = ?
        ORDER BY rpu.submitted_at DESC
        LIMIT 5
    ");
    $recentUpdatesStmt->execute([$groupId]);
    $recentUpdates = $recentUpdatesStmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) { $recentUpdates = []; }

$overallProgress  = (float) ($plan['overall_progress'] ?? 0);
$totalMilestones  = count($milestones);
$doneMilestones   = 0;
$pendingTotal     = 0;
foreach ($milestones as $m) {
    if (in_array($m['status'], ['Approved', 'Completed'])) $doneMilestones++;
    $pendingTotal += (int) $m['pending_count'];
}

$statusColors = [
    'Not Started'          => ['color' => '#94a3b8', 'bg' => '#f1f5f9', 'icon' => 'circle'],
    'In Progress'          => ['color' => '#f59e0b', 'bg' => '#fef3c7', 'icon' => 'spinner'],
    'Submitted for Review' => ['color' => '#3b82f6', 'bg' => '#dbeafe', 'icon' => 'clock'],
    'Revision Requested'   => ['color' => '#ef4444', 'bg' => '#fee2e2', 'icon' => 'exclamation-triangle'],
    'Approved'             => ['color' => '#10b981', 'bg' => '#d1fae5', 'icon' => 'check-circle'],
    'Completed'            => ['color' => '#059669', 'bg' => '#d1fae5', 'icon' => 'check-double'],
];

$progressColor = $overallProgress >= 80 ? '#10b981' : ($overallProgress >= 40 ? '#f59e0b' : '#3b82f6');
?>

<div class="glass-dashboard" data-live-update-page="progress-monitoring" data-group-number="<?= htmlspecialchars($groupNumber) ?>">
    <div class="glass-board">

        <!-- ── Page Header ───────────────────────────────── -->
        <div class="rm-page-header">
            <div class="rm-page-header-left">
                <h4><i class="fas fa-chart-line me-2" style="color:var(--sms-primary);"></i>Research Progress</h4>
                <p>Detailed monitoring for this research group</p>
            </div>
            <div class="rm-page-header-right">
                <div class="rm-live-badge"><span class="rm-live-dot"></span>Live</div>
                <a href="<?= BASE_URL ?>/modules/faculty/pages/my-research-groups.php" class="rm-back-btn">
                    <i class="fas fa-arrow-left"></i>My Groups
                </a>
            </div>
        </div>

        <!-- ── Group Hero ────────────────────────────────── -->
        <div class="rm-group-hero">
            <div class="rm-group-hero-body">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <span class="badge"><?= htmlspecialchars($researchGroup['group_number']) ?></span>
                    <span class="badge"><?= htmlspecialchars($researchGroup['academic_year']) ?></span>
                </div>
                <h5 class="mt-2 mb-1"><?= htmlspecialchars($researchGroup['group_name']) ?></h5>
                <p><?= htmlspecialchars($researchGroup['research_title']) ?></p>

                <!-- Hero progress bar -->
                <div class="rm-hero-progress">
                    <div class="rm-hero-progress-header">
                        <span class="rm-hero-progress-label">Overall Progress</span>
                        <span class="rm-hero-progress-pct" data-overall-progress-text><?= number_format($overallProgress, 1) ?>%</span>
                    </div>
                    <div class="rm-hero-progress-track">
                        <div class="rm-hero-progress-fill" style="width:<?= $overallProgress ?>%;" data-overall-progress-bar></div>
                    </div>
                </div>

                <!-- Hero stats -->
                <div class="rm-group-hero-stats">
                    <div class="rm-hero-stat">
                        <span class="rm-hero-stat-value"><?= $totalMilestones ?></span>
                        <span class="rm-hero-stat-label">Total Milestones</span>
                    </div>
                    <div class="rm-hero-stat">
                        <span class="rm-hero-stat-value"><?= $doneMilestones ?></span>
                        <span class="rm-hero-stat-label">Completed</span>
                    </div>
                    <div class="rm-hero-stat">
                        <span class="rm-hero-stat-value"><?= $pendingTotal ?></span>
                        <span class="rm-hero-stat-label">Pending Reviews</span>
                    </div>
                    <?php if (!empty($plan['current_stage'])): ?>
                    <div class="rm-hero-stat">
                        <span class="rm-hero-stat-value" style="font-size:1rem;font-weight:700;">
                            <?= htmlspecialchars($plan['current_stage']) ?>
                        </span>
                        <span class="rm-hero-stat-label">Current Stage</span>
                    </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>

        <!-- ── Main Grid ─────────────────────────────────── -->
        <div class="row g-4">

            <!-- Milestone Progress Table -->
            <div class="col-lg-8">
                <div class="glass-panel h-100">
                    <div class="glass-panel-body">
                        <div class="glass-panel-head">
                            <div>
                                <h5 class="glass-panel-title">Milestone Progress</h5>
                                <p class="glass-panel-sub">Stage-by-stage research development</p>
                            </div>
                            <a href="<?= BASE_URL ?>/modules/faculty/pages/milestones-overview.php?group=<?= urlencode($groupNumber) ?>"
                               class="rm-back-btn" style="font-size:0.8rem;">
                                <i class="fas fa-external-link-alt"></i>Full View
                            </a>
                        </div>

                        <?php if (!empty($milestones)): ?>
                        <div class="table-responsive">
                            <table class="table align-middle rm-milestone-table mb-0">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Milestone</th>
                                        <th style="min-width:130px;">Progress</th>
                                        <th>Status</th>
                                        <th>Pending</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($milestones as $m):
                                        $mp   = (float) $m['progress_percentage'];
                                        $sc   = $statusColors[$m['status']] ?? $statusColors['Not Started'];
                                        $pend = (int) $m['pending_count'];
                                    ?>
                                    <tr data-milestone-id="<?= $m['id'] ?>">
                                        <td>
                                            <span style="display:inline-flex;align-items:center;justify-content:center;
                                                width:26px;height:26px;border-radius:7px;
                                                background:var(--sms-surface-muted);
                                                font-size:0.75rem;font-weight:800;color:var(--sms-text-muted);">
                                                <?= $m['milestone_order'] ?>
                                            </span>
                                        </td>
                                        <td style="font-weight:700;color:var(--sms-heading);max-width:200px;">
                                            <?= htmlspecialchars($m['milestone_name']) ?>
                                            <?php if (!empty($m['target_date'])): ?>
                                                <div style="font-size:0.72rem;color:var(--sms-text-muted);font-weight:600;margin-top:2px;">
                                                    <i class="fas fa-calendar-check me-1"></i><?= date('M d, Y', strtotime($m['target_date'])) ?>
                                                </div>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rm-progress-track flex-grow-1" style="height:8px;max-width:90px;min-width:60px;">
                                                    <div class="rm-progress-fill" style="width:<?= $mp ?>%;background:<?= $sc['color'] ?>;"></div>
                                                </div>
                                                <span style="font-size:0.82rem;font-weight:800;color:<?= $sc['color'] ?>;min-width:38px;">
                                                    <?= number_format($mp, 0) ?>%
                                                </span>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="rm-status-pill" style="background:<?= $sc['bg'] ?>;color:<?= $sc['color'] ?>;">
                                                <i class="fas fa-<?= $sc['icon'] ?>"></i>
                                                <?= htmlspecialchars($m['status']) ?>
                                            </span>
                                        </td>
                                        <td>
                                            <?php if ($pend > 0): ?>
                                                <a href="<?= BASE_URL ?>/modules/faculty/pages/submitted-updates.php?group=<?= urlencode($groupNumber) ?>&milestone_id=<?= $m['id'] ?>"
                                                   class="badge bg-warning text-dark text-decoration-none"
                                                   style="font-size:0.75rem;padding:0.3rem 0.6rem;">
                                                    <i class="fas fa-clock me-1"></i><?= $pend ?>
                                                </a>
                                            <?php else: ?>
                                                <span class="text-muted" style="font-size:0.85rem;">—</span>
                                            <?php endif; ?>
                                        </td>
                                    </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                        <?php else: ?>
                            <div class="rm-empty" style="padding:2rem 1rem;">
                                <div class="rm-empty-icon"><i class="fas fa-tasks"></i></div>
                                <h6>No Milestones Yet</h6>
                                <p>Milestones have not been initialized for this group.</p>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <!-- Right column: quick stats + recent activity -->
            <div class="col-lg-4 d-flex flex-column gap-4">

                <!-- Quick Action Cards -->
                <div class="glass-panel">
                    <div class="glass-panel-body">
                        <h6 class="glass-panel-title mb-3">Quick Actions</h6>
                        <div class="d-flex flex-column gap-2">
                            <a href="<?= BASE_URL ?>/modules/faculty/pages/submitted-updates.php?group=<?= urlencode($groupNumber) ?>"
                               class="rm-primary-action" style="justify-content:flex-start;">
                                <i class="fas fa-inbox"></i>
                                Review Updates
                                <?php if ($pendingTotal > 0): ?>
                                    <span class="badge bg-warning text-dark ms-auto"><?= $pendingTotal ?></span>
                                <?php endif; ?>
                            </a>
                            <a href="<?= BASE_URL ?>/modules/faculty/pages/milestones-overview.php?group=<?= urlencode($groupNumber) ?>"
                               class="rm-sec-action" style="justify-content:flex-start;padding:0.6rem 0.85rem;">
                                <i class="fas fa-tasks"></i>Milestone Details
                            </a>
                            <a href="<?= BASE_URL ?>/modules/faculty/pages/adviser-feedback-history.php?group=<?= urlencode($groupNumber) ?>"
                               class="rm-sec-action" style="justify-content:flex-start;padding:0.6rem 0.85rem;">
                                <i class="fas fa-comments"></i>Feedback History
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Recent Updates Feed -->
                <div class="glass-panel flex-grow-1">
                    <div class="glass-panel-body">
                        <div class="glass-panel-head">
                            <div>
                                <h5 class="glass-panel-title">Recent Activity</h5>
                                <p class="glass-panel-sub">Latest submissions</p>
                            </div>
                        </div>

                        <?php if (!empty($recentUpdates)): ?>
                            <div class="d-flex flex-column gap-3" data-recent-updates-container>
                            <?php foreach ($recentUpdates as $u):
                                $uStatus = $u['milestone_status'] ?? 'In Progress';
                                $uSC = $statusColors[$uStatus] ?? $statusColors['In Progress'];
                            ?>
                                <div style="padding-bottom:0.85rem;border-bottom:1px solid var(--sms-border-soft);">
                                    <div class="d-flex align-items-start justify-content-between gap-2 mb-1">
                                        <div style="font-weight:700;font-size:0.88rem;color:var(--sms-heading);flex:1;min-width:0;
                                                    display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                                            <?= htmlspecialchars($u['update_title']) ?>
                                        </div>
                                        <div style="font-size:1.1rem;font-weight:800;color:<?= $uSC['color'] ?>;flex-shrink:0;">
                                            <?= number_format((float)$u['new_progress'], 0) ?>%
                                        </div>
                                    </div>
                                    <?php if ($u['milestone_name']): ?>
                                        <div style="font-size:0.75rem;color:var(--sms-text-muted);font-weight:600;margin-bottom:0.3rem;">
                                            <i class="fas fa-bookmark me-1"></i><?= htmlspecialchars($u['milestone_name']) ?>
                                        </div>
                                    <?php endif; ?>
                                    <div class="d-flex align-items-center justify-content-between gap-2">
                                        <div style="font-size:0.7rem;color:var(--sms-text-muted);">
                                            <i class="fas fa-clock me-1"></i>
                                            <?= date('M d, g:i A', strtotime($u['submitted_at'])) ?>
                                        </div>
                                        <span class="rm-status-pill" style="background:<?= $uSC['bg'] ?>;color:<?= $uSC['color'] ?>;font-size:0.65rem;padding:0.18rem 0.55rem;">
                                            <?= htmlspecialchars($uStatus) ?>
                                        </span>
                                    </div>
                                    <div class="mt-2">
                                        <a href="<?= BASE_URL ?>/modules/faculty/pages/submitted-updates.php?group=<?= urlencode($groupNumber) ?>&update_id=<?= $u['id'] ?>"
                                           style="font-size:0.78rem;font-weight:700;color:var(--sms-primary);text-decoration:none;">
                                            <i class="fas fa-eye me-1"></i>Review →
                                        </a>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                            </div>
                            <div class="mt-3">
                                <a href="<?= BASE_URL ?>/modules/faculty/pages/submitted-updates.php?group=<?= urlencode($groupNumber) ?>"
                                   class="rm-primary-action" style="font-size:0.82rem;">
                                    <i class="fas fa-inbox"></i>View All Updates
                                </a>
                            </div>
                        <?php else: ?>
                            <div class="rm-empty" style="padding:1.5rem 0;">
                                <div class="rm-empty-icon" style="width:48px;height:48px;font-size:1.2rem;"><i class="fas fa-inbox"></i></div>
                                <p style="margin:0;font-size:0.85rem;">No updates submitted yet</p>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>

            </div>
        </div>

        <!-- Live refresh bar -->
        <div class="rm-refresh-bar" id="rmRefreshBar">
            <i class="fas fa-sync-alt rm-refresh-icon" id="rmRefreshIcon"></i>
            <span id="rmRefreshText">Last updated: <?= date('g:i:s A') ?></span>
        </div>

    </div>
</div>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
