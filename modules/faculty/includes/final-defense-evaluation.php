<?php
declare(strict_types=1);

require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';
require_once ROOT_PATH . '/modules/crad/config/config.php';

function finalDefenseEnsureSchema(PDO $crad): void
{
    $crad->exec(
        "CREATE TABLE IF NOT EXISTS final_defense_evaluations (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            defense_schedule_id INT UNSIGNED NOT NULL,
            research_group_id INT UNSIGNED DEFAULT NULL,
            panel_user_id INT UNSIGNED NOT NULL,
            panel_name VARCHAR(150) NOT NULL DEFAULT '',
            content_score DECIMAL(5,2) NOT NULL,
            methodology_score DECIMAL(5,2) NOT NULL,
            references_score DECIMAL(5,2) NOT NULL,
            format_score DECIMAL(5,2) NOT NULL,
            remarks TEXT DEFAULT NULL,
            result ENUM('APPROVED','APPROVED WITH REVISION','FAILED') NOT NULL,
            overall_score DECIMAL(5,2) NOT NULL,
            status VARCHAR(30) NOT NULL DEFAULT 'Submitted',
            submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY uniq_final_panel_submission (defense_schedule_id, panel_user_id),
            KEY idx_final_group (research_group_id),
            KEY idx_final_panel (panel_user_id),
            KEY idx_final_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
    );
}

function finalDefenseRequirePanelMember(): void
{
    requireAuth();
    if (getCurrentUserRoleKey() !== 'panel') {
        http_response_code(403);
        exit('Forbidden');
    }
}

function finalDefenseDb(): ?PDO
{
    return function_exists('cradDb') ? cradDb() : null;
}

function finalDefenseRubric(): array
{
    return [
        ['key' => 'content', 'label' => 'Content', 'min' => 0, 'max' => 100],
        ['key' => 'methodology', 'label' => 'Methodology', 'min' => 0, 'max' => 100],
        ['key' => 'references', 'label' => 'References', 'min' => 0, 'max' => 100],
        ['key' => 'format', 'label' => 'Format', 'min' => 0, 'max' => 100],
    ];
}

function finalDefenseAssignedSchedule(PDO $crad, int $scheduleId): ?array
{
    if ($scheduleId <= 0) {
        return null;
    }

    $stmt = $crad->prepare(
        "SELECT rds.id, rds.research_group_id, rds.group_number, rds.research_group,
                rds.research_title, rds.adviser_name, rds.venue,
                rds.defense_datetime, rds.defense_end_datetime, rds.status,
                rds.defense_type,
                rpa.panel_name,
                (SELECT fde.id FROM final_defense_evaluations fde
                 WHERE fde.defense_schedule_id = rds.id
                   AND fde.panel_user_id = :panel_id_check
                 LIMIT 1) AS evaluation_id
         FROM research_defense_schedules rds
         INNER JOIN research_panel_assignments rpa
           ON rpa.research_group_id = rds.research_group_id
          AND rpa.panel_user_id = :panel_id
          AND rpa.defense_phase = 'Final Defense'
          AND rpa.assignment_status = 'Assigned'
         WHERE rds.id = :schedule_id
           AND LOWER(TRIM(COALESCE(rds.defense_type, ''))) = 'final defense'
           AND rds.defense_datetime IS NOT NULL
         LIMIT 1"
    );
    $panelId = (int) getCurrentUserId();
    $stmt->execute([
        ':panel_id_check' => $panelId,
        ':panel_id' => $panelId,
        ':schedule_id' => $scheduleId,
    ]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

function finalDefenseRows(PDO $crad, bool $history = false): array
{
    finalDefenseEnsureSchema($crad);
    $panelId = (int) getCurrentUserId();
    $evaluationFilter = $history ? 'fde.id IS NOT NULL' : 'fde.id IS NULL';

    $stmt = $crad->prepare(
        "SELECT rds.id, rds.research_group_id, rds.group_number, rds.research_group,
                rds.research_title, rds.adviser_name, rds.venue,
                rds.defense_datetime, rds.defense_end_datetime, rds.status,
                rds.defense_type, fde.id AS evaluation_id,
                fde.result AS panel_result, fde.overall_score AS panel_score,
                fde.submitted_at
         FROM research_defense_schedules rds
         INNER JOIN research_panel_assignments rpa
           ON rpa.research_group_id = rds.research_group_id
          AND rpa.panel_user_id = :panel_id
          AND rpa.defense_phase = 'Final Defense'
          AND rpa.assignment_status = 'Assigned'
         LEFT JOIN final_defense_evaluations fde
           ON fde.defense_schedule_id = rds.id
          AND fde.panel_user_id = :panel_id_eval
         WHERE LOWER(TRIM(COALESCE(rds.defense_type, ''))) = 'final defense'
           AND rds.defense_datetime IS NOT NULL
           AND LOWER(rds.status) IN ('scheduled', 'finalized', 'final', 'completed', 'passed', 'failed')
           AND {$evaluationFilter}
         ORDER BY rds.defense_datetime DESC, rds.id DESC"
    );
    $stmt->execute([
        ':panel_id' => $panelId,
        ':panel_id_eval' => $panelId,
    ]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
}

function finalDefenseSubmitEvaluation(PDO $crad, int $scheduleId, array $data): array
{
    $defense = finalDefenseAssignedSchedule($crad, $scheduleId);
    if (!$defense) {
        return ['ok' => false, 'error' => 'This Final Defense is not assigned to your panel account.'];
    }
    if (!empty($defense['evaluation_id'])) {
        return ['ok' => false, 'error' => 'This Final Defense already has your evaluation.'];
    }

    $scores = [];
    foreach (finalDefenseRubric() as $criterion) {
        $raw = trim((string) ($data[$criterion['key'] . '_score'] ?? ''));
        if ($raw === '' || !is_numeric($raw)) {
            return ['ok' => false, 'error' => 'Please enter a valid score for ' . $criterion['label'] . '.'];
        }
        $score = (float) $raw;
        if ($score < $criterion['min'] || $score > $criterion['max']) {
            return ['ok' => false, 'error' => $criterion['label'] . ' score must be between 0 and 100.'];
        }
        $scores[$criterion['key']] = $score;
    }

    $result = strtoupper(trim((string) ($data['result'] ?? '')));
    if (!in_array($result, ['APPROVED', 'APPROVED WITH REVISION', 'FAILED'], true)) {
        return ['ok' => false, 'error' => 'Please select a valid result.'];
    }

    try {
        $stmt = $crad->prepare(
            "INSERT INTO final_defense_evaluations
                (defense_schedule_id, research_group_id, panel_user_id, panel_name,
                 content_score, methodology_score, references_score, format_score,
                 remarks, result, overall_score, status, submitted_at, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Submitted', NOW(), NOW())"
        );
        $stmt->execute([
            $scheduleId,
            (int) ($defense['research_group_id'] ?? 0) ?: null,
            (int) getCurrentUserId(),
            getCurrentUserName(),
            $scores['content'],
            $scores['methodology'],
            $scores['references'],
            $scores['format'],
            trim((string) ($data['remarks'] ?? '')),
            $result,
            round(array_sum($scores) / count($scores), 2),
        ]);
        return ['ok' => true, 'message' => 'Final Defense evaluation submitted successfully.'];
    } catch (PDOException $e) {
        if (($e->errorInfo[1] ?? 0) === 1062) {
            return ['ok' => false, 'error' => 'This Final Defense already has your evaluation.'];
        }
        error_log('Final Defense evaluation submit failed: ' . $e->getMessage());
        return ['ok' => false, 'error' => 'Unable to submit Final Defense evaluation.'];
    }
}
