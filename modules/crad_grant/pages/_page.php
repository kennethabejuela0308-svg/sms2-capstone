<?php
/**
 * Shared Research Grant page renderer.
 */
require_once __DIR__ . '/../../../config/config.php';

$activeModule = 'crad_grant';
$activePage = $activePage ?? basename((string) ($_SERVER['SCRIPT_NAME'] ?? ''), '.php');

$pageTitle = $pageTitle ?? ucwords(str_replace('-', ' ', $activePage));
$breadcrumbs = [
    ['label' => 'Research Grant', 'url' => BASE_URL . '/modules/crad_grant/index.php'],
    ['label' => $pageTitle, 'url' => null],
];

require_once __DIR__ . '/../../../includes/breadcrumbs.php';
require_once __DIR__ . '/../../../includes/layout-start.php';
?>

<?php renderBreadcrumbs($breadcrumbs); ?>
<?php require_once ROOT_PATH . '/includes/submodule-process.php'; ?>
<?php require_once __DIR__ . '/../../../includes/layout-end.php'; ?>
