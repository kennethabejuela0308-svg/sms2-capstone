<?php
require __DIR__ . '/config/config.php';
require ROOT_PATH . '/modules/crad/config/config.php';
require ROOT_PATH . '/modules/faculty/includes/research-director-panel-assignment.php';

if (!defined('CRAD_DEFENSE_TYPE_PRE_ORAL')) {
    define('CRAD_DEFENSE_TYPE_PRE_ORAL', 'Pre-Oral Defense');
}
if (!defined('CRAD_DEFENSE_TYPE_FINAL')) {
    define('CRAD_DEFENSE_TYPE_FINAL', 'Final Defense');
}
if (!defined('RD_SCHEDULE_MAX_PANEL_MEMBERS')) {
    define('RD_SCHEDULE_MAX_PANEL_MEMBERS', 3);
}

function rdOfficialRegistrySql(string $alias = 'rg'): string
{
    return "{$alias}.id IS NOT NULL";
}

function rdOfficialScheduleJoinSql(): string
{
    return 'INNER JOIN research_groups registry_rg ON registry_rg.id = rds.research_group_id';
}

function rdSchedulePanelRows(PDO $pdo, int $groupId): array
{
    $stmt = $pdo->prepare(
        "SELECT rpa.panel_user_id,
                COALESCE(NULLIF(u.full_name, ''), NULLIF(rpa.panel_name, ''), 'Panel Member') AS panel_name,
                COALESCE(MAX(NULLIF(pma.availability_status, '')), MAX(NULLIF(rpa.availability_status, '')), 'Pending') AS availability_status
         FROM research_panel_assignments rpa
         LEFT JOIN sms2_db.users u ON u.id = rpa.panel_user_id
         LEFT JOIN panel_member_availability pma ON pma.panel_user_id = rpa.panel_user_id
         WHERE rpa.research_group_id = ?
           AND " . rdPanelActiveAssignmentSql('rpa') . "
         GROUP BY rpa.panel_user_id, panel_name
         ORDER BY panel_name ASC"
    );
    $stmt->execute([$groupId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
}

function rdScheduleReadyGroup(PDO $pdo, int $groupId, string $defenseType = CRAD_DEFENSE_TYPE_PRE_ORAL): ?array
{
    $stmt = $pdo->prepare(
        "SELECT rg.id AS research_group_id,
                rg.group_number,
                rg.research_title,
                raa.adviser_user_id,
                raa.adviser_name,
                raa.availability_status AS adviser_availability
         FROM research_groups rg
         INNER JOIN research_adviser_assignments raa ON raa.id = (
            SELECT raa2.id FROM research_adviser_assignments raa2
            WHERE raa2.assignment_status IN ('Assigned', 'Confirmed')
              AND ((raa2.research_group_id IS NOT NULL AND raa2.research_group_id = rg.id)
                OR (raa2.group_number IS NOT NULL AND raa2.group_number <> '' AND raa2.group_number = rg.group_number))
            ORDER BY (raa2.assignment_status = 'Confirmed') DESC, raa2.updated_at DESC, raa2.id DESC
            LIMIT 1
         )
         WHERE rg.id = ?
         LIMIT 1"
    );
    $stmt->execute([$groupId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row ?: null;
}

require ROOT_PATH . '/modules/faculty/includes/rd-scheduling-optimizer.php';

$pdo = cradDb();
$result = rdScheduleGenerateOptimizedSlots(
    $pdo,
    71,
    CRAD_DEFENSE_TYPE_FINAL,
    date('Y-m-d'),
    date('Y-m-d', strtotime('+30 days')),
    15
);

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
