<?php
/**
 * SMS 2 - Database Configuration (Phase 2)
 */

declare(strict_types=1);

require_once __DIR__ . '/config.php';

if (!defined('DB_HOST')) {
    define('DB_HOST', sms2_env('SMS2_DB_HOST', 'localhost'));
}
if (!defined('DB_NAME')) {
    define('DB_NAME', sms2_env('SMS2_DB_NAME', 'sms2_db'));
}
if (!defined('DB_USER')) {
    define('DB_USER', sms2_env('SMS2_DB_USER', 'root'));
}
if (!defined('DB_PASS')) {
    define('DB_PASS', sms2_env('SMS2_DB_PASS', ''));
}
if (!defined('DB_CHARSET')) {
    define('DB_CHARSET', sms2_env('SMS2_DB_CHARSET', 'utf8mb4'));
}

/**
 * Shared PDO connection (singleton).
 *
 * @throws RuntimeException when connection fails
 */
function getDatabaseConnection(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=' . DB_CHARSET;

    try {
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    } catch (PDOException $e) {
        error_log('SMS2 DB connection failed: ' . $e->getMessage());
        throw new RuntimeException(
            'Database unavailable. Run database/install.php or start MySQL in XAMPP.'
        );
    }

    return $pdo;
}

/**
 * Safe helper — returns null instead of throwing (for optional features).
 */
function db(): ?PDO
{
    try {
        return getDatabaseConnection();
    } catch (Throwable $e) {
        return null;
    }
}
