<?php
/**
 * CRAD Module - Database Configuration
 * Separate database for research proposal tracking
 */

declare(strict_types=1);

require_once dirname(__DIR__, 3) . '/config/config.php';

if (!defined('CRAD_DB_HOST')) {
    define('CRAD_DB_HOST', sms2_env('CRAD_DB_HOST', sms2_env('SMS2_DB_HOST', 'localhost')));
}
if (!defined('CRAD_DB_NAME')) {
    define('CRAD_DB_NAME', sms2_env('CRAD_DB_NAME', 'crad_db'));
}
if (!defined('CRAD_DB_USER')) {
    define('CRAD_DB_USER', sms2_env('CRAD_DB_USER', sms2_env('SMS2_DB_USER', 'root')));
}
if (!defined('CRAD_DB_PASS')) {
    define('CRAD_DB_PASS', sms2_env('CRAD_DB_PASS', sms2_env('SMS2_DB_PASS', '')));
}
if (!defined('CRAD_DB_CHARSET')) {
    define('CRAD_DB_CHARSET', sms2_env('CRAD_DB_CHARSET', sms2_env('SMS2_DB_CHARSET', 'utf8mb4')));
}

/**
 * Get CRAD database connection (singleton).
 *
 * @return PDO
 * @throws RuntimeException when connection fails
 */
function getCradDatabaseConnection(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $dsn = 'mysql:host=' . CRAD_DB_HOST . ';dbname=' . CRAD_DB_NAME . ';charset=' . CRAD_DB_CHARSET;

    try {
        $pdo = new PDO($dsn, CRAD_DB_USER, CRAD_DB_PASS, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    } catch (PDOException $e) {
        error_log('CRAD DB connection failed: ' . $e->getMessage());
        throw new RuntimeException(
            'CRAD database unavailable. Run modules/crad/database/install.php or create crad_db in MySQL.'
        );
    }

    return $pdo;
}

/**
 * Safe helper — returns null instead of throwing (for optional features).
 *
 * @return PDO|null
 */
function cradDb(): ?PDO
{
    try {
        return getCradDatabaseConnection();
    } catch (Throwable $e) {
        return null;
    }
}
