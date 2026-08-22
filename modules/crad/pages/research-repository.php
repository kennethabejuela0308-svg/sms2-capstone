<?php
/**
 * SMS 2 - Research Repository
 * Module: CRAD
 */
require_once __DIR__ . '/../../../config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/security.php';
require_once ROOT_PATH . '/modules/crad/config/config.php';
require_once ROOT_PATH . '/modules/crad/includes/final-phase-helpers.php';
require_once ROOT_PATH . '/includes/breadcrumbs.php';
requireAuth();
if (!in_array(getCurrentUserRoleKey(), ['crad_officer', 'research_coordinator', 'superadmin', 'admin'], true)) { http_response_code(403); exit('Forbidden'); }
$crad = cradDb(); finalPhaseEnsureSchema($crad);
$repositoryRows = $crad->query("SELECT p.*, rg.group_number, rg.group_name FROM publications p LEFT JOIN research_groups rg ON rg.id = p.research_group_id WHERE p.status IN ('For Publication','Published','Archived') ORDER BY p.updated_at DESC, p.id DESC")->fetchAll(PDO::FETCH_ASSOC) ?: [];
$repositoryMetrics = ['total' => count($repositoryRows), 'published' => 0, 'archived' => 0];
foreach ($repositoryRows as $repositoryRow) { if ($repositoryRow['status'] === 'Published') $repositoryMetrics['published']++; if ($repositoryRow['status'] === 'Archived') $repositoryMetrics['archived']++; }
$breadcrumbs = [['label' => 'CRAD', 'url' => BASE_URL . '/modules/crad/index.php'], ['label' => 'Research Repository', 'url' => null]];
require_once ROOT_PATH . '/includes/layout-start.php'; renderBreadcrumbs($breadcrumbs);
?>
<div class="glass-dashboard"><div class="glass-board"><div class="row g-3 mb-4"><div class="col-md-4"><div class="glass-panel p-3"><small>Catalogued Records</small><h3><?= $repositoryMetrics['total'] ?></h3></div></div><div class="col-md-4"><div class="glass-panel p-3"><small>Published</small><h3><?= $repositoryMetrics['published'] ?></h3></div></div><div class="col-md-4"><div class="glass-panel p-3"><small>Archived</small><h3><?= $repositoryMetrics['archived'] ?></h3></div></div></div><div class="glass-panel"><div class="glass-panel-body"><h5 class="glass-panel-title">Research Repository</h5><?php if (!$repositoryRows): ?><p class="text-muted">No publication records are ready for the repository.</p><?php else: ?><div class="table-responsive"><table class="table align-middle"><thead><tr><th>Repository Record</th><th>Research Title</th><th>Outlet</th><th>Status</th><th>Updated</th><th>DOI / Link</th></tr></thead><tbody><?php foreach ($repositoryRows as $row): ?><tr><td>REP-<?= (int) $row['id'] ?></td><td><?= e((string) $row['title']) ?><div class="small text-muted"><?= e((string) ($row['group_number'] ?? '')) ?></div></td><td><?= e((string) $row['publication_outlet']) ?></td><td><?= e((string) $row['status']) ?></td><td><?= e((string) $row['updated_at']) ?></td><td><?php if (trim((string) $row['doi_link']) !== ''): ?><a href="<?= e((string) $row['doi_link']) ?>" target="_blank" rel="noopener">Open</a><?php else: ?>Not recorded<?php endif; ?></td></tr><?php endforeach; ?></tbody></table></div><?php endif; ?></div></div></div></div>
<?php require_once ROOT_PATH . '/includes/layout-end.php'; exit;

$pageTitle    = 'Research Repository';
$activeModule = 'crad';
$activePage   = 'research-repository';
$breadcrumbs  = [
    ['label' => 'CRAD', 'url' => BASE_URL . '/modules/crad/index.php'],
    ['label' => 'Research Repository', 'url' => null],
];

$cradProcess = [
    'kicker' => 'CRAD Officer · Repository Workflow',
    'description' => 'Catalog, review, archive, and release completed research outputs in the institutional research repository.',
    'metrics' => [
        ['label' => 'Pending Upload Review', 'value' => '6', 'icon' => 'fa-cloud-upload-alt', 'tone' => 'amber'],
        ['label' => 'Catalogued Studies', 'value' => '128', 'icon' => 'fa-archive', 'tone' => 'blue'],
        ['label' => 'Public Access', 'value' => '84', 'icon' => 'fa-globe', 'tone' => 'green'],
        ['label' => 'Restricted Files', 'value' => '17', 'icon' => 'fa-lock', 'tone' => 'purple'],
    ],
    'steps' => [
        ['Receive Completed Study', 'Accept manuscript, abstract, keywords, and final approved title metadata.'],
        ['Review Metadata & Files', 'Check authors, college, SDG tags, file integrity, and access classification.'],
        ['Catalog into Repository', 'Assign repository ID, indexing tags, and storage location.'],
        ['Publish Access Level', 'Release as public, campus-only, or restricted archive access.'],
    ],
    'columns' => ['Repository ID', 'Research Title', 'Access Level', 'Status', 'Updated'],
    'fields' => ['reference', 'title', 'owner', 'status', 'updated'],
    'records' => [
        [
            'reference' => 'REP-2026-118',
            'title' => 'IoT-Based Flood Monitoring System',
            'owner' => 'Campus Only',
            'status' => 'For Cataloguing',
            'status_class' => 'pending',
            'updated' => 'Jul 18, 2026',
        ],
        [
            'reference' => 'REP-2026-117',
            'title' => 'Post-Pandemic Micro-Enterprise Adaptability',
            'owner' => 'Public',
            'status' => 'Archived',
            'status_class' => 'archived',
            'updated' => 'Jul 14, 2026',
        ],
        [
            'reference' => 'REP-2026-116',
            'title' => 'Solid Waste Segregation Awareness Program',
            'owner' => 'Public',
            'status' => 'Published',
            'status_class' => 'published',
            'updated' => 'Jul 10, 2026',
        ],
        [
            'reference' => 'REP-2026-115',
            'title' => 'Community Mental Health Literacy Baseline',
            'owner' => 'Restricted',
            'status' => 'Under Review',
            'status_class' => 'review',
            'updated' => 'Jul 7, 2026',
        ],
    ],
    'actions' => [
        ['label' => 'New Repository Entry', 'process' => 'new', 'icon' => 'fa-plus', 'class' => 'primary'],
        ['label' => 'Review Metadata', 'process' => 'validate', 'icon' => 'fa-tags', 'class' => 'ghost'],
        ['label' => 'Archive / Publish', 'process' => 'approve', 'icon' => 'fa-archive', 'class' => 'ghost'],
        ['label' => 'Repository Report', 'process' => 'report', 'icon' => 'fa-file-export', 'class' => 'ghost'],
    ],
    'form' => [
        ['label' => 'Repository ID', 'type' => 'text', 'name' => 'repo_id', 'placeholder' => 'REP-2026-00X'],
        ['label' => 'Research Title', 'type' => 'text', 'name' => 'title', 'placeholder' => 'Final approved title'],
        ['label' => 'College / Unit', 'type' => 'select', 'name' => 'college', 'options' => [
            'College of Computer Studies',
            'College of Business Administration',
            'College of Criminology',
            'College of Education',
            'College of Hospitality & Tourism Management',
        ]],
        ['label' => 'Access Level', 'type' => 'select', 'name' => 'access', 'options' => [
            'Public',
            'Campus Only',
            'Restricted',
        ]],
        ['label' => 'Primary SDG Tag', 'type' => 'text', 'name' => 'sdg', 'placeholder' => 'e.g. SDG 9'],
        ['label' => 'Catalog Notes', 'type' => 'textarea', 'name' => 'notes', 'placeholder' => 'Keywords, embargo notes, related files...'],
    ],
    'notice' => 'Only completed and CRAD-endorsed research outputs may be archived. Restricted files require written clearance before campus or public release.',
];

require_once __DIR__ . '/../../../includes/breadcrumbs.php';
require_once __DIR__ . '/../../../includes/layout-start.php';
?>

<?php renderBreadcrumbs($breadcrumbs); ?>
<?php require_once ROOT_PATH . '/includes/crad-module-process.php'; ?>
<?php require_once __DIR__ . '/../../../includes/layout-end.php'; ?>
