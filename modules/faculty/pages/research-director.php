<?php
require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/breadcrumbs.php';
require_once ROOT_PATH . '/modules/crad/config/config.php';

requireAuth();

$directorPages = [
    'overview' => ['title' => 'Overview', 'group' => 'Dashboard', 'icon' => 'fa-home'],
    'defense-scheduling-queue' => ['title' => 'Defense Scheduling Queue', 'group' => 'Defense Management', 'icon' => 'fa-list-alt'],
    'verify-research-defense' => ['title' => 'Verify Research for Defense', 'group' => 'Defense Management', 'icon' => 'fa-check-double'],
    'defense-schedule' => ['title' => 'Defense Schedule', 'group' => 'Defense Management', 'icon' => 'fa-calendar-check'],
    'ai-scheduling-optimizer' => ['title' => 'AI Scheduling Optimizer', 'group' => 'AI Scheduling', 'icon' => 'fa-magic'],
    'proposed-schedules' => ['title' => 'Proposed Schedules', 'group' => 'AI Scheduling', 'icon' => 'fa-calendar-plus'],
    'alternative-time-slots' => ['title' => 'Alternative Time Slots', 'group' => 'AI Scheduling', 'icon' => 'fa-clock'],
    'calendar' => ['title' => 'Calendar', 'group' => 'Schedule Management', 'icon' => 'fa-calendar-alt'],
    'venues' => ['title' => 'Venues', 'group' => 'Schedule Management', 'icon' => 'fa-map-marker-alt'],
    'finalize-defense-schedule' => ['title' => 'Finalize Defense Schedule', 'group' => 'Schedule Management', 'icon' => 'fa-clipboard-check'],
    'researchers' => ['title' => 'Researchers', 'group' => 'Defense Participants', 'icon' => 'fa-users'],
    'advisers' => ['title' => 'Advisers', 'group' => 'Defense Participants', 'icon' => 'fa-user-tie'],
    'panel-members' => ['title' => 'Panel Members', 'group' => 'Defense Participants', 'icon' => 'fa-users'],
    'notifications' => ['title' => 'Notifications', 'group' => 'Communication', 'icon' => 'fa-bell'],
    'defense-results' => ['title' => 'Defense Results', 'group' => 'Defense Results', 'icon' => 'fa-chart-bar'],
    'digital-scores' => ['title' => 'Digital Scores', 'group' => 'Defense Results', 'icon' => 'fa-poll'],
    'defense-history' => ['title' => 'Defense History', 'group' => 'Defense Results', 'icon' => 'fa-history'],
    'proceed-archiving' => ['title' => 'Proceed to Archiving', 'group' => 'Archiving', 'icon' => 'fa-folder-open'],
];

$view = strtolower(trim((string) ($_GET['view'] ?? 'overview')));
if ($view === '') {
    $view = 'overview';
}
if (!isset($directorPages[$view])) {
    $view = 'overview';
}

$pageInfo = $directorPages[$view];
$pageTitle = $pageInfo['title'];
$activeModule = 'faculty';
$activePage = $view === 'overview' ? '' : $view;
$breadcrumbs = [
    ['label' => 'Research Director', 'url' => BASE_URL . '/modules/faculty/pages/research-director.php'],
    ['label' => $pageTitle, 'url' => null],
];

$readyRows = [];
$scheduledRows = [];
$venueRows = [];
$venueMessage = null;
$crad = cradDb();
if ($crad) {
    try {
        $crad->exec(
            "CREATE TABLE IF NOT EXISTS research_venues (
                id INT UNSIGNED NOT NULL AUTO_INCREMENT,
                venue_name VARCHAR(160) NOT NULL,
                capacity INT UNSIGNED NOT NULL DEFAULT 0,
                venue_type VARCHAR(80) NOT NULL DEFAULT '',
                status VARCHAR(40) NOT NULL DEFAULT 'Available',
                created_by INT UNSIGNED DEFAULT NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (id),
                UNIQUE KEY uniq_research_venue_name (venue_name),
                KEY idx_research_venues_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
        );

        $seedVenue = $crad->prepare(
            "INSERT IGNORE INTO research_venues
                (venue_name, capacity, venue_type, status, created_at, updated_at)
             VALUES
                (?, ?, ?, 'Available', NOW(), NOW())"
        );
        foreach ([
            ['CRAD Conference Room', 30, 'Conference Room'],
            ['Research Room 1', 25, 'Research Room'],
            ['Research Room 2', 25, 'Research Room'],
            ['AVR Room', 100, 'Auditorium'],
            ['Computer Laboratory 1', 40, 'Laboratory'],
        ] as $venueSeed) {
            $seedVenue->execute($venueSeed);
        }
    } catch (Throwable $e) {
        error_log('Research director venue table setup failed: ' . $e->getMessage());
    }

    if ($view === 'venues' && $_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['venue_action'] ?? '') === 'update_status') {
        header('Content-Type: application/json; charset=utf-8');
        if (!csrfVerify()) {
            echo json_encode(['ok' => false, 'message' => 'Security token expired.']);
            exit;
        }
        $venueId     = (int) ($_POST['venue_id'] ?? 0);
        $newStatus   = trim((string) ($_POST['status'] ?? ''));
        $allowedSt   = ['Available', 'Reserved', 'Unavailable'];
        if ($venueId < 1 || !in_array($newStatus, $allowedSt, true)) {
            echo json_encode(['ok' => false, 'message' => 'Invalid venue or status.']);
            exit;
        }
        try {
            $upd = $crad->prepare(
                "UPDATE research_venues SET status = :status, updated_at = NOW() WHERE id = :id"
            );
            $upd->execute([':status' => $newStatus, ':id' => $venueId]);
            echo json_encode(['ok' => true, 'status' => $newStatus]);
        } catch (Throwable $e) {
            error_log('Research director update venue status failed: ' . $e->getMessage());
            echo json_encode(['ok' => false, 'message' => 'Database error.']);
        }
        exit;
    }

    if ($view === 'venues' && $_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['venue_action'] ?? '') === 'add') {
        if (!csrfVerify()) {
            $venueMessage = ['type' => 'danger', 'text' => 'Security token expired. Refresh the page and try again.'];
        } else {
            $venueName = trim((string) ($_POST['venue_name'] ?? ''));
            $venueType = trim((string) ($_POST['venue_type'] ?? ''));
            $capacity = max(0, (int) ($_POST['capacity'] ?? 0));
            $venueStatus = trim((string) ($_POST['status'] ?? 'Available'));
            $allowedStatuses = ['Available', 'Unavailable', 'Reserved'];

            if ($venueName === '' || $venueType === '' || $capacity < 1 || !in_array($venueStatus, $allowedStatuses, true)) {
                $venueMessage = ['type' => 'danger', 'text' => 'Complete the venue name, capacity, type, and valid status.'];
            } else {
                try {
                    $addVenue = $crad->prepare(
                        "INSERT INTO research_venues
                            (venue_name, capacity, venue_type, status, created_by, created_at, updated_at)
                         VALUES
                            (:venue_name, :capacity, :venue_type, :status, :created_by, NOW(), NOW())
                         ON DUPLICATE KEY UPDATE
                            capacity = VALUES(capacity),
                            venue_type = VALUES(venue_type),
                            status = VALUES(status),
                            updated_at = NOW()"
                    );
                    $addVenue->execute([
                        ':venue_name' => $venueName,
                        ':capacity' => $capacity,
                        ':venue_type' => $venueType,
                        ':status' => $venueStatus,
                        ':created_by' => (int) ($_SESSION['user_id'] ?? 0) ?: null,
                    ]);
                    $venueMessage = ['type' => 'success', 'text' => 'Venue saved successfully.'];
                } catch (Throwable $e) {
                    error_log('Research director add venue failed: ' . $e->getMessage());
                    $venueMessage = ['type' => 'danger', 'text' => 'Unable to save venue. Please try again.'];
                }
            }
        }
    }

    try {
        $readyStmt = $crad->query(
            "SELECT
                COALESCE(NULLIF(rg.group_name, ''), NULLIF(a.group_number, ''), CONCAT('Group ', LPAD(a.research_group_id, 2, '0'))) AS group_name,
                COALESCE(NULLIF(rg.research_title, ''), rp.research_title, 'Research title pending') AS research_title,
                a.adviser_name,
                '' AS panel_members,
                MAX(COALESCE(a.updated_at, a.created_at)) AS updated_at
             FROM research_adviser_assignments a
             JOIN research_proposals rp
               ON (a.proposal_id IS NOT NULL AND rp.id = a.proposal_id)
               OR (a.proposal_number IS NOT NULL AND a.proposal_number <> '' AND (rp.proposal_number = a.proposal_number OR rp.ref_code = a.proposal_number))
             LEFT JOIN research_groups rg
               ON (a.research_group_id IS NOT NULL AND rg.id = a.research_group_id)
               OR (a.group_number IS NOT NULL AND a.group_number <> '' AND rg.group_number = a.group_number)
               OR (rg.proposal_id = rp.id)
             WHERE a.assignment_status = 'Assigned'
             GROUP BY rp.id, group_name, research_title, a.adviser_name
             ORDER BY updated_at DESC"
        );
        $readyRows = $readyStmt->fetchAll() ?: [];
    } catch (Throwable $e) {
        error_log('Research director ready list failed: ' . $e->getMessage());
    }

    try {
        $scheduleStmt = $crad->query(
            "SELECT
                rds.group_number AS reference,
                rds.research_title,
                rds.research_group,
                COALESCE(NULLIF(rds.adviser_name, ''), '') AS adviser_name,
                COALESCE(NULLIF(rds.panel_members, ''), '') AS panel_members,
                COALESCE(NULLIF(rds.panel_chair, ''), 'For panel chair') AS panel_chair,
                COALESCE(NULLIF(rds.venue, ''), 'Ready for venue') AS venue,
                COALESCE(NULLIF(rds.status, ''), 'Ready for Scheduling') AS status,
                rds.defense_datetime,
                rds.updated_at,
                rp.status AS proposal_status,
                rp.progress AS proposal_progress
             FROM research_defense_schedules rds
             JOIN research_proposals rp
               ON (rds.proposal_id IS NOT NULL AND rp.id = rds.proposal_id)
               OR (
                    rds.proposal_number IS NOT NULL
                    AND rds.proposal_number <> ''
                    AND (rp.proposal_number = rds.proposal_number OR rp.ref_code = rds.proposal_number)
               )
             ORDER BY rds.updated_at DESC, rds.id DESC"
        );
        foreach (($scheduleStmt->fetchAll() ?: []) as $row) {
            $updated = strtotime((string) ($row['updated_at'] ?? '')) ?: time();
            $defenseTime = !empty($row['defense_datetime'])
                ? strtotime((string) $row['defense_datetime'])
                : false;
            $scheduledRows[] = [
                'reference' => (string) ($row['reference'] ?? ''),
                'title' => (string) (($row['research_title'] ?? '') ?: ($row['research_group'] ?? 'Research Group')),
                'subtitle' => (string) ($row['research_group'] ?? ''),
                'owner' => (string) ($row['panel_chair'] ?? 'For panel chair'),
                'detail' => (string) ($row['venue'] ?? 'Ready for venue'),
                'adviser' => (string) ($row['adviser_name'] ?? ''),
                'panel_members' => (string) ($row['panel_members'] ?? ''),
                'status' => (string) (($row['status'] ?? '') ?: 'Ready for Scheduling'),
                'proposal_status' => (string) ($row['proposal_status'] ?? ''),
                'proposal_progress' => (int) ($row['proposal_progress'] ?? 0),
                'updated' => $defenseTime ? date('M j, Y h:i A', $defenseTime) : date('M j, Y h:i A', $updated),
                'updated_raw' => (string) ($row['updated_at'] ?? ''),
                'defense_datetime_raw' => (string) ($row['defense_datetime'] ?? ''),
            ];
        }
    } catch (Throwable $e) {
        error_log('Research director schedule list failed: ' . $e->getMessage());
    }

    if ($view === 'venues') {
        try {
            $venueStmt = $crad->query(
                "SELECT id, venue_name, capacity, venue_type, status, updated_at
                 FROM research_venues
                 ORDER BY FIELD(status, 'Available', 'Reserved', 'Unavailable'), venue_name ASC"
            );
            $venueRows = $venueStmt->fetchAll() ?: [];
        } catch (Throwable $e) {
            error_log('Research director venue list failed: ' . $e->getMessage());
        }
    }
}

$directorUsesScheduleRows = in_array($view, ['verify-research-defense', 'defense-schedule'], true);

// Normalize venue rows for JS compatibility (add `updated` field)
$normalizedVenueRows = array_map(static function (array $row): array {
    $row['updated'] = date('M j, Y h:i A', strtotime((string) ($row['updated_at'] ?? 'now')));
    return $row;
}, $venueRows);

$displayRows = $view === 'venues' ? $normalizedVenueRows : ($directorUsesScheduleRows ? $scheduledRows : array_map(static function (array $row): array {
    return [
        'reference' => (string) ($row['group_name'] ?? 'Research Group'),
        'title' => (string) ($row['research_title'] ?? 'Research title pending'),
        'subtitle' => '',
        'owner' => (string) ($row['adviser_name'] ?? 'For adviser'),
        'detail' => (string) ($row['panel_members'] ?? 'For panel members'),
        'status' => 'Ready for Scheduling',
        'updated' => date('M j, Y h:i A', strtotime((string) ($row['updated_at'] ?? 'now'))),
    ];
}, $readyRows));

if ($directorUsesScheduleRows) {
    $displayRows = array_map(static function (array $row): array {
        $proposalStatus = trim((string) ($row['proposal_status'] ?? ''));
        $progress = (int) ($row['proposal_progress'] ?? 0);
        $adviser = trim((string) ($row['adviser'] ?? ''));
        $panel = trim((string) ($row['panel_members'] ?? ''));
        $panelChair = trim((string) ($row['owner'] ?? ''));
        $title = trim((string) ($row['title'] ?? ''));
        $group = trim((string) ($row['subtitle'] ?? ''));
        $status = trim((string) ($row['status'] ?? ''));

        $isApproved = strcasecmp($proposalStatus, 'Approved') === 0;
        $hasPanel = $panel !== '' || ($panelChair !== '' && strcasecmp($panelChair, 'For panel chair') !== 0);
        $hasRequiredInfo = $title !== '' && $group !== '' && $adviser !== '' && $hasPanel;

        $row['verification'] = [
            'proposal_complete' => $isApproved || $progress >= 100,
            'approval_approved' => $isApproved,
            'required_info_complete' => $hasRequiredInfo,
            'adviser_assigned' => $adviser !== '',
            'panel_assigned' => $hasPanel,
            'ready_for_defense' => $hasRequiredInfo && in_array(strtolower($status), ['ready for scheduling', 'scheduled', 'completed', 'passed'], true),
        ];
        $row['verification_status'] = in_array(false, $row['verification'], true) ? 'Needs Verification' : 'Verified';
        $row['proceed_url'] = BASE_URL . '/modules/faculty/pages/research-director.php?view=proposed-schedules'
            . '&group=' . rawurlencode((string) ($row['reference'] ?? ''))
            . '&title=' . rawurlencode((string) ($row['title'] ?? ''));
        return $row;
    }, $displayRows);
}

$readyCount = $directorUsesScheduleRows
    ? count(array_filter($scheduledRows, static fn (array $row): bool => strcasecmp((string) ($row['status'] ?? ''), 'Ready for Scheduling') === 0))
    : count($readyRows);
$scheduledCount = count($scheduledRows);
$needsVerification = $directorUsesScheduleRows ? 0 : max(0, $readyCount - $scheduledCount);
$completedCount = 0;
foreach ($scheduledRows as $row) {
    if (strcasecmp((string) ($row['status'] ?? ''), 'Completed') === 0 || strcasecmp((string) ($row['status'] ?? ''), 'Passed') === 0) {
        $completedCount++;
    }
}

if ($view === 'venues') {
    $readyCount = count($venueRows);
    $needsVerification = count(array_filter($venueRows, static fn (array $row): bool => strcasecmp((string) ($row['status'] ?? ''), 'Reserved') === 0));
    $scheduledCount = count(array_filter($venueRows, static fn (array $row): bool => strcasecmp((string) ($row['status'] ?? ''), 'Available') === 0));
    $completedCount = count(array_filter($venueRows, static fn (array $row): bool => strcasecmp((string) ($row['status'] ?? ''), 'Unavailable') === 0));
}

if ($view === 'verify-research-defense') {
    $needsVerification = count(array_filter($displayRows, static function (array $row): bool {
        return strcasecmp((string) ($row['verification_status'] ?? ''), 'Verified') !== 0;
    }));
}

if (($_GET['ajax'] ?? '') === 'director-schedules') {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'ok' => true,
        'rows' => $displayRows,
        'stats' => [
            'ready' => $readyCount,
            'needs_verification' => $needsVerification,
            'scheduled' => $scheduledCount,
            'completed' => $completedCount,
        ],
        'synced_at' => date('M j, Y h:i:s A'),
    ]);
    exit;
}

require_once ROOT_PATH . '/includes/layout-start.php';
renderBreadcrumbs($breadcrumbs);
?>

<style>
    /* ── Director page — fully theme-aware ─────────────────────────────── */
    .director-stats {
        display: grid;
        gap: .85rem;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        margin: 1rem 0;
    }
    .director-stat {
        align-items: center;
        background: var(--sms-surface);
        border: 1px solid var(--sms-border);
        border-radius: 14px;
        box-shadow: var(--sms-shadow-xs);
        display: flex;
        gap: .85rem;
        min-height: 76px;
        padding: .95rem 1rem;
        transition: background .2s, border-color .2s;
    }
    .director-stat__icon {
        align-items: center;
        border-radius: 12px;
        display: inline-flex;
        flex: 0 0 42px;
        height: 42px;
        justify-content: center;
        width: 42px;
    }
    .director-stat__icon--blue  { background: var(--sms-primary-xlight); color: var(--sms-primary); }
    .director-stat__icon--amber { background: rgba(217,119,6,.15);        color: var(--sms-warning); }
    .director-stat__icon--cyan  { background: rgba(2,132,199,.15);         color: var(--sms-info); }
    .director-stat__icon--green { background: rgba(22,163,74,.15);         color: var(--sms-success); }
    .director-stat small {
        color: var(--sms-text-muted);
        display: block;
        font-size: .72rem;
        font-weight: 800;
        letter-spacing: .04em;
        text-transform: uppercase;
    }
    .director-stat strong {
        color: var(--sms-heading);
        display: block;
        font-size: 1.35rem;
        font-weight: 800;
        line-height: 1.1;
        margin-top: .15rem;
    }
    .director-tracking {
        background: var(--sms-surface);
        border: 1px solid var(--sms-border);
        border-radius: 16px;
        box-shadow: var(--sms-shadow-sm);
        margin-bottom: 1rem;
        overflow: hidden;
        transition: background .2s, border-color .2s;
    }
    .director-tracking__title {
        border-bottom: 1px solid var(--sms-border);
        color: var(--sms-text-muted);
        font-size: .78rem;
        font-weight: 800;
        letter-spacing: .08em;
        padding: 1rem 1.25rem;
        text-transform: uppercase;
    }
    .director-tracking__controls {
        align-items: center;
        background: var(--sms-surface-muted);
        display: flex;
        flex-wrap: wrap;
        gap: .65rem;
        padding: .85rem 1.25rem;
    }
    .director-search {
        align-items: center;
        background: var(--sms-input-bg);
        border: 1px solid var(--sms-input-border);
        border-radius: 10px;
        display: flex;
        flex: 1 1 260px;
        gap: .5rem;
        min-height: 38px;
        padding: .4rem .75rem;
        transition: border-color .15s;
    }
    .director-search:focus-within {
        border-color: var(--sms-primary-light);
        box-shadow: 0 0 0 3px var(--sms-input-focus);
    }
    .director-search i { color: var(--sms-text-muted); }
    .director-search input {
        background: transparent;
        border: 0;
        color: var(--sms-text);
        font-size: .84rem;
        min-width: 0;
        outline: 0;
        width: 100%;
    }
    .director-search input::placeholder { color: var(--sms-text-faint); }
    .director-filter {
        background: var(--sms-input-bg);
        border: 1px solid var(--sms-input-border);
        border-radius: 10px;
        color: var(--sms-text);
        font-size: .84rem;
        min-height: 38px;
        outline: 0;
        padding: .4rem .75rem;
        transition: border-color .15s;
    }
    .director-filter:focus {
        border-color: var(--sms-primary-light);
        box-shadow: 0 0 0 3px var(--sms-input-focus);
    }
    .director-record {
        background: var(--sms-surface);
        border: 1px solid var(--sms-border);
        border-radius: 14px;
        box-shadow: var(--sms-shadow-sm);
        overflow: hidden;
        transition: background .2s, border-color .2s;
    }
    .director-record__head {
        align-items: center;
        border-bottom: 1px solid var(--sms-border);
        display: flex;
        gap: 1rem;
        justify-content: space-between;
        padding: 1rem 1.15rem;
    }
    .director-record__head h2 {
        color: var(--sms-heading);
        font-size: 1rem;
        font-weight: 800;
        margin: 0;
    }
    .director-record__head p,
    .director-record__sync,
    .director-record small {
        color: var(--sms-text-muted);
    }
    .director-record__head p {
        font-size: .86rem;
        margin: .2rem 0 0;
    }
    .director-record__sync {
        flex: 0 0 auto;
        font-size: .78rem;
        font-weight: 700;
    }
    .director-record table { margin: 0; }
    .director-record th {
        background: var(--sms-table-head-bg);
        color: var(--sms-text-muted);
        font-size: .76rem;
        font-weight: 800;
        text-transform: uppercase;
        border-bottom: 1px solid var(--sms-table-border) !important;
    }
    .director-record td {
        color: var(--sms-text);
        font-size: .9rem;
        vertical-align: middle;
        border-color: var(--sms-table-border);
    }
    .director-record strong {
        color: var(--sms-heading);
        display: block;
        font-weight: 800;
    }
    .director-record small { display: block; margin-top: .15rem; }
    .director-record__empty { color: var(--sms-text-muted); padding: 1.2rem; text-align: center; }
    .director-status {
        background: var(--sms-primary-xlight);
        border-radius: 999px;
        color: var(--sms-primary);
        display: inline-flex;
        font-size: .75rem;
        font-weight: 800;
        padding: .35rem .65rem;
        white-space: nowrap;
    }
    .director-status.is-verified {
        background: rgba(22,163,74,.14);
        color: var(--sms-success);
    }
    .director-status.is-needs-verification {
        background: rgba(217,119,6,.14);
        color: var(--sms-warning);
    }
    .director-verify-list {
        display: grid;
        gap: .85rem;
        padding: 1rem;
    }
    .director-verify-card {
        background: var(--sms-surface-muted);
        border: 1px solid var(--sms-border);
        border-radius: 12px;
        padding: .95rem 1rem;
    }
    .director-verify-card__top {
        align-items: flex-start;
        display: flex;
        gap: 1rem;
        justify-content: space-between;
        margin-bottom: .75rem;
    }
    .director-verify-card__title strong {
        color: var(--sms-heading);
        font-size: 1rem;
    }
    .director-verify-grid {
        display: grid;
        gap: .55rem;
        grid-template-columns: repeat(3, minmax(0, 1fr));
    }
    .director-verify-actions {
        display: flex;
        justify-content: flex-end;
        margin-top: .8rem;
    }
    .director-proceed-btn {
        align-items: center;
        background: var(--sms-primary);
        border: 0;
        border-radius: 10px;
        box-shadow: 0 8px 18px rgba(29,78,216,.18);
        color: #fff;
        display: inline-flex;
        font-size: .82rem;
        font-weight: 800;
        gap: .45rem;
        min-height: 40px;
        padding: .62rem .9rem;
        text-decoration: none;
        text-transform: uppercase;
        transition: background .15s, box-shadow .15s;
    }
    .director-proceed-btn:hover {
        background: var(--sms-primary-dark);
        color: #fff;
        text-decoration: none;
        box-shadow: 0 10px 24px rgba(29,78,216,.28);
    }
    .director-check {
        align-items: center;
        background: var(--sms-surface);
        border: 1px solid var(--sms-border);
        border-radius: 10px;
        color: var(--sms-text);
        display: flex;
        font-size: .86rem;
        font-weight: 700;
        gap: .55rem;
        min-height: 42px;
        padding: .55rem .7rem;
    }
    .director-check i {
        align-items: center;
        border-radius: 999px;
        display: inline-flex;
        flex: 0 0 22px;
        height: 22px;
        justify-content: center;
        width: 22px;
    }
    .director-check.is-ok i      { background: rgba(22,163,74,.16);  color: var(--sms-success); }
    .director-check.is-missing i { background: rgba(220,38,38,.14);  color: var(--sms-danger); }
    /* Venue form */
    .director-venue-form {
        margin-bottom: 0;
    }
    .director-venue-grid {
        display: grid;
        gap: .75rem;
        grid-template-columns: repeat(4, minmax(0, 1fr)) auto;
        align-items: end;
        padding: 1rem 1.15rem;
    }
    .director-venue-grid label {
        display: flex;
        flex-direction: column;
        gap: .35rem;
    }
    .director-venue-grid label span {
        color: var(--sms-text-muted);
        font-size: .75rem;
        font-weight: 700;
        letter-spacing: .04em;
        text-transform: uppercase;
    }
    .director-venue-grid input,
    .director-venue-grid select {
        background: var(--sms-input-bg);
        border: 1px solid var(--sms-input-border);
        border-radius: 9px;
        color: var(--sms-text);
        font-size: .88rem;
        min-height: 40px;
        outline: 0;
        padding: .4rem .7rem;
        transition: border-color .15s, box-shadow .15s;
        width: 100%;
    }
    .director-venue-grid input:focus,
    .director-venue-grid select:focus {
        border-color: var(--sms-primary-light);
        box-shadow: 0 0 0 3px var(--sms-input-focus);
    }
    .director-venue-grid input::placeholder { color: var(--sms-text-faint); }
    /* Add / Save venue buttons */
    .director-add-venue-btn {
        align-items: center;
        background: var(--sms-primary);
        border: 0;
        border-radius: 10px;
        box-shadow: 0 6px 16px rgba(29,78,216,.2);
        color: #fff;
        cursor: pointer;
        display: inline-flex;
        font-size: .82rem;
        font-weight: 800;
        gap: .45rem;
        min-height: 40px;
        padding: .5rem 1rem;
        text-decoration: none;
        transition: background .15s, box-shadow .15s;
        white-space: nowrap;
    }
    .director-add-venue-btn:hover,
    .director-add-venue-btn:focus {
        background: var(--sms-primary-dark);
        box-shadow: 0 8px 22px rgba(29,78,216,.3);
        color: #fff;
        outline: 0;
        text-decoration: none;
    }
    .director-add-venue-btn.is-cancel       { background: var(--sms-text-muted); box-shadow: none; }
    .director-add-venue-btn.is-cancel:hover { background: var(--sms-text); color: #fff; }
    /* Inline venue status dropdown */
    .venue-status-select {
        -webkit-appearance: none;
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%23555'/%3E%3C/svg%3E");
        background-position: right .5rem center;
        background-repeat: no-repeat;
        background-size: 8px;
        border: 2px solid transparent;
        border-radius: 999px;
        cursor: pointer;
        font-size: .75rem;
        font-weight: 800;
        letter-spacing: .02em;
        min-height: 30px;
        outline: 0;
        padding: .25rem 1.5rem .25rem .6rem;
        transition: box-shadow .15s, border-color .15s, opacity .15s;
    }
    .venue-status-select:focus         { border-color: var(--sms-primary-light); box-shadow: 0 0 0 3px var(--sms-input-focus); }
    .venue-status-select:disabled      { opacity: .5; cursor: not-allowed; }
    .venue-status-select.is-saving     { opacity: .6; cursor: wait; }
    .venue-status-select--available    { background-color: #d1fae5; color: #047857; border-color: #6ee7b7; }
    .venue-status-select--reserved     { background-color: #ede9fe; color: #6d28d9; border-color: #c4b5fd; }
    .venue-status-select--unavailable  { background-color: #fee2e2; color: #b91c1c; border-color: #fca5a5; }
    [data-theme="dark"] .venue-status-select {
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%23aaa'/%3E%3C/svg%3E");
    }
    [data-theme="dark"] .venue-status-select--available   { background-color: rgba(52,211,153,.18);  color: #6ee7b7;  border-color: rgba(52,211,153,.35); }
    [data-theme="dark"] .venue-status-select--reserved    { background-color: rgba(139,92,246,.20);  color: #c4b5fd;  border-color: rgba(139,92,246,.38); }
    [data-theme="dark"] .venue-status-select--unavailable { background-color: rgba(248,113,113,.18); color: #fca5a5;  border-color: rgba(248,113,113,.35); }
    /* ── Responsive ───────────────────────────────────────────────────── */
    @media (max-width: 1100px) {
        .director-stats            { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .director-venue-grid       { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .director-venue-grid > div { grid-column: span 2; }
    }
    @media (max-width: 720px) {
        .director-stats            { grid-template-columns: 1fr; }
        .director-record__head     { align-items: flex-start; flex-direction: column; }
        .director-filter           { width: 100%; }
        .director-verify-card__top { flex-direction: column; }
        .director-verify-grid      { grid-template-columns: 1fr; }
        .director-venue-grid       { grid-template-columns: 1fr; }
        .director-venue-grid > div { grid-column: 1; }
    }
</style>

<div class="director-stats">
    <section class="director-stat">
        <span class="director-stat__icon director-stat__icon--blue"><i class="fas fa-list-alt" aria-hidden="true"></i></span>
        <div>
            <small><?= $view === 'venues' ? 'Total Venues' : 'Ready for Scheduling' ?></small>
            <strong data-director-stat="ready"><?= (int) $readyCount ?></strong>
        </div>
    </section>
    <section class="director-stat">
        <span class="director-stat__icon director-stat__icon--amber"><i class="fas fa-check-double" aria-hidden="true"></i></span>
        <div>
            <small><?= $view === 'venues' ? 'Reserved' : 'Needs Verification' ?></small>
            <strong data-director-stat="needs_verification"><?= (int) $needsVerification ?></strong>
        </div>
    </section>
    <section class="director-stat">
        <span class="director-stat__icon director-stat__icon--cyan"><i class="fas fa-calendar-check" aria-hidden="true"></i></span>
        <div>
            <small><?= $view === 'venues' ? 'Available' : 'Scheduled Defenses' ?></small>
            <strong data-director-stat="scheduled"><?= (int) $scheduledCount ?></strong>
        </div>
    </section>
    <section class="director-stat">
        <span class="director-stat__icon director-stat__icon--green"><i class="fas fa-check-circle" aria-hidden="true"></i></span>
        <div>
            <small><?= $view === 'venues' ? 'Unavailable' : 'Completed' ?></small>
            <strong data-director-stat="completed"><?= (int) $completedCount ?></strong>
        </div>
    </section>
</div>

<section class="director-tracking">
    <div class="director-tracking__title"><?= htmlspecialchars($pageTitle) ?> Tracking</div>
    <div class="director-tracking__controls">
        <label class="director-search">
            <i class="fas fa-search" aria-hidden="true"></i>
            <input type="search" data-director-search placeholder="<?= $view === 'venues' ? 'Search by venue, capacity, type, or status...' : 'Search by group, title, adviser, or panel...' ?>">
        </label>
        <select class="director-filter" data-director-status>
            <option value="all">All Status</option>
            <?php if ($view === 'venues'): ?>
                <option value="available">Available</option>
                <option value="reserved">Reserved</option>
                <option value="unavailable">Unavailable</option>
            <?php else: ?>
                <option value="ready">Ready for Scheduling</option>
                <option value="scheduled">Scheduled</option>
                <option value="completed">Completed</option>
            <?php endif; ?>
            <?php if ($view === 'verify-research-defense'): ?>
                <option value="verified">Verified</option>
                <option value="needs-verification">Needs Verification</option>
            <?php endif; ?>
        </select>
    </div>
</section>

<?php if ($view === 'venues'): ?>
    <?php if ($venueMessage): ?>
        <div class="alert alert-<?= htmlspecialchars($venueMessage['type']) ?> mb-3">
            <?= htmlspecialchars($venueMessage['text']) ?>
        </div>
    <?php endif; ?>
<?php endif; ?>

<section class="director-record">
    <div class="director-record__head">
        <div>
            <h2><?= $view === 'venues' ? 'Venue List' : ($view === 'verify-research-defense' ? 'Verify Proposal Complete & Approved' : 'Research Defense Scheduling Queue') ?></h2>
            <p><?= $view === 'venues' ? 'Manage defense venues, capacity, type, and availability status.' : ($view === 'verify-research-defense' ? 'Check approved, complete, assigned, and ready-for-defense records from Research Defense Scheduling.' : ($directorUsesScheduleRows ? 'Realtime records from Research Defense Scheduling.' : 'Realtime records from completed adviser assignments.')) ?></p>
        </div>
        <?php if ($view === 'venues'): ?>
            <button type="button" class="director-add-venue-btn" data-director-add-venue>
                <i class="fas fa-plus" aria-hidden="true"></i>
                Add Venue
            </button>
        <?php endif; ?>
        <span class="director-record__sync" data-director-sync>Synced <?= htmlspecialchars(date('M j, Y h:i:s A')) ?></span>
    </div>
    <?php if ($view === 'venues'): ?>
        <div class="director-venue-form" data-director-venue-form style="display:none; border-top: 1px solid var(--sms-border, #dbe4f0);">
            <form method="post" class="director-venue-grid">
                <?= csrfField() ?>
                <input type="hidden" name="venue_action" value="add">
                <label>
                    <span>Venue Name</span>
                    <input type="text" name="venue_name" required placeholder="e.g. CRAD Conference Room">
                </label>
                <label>
                    <span>Capacity</span>
                    <input type="number" name="capacity" min="1" required placeholder="30">
                </label>
                <label>
                    <span>Type</span>
                    <input type="text" name="venue_type" required placeholder="e.g. Conference Room">
                </label>
                <label>
                    <span>Status</span>
                    <select name="status" required>
                        <option value="Available">Available</option>
                        <option value="Reserved">Reserved</option>
                        <option value="Unavailable">Unavailable</option>
                    </select>
                </label>
                <div style="display:flex; gap:.5rem; align-items:flex-end;">
                    <button type="submit" class="director-add-venue-btn">
                        <i class="fas fa-save" aria-hidden="true"></i>
                        Save Venue
                    </button>
                    <button type="button" class="director-add-venue-btn is-cancel" data-director-cancel-venue>
                        <i class="fas fa-times" aria-hidden="true"></i>
                        Cancel
                    </button>
                </div>
            </form>
        </div>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                    <tr>
                        <th>Venue</th>
                        <th>Capacity</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Updated</th>
                    </tr>
                </thead>
                <tbody data-director-rows>
                    <?php foreach ($venueRows as $row): ?>
                        <?php
                            $vid          = (int) ($row['id'] ?? 0);
                            $vStatusVal   = (string) ($row['status'] ?? 'Available');
                            $vStatusKey   = strtolower($vStatusVal);
                        ?>
                        <tr data-director-row data-status="<?= htmlspecialchars($vStatusKey) ?>" data-venue-id="<?= $vid ?>">
                            <td><strong><?= htmlspecialchars((string) ($row['venue_name'] ?? 'Venue')) ?></strong></td>
                            <td><?= (int) ($row['capacity'] ?? 0) ?></td>
                            <td><?= htmlspecialchars((string) ($row['venue_type'] ?? '')) ?></td>
                            <td>
                                <select class="venue-status-select venue-status-select--<?= htmlspecialchars($vStatusKey) ?>"
                                        data-venue-status-select
                                        data-venue-id="<?= $vid ?>"
                                        aria-label="Status for <?= htmlspecialchars((string) ($row['venue_name'] ?? 'venue')) ?>">
                                    <option value="Available"   <?= $vStatusVal === 'Available'   ? 'selected' : '' ?>>Available</option>
                                    <option value="Reserved"    <?= $vStatusVal === 'Reserved'    ? 'selected' : '' ?>>Reserved</option>
                                    <option value="Unavailable" <?= $vStatusVal === 'Unavailable' ? 'selected' : '' ?>>Unavailable</option>
                                </select>
                            </td>
                            <td class="venue-updated-cell"><?= htmlspecialchars(date('M j, Y h:i A', strtotime((string) ($row['updated_at'] ?? 'now')))) ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    <?php elseif ($view === 'verify-research-defense'): ?>
        <div class="director-verify-list" data-director-rows>
            <?php foreach ($displayRows as $row): ?>
                <?php
                    $verification = is_array($row['verification'] ?? null) ? $row['verification'] : [];
                    $verificationStatus = (string) ($row['verification_status'] ?? 'Needs Verification');
                    $statusKey = strcasecmp($verificationStatus, 'Verified') === 0 ? 'verified' : 'needs-verification';
                    $checks = [
                        'Proposal Complete' => (bool) ($verification['proposal_complete'] ?? false),
                        'Approval Approved' => (bool) ($verification['approval_approved'] ?? false),
                        'Required Info Complete' => (bool) ($verification['required_info_complete'] ?? false),
                        'Adviser Assigned' => (bool) ($verification['adviser_assigned'] ?? false),
                        'Panel Assigned' => (bool) ($verification['panel_assigned'] ?? false),
                        'Ready for Defense' => (bool) ($verification['ready_for_defense'] ?? false),
                    ];
                ?>
                <article class="director-verify-card" data-director-row data-status="<?= htmlspecialchars($statusKey) ?>">
                    <div class="director-verify-card__top">
                        <div class="director-verify-card__title">
                            <strong><?= htmlspecialchars((string) ($row['subtitle'] ?: $row['reference'] ?: 'Research Group')) ?></strong>
                            <small><?= htmlspecialchars((string) ($row['title'] ?? 'Research title pending')) ?></small>
                        </div>
                        <span class="director-status <?= $statusKey === 'verified' ? 'is-verified' : 'is-needs-verification' ?>">
                            <?= htmlspecialchars($verificationStatus) ?>
                        </span>
                    </div>
                    <div class="director-verify-grid">
                        <?php foreach ($checks as $label => $isOk): ?>
                            <span class="director-check <?= $isOk ? 'is-ok' : 'is-missing' ?>">
                                <i class="fas <?= $isOk ? 'fa-check' : 'fa-times' ?>" aria-hidden="true"></i>
                                <?= htmlspecialchars($label) ?>
                            </span>
                        <?php endforeach; ?>
                    </div>
                    <?php if ($statusKey === 'verified'): ?>
                        <div class="director-verify-actions">
                            <a class="director-proceed-btn" href="<?= htmlspecialchars((string) ($row['proceed_url'] ?? '#')) ?>">
                                <i class="fas fa-arrow-right" aria-hidden="true"></i>
                                VERIFY &amp; PROCEED
                            </a>
                        </div>
                    <?php endif; ?>
                </article>
            <?php endforeach; ?>
        </div>
    <?php else: ?>
    <div class="table-responsive">
        <table class="table align-middle">
            <thead>
                <tr>
                    <th>Reference No.</th>
                    <th>Research Title / Group</th>
                    <th><?= $directorUsesScheduleRows ? 'Panel Chair' : 'Adviser' ?></th>
                    <th><?= $directorUsesScheduleRows ? 'Office / Detail' : 'Panel Members' ?></th>
                    <th>Status</th>
                    <th>Updated</th>
                </tr>
            </thead>
            <tbody data-director-rows>
                <?php foreach ($displayRows as $row): ?>
                    <?php
                        $statusValue = trim((string) ($row['status'] ?? 'Ready for Scheduling'));
                        $lowerStatus = strtolower($statusValue);
                        $statusKey = 'scheduled';
                        if ($lowerStatus === 'ready for scheduling') {
                            $statusKey = 'ready';
                        } elseif (in_array($lowerStatus, ['completed', 'passed'], true)) {
                            $statusKey = 'completed';
                        }
                    ?>
                    <tr data-director-row data-status="<?= htmlspecialchars($statusKey) ?>">
                        <td class="fw-semibold"><?= htmlspecialchars((string) ($row['reference'] ?? 'For Scheduling')) ?></td>
                        <td>
                            <strong><?= htmlspecialchars((string) ($row['title'] ?? 'Research title pending')) ?></strong>
                            <?php if (!empty($row['subtitle'])): ?>
                                <small><?= htmlspecialchars((string) $row['subtitle']) ?></small>
                            <?php endif; ?>
                        </td>
                        <td><?= htmlspecialchars((string) ($row['owner'] ?? 'For panel chair')) ?></td>
                        <td><?= htmlspecialchars((string) ($row['detail'] ?? 'Ready for venue')) ?></td>
                        <td><span class="director-status"><?= htmlspecialchars($statusValue) ?></span></td>
                        <td><?= htmlspecialchars((string) ($row['updated'] ?? '')) ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
    <?php endif; ?>
    <div class="director-record__empty" data-director-empty <?= $displayRows ? 'hidden' : '' ?>>
        No records found.
    </div>
</section>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const isVerifyView = <?= $view === 'verify-research-defense' ? 'true' : 'false' ?>;
    const isVenueView  = <?= $view === 'venues' ? 'true' : 'false' ?>;
    const csrfToken    = <?= json_encode(csrfToken()) ?>;
    const pageUrl      = window.location.pathname + '?view=venues';
    const search = document.querySelector('[data-director-search]');
    const status = document.querySelector('[data-director-status]');
    const rowsBody = document.querySelector('[data-director-rows]');
    const empty = document.querySelector('[data-director-empty]');
    const sync = document.querySelector('[data-director-sync]');
    const statNodes = document.querySelectorAll('[data-director-stat]');
    let rows = Array.from(document.querySelectorAll('[data-director-row]'));
    let refreshing = false;
    let timer = null;

    const esc = function (value) {
        return String(value || '').replace(/[&<>"']/g, function (char) {
            return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' })[char];
        });
    };

    const statusKey = function (value) {
        const text = String(value || '').toLowerCase();
        if (text === 'ready for scheduling') return 'ready';
        if (text === 'completed' || text === 'passed') return 'completed';
        return 'scheduled';
    };

    const verificationStatus = function (row) {
        const checks = row.verification || {};
        const keys = ['proposal_complete', 'approval_approved', 'required_info_complete', 'adviser_assigned', 'panel_assigned', 'ready_for_defense'];
        const verified = keys.every(function (key) { return checks[key] === true; });
        return verified ? 'Verified' : 'Needs Verification';
    };

    const renderVerificationChecks = function (checks) {
        const labels = [
            ['proposal_complete', 'Proposal Complete'],
            ['approval_approved', 'Approval Approved'],
            ['required_info_complete', 'Required Info Complete'],
            ['adviser_assigned', 'Adviser Assigned'],
            ['panel_assigned', 'Panel Assigned'],
            ['ready_for_defense', 'Ready for Defense']
        ];
        return labels.map(function (item) {
            const ok = checks && checks[item[0]] === true;
            return '<span class="director-check ' + (ok ? 'is-ok' : 'is-missing') + '">' +
                '<i class="fas ' + (ok ? 'fa-check' : 'fa-times') + '" aria-hidden="true"></i>' +
                esc(item[1]) +
            '</span>';
        }).join('');
    };

    const renderStats = function (stats) {
        statNodes.forEach(function (node) {
            const key = node.dataset.directorStat;
            node.textContent = stats && Object.prototype.hasOwnProperty.call(stats, key)
                ? String(stats[key])
                : '0';
        });
    };

    const renderRows = function (list) {
        if (!rowsBody) return;
        if (!Array.isArray(list) || list.length === 0) {
            rowsBody.innerHTML = '';
            rows = [];
            applyFilters();
            return;
        }

        if (isVenueView) {
            rowsBody.innerHTML = list.map(function (row) {
                const s    = String(row.status || 'Available').toLowerCase();
                const vid  = parseInt(row.id, 10) || 0;
                const opts = ['Available', 'Reserved', 'Unavailable'].map(function (opt) {
                    const sel = opt.toLowerCase() === s ? ' selected' : '';
                    return '<option value="' + opt + '"' + sel + '>' + opt + '</option>';
                }).join('');
                return '<tr data-director-row data-status="' + esc(s) + '" data-venue-id="' + vid + '">' +
                    '<td><strong>' + esc(row.venue_name || 'Venue') + '</strong></td>' +
                    '<td>' + (parseInt(row.capacity, 10) || 0) + '</td>' +
                    '<td>' + esc(row.venue_type || '') + '</td>' +
                    '<td><select class="venue-status-select venue-status-select--' + esc(s) + '" ' +
                        'data-venue-status-select data-venue-id="' + vid + '" ' +
                        'aria-label="Status for ' + esc(row.venue_name || 'venue') + '">' +
                        opts + '</select></td>' +
                    '<td class="venue-updated-cell">' + esc(row.updated || '') + '</td>' +
                '</tr>';
            }).join('');
            rows = Array.from(document.querySelectorAll('[data-director-row]'));
            bindStatusSelects();
            applyFilters();
            return;
        }

        if (isVerifyView) {
            rowsBody.innerHTML = list.map(function (row) {
                const verifyStatus = row.verification_status || verificationStatus(row);
                const key = verifyStatus.toLowerCase().replace(/\s+/g, '-');
                return '<article class="director-verify-card" data-director-row data-status="' + esc(key) + '">' +
                    '<div class="director-verify-card__top">' +
                        '<div class="director-verify-card__title">' +
                            '<strong>' + esc(row.subtitle || row.reference || 'Research Group') + '</strong>' +
                            '<small>' + esc(row.title || 'Research title pending') + '</small>' +
                        '</div>' +
                        '<span class="director-status ' + (key === 'verified' ? 'is-verified' : 'is-needs-verification') + '">' + esc(verifyStatus) + '</span>' +
                    '</div>' +
                    '<div class="director-verify-grid">' + renderVerificationChecks(row.verification || {}) + '</div>' +
                    (key === 'verified'
                        ? '<div class="director-verify-actions"><a class="director-proceed-btn" href="' + esc(row.proceed_url || '#') + '"><i class="fas fa-arrow-right" aria-hidden="true"></i>VERIFY &amp; PROCEED</a></div>'
                        : '') +
                '</article>';
            }).join('');
            rows = Array.from(document.querySelectorAll('[data-director-row]'));
            applyFilters();
            return;
        }

        rowsBody.innerHTML = list.map(function (row) {
            const key = statusKey(row.status);
            return '<tr data-director-row data-status="' + esc(key) + '">' +
                '<td class="fw-semibold">' + esc(row.reference || 'For Scheduling') + '</td>' +
                '<td><strong>' + esc(row.title || 'Research title pending') + '</strong>' +
                    (row.subtitle ? '<small>' + esc(row.subtitle) + '</small>' : '') +
                '</td>' +
                '<td>' + esc(row.owner || 'For panel chair') + '</td>' +
                '<td>' + esc(row.detail || 'Ready for venue') + '</td>' +
                '<td><span class="director-status">' + esc(row.status || 'Ready for Scheduling') + '</span></td>' +
                '<td>' + esc(row.updated || '') + '</td>' +
            '</tr>';
        }).join('');
        rows = Array.from(document.querySelectorAll('[data-director-row]'));
        applyFilters();
    };

    /* ── Venue status dropdown handler ─────────────────────────────────── */
    const bindStatusSelects = function () {
        document.querySelectorAll('[data-venue-status-select]').forEach(function (sel) {
            if (sel.dataset.bound === '1') return;
            sel.dataset.bound = '1';
            sel.addEventListener('change', async function () {
                const venueId   = parseInt(sel.dataset.venueId, 10);
                const newStatus = sel.value;
                const row       = sel.closest('[data-director-row]');
                const updCell   = row ? row.querySelector('.venue-updated-cell') : null;
                sel.disabled = true;
                sel.classList.add('is-saving');
                try {
                    const body = new URLSearchParams();
                    body.set('venue_action', 'update_status');
                    body.set('venue_id', venueId);
                    body.set('status', newStatus);
                    body.set('csrf_token', csrfToken);
                    const res = await fetch(pageUrl, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            'Accept': 'application/json'
                        },
                        credentials: 'same-origin',
                        body: body.toString()
                    });
                    const data = await res.json();
                    if (!data.ok) throw new Error(data.message || 'Save failed');
                    const s = newStatus.toLowerCase();
                    if (row) row.dataset.status = s;
                    sel.className = 'venue-status-select venue-status-select--' + s;
                    // keep bound=1 so duplicate listeners aren't added
                    if (updCell) {
                        const now = new Date();
                        updCell.textContent = now.toLocaleString('en-US', {
                            month: 'short', day: 'numeric', year: 'numeric',
                            hour: 'numeric', minute: '2-digit', hour12: true
                        });
                    }
                } catch (err) {
                    alert('Could not save status. Please try again.');
                }
                sel.disabled = false;
                sel.classList.remove('is-saving');
            });
        });
    };

    const applyFilters = function () {
        const term     = search ? search.value.trim().toLowerCase() : '';
        const selected = status ? status.value : 'all';
        let visibleCount = 0;

        rows.forEach(function (row) {
            const matchesTerm = !term || row.textContent.toLowerCase().includes(term);
            const matchesStatus = selected === 'all' || row.dataset.status === selected;
            const show = matchesTerm && matchesStatus;
            row.hidden = !show;
            if (show) visibleCount++;
        });

        if (empty) {
            empty.hidden = visibleCount > 0;
            empty.textContent = rows.length ? 'No records match the search or filter.' : 'No records found.';
        }
    };

    const refreshRows = async function () {
        if (refreshing) return;
        refreshing = true;
        try {
            const url = new URL(window.location.href);
            url.searchParams.set('ajax', 'director-schedules');
            url.searchParams.set('_', Date.now().toString());
            const res = await fetch(url.toString(), {
                headers: { 'Accept': 'application/json' },
                cache: 'no-store',
                credentials: 'same-origin'
            });
            if (!res.ok) throw new Error('Sync failed');
            const data = await res.json();
            if (!data.ok) throw new Error('Sync failed');
            renderRows(data.rows || []);
            renderStats(data.stats || {});
            if (sync) sync.textContent = 'Synced ' + (data.synced_at || '');
        } catch (error) {
        } finally {
            refreshing = false;
        }
    };

    if (search) search.addEventListener('input', applyFilters);
    if (status) status.addEventListener('change', applyFilters);

    // Add Venue toggle
    const addVenueBtn = document.querySelector('[data-director-add-venue]');
    const venueForm = document.querySelector('[data-director-venue-form]');
    const cancelVenueBtn = document.querySelector('[data-director-cancel-venue]');

    if (addVenueBtn && venueForm) {
        addVenueBtn.addEventListener('click', function () {
            const isVisible = venueForm.style.display !== 'none';
            if (isVisible) {
                venueForm.style.display = 'none';
                addVenueBtn.innerHTML = '<i class="fas fa-plus" aria-hidden="true"></i> Add Venue';
                addVenueBtn.classList.remove('is-cancel');
            } else {
                venueForm.style.display = '';
                addVenueBtn.innerHTML = '<i class="fas fa-chevron-up" aria-hidden="true"></i> Hide Form';
                addVenueBtn.classList.add('is-cancel');
                venueForm.querySelector('input[name="venue_name"]')?.focus();
            }
        });
    }

    if (cancelVenueBtn && venueForm && addVenueBtn) {
        cancelVenueBtn.addEventListener('click', function () {
            venueForm.style.display = 'none';
            addVenueBtn.innerHTML = '<i class="fas fa-plus" aria-hidden="true"></i> Add Venue';
            addVenueBtn.classList.remove('is-cancel');
        });
    }

    // Auto-open form if there's a message (after submit attempt)
    <?php if ($view === 'venues' && $venueMessage): ?>
    if (venueForm && addVenueBtn) {
        venueForm.style.display = '';
        addVenueBtn.innerHTML = '<i class="fas fa-chevron-up" aria-hidden="true"></i> Hide Form';
        addVenueBtn.classList.add('is-cancel');
    }
    <?php endif; ?>

    applyFilters();
    if (isVenueView) bindStatusSelects();
    refreshRows();
    timer = window.setInterval(refreshRows, 5000);
    document.addEventListener('visibilitychange', function () {
        if (document.hidden) {
            if (timer) window.clearInterval(timer);
            timer = null;
            return;
        }
        if (timer) window.clearInterval(timer);
        refreshRows();
        timer = window.setInterval(refreshRows, 5000);
    });
});
</script>

<?php require_once ROOT_PATH . '/includes/layout-end.php'; ?>
