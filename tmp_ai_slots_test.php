<?php
require __DIR__ . '/config/config.php';
require ROOT_PATH . '/modules/crad/config/config.php';
require ROOT_PATH . '/modules/crad/includes/research-progress-helpers.php';
require ROOT_PATH . '/modules/faculty/includes/research-director-panel-assignment.php';

// Pull conflict helpers from research-director without running the page UI.
$src = file_get_contents(ROOT_PATH . '/modules/faculty/pages/research-director.php');
// Instead just include optimizer after defining minimal stubs by requiring through a bootstrap.

$crad = cradDb();
if (!$crad) {
    fwrite(STDERR, "no db\n");
    exit(1);
}

// Include only the function definitions we need by loading research-director up to require optimizer — too heavy.
// Call via CLI simulating POST is better: use include of optimizer after defining deps from research-director.

ob_start();
$_SERVER['REQUEST_METHOD'] = 'GET';
$_GET['view'] = 'manual-scheduling-optimizer';
$_GET['defense_type'] = 'Final Defense';
$_GET['group_id'] = '71';
// Don't fully run page — extract functions by requiring a thin wrapper.

require ROOT_PATH . '/modules/faculty/includes/rd-scheduling-optimizer.php';

// Define missing deps used by optimizer from research-director if not loaded
if (!defined('CRAD_DEFENSE_TYPE_FINAL')) {
    define('CRAD_DEFENSE_TYPE_PRE_ORAL', 'Pre-Oral Defense');
    define('CRAD_DEFENSE_TYPE_FINAL', 'Final Defense');
}
if (!defined('RD_SCHEDULE_MAX_PANEL_MEMBERS')) {
    define('RD_SCHEDULE_MAX_PANEL_MEMBERS', 3);
}

// Load functions from research-director by parsing — easier to include a snippet file.
// Use eval of function blocks — messy. Just include research-director with early exit.

echo "optimizer_loaded\n";
