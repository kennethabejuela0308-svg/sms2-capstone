<?php
/**
 * SMS 2 - Welcome Page
 * Landing page for Bestlink College of the Philippines
 */
require_once __DIR__ . '/../config/config.php';
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

$pageTitle = 'Welcome';
$bodyClass = 'welcome-page';

require_once ROOT_PATH . '/includes/header.php';
?>

<style>
body.welcome-page {
    min-height: 100vh;
    background: #071c48 !important;
    color-scheme: light;
    display: flex;
    flex-direction: column;
    font-family: "Inter", "Segoe UI", Tahoma, sans-serif;
    overflow-x: hidden;
    position: relative;
    transition: none !important;
}

.welcome-video-bg {
    position: fixed;
    inset: 0;
    z-index: 0;
    overflow: hidden;
    pointer-events: none;
}

.welcome-video-bg video {
    width: 100%;
    height: 100%;
    object-fit: cover;
    object-position: center;
    transform: scale(1.04);
    filter: saturate(1.05) brightness(0.92);
}

/* Keep video visible behind the glassy welcome */
.welcome-video-bg::after {
    content: "";
    position: absolute;
    inset: 0;
    background:
        radial-gradient(ellipse 75% 60% at 50% 42%, rgba(4, 16, 42, 0.12) 0%, rgba(4, 16, 42, 0.42) 75%, rgba(2, 8, 24, 0.62) 100%),
        linear-gradient(180deg, rgba(4, 16, 42, 0.28) 0%, rgba(4, 16, 42, 0.18) 45%, rgba(2, 8, 24, 0.55) 100%);
}

.welcome-stage {
    position: relative;
    z-index: 1;
    box-sizing: border-box;
    flex: 1;
    min-height: calc(100vh - 70px);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 2rem;
}

.welcome-shell {
    width: min(1060px, calc(100vw - 4rem));
    min-height: 560px;
    display: flex;
    overflow: hidden;
    border: 1px solid rgba(255, 255, 255, 0.72);
    border-radius: 22px;
    background: #fff;
    box-shadow: 0 28px 70px rgba(2, 12, 32, 0.32);
}

.welcome-showcase {
    width: 58%;
    min-height: 560px;
    display: flex;
    align-items: flex-end;
    padding: 0 36px 32px;
    color: #fff;
    background-image:
        linear-gradient(180deg, rgba(4, 23, 55, 0.08) 0%, rgba(4, 20, 50, 0.78) 100%),
        url("<?= BASE_URL ?>/images/school1.png");
    background-size: cover;
    background-position: center;
}

.welcome-showcase-inner {
    max-width: 560px;
}

.welcome-showcase h1 {
    margin: 0 0 12px;
    color: #fff;
    font-family: Georgia, "Times New Roman", serif;
    font-size: clamp(2.4rem, 4vw, 3.25rem);
    line-height: 0.98;
    font-weight: 800;
    letter-spacing: 0;
    text-shadow: 0 4px 18px rgba(0, 0, 0, 0.28);
}

.welcome-showcase p {
    margin: 0;
    color: rgba(255, 255, 255, 0.95);
    font-size: 0.92rem;
    font-weight: 600;
    line-height: 1.3;
    text-shadow: 0 2px 12px rgba(0, 0, 0, 0.28);
}

.welcome-panel {
    width: 42%;
    min-height: 560px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 48px 30px;
    background: #fff;
}

.welcome-badge {
    width: fit-content;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 16px;
    padding: 7px 12px;
    border: 1px solid #d8e5ff;
    border-radius: 999px;
    background: #eef5ff;
    color: #0d4bd6;
    font-size: 0.78rem;
    font-weight: 800;
}

.welcome-title {
    margin: 0 0 8px;
    color: #111827;
    font-family: Georgia, "Times New Roman", serif;
    font-size: clamp(2.55rem, 4vw, 3rem);
    line-height: 1;
    font-weight: 800;
    letter-spacing: 0;
}

.welcome-subtitle {
    margin: 0 0 24px;
    color: #334155;
    font-size: 1rem;
    line-height: 1.4;
    font-weight: 700;
}

.welcome-copy {
    margin: 0 0 16px;
    color: #475569;
    font-size: 0.95rem;
    line-height: 1.55;
}

.welcome-copy strong {
    color: #111827;
}

.welcome-panel .btn-sms-primary {
    width: 100%;
    margin-top: 16px;
    border: 0 !important;
    border-radius: 10px !important;
    background: #294ecb !important;
    color: #fff !important;
    padding: 13px 16px !important;
    font-size: 14px;
    font-weight: 800;
    box-shadow: 0 11px 20px rgba(41, 78, 203, 0.25);
}

.welcome-panel .btn-sms-primary:hover,
.welcome-panel .btn-sms-primary:focus {
    background: #2445b7 !important;
}

.welcome-footer {
    position: relative;
    z-index: 1;
    padding: 0 1.5rem 1.5rem;
    color: rgba(255, 255, 255, 0.88);
    font-size: 0.95rem;
    font-weight: 600;
    text-align: center;
    text-shadow: 0 2px 14px rgba(0, 0, 0, 0.35);
}

@media (prefers-reduced-motion: reduce) {
    .welcome-video-bg video {
        display: none;
    }

    .welcome-video-bg {
        background: #071c48;
    }
}

@media (max-width: 700px) {
    .welcome-stage {
        min-height: auto;
        padding: 1rem;
    }

    .welcome-shell {
        width: min(560px, 100%);
        min-height: 0;
        flex-direction: column;
        border-radius: 18px;
    }

    .welcome-showcase,
    .welcome-panel {
        width: 100%;
        min-height: 0;
    }

    .welcome-showcase {
        min-height: 250px;
        padding: 28px 24px;
    }

    .welcome-panel {
        padding: 30px 22px 34px;
        text-align: center;
        align-items: center;
    }

    .welcome-title {
        font-size: 2.35rem;
    }

    .welcome-subtitle,
    .welcome-copy {
        max-width: 420px;
    }
}
</style>

<div class="welcome-video-bg" aria-hidden="true">
    <video autoplay muted loop playsinline>
        <source src="<?= BASE_URL ?>/assets/videos/bcp-campus.mp4?v=bcp4" type="video/mp4">
    </video>
</div>

<main class="welcome-stage">
    <section class="welcome-shell" aria-label="Student Management System welcome">
        <div class="welcome-showcase">
            <div class="welcome-showcase-inner">
                <h1>Student<br>Management<br>System 2</h1>
                <p>Manage enrollment, student records, financial transactions, and clinic services in one secure platform.</p>
            </div>
        </div>

        <div class="welcome-panel">
            <div class="welcome-badge">
                <i class="fas fa-shield-alt"></i>
                <span>Secure Access Portal</span>
            </div>
            <h1 class="welcome-title"><?= htmlspecialchars(APP_SHORT_NAME) ?></h1>
            <p class="welcome-subtitle"><?= htmlspecialchars(APP_NAME) ?></p>
            <p class="welcome-copy">
                Welcome to the official Student Management System of
                <strong><?= htmlspecialchars(INSTITUTION) ?></strong>.
            </p>
            <p class="welcome-copy">
                A modern, integrated platform for enrollment, academics, faculty management,
                and student services designed for efficiency and excellence.
            </p>
            <a href="<?= BASE_URL ?>/login/login.php" class="btn btn-sms-primary btn-lg">
                <i class="fas fa-sign-in-alt me-2"></i>Login to System
            </a>
        </div>
    </section>
</main>

<footer class="welcome-footer">
    <p class="mb-0">&copy; <?= date('Y') ?> <?= htmlspecialchars(INSTITUTION) ?>. All rights reserved.</p>
</footer>

<?php require_once ROOT_PATH . '/includes/scripts.php'; ?>
