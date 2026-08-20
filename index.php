<?php
/**
 * SMS 2 - Root index
 *
 * Routes visitors to the correct destination without any intermediate
 * welcome page:
 *   - unauthenticated  → existing login entry point
 *   - authenticated    → their existing role portal (current role routing)
 */
require_once __DIR__ . '/config/config.php';
require_once ROOT_PATH . '/includes/authentication.php';
require_once ROOT_PATH . '/includes/module-controls.php';

if (smsNeedsSetup()) {
    header('Location: ' . BASE_URL . '/setup/index.php');
    exit;
}

if (smsIsSystemInMaintenance()) {
    if (isAuthenticated() && getCurrentUserRoleKey() === 'admin') {
        header('Location: ' . BASE_URL . '/modules/user-management/pages/system-settings.php');
        exit;
    }
    header('Location: ' . BASE_URL . '/account/maintenance.php');
    exit;
}

if (isAuthenticated()) {
    if (!empty($_SESSION['must_change_password'])) {
        header('Location: ' . BASE_URL . '/login/change-password.php');
        exit;
    }
    header('Location: ' . smsPostLoginRedirectUrl());
    exit;
}

header('Location: ' . BASE_URL . '/login/login.php');
exit;