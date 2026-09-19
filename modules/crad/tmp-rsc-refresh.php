<?php
declare(strict_types=1);
require_once __DIR__ . '/../../config/config.php';
require_once ROOT_PATH . '/modules/crad/includes/research-services-clearance.php';

$crad = rscDb();
$g = $crad->query('SELECT rg.id, rg.group_number, rg.leader_name, rg.leader_id, rg.proposal_id, t.members_json, t.student_name, t.student_id FROM research_groups rg LEFT JOIN title_approvals t ON t.id = rg.title_approval_id WHERE rg.id = 70')->fetch();
echo json_encode($g, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE), PHP_EOL;
if ($g) {
    echo "resolved=", json_encode(rscMembersFromGroup($crad, $g), JSON_UNESCAPED_UNICODE), PHP_EOL;
}
