<?php
/**
 * SMS 2 - Sidebar Navigation
 * Expects: optional $activeModule (string), optional $activePage (string)
 */
if (!isset($MODULES)) {
    require_once __DIR__ . '/../config/config.php';
}
require_once __DIR__ . '/authentication.php';
require_once __DIR__ . '/module-controls.php';
require_once __DIR__ . '/nav-icons.php';

$activeModule = $activeModule ?? '';
$activePage   = $activePage ?? '';
$roleKey = getCurrentUserRoleKey();
$isStudentPortal = $activeModule === 'student_portal';
$visibleModules = getVisibleModules($MODULES);
$securitySettingsModule = '';
if (!in_array($roleKey, ['superadmin', 'admin'], true)) {
    foreach ($visibleModules as $securityModuleKey => $_securityModule) {
        if ($securityModuleKey !== 'user-management') {
            $securitySettingsModule = (string) $securityModuleKey;
            break;
        }
    }
}
$moduleHasSecuritySettingsPage = false;
if ($securitySettingsModule !== '' && isset($visibleModules[$securitySettingsModule]['pages'])) {
    foreach ((array) $visibleModules[$securitySettingsModule]['pages'] as $securityPage) {
        if (($securityPage['slug'] ?? '') === 'security-settings') {
            $moduleHasSecuritySettingsPage = true;
            break;
        }
    }
}

// ── For students: check if Research Forum is paid ───────────────────────────
$researchForumPaid = false;
$studentReturnedTitleApprovalId = 0;
if ($isStudentPortal) {
    // If student-portal-page.php already computed this, use it.
    // Otherwise check independently from the payment data source.
    if (isset($researchForumPaid) && $researchForumPaid === true) {
        // already set by student-portal-page.php context
    } else {
        // Standalone check: mirror the same transaction list.
        // In production, replace with a real DB query against payment table.
        $sidebarPayments = [
            ['description' => 'Tuition Down Payment',  'status' => 'Paid'],
            ['description' => 'Registration Fee',       'status' => 'Paid'],
            ['description' => 'Laboratory Fee',         'status' => 'Paid'],
            ['description' => 'Research Forum',         'status' => 'Paid'],
        ];
        foreach ($sidebarPayments as $txn) {
            if (
                stripos($txn['description'], 'Research Forum') !== false &&
                strtolower($txn['status']) === 'paid'
            ) {
                $researchForumPaid = true;
                break;
            }
        }
    }

    try {
        require_once ROOT_PATH . '/modules/crad/config/config.php';
        $sidebarCrad = function_exists('cradDb') ? cradDb() : null;
        if ($sidebarCrad instanceof PDO) {
            $sidebarStudentId = trim((string) ($_SESSION['student_id'] ?? ''));
            $sidebarStudentName = strtolower(trim((string) ($_SESSION['user_name'] ?? '')));
            $sidebarStudentUserId = (int) ($_SESSION['user_id'] ?? 0);
            $titleStmt = $sidebarCrad->prepare(
                "SELECT id
                 FROM title_approvals
                 WHERE status = 'Returned'
                   AND (
                        (:student_id_value <> '' AND student_id = :student_id_match)
                     OR (:student_name_value <> '' AND LOWER(TRIM(student_name)) = :student_name_match)
                     OR (:user_id_value > 0 AND student_user_id = :user_id_match)
                   )
                 ORDER BY reviewed_at DESC, id DESC
                 LIMIT 1"
            );
            $titleStmt->execute([
                ':student_id_value' => $sidebarStudentId,
                ':student_id_match' => $sidebarStudentId,
                ':student_name_value' => $sidebarStudentName,
                ':student_name_match' => $sidebarStudentName,
                ':user_id_value' => $sidebarStudentUserId,
                ':user_id_match' => $sidebarStudentUserId,
            ]);
            $studentReturnedTitleApprovalId = (int) ($titleStmt->fetchColumn() ?: 0);
        }
    } catch (Throwable $e) {
        error_log('Student returned title approval sidebar check failed: ' . $e->getMessage());
    }
}

$studentResearchProposalHref = $studentReturnedTitleApprovalId > 0
    ? BASE_URL . '/notifications/view.php?type=returned_title_approval&title_approval=' . $studentReturnedTitleApprovalId
    : BASE_URL . '/modules/student-portal/pages/research-proposal-submission.php';

$studentNavGroups = [
    'Overview' => [
        ['slug' => 'dashboard', 'href' => BASE_URL . '/modules/student-portal/pages/dashboard.php', 'icon' => 'fa-tachometer-alt', 'label' => 'Dashboard', 'locked' => false],
    ],
    'Student Information' => [
        ['slug' => 'my-profile',  'href' => BASE_URL . '/modules/student-portal/pages/my-profile.php',  'icon' => 'fa-user',    'label' => 'My Profile',  'locked' => false],
        ['slug' => 'student-id',  'href' => BASE_URL . '/modules/student-portal/pages/student-id.php',  'icon' => 'fa-id-card', 'label' => 'Student ID',  'locked' => false],
    ],
    'Financial' => [
        ['slug' => 'account-balance',  'href' => BASE_URL . '/modules/student-portal/pages/account-balance.php',  'icon' => 'fa-wallet',  'label' => 'Account Balance',  'locked' => false],
        ['slug' => 'payment-history',  'href' => BASE_URL . '/modules/student-portal/pages/payment-history.php',  'icon' => 'fa-receipt', 'label' => 'Payment History',  'locked' => false],
    ],
    'Academics' => [
        ['slug' => 'class-schedule',      'href' => BASE_URL . '/modules/student-portal/pages/class-schedule.php',      'icon' => 'fa-calendar-alt',        'label' => 'Class Schedule',       'locked' => false],
        ['slug' => 'academic-records',    'href' => BASE_URL . '/modules/student-portal/pages/academic-records.php',    'icon' => 'fa-file-alt',            'label' => 'Academic Records',     'locked' => false],
        ['slug' => 'subjects-professors', 'href' => BASE_URL . '/modules/student-portal/pages/subjects-professors.php', 'icon' => 'fa-chalkboard-teacher',  'label' => 'Subject & Professors', 'locked' => false],
        ['slug' => 'grades-portal',       'href' => BASE_URL . '/modules/student-portal/pages/grades-portal.php',       'icon' => 'fa-star-half-alt',       'label' => 'Grades Portal',        'locked' => false],
    ],
    'Research' => [
        ['slug' => 'research-proposal-submission', 'href' => $studentResearchProposalHref, 'icon' => 'fa-flask',            'label' => 'Research Proposal', 'locked' => false],
        ['slug' => 'submit-documents',             'href' => BASE_URL . '/modules/student-portal/pages/submit-documents.php',             'icon' => 'fa-cloud-upload-alt', 'label' => 'Submit Documents',  'locked' => !$researchForumPaid],
    ],
    'System' => [
        ['slug' => 'security-settings', 'href' => BASE_URL . '/account/module-security.php?module=student_portal', 'icon' => 'fa-shield-alt', 'label' => 'Security Settings', 'locked' => false],
    ],
];

$facultyAccountNavGroups = [
    'Dashboard' => [
        ['slug' => '', 'href' => BASE_URL . '/modules/faculty/index.php', 'icon' => 'fa-th-large', 'label' => 'Overview'],
    ],
    'Approved Research' => [
        ['slug' => 'approved-research', 'href' => BASE_URL . '/modules/faculty/pages/approved-research.php', 'icon' => 'fa-check-square', 'label' => 'View Approved Research'],
    ],
    'My Research' => [
        ['slug' => 'assigned-research', 'href' => BASE_URL . '/modules/faculty/pages/assigned-research.php', 'icon' => 'fa-flask', 'label' => 'Assigned Research'],
        ['slug' => 'research-details', 'href' => BASE_URL . '/modules/faculty/pages/research-details.php', 'icon' => 'fa-file-alt', 'label' => 'Research Details'],
        ['slug' => 'research-progress', 'href' => BASE_URL . '/modules/faculty/pages/research-progress.php', 'icon' => 'fa-tasks', 'label' => 'Research Progress'],
        ['slug' => 'research-documents', 'href' => BASE_URL . '/modules/faculty/pages/research-documents.php', 'icon' => 'fa-folder-open', 'label' => 'Research Documents'],
    ],
    'Grades Portal' => [
        ['slug' => 'grade-entry', 'href' => BASE_URL . '/modules/faculty/pages/grade-entry.php', 'icon' => 'fa-pen', 'label' => 'Grade Entry'],
        ['slug' => 'grade-records', 'href' => BASE_URL . '/modules/faculty/pages/grade-records.php', 'icon' => 'fa-list-alt', 'label' => 'Grade Records'],
        ['slug' => 'grade-summary', 'href' => BASE_URL . '/modules/faculty/pages/grade-summary.php', 'icon' => 'fa-chart-pie', 'label' => 'Grade Summary'],
    ],
    'Schedule' => [
        ['slug' => 'my-schedule', 'href' => BASE_URL . '/modules/faculty/pages/my-schedule.php', 'icon' => 'fa-calendar', 'label' => 'My Schedule'],
        ['slug' => 'defense-schedule', 'href' => BASE_URL . '/modules/faculty/pages/defense-schedule.php', 'icon' => 'fa-calendar-check', 'label' => 'Defense Schedule'],
    ],
    'Profile' => [
        ['slug' => 'my-profile', 'href' => BASE_URL . '/modules/faculty/pages/my-profile.php', 'icon' => 'fa-user', 'label' => 'My Profile'],
        ['slug' => 'expertise', 'href' => BASE_URL . '/modules/faculty/pages/expertise.php', 'icon' => 'fa-brain', 'label' => 'Expertise'],
        ['slug' => 'availability', 'href' => BASE_URL . '/modules/faculty/pages/availability.php', 'icon' => 'fa-user-check', 'label' => 'Availability'],
    ],
    'System' => [
        ['slug' => 'security-settings', 'href' => BASE_URL . '/account/module-security.php?module=faculty', 'icon' => 'fa-shield-alt', 'label' => 'Security Settings'],
    ],
];

$researchDirectorBaseUrl = BASE_URL . '/modules/faculty/pages/research-director.php?view=';
$researchDirectorNavGroups = [
    'Dashboard' => [
        ['slug' => '', 'href' => BASE_URL . '/modules/faculty/index.php', 'icon' => 'fa-home', 'label' => 'Overview'],
    ],
    'Defense Management' => [
        ['slug' => 'verify-research-defense', 'href' => $researchDirectorBaseUrl . 'verify-research-defense', 'icon' => 'fa-check-double', 'label' => 'Verify Research for Defense'],
        ['slug' => 'defense-schedule', 'href' => $researchDirectorBaseUrl . 'defense-schedule', 'icon' => 'fa-calendar-check', 'label' => 'Defense Schedule'],
    ],
    'AI Scheduling' => [
        ['slug' => 'ai-scheduling-optimizer', 'href' => $researchDirectorBaseUrl . 'ai-scheduling-optimizer', 'icon' => 'fa-magic', 'label' => 'AI Scheduling Optimizer'],
        ['slug' => 'proposed-schedules', 'href' => $researchDirectorBaseUrl . 'proposed-schedules', 'icon' => 'fa-calendar-plus', 'label' => 'Proposed Schedules'],
        ['slug' => 'alternative-time-slots', 'href' => $researchDirectorBaseUrl . 'alternative-time-slots', 'icon' => 'fa-clock', 'label' => 'Alternative Time Slots'],
    ],
    'Schedule Management' => [
        ['slug' => 'calendar', 'href' => $researchDirectorBaseUrl . 'calendar', 'icon' => 'fa-calendar-alt', 'label' => 'Calendar'],
        ['slug' => 'venues', 'href' => $researchDirectorBaseUrl . 'venues', 'icon' => 'fa-map-marker-alt', 'label' => 'Venues'],
        ['slug' => 'finalize-defense-schedule', 'href' => $researchDirectorBaseUrl . 'finalize-defense-schedule', 'icon' => 'fa-clipboard-check', 'label' => 'Finalize Defense Schedule'],
    ],
    'Defense Participants' => [
        ['slug' => 'researchers', 'href' => $researchDirectorBaseUrl . 'researchers', 'icon' => 'fa-users', 'label' => 'Researchers'],
        ['slug' => 'advisers', 'href' => $researchDirectorBaseUrl . 'advisers', 'icon' => 'fa-user-tie', 'label' => 'Advisers'],
        ['slug' => 'panel-members', 'href' => $researchDirectorBaseUrl . 'panel-members', 'icon' => 'fa-users', 'label' => 'Panel Members'],
    ],
    'Communication' => [
        ['slug' => 'notifications', 'href' => $researchDirectorBaseUrl . 'notifications', 'icon' => 'fa-bell', 'label' => 'Notifications'],
    ],
    'Defense Results' => [
        ['slug' => 'defense-results', 'href' => $researchDirectorBaseUrl . 'defense-results', 'icon' => 'fa-chart-bar', 'label' => 'Defense Results'],
        ['slug' => 'digital-scores', 'href' => $researchDirectorBaseUrl . 'digital-scores', 'icon' => 'fa-poll', 'label' => 'Digital Scores'],
        ['slug' => 'defense-history', 'href' => $researchDirectorBaseUrl . 'defense-history', 'icon' => 'fa-history', 'label' => 'Defense History'],
    ],
    'Archiving' => [
        ['slug' => 'proceed-archiving', 'href' => $researchDirectorBaseUrl . 'proceed-archiving', 'icon' => 'fa-folder-open', 'label' => 'Proceed to Archiving'],
    ],
    'Profile' => [
        ['slug' => 'my-profile', 'href' => BASE_URL . '/modules/faculty/pages/my-profile.php', 'icon' => 'fa-user', 'label' => 'My Profile'],
        ['slug' => 'account-settings', 'href' => BASE_URL . '/account/profile.php', 'icon' => 'fa-user-cog', 'label' => 'Account Settings'],
    ],
    'System' => [
        ['slug' => 'security-settings', 'href' => BASE_URL . '/account/module-security.php?module=faculty', 'icon' => 'fa-shield-alt', 'label' => 'Security Settings'],
    ],
];
?>
<aside class="sms-sidebar" id="smsSidebar" aria-label="Main navigation">
    <nav class="sidebar-nav" id="smsSidebarAccordion">
        <ul class="nav flex-column">
            <?php if ($isStudentPortal): ?>
                <?php foreach ($studentNavGroups as $groupLabel => $groupItems): ?>
                    <li class="nav-item sidebar-group-label">
                        <span class="nav-link sidebar-group-heading"><?= htmlspecialchars($groupLabel) ?></span>
                    </li>
                    <?php foreach ($groupItems as $item): ?>
                        <?php
                        $isLocked  = !empty($item['locked']);
                        $linkClass = ($activeModule === 'student_portal' && $activePage === $item['slug']) ? 'active' : '';
                        if ($isLocked) { $linkClass .= ' nav-link-locked'; }
                        ?>
                        <li class="nav-item">
                            <?php if ($isLocked): ?>
                                <span class="nav-link sidebar-sub <?= $linkClass ?>"
                                      data-title="<?= htmlspecialchars($item['label']) ?> (Locked)"
                                      title="<?= htmlspecialchars($item['label']) ?> — Pay Research Forum to unlock"
                                      style="cursor:not-allowed;opacity:0.5;">
                                    <i class="fas fa-lock me-1" aria-hidden="true" style="font-size:0.75rem;"></i>
                                    <i class="fas <?= htmlspecialchars($item['icon']) ?>" aria-hidden="true"></i>
                                    <span><?= htmlspecialchars($item['label']) ?></span>
                                </span>
                            <?php else: ?>
                                <a class="nav-link sidebar-sub <?= $linkClass ?>"
                                   href="<?= htmlspecialchars($item['href']) ?>"
                                   data-title="<?= htmlspecialchars($item['label']) ?>"
                                   title="<?= htmlspecialchars($item['label']) ?>">
                                    <i class="fas <?= htmlspecialchars($item['icon']) ?>" aria-hidden="true"></i>
                                    <span><?= htmlspecialchars($item['label']) ?></span>
                                </a>
                            <?php endif; ?>
                        </li>
                    <?php endforeach; ?>
                <?php endforeach; ?>

            <?php elseif (in_array($roleKey, ['adviser', 'research_director'], true) && $activeModule === 'faculty'): ?>
                <?php $accountNavGroups = $roleKey === 'research_director' ? $researchDirectorNavGroups : $facultyAccountNavGroups; ?>
                <?php foreach ($accountNavGroups as $groupLabel => $groupItems): ?>
                    <li class="nav-item sidebar-group-label">
                        <span class="nav-link sidebar-group-heading"><?= htmlspecialchars($groupLabel) ?></span>
                    </li>
                    <?php foreach ($groupItems as $item): ?>
                        <?php $linkClass = ($activeModule === 'faculty' && $activePage === $item['slug']) ? 'active' : ''; ?>
                        <li class="nav-item">
                            <a class="nav-link sidebar-sub <?= $linkClass ?>"
                               href="<?= htmlspecialchars($item['href']) ?>"
                               data-title="<?= htmlspecialchars($item['label']) ?>"
                               title="<?= htmlspecialchars($item['label']) ?>">
                                <i class="fas <?= htmlspecialchars($item['icon']) ?>" aria-hidden="true"></i>
                                <span><?= htmlspecialchars($item['label']) ?></span>
                            </a>
                        </li>
                    <?php endforeach; ?>
                <?php endforeach; ?>

            <?php else: ?>
                <li class="nav-item sidebar-group-label">
                    <span class="nav-link sidebar-group-heading">Dashboard</span>
                </li>
                <li class="nav-item">
                    <a class="nav-link sidebar-sub <?= $activeModule === 'dashboard' ? 'active' : '' ?>"
                       href="<?= BASE_URL ?>/dashboard/index.php"
                       data-title="Overview"
                       title="Overview">
                        <i class="fas fa-th-large" aria-hidden="true"></i>
                        <span>Overview</span>
                    </a>
                </li>

                <?php foreach ($visibleModules as $navModuleKey => $module): ?>
                    <?php
                    $isModuleActive = ($activeModule === $navModuleKey);
                    $moduleFolder = $navModuleKey === 'student_portal' ? 'student-portal' : $navModuleKey;
                    $overviewUrl = BASE_URL . '/modules/' . $moduleFolder . '/index.php';
                    $moduleInMaint = smsIsModuleInMaintenance((string) $navModuleKey);
                    ?>
                    <li class="nav-item sidebar-group-label">
                        <span class="nav-link sidebar-group-heading">
                            <?= htmlspecialchars($module['label']) ?>
                            <?php if ($moduleInMaint): ?>
                                <span class="badge text-bg-warning ms-1" style="font-size:0.62rem;">Maint</span>
                            <?php endif; ?>
                        </span>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link sidebar-sub overview-link <?= ($isModuleActive && $activePage === '') ? 'active' : '' ?>"
                           href="<?= htmlspecialchars($overviewUrl) ?>">
                            <i class="fas fa-th-large" aria-hidden="true"></i>
                            <span>Overview</span>
                        </a>
                    </li>
                    <?php
                    // Check if module has grouped sidebar sections
                    $hasGroups = !empty($module['groups']) && is_array($module['groups']);
                    if ($hasGroups):
                        // Build a lookup map from slug to page title
                        $pageTitles = [];
                        foreach ($module['pages'] as $p) {
                            $pageTitles[$p['slug']] = $p['title'];
                        }
                        foreach ($module['groups'] as $groupLabel => $groupSlugs):
                    ?>
                        <li class="nav-item sidebar-group-label">
                            <span class="nav-link sidebar-group-heading"><?= htmlspecialchars($groupLabel) ?></span>
                        </li>
                        <?php foreach ($groupSlugs as $slug): ?>
                            <?php
                            if (!isset($pageTitles[$slug])) { continue; }
                            $isPageActive = ($isModuleActive && $activePage === $slug);
                            $pageHref = BASE_URL . '/modules/' . $moduleFolder . '/pages/' . $slug . '.php';
                            if ($slug === 'security-settings') {
                                $pageHref = BASE_URL . '/account/module-security.php?module=' . urlencode((string) $navModuleKey);
                            }
                            ?>
                            <li class="nav-item">
                                <a class="nav-link sidebar-sub <?= $isPageActive ? 'active' : '' ?>"
                                   href="<?= htmlspecialchars($pageHref) ?>">
                                    <i class="fas <?= htmlspecialchars(smsNavPageIcon($slug)) ?>" aria-hidden="true"></i>
                                    <span><?= htmlspecialchars($pageTitles[$slug]) ?></span>
                                </a>
                            </li>
                        <?php endforeach; ?>
                    <?php endforeach; ?>
                    <?php else: ?>
                        <?php foreach ($module['pages'] as $page): ?>
                            <?php
                            $isPageActive = ($isModuleActive && $activePage === $page['slug']);
                            $pageHref = BASE_URL . '/modules/' . $moduleFolder . '/pages/' . $page['slug'] . '.php';
                            // Module Security: keep CRAD/etc. focus when already inside a module.
                            if ($navModuleKey === 'user-management' && $page['slug'] === 'module-security') {
                                $secFocus = (string) ($_SESSION['um_sec_focus'] ?? '');
                                if ($secFocus !== '' && ($activePage ?? '') === 'module-security' && empty($_GET['picker'])) {
                                    $pageHref .= '?focus=' . rawurlencode($secFocus);
                                } else {
                                    $pageHref .= '?picker=1';
                                }
                            }
                            ?>
                            <li class="nav-item">
                                <a class="nav-link sidebar-sub <?= $isPageActive ? 'active' : '' ?>"
                                   href="<?= htmlspecialchars($pageHref) ?>">
                                    <i class="fas <?= htmlspecialchars(smsNavPageIcon($page['slug'])) ?>" aria-hidden="true"></i>
                                    <span><?= htmlspecialchars($page['title']) ?></span>
                                </a>
                            </li>
                        <?php endforeach; ?>
                    <?php endif; ?>
                <?php endforeach; ?>
                <?php if ($securitySettingsModule !== '' && !$moduleHasSecuritySettingsPage): ?>
                    <li class="nav-item sidebar-group-label">
                        <span class="nav-link sidebar-group-heading">System</span>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link sidebar-sub <?= ($activePage === 'security-settings') ? 'active' : '' ?>"
                           href="<?= BASE_URL ?>/account/module-security.php?module=<?= urlencode($securitySettingsModule) ?>">
                            <i class="fas fa-shield-alt" aria-hidden="true"></i>
                            <span>Security Settings</span>
                        </a>
                    </li>
                <?php endif; ?>
                <?php unset($navModuleKey, $module, $page, $isModuleActive, $overviewUrl, $pageHref, $isPageActive, $secFocus); ?>            <?php endif; ?>
        </ul>
    </nav>
</aside>

<div class="sidebar-overlay" id="sidebarOverlay"></div>
