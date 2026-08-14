<?php
/**
 * Research Implementation & Progress Monitoring
 * Helper Functions for Duplicate Prevention and Database Operations
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/config.php';
require_once ROOT_PATH . '/includes/uploads.php';

function rpNormalizeEmail(string $email): string
{
    return strtolower(trim($email));
}

function rpCurrentUserEmail(): string
{
    $email = rpNormalizeEmail((string) ($_SESSION['user_email'] ?? ''));
    if ($email !== '') {
        return $email;
    }

    $userId = (int) ($_SESSION['user_id'] ?? 0);
    if ($userId <= 0 || !function_exists('db')) {
        return '';
    }

    try {
        $sms = db();
        if (!$sms) {
            return '';
        }
        $stmt = $sms->prepare('SELECT email FROM users WHERE id = ? LIMIT 1');
        $stmt->execute([$userId]);
        return rpNormalizeEmail((string) ($stmt->fetchColumn() ?: ''));
    } catch (Throwable $e) {
        error_log('Unable to resolve current user email: ' . $e->getMessage());
        return '';
    }
}

function rpAdviserAssignmentMatchSql(string $assignmentAlias = 'raa', string $groupAlias = 'rg'): string
{
    return "((
                {$assignmentAlias}.research_group_id IS NOT NULL
            AND {$assignmentAlias}.research_group_id = {$groupAlias}.id
        ) OR (
                {$assignmentAlias}.research_group_id IS NULL
            AND {$assignmentAlias}.group_number IS NOT NULL
            AND {$assignmentAlias}.group_number = {$groupAlias}.group_number
        ))";
}

function rpAdviserIdentitySql(string $assignmentAlias = 'raa'): string
{
    return "((
                {$assignmentAlias}.adviser_user_id IS NOT NULL
            AND {$assignmentAlias}.adviser_user_id = :adviser_user_id
        ) OR (
                :adviser_email <> ''
            AND TRIM(COALESCE({$assignmentAlias}.adviser_email, '')) <> ''
            AND LOWER(TRIM({$assignmentAlias}.adviser_email)) = :adviser_email_match
        ))";
}

function rpActiveAdviserAssignmentStatusSql(string $assignmentAlias = 'raa'): string
{
    return "{$assignmentAlias}.assignment_status IN ('Assigned', 'Confirmed')";
}

function rpAdviserIdentityParams(int $adviserUserId, string $adviserEmail): array
{
    $email = rpNormalizeEmail($adviserEmail);
    return [
        ':adviser_user_id' => $adviserUserId,
        ':adviser_email' => $email,
        ':adviser_email_match' => $email,
    ];
}

function rpDefaultMilestoneRows(): array
{
    return [
        ['id' => null, 'milestone_name' => 'Chapter 1', 'milestone_order' => 1, 'description' => 'Introduction and Background', 'status' => 'Not Started', 'progress_percentage' => 0, 'pending_count' => 0, 'update_count' => 0, 'last_update_at' => null, 'start_date' => null, 'target_date' => null, 'completed_at' => null, 'researcher_notes' => '', 'adviser_remarks' => ''],
        ['id' => null, 'milestone_name' => 'Chapter 2', 'milestone_order' => 2, 'description' => 'Review of Related Literature', 'status' => 'Not Started', 'progress_percentage' => 0, 'pending_count' => 0, 'update_count' => 0, 'last_update_at' => null, 'start_date' => null, 'target_date' => null, 'completed_at' => null, 'researcher_notes' => '', 'adviser_remarks' => ''],
        ['id' => null, 'milestone_name' => 'Chapter 3', 'milestone_order' => 3, 'description' => 'Methodology', 'status' => 'Not Started', 'progress_percentage' => 0, 'pending_count' => 0, 'update_count' => 0, 'last_update_at' => null, 'start_date' => null, 'target_date' => null, 'completed_at' => null, 'researcher_notes' => '', 'adviser_remarks' => ''],
        ['id' => null, 'milestone_name' => 'System Development', 'milestone_order' => 4, 'description' => 'System Implementation', 'status' => 'Not Started', 'progress_percentage' => 0, 'pending_count' => 0, 'update_count' => 0, 'last_update_at' => null, 'start_date' => null, 'target_date' => null, 'completed_at' => null, 'researcher_notes' => '', 'adviser_remarks' => ''],
        ['id' => null, 'milestone_name' => 'Testing', 'milestone_order' => 5, 'description' => 'Testing and Quality Assurance', 'status' => 'Not Started', 'progress_percentage' => 0, 'pending_count' => 0, 'update_count' => 0, 'last_update_at' => null, 'start_date' => null, 'target_date' => null, 'completed_at' => null, 'researcher_notes' => '', 'adviser_remarks' => ''],
        ['id' => null, 'milestone_name' => 'Documentation', 'milestone_order' => 6, 'description' => 'Final Documentation and Report', 'status' => 'Not Started', 'progress_percentage' => 0, 'pending_count' => 0, 'update_count' => 0, 'last_update_at' => null, 'start_date' => null, 'target_date' => null, 'completed_at' => null, 'researcher_notes' => '', 'adviser_remarks' => ''],
    ];
}

function rpGetResearchPlan(PDO $crad, int $groupId): ?array
{
    if ($groupId <= 0) {
        return null;
    }

    $stmt = $crad->prepare('SELECT * FROM research_plans WHERE research_group_id = ? LIMIT 1');
    $stmt->execute([$groupId]);
    $plan = $stmt->fetch(PDO::FETCH_ASSOC);
    return $plan ?: null;
}

function rpChapterMilestoneNames(): array
{
    return [
        1 => 'Chapter 1',
        2 => 'Chapter 2',
        3 => 'Chapter 3',
    ];
}

function rpMilestoneChapterNumber(array $milestone): ?int
{
    $order = (int) ($milestone['milestone_order'] ?? 0);
    $name = strtolower(trim((string) ($milestone['milestone_name'] ?? '')));

    if ($order >= 1 && $order <= 3 && preg_match('/^chapter\s+' . $order . '\b/i', (string) ($milestone['milestone_name'] ?? ''))) {
        return $order;
    }

    if (preg_match('/^chapter\s+([1-3])\b/i', $name, $matches)) {
        return (int) $matches[1];
    }

    return null;
}

function rpChapterSubmissionProgressState(PDO $crad, int $groupId, int $chapter): array
{
    $empty = [
        'progress_percentage' => 0.0,
        'status' => 'Not Started',
        'chapter_status' => null,
        'latest_submission_id' => null,
        'latest_version_number' => null,
        'latest_submitted_at' => null,
        'latest_updated_at' => null,
    ];

    if ($groupId <= 0 || $chapter < 1 || $chapter > 3) {
        return $empty;
    }

    try {
        $stmt = $crad->prepare(
            "SELECT id, version_number, status, submitted_at, updated_at
             FROM chapter_submissions
             WHERE research_group_id = :group_id
               AND chapter_number = :chapter
             ORDER BY version_number DESC, id DESC"
        );
        $stmt->execute([':group_id' => $groupId, ':chapter' => $chapter]);
        $submissions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log('Chapter milestone sync lookup failed: ' . $e->getMessage());
        return $empty;
    }

    if (!$submissions) {
        return $empty;
    }

    $latest = $submissions[0];
    $highestProgress = 0.0;
    foreach ($submissions as $submission) {
        $status = (string) ($submission['status'] ?? '');
        $highestProgress = max($highestProgress, match ($status) {
            'Accepted' => 100.0,
            'Under Review', 'Needs Revision' => 66.0,
            'Submitted' => 33.0,
            default => 0.0,
        });
    }

    $latestStatus = (string) ($latest['status'] ?? '');
    $progress = match ($latestStatus) {
        'Accepted' => 100.0,
        'Under Review', 'Needs Revision' => 66.0,
        'Submitted' => max(33.0, min(66.0, $highestProgress)),
        default => 0.0,
    };

    $status = match ($latestStatus) {
        'Accepted' => 'Completed',
        'Needs Revision' => 'Revision Requested',
        'Submitted', 'Under Review' => 'In Progress',
        default => 'Not Started',
    };

    return [
        'progress_percentage' => $progress,
        'status' => $status,
        'chapter_status' => $latestStatus ?: null,
        'latest_submission_id' => (int) ($latest['id'] ?? 0) ?: null,
        'latest_version_number' => (int) ($latest['version_number'] ?? 0) ?: null,
        'latest_submitted_at' => $latest['submitted_at'] ?? null,
        'latest_updated_at' => $latest['updated_at'] ?? null,
    ];
}

function rpApplyChapterMilestoneOverrides(PDO $crad, int $groupId, array $milestones): array
{
    foreach ($milestones as &$milestone) {
        $chapter = rpMilestoneChapterNumber($milestone);
        $milestone['is_chapter_synced'] = false;
        if ($chapter) {
            $milestone['chapter_number'] = $chapter;
        }
    }
    unset($milestone);

    return $milestones;
}

function rpMilestonesOverallProgress(array $milestones): float
{
    if (!$milestones) {
        return 0.0;
    }

    $total = 0.0;
    foreach ($milestones as $milestone) {
        $total += (float) ($milestone['progress_percentage'] ?? 0);
    }

    return round($total / count($milestones), 2);
}

function rpApplySyncedPlanProgress(array $plan, array $milestones): array
{
    $plan['overall_progress'] = rpMilestonesOverallProgress($milestones);
    return $plan;
}

function rpGetMilestonesForPlan(PDO $crad, ?int $planId, ?int $groupId = null): array
{
    if (!$planId) {
        $milestones = rpDefaultMilestoneRows();
        return $groupId ? rpApplyChapterMilestoneOverrides($crad, $groupId, $milestones) : $milestones;
    }

    $stmt = $crad->prepare("
        SELECT *
        FROM research_milestones
        WHERE research_plan_id = ?
        ORDER BY milestone_order ASC
    ");
    $stmt->execute([$planId]);
    $milestones = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $milestones = $milestones ?: rpDefaultMilestoneRows();
    return $groupId ? rpApplyChapterMilestoneOverrides($crad, $groupId, $milestones) : $milestones;
}

function rpGetMilestonesWithUpdateStats(PDO $crad, ?int $planId, ?int $groupId = null): array
{
    if (!$planId) {
        $milestones = rpDefaultMilestoneRows();
        return $groupId ? rpApplyChapterMilestoneOverrides($crad, $groupId, $milestones) : $milestones;
    }

    $stmt = $crad->prepare(
        "SELECT rm.*,
                (SELECT COUNT(*) FROM research_progress_updates rpu WHERE rpu.milestone_id = rm.id) AS update_count,
                (SELECT COUNT(*) FROM research_progress_updates rpu WHERE rpu.milestone_id = rm.id
                   AND rpu.milestone_status = 'Submitted for Review') AS pending_count,
                (SELECT rpu.submitted_at FROM research_progress_updates rpu WHERE rpu.milestone_id = rm.id
                 ORDER BY rpu.submitted_at DESC LIMIT 1) AS last_update_at
         FROM research_milestones rm
         WHERE rm.research_plan_id = ?
         ORDER BY rm.milestone_order ASC"
    );
    $stmt->execute([$planId]);
    $milestones = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: rpDefaultMilestoneRows();

    return $groupId ? rpApplyChapterMilestoneOverrides($crad, $groupId, $milestones) : $milestones;
}

function rpSyncChapterMilestonesFromSubmissions(PDO $crad, int $groupId): void
{
    // Chapter 1-3 research progress is adviser-review controlled now.
    // Official Grammarian submissions must not drive Research Development state.
    return;
}

function rpChapterControlledMilestoneState(PDO $crad, int $milestoneId): ?array
{
    return null;
}

function rpEnsureProgressAttachmentSchema(PDO $crad): void
{
    $crad->exec(
        "CREATE TABLE IF NOT EXISTS research_progress_attachments (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            progress_update_id INT UNSIGNED NOT NULL,
            file_name VARCHAR(300) NOT NULL,
            file_path VARCHAR(500) NOT NULL,
            file_type VARCHAR(100) NOT NULL DEFAULT '',
            file_size INT UNSIGNED NOT NULL DEFAULT 0,
            uploaded_by INT UNSIGNED NOT NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            KEY idx_rpa_update (progress_update_id),
            KEY idx_rpa_uploaded (uploaded_by)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );
}

function rpLatestAttachmentForUpdate(PDO $crad, int $progressUpdateId): ?array
{
    if ($progressUpdateId <= 0) {
        return null;
    }
    rpEnsureProgressAttachmentSchema($crad);
    $stmt = $crad->prepare(
        "SELECT *
         FROM research_progress_attachments
         WHERE progress_update_id = ?
         ORDER BY id DESC
         LIMIT 1"
    );
    $stmt->execute([$progressUpdateId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function rpProgressAttachmentUrl(int $attachmentId, bool $download = false): string
{
    return BASE_URL . '/modules/crad/api/progress-document.php?id=' . $attachmentId . ($download ? '&download=1' : '');
}

function rpAdviserApprovedChapter(PDO $crad, int $groupId, int $chapter): ?array
{
    if ($groupId <= 0 || $chapter < 1 || $chapter > 3) {
        return null;
    }

    $stmt = $crad->prepare(
        "SELECT rpu.id AS progress_update_id, rpu.milestone_id, rpu.research_group_id,
                rpu.new_progress, rpu.submitted_at, rpu.updated_at,
                rpf.id AS feedback_id, rpf.adviser_user_id AS approved_by,
                rpf.adviser_name AS approved_by_name, rpf.created_at AS approved_at
         FROM research_progress_updates rpu
         INNER JOIN research_milestones rm ON rm.id = rpu.milestone_id
         INNER JOIN research_progress_feedback rpf ON rpf.id = (
            SELECT rpf2.id
            FROM research_progress_feedback rpf2
            WHERE rpf2.progress_update_id = rpu.id
              AND rpf2.feedback_type = 'Progress Approved'
              AND rpf2.new_milestone_status = 'Approved'
            ORDER BY rpf2.created_at DESC, rpf2.id DESC
            LIMIT 1
         )
         WHERE rpu.research_group_id = :gid
           AND rpu.milestone_status IN ('Submitted for Review', 'Approved')
           AND rm.milestone_order = :chapter
           AND LOWER(TRIM(rm.milestone_name)) = :chapter_name
           AND rpu.id = (
                SELECT rpu2.id
                FROM research_progress_updates rpu2
                INNER JOIN research_milestones rm2 ON rm2.id = rpu2.milestone_id
                WHERE rpu2.research_group_id = :gid2
                  AND rm2.milestone_order = :chapter2
                  AND LOWER(TRIM(rm2.milestone_name)) = :chapter_name2
                ORDER BY rpu2.submitted_at DESC, rpu2.id DESC
                LIMIT 1
           )
         LIMIT 1"
    );
    $chapterName = 'chapter ' . $chapter;
    $stmt->execute([
        ':gid' => $groupId,
        ':chapter' => $chapter,
        ':chapter_name' => $chapterName,
        ':gid2' => $groupId,
        ':chapter2' => $chapter,
        ':chapter_name2' => $chapterName,
    ]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function rpChapterSubmissionEligibility(PDO $crad, int $groupId): array
{
    $eligibility = [];
    foreach (rpChapterMilestoneNames() as $chapter => $label) {
        $approval = rpAdviserApprovedChapter($crad, $groupId, (int) $chapter);
        $eligibility[(int) $chapter] = [
            'chapter' => (int) $chapter,
            'label' => $label,
            'eligible' => (bool) $approval,
            'message' => $approval ? 'Ready for Submission' : 'Adviser Approval Required',
            'approval' => $approval,
        ];
    }
    return $eligibility;
}

function rpGetAssignedResearchGroupsForAdviser(PDO $crad, int $adviserUserId, string $adviserEmail): array
{
    if ($adviserUserId <= 0 && rpNormalizeEmail($adviserEmail) === '') {
        return [];
    }

    $assignmentMatch = rpAdviserAssignmentMatchSql('raa2', 'rg');
    $identitySql = rpAdviserIdentitySql('raa2');
    $statusSql = rpActiveAdviserAssignmentStatusSql('raa2');

    $stmt = $crad->prepare("
        SELECT
            rg.id,
            rg.group_number,
            rg.group_name,
            rg.research_title,
            rg.academic_year,
            rg.status AS group_status,
            raa.assignment_status,
            raa.adviser_user_id,
            raa.adviser_name,
            raa.adviser_email,
            rp.id AS plan_id,
            COALESCE(rp.overall_progress, 0) AS overall_progress,
            COALESCE(rp.current_stage, 'Planning') AS current_stage,
            rp.status AS plan_status,
            rp.updated_at AS plan_updated_at,
            (SELECT COUNT(*)
               FROM research_progress_updates rpu
              WHERE rpu.research_group_id = rg.id
                AND rpu.milestone_status = 'Submitted for Review') AS pending_reviews,
            (SELECT COUNT(*)
               FROM research_progress_updates rpu2
              WHERE rpu2.research_group_id = rg.id) AS update_count,
            (SELECT MAX(rpu3.submitted_at)
               FROM research_progress_updates rpu3
              WHERE rpu3.research_group_id = rg.id) AS last_update_at,
            (SELECT COUNT(*)
               FROM research_milestones rm2
              WHERE rm2.research_plan_id = rp.id) AS total_milestones,
            (SELECT COUNT(*)
               FROM research_milestones rm3
              WHERE rm3.research_plan_id = rp.id
                AND rm3.status IN ('Approved','Completed')) AS done_milestones
        FROM research_groups rg
        INNER JOIN research_adviser_assignments raa ON raa.id = (
            SELECT raa2.id
            FROM research_adviser_assignments raa2
            WHERE {$assignmentMatch}
              AND {$identitySql}
              AND {$statusSql}
            ORDER BY (raa2.assignment_status = 'Confirmed') DESC,
                     (raa2.assignment_status = 'Assigned') DESC,
                     raa2.updated_at DESC,
                     raa2.id DESC
            LIMIT 1
        )
        LEFT JOIN research_plans rp ON rp.research_group_id = rg.id
        WHERE rg.status = 'Approved'
        ORDER BY rg.date_assigned DESC, rg.id DESC
    ");

    $stmt->execute(rpAdviserIdentityParams($adviserUserId, $adviserEmail));
    $groups = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($groups as &$group) {
        $group['milestones'] = rpGetMilestonesForPlan(
            $crad,
            !empty($group['plan_id']) ? (int) $group['plan_id'] : null,
            (int) $group['id']
        );
        $group['overall_progress'] = rpMilestonesOverallProgress($group['milestones']);
        $group['total_milestones'] = count($group['milestones']);
        $group['done_milestones'] = count(array_filter(
            $group['milestones'],
            static fn(array $milestone): bool => in_array((string) ($milestone['status'] ?? ''), ['Approved', 'Completed'], true)
        ));
    }
    unset($group);

    return $groups;
}

function rpGetAssignedResearchGroupForAdviser(PDO $crad, int $adviserUserId, string $adviserEmail, string $groupNumber): ?array
{
    $groupNumber = trim($groupNumber);
    if ($groupNumber === '') {
        return null;
    }

    foreach (rpGetAssignedResearchGroupsForAdviser($crad, $adviserUserId, $adviserEmail) as $group) {
        if ((string) ($group['group_number'] ?? '') === $groupNumber) {
            return $group;
        }
    }

    return null;
}

function rpClearActiveAdviserResearchGroup(): void
{
    unset(
        $_SESSION['active_research_group_id'],
        $_SESSION['active_research_group_number']
    );
}

function rpSetActiveAdviserResearchGroup(array $group): void
{
    $_SESSION['active_research_group_id'] = (int) ($group['id'] ?? 0);
    $_SESSION['active_research_group_number'] = (string) ($group['group_number'] ?? '');
}

function rpResolveAdviserResearchGroupContext(PDO $crad, int $adviserUserId, string $adviserEmail, ?string $requestedGroupNumber = null): array
{
    $groups = rpGetAssignedResearchGroupsForAdviser($crad, $adviserUserId, $adviserEmail);
    $requestedGroupNumber = trim((string) $requestedGroupNumber);

    if (!$groups) {
        rpClearActiveAdviserResearchGroup();
        return ['status' => 'no_groups', 'group' => null, 'groups' => []];
    }

    if ($requestedGroupNumber !== '') {
        foreach ($groups as $group) {
            if ((string) ($group['group_number'] ?? '') === $requestedGroupNumber) {
                rpSetActiveAdviserResearchGroup($group);
                return ['status' => 'ok', 'group' => $group, 'groups' => $groups];
            }
        }

        rpClearActiveAdviserResearchGroup();
        return ['status' => 'invalid_requested', 'group' => null, 'groups' => $groups];
    }

    $activeId = (int) ($_SESSION['active_research_group_id'] ?? 0);
    if ($activeId > 0) {
        foreach ($groups as $group) {
            if ((int) ($group['id'] ?? 0) === $activeId) {
                rpSetActiveAdviserResearchGroup($group);
                return ['status' => 'ok', 'group' => $group, 'groups' => $groups];
            }
        }
        rpClearActiveAdviserResearchGroup();
    }

    if (count($groups) === 1) {
        rpSetActiveAdviserResearchGroup($groups[0]);
        return ['status' => 'ok', 'group' => $groups[0], 'groups' => $groups];
    }

    return ['status' => 'needs_selection', 'group' => null, 'groups' => $groups];
}

function rpRenderAdviserGroupSelector(array $groups, string $title = 'Select Research Group', string $description = 'Choose a research group to continue.'): void
{
    $currentPath = strtok((string) ($_SERVER['REQUEST_URI'] ?? ''), '?');
    $action = htmlspecialchars($currentPath ?: '', ENT_QUOTES);
    ?>
    <div class="glass-dashboard"><div class="glass-board">
        <div class="glass-panel"><div class="glass-panel-body rm-empty">
            <div class="rm-empty-icon"><i class="fas fa-layer-group" style="color:#2563eb;"></i></div>
            <h6><?= htmlspecialchars($title) ?></h6>
            <p><?= htmlspecialchars($description) ?></p>
            <form method="GET" action="<?= $action ?>" class="mt-3" style="max-width:520px;margin:0 auto;">
                <div class="input-group">
                    <select name="group" class="form-select" required>
                        <option value="">Select assigned group</option>
                        <?php foreach ($groups as $group): ?>
                            <option value="<?= htmlspecialchars((string) $group['group_number'], ENT_QUOTES) ?>">
                                <?= htmlspecialchars((string) $group['group_name']) ?>
                                (<?= htmlspecialchars((string) $group['group_number']) ?>)
                            </option>
                        <?php endforeach; ?>
                    </select>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-arrow-right me-1"></i>Open
                    </button>
                </div>
            </form>
        </div></div>
    </div></div>
    <?php
}

function rpRenderAdviserNoGroupsState(): void
{
    ?>
    <div class="glass-dashboard"><div class="glass-board">
        <div class="glass-panel"><div class="glass-panel-body rm-empty">
            <div class="rm-empty-icon"><i class="fas fa-users"></i></div>
            <h6>No Research Groups Assigned</h6>
            <p>You currently have no research groups assigned for monitoring.</p>
        </div></div>
    </div></div>
    <?php
}

function rpRenderAdviserGroupAccessDenied(): void
{
    ?>
    <div class="glass-dashboard"><div class="glass-board">
        <div class="glass-panel"><div class="glass-panel-body rm-empty">
            <div class="rm-empty-icon"><i class="fas fa-ban" style="color:#ef4444;"></i></div>
            <h6>Access Denied</h6>
            <p>This research group is not assigned to you or is no longer available.</p>
            <a href="<?= BASE_URL ?>/modules/faculty/pages/my-research-groups.php" class="btn btn-primary mt-3">
                <i class="fas fa-users me-2"></i>View My Research Groups
            </a>
        </div></div>
    </div></div>
    <?php
}

function rpGetProgressUpdateForAdviser(PDO $crad, int $progressUpdateId, int $adviserUserId, string $adviserEmail): ?array
{
    if ($progressUpdateId <= 0) {
        return null;
    }

    $assignmentMatch = rpAdviserAssignmentMatchSql('raa2', 'rg');
    $identitySql = rpAdviserIdentitySql('raa2');
    $statusSql = rpActiveAdviserAssignmentStatusSql('raa2');

    $stmt = $crad->prepare("
        SELECT
            rpu.*,
            rg.group_number,
            rg.leader_id
        FROM research_progress_updates rpu
        INNER JOIN research_groups rg ON rg.id = rpu.research_group_id
        INNER JOIN research_adviser_assignments raa ON raa.id = (
            SELECT raa2.id
            FROM research_adviser_assignments raa2
            WHERE {$assignmentMatch}
              AND {$identitySql}
              AND {$statusSql}
            ORDER BY (raa2.assignment_status = 'Confirmed') DESC,
                     (raa2.assignment_status = 'Assigned') DESC,
                     raa2.updated_at DESC,
                     raa2.id DESC
            LIMIT 1
        )
        WHERE rpu.id = :progress_update_id
        LIMIT 1
    ");

    $params = rpAdviserIdentityParams($adviserUserId, $adviserEmail);
    $params[':progress_update_id'] = $progressUpdateId;
    $stmt->execute($params);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row ?: null;
}

/**
 * Get the student's research group — but ONLY if it qualifies for the
 * Capstone Group/Student Registry (fully approved title, all three signatures,
 * active coordinator assignment, and an assigned adviser).
 *
 * This is the single authoritative gate used by every Research Development
 * page in the student portal.  If the group does not appear in the Registry,
 * NULL is returned and the calling page must deny access.
 *
 * @param PDO    $crad          CRAD database connection
 * @param string $studentId     Student ID from session  (e.g. "S230000001")
 * @param int    $studentUserId User ID from session     (sms2_db.users.id)
 * @return array|null           research_groups row (+ adviser info) or null
 */
function rpGetRegisteredResearchGroup(PDO $crad, string $studentId, int $studentUserId): ?array
{
    $stmt = $crad->prepare("
        SELECT
            rg.*,
            COALESCE(raa.adviser_user_id, NULL)   AS adviser_user_id,
            COALESCE(raa.adviser_name,   '')       AS adviser_name,
            COALESCE(raa.adviser_email,  '')       AS adviser_email
        FROM research_groups rg

        /* Title Approval must be fully approved with all three signatures */
        JOIN title_approvals t ON t.id = rg.title_approval_id

        /* Active research coordinator assignment */
        JOIN research_coordinator_assignments ca ON ca.id = (
            SELECT ca2.id
            FROM   research_coordinator_assignments ca2
            WHERE  ca2.status = 'Active'
              AND  (
                    ca2.research_group_id = rg.id
                 OR (ca2.research_group_id IS NULL AND ca2.group_number = rg.group_number)
              )
            ORDER BY ca2.updated_at DESC, ca2.id DESC
            LIMIT 1
        )

        /* Adviser assignment (any status — Assigned or Confirmed) */
        LEFT JOIN research_adviser_assignments raa ON raa.id = (
            SELECT aa2.id
            FROM   research_adviser_assignments aa2
            WHERE  (
                    aa2.research_group_id = rg.id
                 OR (aa2.research_group_id IS NULL AND aa2.group_number = rg.group_number)
              )
            ORDER BY (aa2.assignment_status = 'Confirmed') DESC,
                     (aa2.assignment_status = 'Assigned')  DESC,
                     aa2.updated_at DESC, aa2.id DESC
            LIMIT 1
        )

        WHERE rg.title_approval_id IS NOT NULL

          /* All three approval statuses must be 'Approved' */
          AND t.status               = 'Approved'
          AND t.coordinator_status   = 'Approved'
          AND t.crad_status          = 'Approved'

          /* All three digital signatures must be present */
          AND t.adviser_signature_data     IS NOT NULL
          AND t.adviser_signature_data     <> ''
          AND t.coordinator_signature_data IS NOT NULL
          AND t.coordinator_signature_data <> ''
          AND t.crad_signature_data        IS NOT NULL
          AND t.crad_signature_data        <> ''

          /* Non-empty required fields */
          AND TRIM(COALESCE(rg.research_title, '')) <> ''
          AND TRIM(COALESCE(rg.academic_year,  '')) <> ''
          AND (
               TRIM(COALESCE(rg.college_dept, ''))  <> ''
            OR TRIM(COALESCE(t.department,    ''))   <> ''
          )

          /* Must be this student's group (as leader) */
          AND (
               rg.leader_id = ?
            OR rg.leader_id = (
                 SELECT student_id
                 FROM   sms2_db.users
                 WHERE  id = ?
                 LIMIT  1
               )
          )

        ORDER BY rg.date_assigned DESC
        LIMIT 1
    ");

    $stmt->execute([$studentId, $studentUserId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

/**
 * Get or create research plan for a group (idempotent)
 * Returns existing plan if found, creates new one if not exists
 * 
 * @param PDO $crad CRAD database connection
 * @param int $groupId Research group ID
 * @return array|null Research plan record
 */
function rpGetOrCreateResearchPlan(PDO $crad, int $groupId): ?array
{
    if ($groupId <= 0) {
        return null;
    }
    
    // Check for existing plan first (DUPLICATE PREVENTION)
    $stmt = $crad->prepare("SELECT * FROM research_plans WHERE research_group_id = ? LIMIT 1");
    $stmt->execute([$groupId]);
    $existing = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($existing) {
        return $existing;
    }
    
    // Get group details
    $groupStmt = $crad->prepare("
        SELECT rg.*, raa.adviser_user_id, raa.adviser_name, raa.adviser_email
        FROM research_groups rg
        LEFT JOIN research_adviser_assignments raa ON raa.id = (
            SELECT raa2.id
            FROM research_adviser_assignments raa2
            WHERE " . rpAdviserAssignmentMatchSql('raa2', 'rg') . "
              AND " . rpActiveAdviserAssignmentStatusSql('raa2') . "
            ORDER BY (raa2.assignment_status = 'Confirmed') DESC,
                     (raa2.assignment_status = 'Assigned') DESC,
                     raa2.updated_at DESC,
                     raa2.id DESC
            LIMIT 1
        )
        WHERE rg.id = ?
        LIMIT 1
    ");
    $groupStmt->execute([$groupId]);
    $group = $groupStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$group) {
        return null;
    }
    
    // Create new plan
    $insertStmt = $crad->prepare("
        INSERT INTO research_plans (
            research_group_id, group_number, research_title,
            adviser_id, adviser_name, start_date, status
        ) VALUES (?, ?, ?, ?, ?, CURDATE(), 'Active')
    ");
    
    try {
        $insertStmt->execute([
            $groupId,
            $group['group_number'],
            $group['research_title'],
            $group['adviser_user_id'] ?? null,
            $group['adviser_name'] ?: $group['adviser']
        ]);
        
        $planId = (int) $crad->lastInsertId();
        
        // Initialize default milestones
        rpInitializeDefaultMilestones($crad, $planId);
        
        // Fetch and return the new plan
        $stmt->execute([$groupId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        
    } catch (PDOException $e) {
        // Check for duplicate key error (unique key is `uniq_rp_group`)
        if (strpos($e->getMessage(), 'uniq_rp_group') !== false) {
            // Another process created it, fetch and return
            $stmt->execute([$groupId]);
            return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        }
        throw $e;
    }
}

/**
 * Initialize default milestones for a research plan (idempotent)
 * Uses INSERT IGNORE to prevent duplicates
 * 
 * @param PDO $crad CRAD database connection
 * @param int $planId Research plan ID
 * @return int Number of milestones created
 */
function rpInitializeDefaultMilestones(PDO $crad, int $planId): int
{
    $defaultMilestones = [
        ['name' => 'Chapter 1', 'order' => 1, 'desc' => 'Introduction and Background'],
        ['name' => 'Chapter 2', 'order' => 2, 'desc' => 'Review of Related Literature'],
        ['name' => 'Chapter 3', 'order' => 3, 'desc' => 'Methodology'],
        ['name' => 'System Development', 'order' => 4, 'desc' => 'System Implementation'],
        ['name' => 'Testing', 'order' => 5, 'desc' => 'Testing and Quality Assurance'],
        ['name' => 'Documentation', 'order' => 6, 'desc' => 'Final Documentation and Report']
    ];
    
    // Use INSERT IGNORE to prevent duplicate milestones
    $stmt = $crad->prepare("
        INSERT IGNORE INTO research_milestones (
            research_plan_id, milestone_name, milestone_order, description, status
        ) VALUES (?, ?, ?, ?, 'Not Started')
    ");
    
    $count = 0;
    foreach ($defaultMilestones as $milestone) {
        try {
            $stmt->execute([
                $planId,
                $milestone['name'],
                $milestone['order'],
                $milestone['desc']
            ]);
            $count += $stmt->rowCount();
        } catch (PDOException $e) {
            // Ignore duplicate key errors
            if (strpos($e->getMessage(), 'uniq_rm_plan_name') === false) {
                error_log('Failed to create milestone: ' . $e->getMessage());
            }
        }
    }
    
    return $count;
}

/**
 * Generate unique submission token for duplicate prevention
 * 
 * @return string 32-character hex token
 */
function rpGenerateSubmissionToken(): string
{
    return bin2hex(random_bytes(16));
}

/**
 * Check if submission token was recently used (duplicate detection)
 * 
 * @param PDO $crad CRAD database connection
 * @param string $table Table name (research_progress_updates or research_progress_feedback)
 * @param string $token Submission token
 * @param int $windowMinutes Time window in minutes (default 5)
 * @return bool True if token was recently used
 */
function rpIsTokenRecentlyUsed(PDO $crad, string $table, string $token, int $windowMinutes = 5): bool
{
    if (empty($token)) {
        return false;
    }
    
    $allowedTables = ['research_progress_updates', 'research_progress_feedback'];
    if (!in_array($table, $allowedTables, true)) {
        return false;
    }
    
    $timeColumn = $table === 'research_progress_updates' ? 'submitted_at' : 'created_at';
    
    $stmt = $crad->prepare("
        SELECT COUNT(*) FROM {$table}
        WHERE submission_token = ?
          AND {$timeColumn} >= DATE_SUB(NOW(), INTERVAL ? MINUTE)
    ");
    
    $stmt->execute([$token, $windowMinutes]);
    return (int) $stmt->fetchColumn() > 0;
}

/**
 * Submit progress update with duplicate prevention
 * 
 * @param PDO $crad CRAD database connection
 * @param array $data Progress update data
 * @return array Result with success status and message
 */
function rpSubmitProgressUpdate(PDO $crad, array $data): array
{
    // Validate required fields
    $required = ['research_plan_id', 'research_group_id', 'submitted_by_user_id', 
                 'submitted_by_name', 'new_progress'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return ['success' => false, 'message' => "Missing required field: {$field}"];
        }
    }
    
    // Check for duplicate submission token
    if (!empty($data['submission_token'])) {
        if (rpIsTokenRecentlyUsed($crad, 'research_progress_updates', $data['submission_token'])) {
            return [
                'success' => false, 
                'message' => 'Duplicate submission detected. Please wait before submitting again.',
                'is_duplicate' => true
            ];
        }
    }
    
    // Validate progress range
    $newProgress = (float) $data['new_progress'];
    if ($newProgress < 0 || $newProgress > 100) {
        return ['success' => false, 'message' => 'Progress must be between 0 and 100'];
    }
    
    try {
        $crad->beginTransaction();
        
        // Insert progress update
        $stmt = $crad->prepare("
            INSERT INTO research_progress_updates (
                research_plan_id, research_group_id, milestone_id, 
                submitted_by_user_id, submitted_by_name, update_title,
                previous_progress, new_progress, milestone_status,
                accomplishments, problems_blockers, next_planned_activity,
                attachment_path, attachment_original_name, submission_token
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        
        $stmt->execute([
            $data['research_plan_id'],
            $data['research_group_id'],
            $data['milestone_id'] ?? null,
            $data['submitted_by_user_id'],
            $data['submitted_by_name'],
            $data['update_title'] ?? 'Progress Update',
            $data['previous_progress'] ?? 0,
            $newProgress,
            $data['milestone_status'] ?? 'In Progress',
            $data['accomplishments'] ?? null,
            $data['problems_blockers'] ?? null,
            $data['next_planned_activity'] ?? null,
            $data['attachment_path'] ?? null,
            $data['attachment_original_name'] ?? null,
            $data['submission_token'] ?? null
        ]);
        
        $updateId = (int) $crad->lastInsertId();

        if (!empty($data['uploaded_document']) && is_array($data['uploaded_document'])) {
            rpEnsureProgressAttachmentSchema($crad);
            $attachment = $data['uploaded_document'];
            $attachStmt = $crad->prepare("
                INSERT INTO research_progress_attachments (
                    progress_update_id, file_name, file_path, file_type, file_size, uploaded_by
                ) VALUES (?, ?, ?, ?, ?, ?)
            ");
            $attachStmt->execute([
                $updateId,
                (string) ($attachment['original_name'] ?? ''),
                (string) ($attachment['path'] ?? ''),
                (string) ($attachment['mime'] ?? ''),
                (int) ($attachment['size'] ?? 0),
                (int) $data['submitted_by_user_id'],
            ]);
        }
        
        // Update milestone progress if milestone_id provided.
        if (!empty($data['milestone_id'])) {
            $updateMilestone = $crad->prepare("
                UPDATE research_milestones 
                SET progress_percentage = ?,
                    status = ?,
                    updated_at = NOW()
                WHERE id = ?
            ");
            $updateMilestone->execute([
                $newProgress,
                $data['milestone_status'] ?? 'In Progress',
                $data['milestone_id']
            ]);
        }
        
        // Recalculate overall progress
        rpRecalculateOverallProgress($crad, (int) $data['research_plan_id']);
        
        // Log activity
        rpLogActivity($crad, [
            'research_plan_id' => $data['research_plan_id'],
            'research_group_id' => $data['research_group_id'],
            'user_id' => $data['submitted_by_user_id'],
            'user_name' => $data['submitted_by_name'],
            'user_role' => 'student',
            'action' => 'progress_updated',
            'entity_type' => 'progress_update',
            'entity_id' => $updateId,
            'detail' => "Progress updated to {$newProgress}%"
        ]);
        
        $crad->commit();
        
        return [
            'success' => true,
            'message' => 'Progress update submitted successfully',
            'update_id' => $updateId
        ];
        
    } catch (Throwable $e) {
        $crad->rollBack();
        error_log('Progress update submission failed: ' . $e->getMessage());
        return [
            'success' => false,
            'message' => 'Failed to submit progress update. Please try again.'
        ];
    }
}

/**
 * Recalculate overall progress for a research plan
 * Based on average of all milestone progress percentages
 * 
 * @param PDO $crad CRAD database connection
 * @param int $planId Research plan ID
 * @return void
 */
function rpRecalculateOverallProgress(PDO $crad, int $planId): void
{
    $groupStmt = $crad->prepare('SELECT research_group_id FROM research_plans WHERE id = ? LIMIT 1');
    $groupStmt->execute([$planId]);
    $groupId = (int) ($groupStmt->fetchColumn() ?: 0);

    $stmt = $crad->prepare("
        SELECT *
        FROM research_milestones
        WHERE research_plan_id = ?
        ORDER BY milestone_order ASC
    ");
    $stmt->execute([$planId]);
    $milestones = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $avgProgress = rpMilestonesOverallProgress($milestones);
    
    $updateStmt = $crad->prepare("
        UPDATE research_plans 
        SET overall_progress = ?,
            updated_at = NOW()
        WHERE id = ?
    ");
    $updateStmt->execute([$avgProgress, $planId]);
}

/**
 * Log activity with duplicate prevention via activity hash
 * 
 * @param PDO $crad CRAD database connection
 * @param array $data Activity data
 * @return void
 */
function rpLogActivity(PDO $crad, array $data): void
{
    // Deduplicate: skip if the same user+action+entity was already logged this minute
    $checkStmt = $crad->prepare("
        SELECT id FROM research_progress_activity_logs
        WHERE user_id    = ?
          AND action     = ?
          AND entity_type = ?
          AND entity_id  = ?
          AND created_at >= DATE_SUB(NOW(), INTERVAL 1 MINUTE)
        LIMIT 1
    ");
    $checkStmt->execute([
        $data['user_id']      ?? null,
        $data['action'],
        $data['entity_type']  ?? '',
        $data['entity_id']    ?? null,
    ]);

    if ($checkStmt->fetch()) {
        return;
    }

    // Log the activity
    // Table columns: research_plan_id, user_id, user_name, user_role,
    //                action, entity_type, entity_id, old_value, new_value, description
    try {
        $stmt = $crad->prepare("
            INSERT INTO research_progress_activity_logs (
                research_plan_id, user_id, user_name, user_role,
                action, entity_type, entity_id, description
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ");

        $stmt->execute([
            $data['research_plan_id'],
            $data['user_id']      ?? null,
            $data['user_name']    ?? '',
            $data['user_role']    ?? '',
            $data['action'],
            $data['entity_type']  ?? '',
            $data['entity_id']    ?? null,
            $data['detail']       ?? '',
        ]);
    } catch (PDOException $e) {
        // Silently fail — logging must never break main functionality
        error_log('Activity log failed: ' . $e->getMessage());
    }
}

/**
 * Create notification with duplicate prevention via batch_key
 * 
 * @param PDO $crad CRAD database connection
 * @param array $data Notification data
 * @return bool Success status
 */
function rpCreateNotification(PDO $crad, array $data): bool
{
    // Generate batch key for duplicate prevention
    $batchKey = $data['batch_key'] ?? (
        $data['notification_type'] . ':' . 
        ($data['related_entity_id'] ?? uniqid())
    );
    
    // Check if notification with same batch_key exists for this recipient
    $checkStmt = $crad->prepare("
        SELECT id FROM research_progress_notifications
        WHERE batch_key = ?
          AND (
               (recipient_user_id IS NOT NULL AND recipient_user_id = ?)
            OR (recipient_user_id IS NULL AND recipient_email = ?)
            OR (recipient_user_id IS NULL AND recipient_email = '' AND recipient_role = ?)
          )
        LIMIT 1
    ");
    
    $checkStmt->execute([
        $batchKey,
        $data['recipient_user_id'] ?? null,
        $data['recipient_email'] ?? '',
        $data['recipient_role'] ?? ''
    ]);
    
    if ($checkStmt->fetch()) {
        // Duplicate notification exists
        return false;
    }
    
    // Create notification
    try {
        $stmt = $crad->prepare("
            INSERT INTO research_progress_notifications (
                recipient_user_id, recipient_email, recipient_role, batch_key,
                notification_type, title, body, related_entity_type, related_entity_id,
                action_url, status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'unread')
        ");
        
        $stmt->execute([
            $data['recipient_user_id'] ?? null,
            $data['recipient_email'] ?? '',
            $data['recipient_role'] ?? '',
            $batchKey,
            $data['notification_type'] ?? 'progress_update',
            $data['title'] ?? 'Notification',
            $data['body'] ?? '',
            $data['related_entity_type'] ?? '',
            $data['related_entity_id'] ?? null,
            $data['action_url'] ?? null
        ]);
        
        return true;
    } catch (PDOException $e) {
        error_log('Notification creation failed: ' . $e->getMessage());
        return false;
    }
}
