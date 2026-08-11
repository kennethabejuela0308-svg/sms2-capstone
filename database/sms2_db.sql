-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 08, 2026 at 12:05 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sms2_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `user_name` varchar(150) DEFAULT NULL,
  `role_key` varchar(40) DEFAULT NULL,
  `action` varchar(40) NOT NULL,
  `module_key` varchar(60) DEFAULT NULL,
  `detail` varchar(500) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_logs`
--

INSERT INTO `activity_logs` (`id`, `user_id`, `user_name`, `role_key`, `action`, `module_key`, `detail`, `ip_address`, `user_agent`, `created_at`) VALUES
(3, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-24 08:59:38'),
(4, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated Super Admin profile', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-24 09:02:04'),
(5, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-24 09:02:07'),
(6, 1, 'Super Admin', 'admin', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 12:04:48'),
(7, 1, 'Super Admin', 'admin', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 12:46:02'),
(8, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 12:46:18'),
(9, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated Super Admin profile', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 12:46:29'),
(10, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 12:46:33'),
(11, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 12:47:36'),
(12, 1, 'Super Admin', 'admin', 'view', 'enrollment', 'Opened Enrollment Management Module Security', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 12:51:40'),
(13, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 12:53:42'),
(14, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:05:23'),
(15, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:05:45'),
(16, 1, 'Super Admin', 'admin', 'password_reset_request', 'System', 'Password reset link emailed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:05:59'),
(17, 1, NULL, NULL, 'password_reset', 'System', 'Password reset via token', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:06:28'),
(18, 9, 'Student User', 'student', 'lockout', 'System', 'Login locked after failed attempts', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:06:33'),
(19, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:06:34'),
(20, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:08:29'),
(21, 1, 'Super Admin', 'admin', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:08:46'),
(22, 1, 'Super Admin', 'admin', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:09:03'),
(23, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:09:41'),
(24, 1, 'Super Admin', 'admin', 'password_reset_request', 'user-management', 'OTP emailed for Super Admin password change', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:10:21'),
(25, 1, 'Super Admin', 'admin', 'password_change', 'user-management', 'Super Admin password reset via account settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:10:29'),
(26, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:11:02'),
(27, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:11:14'),
(28, 9, 'Student User', 'student', 'lockout', 'System', 'Login locked after failed attempts', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:11:19'),
(29, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:11:19'),
(30, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:12:08'),
(31, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:12:17'),
(32, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:13:35'),
(33, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:13:48'),
(34, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:15:37'),
(35, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user registrar', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:16:14'),
(36, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user s230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:17:16'),
(37, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:17:20'),
(38, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:17:32'),
(39, 9, 'Student User', 'student', 'view', 'student_portal', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:17:41'),
(40, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:17:44'),
(41, 9, 'Student User', 'student', 'password_reset_request', 'System', 'Password reset link emailed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:18:27'),
(42, 9, 'Student User', 'student', 'password_reset_request', 'System', 'Password reset link emailed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:18:36'),
(43, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:21:02'),
(44, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:22:47'),
(45, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:25:47'),
(46, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user cradofficer', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:28:10'),
(47, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Archived user #10 (status=inactive)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:29:05'),
(48, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user superadmin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:29:42'),
(49, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user superadmin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:29:51'),
(50, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user cradofficer', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:30:40'),
(51, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:30:43'),
(52, 3, 'CRAD Officer', 'crad_officer', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:30:55'),
(53, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:31:36'),
(54, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user cradofficer', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:31:50'),
(55, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:31:52'),
(56, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:32:15'),
(57, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:41:07'),
(58, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:41:17'),
(59, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:41:26'),
(60, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:41:52'),
(61, 3, 'CRAD Officer', 'crad_officer', 'view', 'crad', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:46:20'),
(62, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:55:08'),
(63, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 13:55:34'),
(64, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:02:03'),
(65, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:02:28'),
(66, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:06:11'),
(67, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:06:38'),
(68, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user s230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:17:40'),
(69, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user superadmin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:18:23'),
(70, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user superadmin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:18:37'),
(71, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user superadmin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:32:52'),
(72, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user s230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:32:59'),
(73, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user finance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:35:47'),
(74, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:36:52'),
(75, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:37:11'),
(76, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:43:31'),
(77, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 14:44:03'),
(78, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 15:07:06'),
(79, 9, 'Student User', 'student', 'view', 'student_portal', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 15:13:15'),
(80, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 15:52:18'),
(81, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 15:52:21'),
(82, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 15:53:03'),
(83, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 15:54:55'),
(84, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 16:36:05'),
(85, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 16:51:54'),
(86, 9, 'Student User', 'student', 'view', 'student_portal', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 17:34:40'),
(87, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 17:36:17'),
(88, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00002 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 18:22:42'),
(89, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00003 (6 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 18:36:18'),
(90, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (6 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 19:10:53'),
(91, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00002 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 19:11:52'),
(92, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:03:13'),
(93, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:03:50'),
(94, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Permission registrar:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:12:08'),
(95, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Permission registrar:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:12:08'),
(96, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user finance', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:20:39'),
(97, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:20:47'),
(98, 4, 'Finance', 'finance', 'login', 'payment', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:20:55'),
(99, 4, 'Finance', 'finance', 'logout', 'payment', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:21:04'),
(100, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:21:27'),
(101, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:22:34'),
(102, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:25:41'),
(103, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:26:12'),
(104, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-06 20:26:19'),
(105, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 11:43:55'),
(106, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 11:44:40'),
(107, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 11:44:46'),
(108, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 11:45:15'),
(109, 3, 'CRAD Officer', 'crad_officer', 'view', 'crad', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 12:33:08'),
(110, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:08:00'),
(111, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00003 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:15:45'),
(112, 9, 'Student User', 'student', 'view', 'student_portal', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:39:34'),
(113, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:46:38'),
(114, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:46:45'),
(115, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:47:17'),
(116, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:47:43'),
(117, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:51:23'),
(118, 4, 'Finance', 'finance', 'login', 'payment', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:51:31'),
(119, 4, 'Finance', 'finance', 'logout', 'payment', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:55:57'),
(120, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 13:56:06'),
(121, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:02:05'),
(122, 4, 'Finance', 'finance', 'login', 'payment', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:02:19'),
(123, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:06:50'),
(124, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:06:57'),
(125, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:07:01'),
(126, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:07:10'),
(127, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:07:40'),
(128, 1, 'Super Admin', 'admin', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:10:29'),
(129, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:10:36'),
(130, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user hr', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:10:53'),
(131, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:10:55'),
(132, 8, 'HR', 'hr', 'login', 'faculty', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:11:03'),
(133, 8, 'HR', 'hr', 'logout', 'faculty', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:11:15'),
(134, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:11:24'),
(135, 4, 'Finance', 'finance', 'logout', 'payment', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:11:33'),
(136, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:11:41'),
(137, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:12:33'),
(138, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:22:41'),
(139, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:22:49'),
(140, 1, 'Super Admin', 'admin', 'update', 'System', 'Added passkey: This device', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:23:01'),
(141, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:23:06'),
(142, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:23:21'),
(143, 1, 'Super Admin', 'admin', 'update', 'System', 'Enabled Google Authenticator', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:24:39'),
(144, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:24:41'),
(145, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:24:56'),
(146, 1, 'Super Admin', 'admin', 'update', 'System', 'Disabled Google Authenticator', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:25:46'),
(147, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:27:34'),
(148, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:27:42'),
(149, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:27:50'),
(150, 4, 'Finance', 'finance', 'login', 'payment', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:28:00'),
(151, 4, 'Finance', 'finance', 'logout', 'payment', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:28:02'),
(152, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:28:10'),
(153, 9, 'Student User', 'student', 'view', 'student_portal', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:32:37'),
(154, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:33:33'),
(155, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:33:55'),
(156, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:37:05'),
(157, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 14:37:12'),
(158, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:04:56'),
(159, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:18:44'),
(160, 3, 'CRAD Officer', 'crad_officer', 'view', 'crad', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:19:12'),
(161, 3, 'CRAD Officer', 'crad_officer', 'update', 'System', 'Enabled Google Authenticator', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:21:14'),
(162, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:21:16'),
(163, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:22:03'),
(164, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:22:09'),
(165, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:22:17'),
(166, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:23:34'),
(167, 9, 'Student User', 'student', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:23:46'),
(168, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:23:57'),
(169, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00004 (6 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:27:28'),
(170, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:27:30'),
(171, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:27:51'),
(172, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:29:05'),
(173, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 15:29:25'),
(174, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 21:37:37'),
(175, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 21:37:40'),
(176, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 21:59:44'),
(177, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 22:01:44'),
(178, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 22:01:51'),
(179, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-07 22:14:54'),
(180, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:37:06'),
(181, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:37:41'),
(182, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:37:49'),
(183, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user studentaffairs', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:38:23'),
(184, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:40:43'),
(185, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:40:52'),
(186, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user superadmin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:48:14'),
(187, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:48:16'),
(188, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:48:21'),
(189, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:48:23'),
(190, 1, 'Super Admin', 'admin', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:48:26'),
(191, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:48:29'),
(192, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Updated user superadmin', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 01:48:41'),
(193, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 12:12:02'),
(194, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 12:12:12'),
(195, 3, 'CRAD Officer', 'crad_officer', 'update', 'crad', 'Registered approved proposal number:CRD-2026-00003', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 12:38:51'),
(196, 3, 'CRAD Officer', 'crad_officer', 'create', 'crad', 'Generated research group number: RG-2026-001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 12:49:15'),
(197, 9, 'Student User', 'student', 'view', 'student_portal', 'Opened Security Settings', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 12:53:19'),
(198, 3, 'CRAD Officer', 'crad_officer', 'update', 'crad', 'Registered approved proposal number:CRD-2026-00004', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:03:57'),
(199, 3, 'CRAD Officer', 'crad_officer', 'create', 'crad', 'Generated research group number: RG-2026-002', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:04:02'),
(200, 3, 'CRAD Officer', 'crad_officer', 'update', 'crad', 'Registered approved proposal number:CRD-2026-00002', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:05:55'),
(201, 3, 'CRAD Officer', 'crad_officer', 'create', 'crad', 'Generated research group number: RG-2026-001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:06:05'),
(202, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:07:15'),
(203, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:08:59'),
(204, 9, 'Student User', 'student', 'create', 'student_portal', 'Resubmitted revised research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:33:56'),
(205, 3, 'CRAD Officer', 'crad_officer', 'update', 'crad', 'Registered approved proposal number:CRD-2026-00006', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:37:18'),
(206, 3, 'CRAD Officer', 'crad_officer', 'create', 'crad', 'Generated research group number: RG-2026-001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:37:21'),
(207, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:39:20'),
(208, 3, 'CRAD Officer', 'crad_officer', 'update', 'crad', 'Registered approved proposal number:CRD-2026-00007', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:39:46'),
(209, 3, 'CRAD Officer', 'crad_officer', 'create', 'crad', 'Generated research group number: RG-2026-001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:39:48'),
(210, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:41:46'),
(211, 3, 'CRAD Officer', 'crad_officer', 'update', 'crad', 'Registered approved proposal number:CRD-2026-00008', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:42:32'),
(212, 3, 'CRAD Officer', 'crad_officer', 'create', 'crad', 'Generated research group number: RG-2026-001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:42:39'),
(213, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:44:07'),
(214, 9, 'Student User', 'student', 'create', 'student_portal', 'Resubmitted revised research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 13:45:25'),
(215, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:52:25'),
(216, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:52:55'),
(217, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:53:04');
INSERT INTO `activity_logs` (`id`, `user_id`, `user_name`, `role_key`, `action`, `module_key`, `detail`, `ip_address`, `user_agent`, `created_at`) VALUES
(218, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:53:10'),
(219, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:53:19'),
(220, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:53:53'),
(221, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:54:01'),
(222, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:54:11'),
(223, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:54:19'),
(224, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (7 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:54:41'),
(225, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:54:56'),
(226, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:55:04'),
(227, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 15:55:12'),
(228, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 16:01:45'),
(229, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 16:01:54'),
(230, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 16:32:36'),
(231, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (6 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 16:37:00'),
(232, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (6 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 16:46:27'),
(233, 9, 'Student User', 'student', 'create', 'student_portal', 'Submitted research document packet ref:CRD-2026-00001 (6 files)', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:02:31'),
(234, 3, 'CRAD Officer', 'crad_officer', 'update', 'crad', 'Registered approved proposal number:CRD-2026-00013', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:03:28'),
(235, 3, 'CRAD Officer', 'crad_officer', 'create', 'crad', 'Generated research group number: RG-2026-001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:03:31'),
(236, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:07:08'),
(237, 1, 'Super Admin', 'admin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:07:17'),
(238, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Permission registrar:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:16:54'),
(239, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Permission registrar:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:18:42'),
(240, 1, 'Super Admin', 'admin', 'update', 'user-management', 'Permission superadmin:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:00'),
(241, 1, 'Super Admin', 'admin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:07'),
(242, 1, 'Super Admin', 'superadmin', 'login', 'System', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:13'),
(243, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:20'),
(244, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission admission:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:25'),
(245, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission registrar:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:26'),
(246, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:39'),
(247, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:registrar = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:41'),
(248, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:crad = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:42'),
(249, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Reset all role permissions to defaults', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:49'),
(250, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission admission:registrar = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:28:55'),
(251, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission admission:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:03'),
(252, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:crad = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:06'),
(253, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:lms = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:07'),
(254, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:reports-analytics = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:07'),
(255, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:cocurricular = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:08'),
(256, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:scheduling = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:08'),
(257, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:faculty = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:08'),
(258, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:payment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:09'),
(259, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:accreditation = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:09'),
(260, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:curriculum = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:10'),
(261, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:registrar = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:11'),
(262, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:12'),
(263, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission admission:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:12'),
(264, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission registrar:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:29:14'),
(265, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission admission:registrar = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:34:34'),
(266, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:34:54'),
(267, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:34:56'),
(268, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission crad_officer:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:10'),
(269, 1, 'Super Admin', 'superadmin', 'logout', 'System', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:11'),
(270, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:19'),
(271, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:22'),
(272, 1, 'Super Admin', 'superadmin', 'login_failed', 'System', 'Invalid password', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:29'),
(273, 1, 'Super Admin', 'superadmin', 'login', 'System', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:35'),
(274, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission crad_officer:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:39'),
(275, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:41'),
(276, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:registrar = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:41'),
(277, 1, 'Super Admin', 'superadmin', 'logout', 'System', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:43'),
(278, 1, 'Super Admin', 'superadmin', 'login', 'System', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:51'),
(279, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:54'),
(280, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:registrar = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:35:54'),
(281, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:reports-analytics = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:40:49'),
(282, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:reports-analytics = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:40:49'),
(283, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Reset all role permissions to defaults', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:41:08'),
(284, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission admission:registrar = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:41:14'),
(285, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission registrar:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:41:16'),
(286, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Updated user registrar', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:51:29'),
(287, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Updated user registrar', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:51:38'),
(288, 1, 'Super Admin', 'superadmin', 'logout', 'user-management', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:51:39'),
(289, 2, 'Registrar', 'registrar', 'login', 'registrar', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:51:44'),
(290, 2, 'Registrar', 'registrar', 'logout', 'registrar', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:51:59'),
(291, 1, 'Super Admin', 'superadmin', 'login', 'user-management', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:52:07'),
(292, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:52:12'),
(293, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:52:12'),
(294, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:52:13'),
(295, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:52:18'),
(296, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission student:student_portal = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:55:49'),
(297, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission student:student_portal = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:55:50'),
(298, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:55:55'),
(299, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:56:03'),
(300, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:57:09'),
(301, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:enrollment = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 17:57:13'),
(302, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission qa:user-management = grant', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 18:04:41'),
(303, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission qa:user-management = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 18:04:42'),
(304, 1, 'Super Admin', 'superadmin', 'update', 'user-management', 'Permission superadmin:student_portal = deny', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 18:05:07');

-- --------------------------------------------------------

--
-- Table structure for table `login_throttles`
--

CREATE TABLE `login_throttles` (
  `id` int(10) UNSIGNED NOT NULL,
  `throttle_key` char(64) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `attempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_ip` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `password_resets`
--

INSERT INTO `password_resets` (`id`, `user_id`, `token_hash`, `expires_at`, `used_at`, `created_ip`, `created_at`) VALUES
(2, 1, '550d259303762ee9ce8b5378b3b6b1e212a4b5cf796b005404689bb4c5596866', '2026-08-06 14:05:55', '2026-08-06 13:06:28', '::1', '2026-08-06 13:05:55'),
(3, 9, '691edab739335bc353c7ecaa7d183393ea51e47def723d4f3e68adccdd10fcb9', '2026-08-06 14:18:23', '2026-08-06 13:18:33', '::1', '2026-08-06 13:18:23'),
(4, 9, '55eabae148518a30c44e17552b678572afdda8d79fc2c59f95152780545da52b', '2026-08-06 14:18:33', NULL, '::1', '2026-08-06 13:18:33');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_requests`
--

CREATE TABLE `password_reset_requests` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `module_key` varchar(60) NOT NULL,
  `reason` varchar(500) DEFAULT NULL,
  `requested_password_hash` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `admin_id` int(10) UNSIGNED DEFAULT NULL,
  `admin_note` varchar(500) DEFAULT NULL,
  `temp_password_set` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `resolved_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `role_key` varchar(40) NOT NULL,
  `label` varchar(80) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `role_key`, `label`, `description`, `is_system`, `created_at`) VALUES
(1, 'admin', 'Super Admin', 'Legacy super admin access', 1, '2026-07-22 22:24:44'),
(2, 'registrar', 'Registrar', 'Enrollment, records, scheduling', 1, '2026-07-22 22:24:44'),
(3, 'finance', 'Finance', 'Payments and receivables', 1, '2026-07-22 22:24:44'),
(4, 'hr', 'Dean', 'Dean and faculty processes', 1, '2026-07-22 22:24:44'),
(5, 'it_office', 'IT Office', 'LMS and IT modules', 1, '2026-07-22 22:24:44'),
(6, 'osa', 'OSA', 'Student affairs / co-curricular', 1, '2026-07-22 22:24:44'),
(7, 'qa', 'QA Office', 'Accreditation and quality', 1, '2026-07-22 22:24:44'),
(8, 'crad_officer', 'CRAD Officer', 'Research and development', 1, '2026-07-22 22:24:44'),
(9, 'student', 'Student', 'Student portal only', 1, '2026-07-22 22:24:44'),
(10, 'superadmin', 'Super Admin', 'Full system access', 1, '2026-08-08 17:25:19'),
(11, 'admission', 'Admission', 'Admission office access', 1, '2026-08-08 17:25:19'),
(12, 'research_coordinator', 'Research Coordinator', 'Research coordination access', 1, '2026-08-08 18:10:00'),
(13, 'research_director', 'Research Director', 'Research defense scheduling director account', 1, '2026-08-09 19:27:00');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `role_key` varchar(40) NOT NULL,
  `module_key` varchar(60) NOT NULL,
  `granted` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`id`, `role_key`, `module_key`, `granted`, `updated_at`) VALUES
(106, 'superadmin', 'user-management', 1, '2026-08-08 17:41:08'),
(107, 'admission', 'enrollment', 1, '2026-08-08 17:41:08'),
(108, 'admission', 'registrar', 0, '2026-08-08 17:41:14'),
(109, 'registrar', 'enrollment', 0, '2026-08-08 17:41:16'),
(110, 'registrar', 'registrar', 1, '2026-08-08 17:41:08'),
(111, 'registrar', 'curriculum', 1, '2026-08-08 17:41:08'),
(112, 'registrar', 'scheduling', 1, '2026-08-08 17:41:08'),
(113, 'finance', 'payment', 1, '2026-08-08 17:41:08'),
(114, 'hr', 'faculty', 1, '2026-08-08 17:41:08'),
(115, 'it_office', 'lms', 1, '2026-08-08 17:41:08'),
(116, 'osa', 'cocurricular', 1, '2026-08-08 17:41:08'),
(117, 'qa', 'accreditation', 1, '2026-08-08 17:41:08'),
(118, 'crad_officer', 'crad', 1, '2026-08-08 17:41:08'),
(119, 'student', 'student_portal', 1, '2026-08-08 17:55:50'),
(130, 'superadmin', 'enrollment', 0, '2026-08-08 17:57:13'),
(141, 'superadmin', 'student_portal', 0, '2026-08-08 18:05:07'),
(142, 'qa', 'user-management', 0, '2026-08-08 18:04:42'),
(143, 'research_coordinator', 'crad', 1, '2026-08-08 18:10:00'),
(144, 'research_director', 'faculty', 1, '2026-08-09 19:27:00');

-- --------------------------------------------------------

--
-- Table structure for table `security_otps`
--

CREATE TABLE `security_otps` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `purpose` varchar(40) NOT NULL,
  `code_hash` char(64) NOT NULL,
  `module_key` varchar(60) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `security_otps`
--

INSERT INTO `security_otps` (`id`, `user_id`, `purpose`, `code_hash`, `module_key`, `expires_at`, `used_at`, `created_at`) VALUES
(1, 3, 'auth_setup', '00aa177502733dd1e947e9addf22e1e33ff0a061d3af840955c53e19f129d130', NULL, '2026-07-23 12:32:33', NULL, '2026-07-23 12:22:33'),
(2, 10, 'auth_setup', '434b2a7ce1742c5901ad141e3fd48d88a160776362d41a87fe120c61735dca25', NULL, '2026-07-23 12:41:18', '2026-07-23 12:31:35', '2026-07-23 12:31:18'),
(3, 1, 'login_2fa', 'fe8a2e43fdc5dfd231e4a5365fb4b97accb2d492d0618b8cb1239f2003384197', 'System', '2026-08-06 12:18:17', '2026-08-07 13:47:43', '2026-08-06 12:08:17'),
(4, 1, 'login_2fa', 'e5533c6584ffce50ff4b8a86ab22a27b4aec09511ca75cc45ae10f872e3b395f', 'System', '2026-08-06 12:35:41', '2026-08-07 13:47:43', '2026-08-06 12:25:41'),
(5, 1, 'login_2fa', '42b95c3f3a5bc304110b877053c1d5165d141cb2dd8aa4640078b64f9cd3f55a', 'System', '2026-08-06 12:37:17', '2026-08-07 13:47:43', '2026-08-06 12:27:17'),
(6, 1, 'login_2fa', 'b121a650c927ab1c64dbe5dcd7b1ee6cad3e31559cc17a9498e845353b39543c', 'System', '2026-08-06 12:49:29', '2026-08-07 13:47:43', '2026-08-06 12:39:29'),
(7, 1, 'login_2fa', 'd8a6f5265b58db60841f94a1910e75b34d95e7d484a4d684ba76c8a376ae8b74', 'System', '2026-08-06 12:51:04', '2026-08-07 13:47:43', '2026-08-06 12:41:04'),
(8, 1, 'login_2fa', '464da7d02deaa950b60fba29e5dd949ddb3d4d2108cc4d07dfd084fa472e4c9f', 'System', '2026-08-06 12:54:49', '2026-08-07 13:47:43', '2026-08-06 12:44:49'),
(9, 1, 'login_2fa', '52f02070f7f89d4a26b2de369b5d3f25b1d5ad68edca4505583d7dfae7629fe4', 'System', '2026-08-06 12:57:18', '2026-08-07 13:47:43', '2026-08-06 12:47:18'),
(10, 1, 'login_2fa', 'b901c750520b0d84eccbd2e6c98d5090d087acf2e44adff08fd38976d0db9412', 'System', '2026-08-06 13:19:23', '2026-08-07 13:47:43', '2026-08-06 13:09:23'),
(11, 1, 'password_change', 'a2b739a763e75c0377332f0cf70bc4d4b1fa1e6c777d960a592a3a9a072a3d40', 'admin-account', '2026-08-06 13:20:17', '2026-08-07 13:47:43', '2026-08-06 13:10:17'),
(12, 1, 'login_2fa', '96fb4145442779cd5534a2c540a7e9c6af8ec7d5d65d44f3a362bd466f75ea1f', 'System', '2026-08-06 13:23:25', '2026-08-07 13:47:43', '2026-08-06 13:13:25'),
(13, 1, 'login_2fa', '1a06a98bfb9fd1053e961bd6756f21edf14accb3eec42542a172d8ad2ae0aa66', 'System', '2026-08-06 13:25:26', '2026-08-07 13:47:43', '2026-08-06 13:15:26'),
(14, 1, 'login_2fa', '98e0b51ec04c9d63f34871bfe2e7a6b7284c174c2cdb537b35a4532978a1cff0', 'System', '2026-08-06 13:30:15', '2026-08-07 13:47:43', '2026-08-06 13:20:15'),
(15, 1, 'login_2fa', '6c828c6267e0b07f37a35b2000fc08831c60cece48c87fce4a60aabd2bbf634e', 'System', '2026-08-06 13:35:35', '2026-08-07 13:47:43', '2026-08-06 13:25:35'),
(16, 1, 'login_2fa', '78b7b05beda2d061eafc5c3dc98d62ab33427d54ccad3efbcc93c5686f68379c', 'System', '2026-08-06 13:41:19', '2026-08-07 13:47:43', '2026-08-06 13:31:19'),
(17, 3, 'login_2fa', 'f0bda89589cd1f9af75f462a57bbdf5d5baf94be8e6553c731c314ca8eea028d', 'System', '2026-08-06 13:42:02', '2026-08-07 13:47:43', '2026-08-06 13:32:02'),
(18, 3, 'login_2fa', '38acad02af807fed2131bc29cba07e19e1df2ab2cb5d0dd6324bb02f13a55556', 'System', '2026-08-06 13:51:38', '2026-08-07 13:47:43', '2026-08-06 13:41:38'),
(19, 1, 'login_2fa', 'cdc036ae8ca397a128794e366b26d21e3e8ec44b03aee9f90735aca07f1ad5a6', 'System', '2026-08-06 14:05:22', '2026-08-07 13:47:43', '2026-08-06 13:55:22'),
(20, 1, 'login_2fa', 'edbde5b085641bb56b53105fa228487e2f7d0c2e1a230f920ddbebe2f2c72e14', 'System', '2026-08-06 14:12:17', '2026-08-07 13:47:43', '2026-08-06 14:02:17'),
(21, 1, 'login_2fa', '59e1d8a04bbdb577a5127fa8e4b51d51f57aa2daad911e88e97b6c843272f28d', 'System', '2026-08-06 14:16:28', '2026-08-07 13:47:43', '2026-08-06 14:06:28'),
(22, 3, 'login_2fa', 'e6c1d8b78e999e9bc4f1b633fa0a584669ec5984759d4adabf59745f49bc503e', 'System', '2026-08-06 14:53:44', '2026-08-07 13:47:43', '2026-08-06 14:43:44'),
(23, 1, 'login_2fa', '264797c49afc4ad46350f996be7c1894b7e19828bdb52083f16a24301e3edb82', 'System', '2026-08-06 16:02:00', '2026-08-07 13:47:43', '2026-08-06 15:52:00'),
(24, 3, 'login_2fa', '5c7435d07f6f8c48816e5d6c8522b3add82f6cce0e3284bb92589998761e4583', 'System', '2026-08-06 16:02:53', '2026-08-07 13:47:43', '2026-08-06 15:52:53'),
(25, 3, 'login_2fa', 'a880ff676aac443c05712a3771640b6275a86282c34ba45a2d1075c757b86991', 'System', '2026-08-06 16:45:53', '2026-08-07 13:47:43', '2026-08-06 16:35:53'),
(26, 1, 'login_2fa', 'cd26d8606d44d05c0e9116c5d9b445655a9132310ad7bda5983a969e9ea9f26d', 'System', '2026-08-06 20:13:26', '2026-08-07 13:47:43', '2026-08-06 20:03:26'),
(27, 1, 'login_2fa', '967cb927a3559c93bbbe1d503405f92049cfeaeedcb2fd11c3ec9eee0c4d2f6e', 'System', '2026-08-06 20:31:15', '2026-08-07 13:47:43', '2026-08-06 20:21:15'),
(28, 3, 'login_2fa', '365e076e8bb97bae37a97870e02200186d2776cdced25150c0d37cc086eb8a5b', 'System', '2026-08-06 20:35:28', '2026-08-07 13:47:43', '2026-08-06 20:25:28'),
(29, 1, 'login_2fa', 'ad13979ae9e79127941523c4bbb960dcee573c5765e05db86dbd1bdf67527e62', 'System', '2026-08-07 11:54:29', '2026-08-07 13:47:43', '2026-08-07 11:44:29'),
(30, 3, 'login_2fa', '8c4b0774bc5f82a69bba1cde2b2965d76c7e7db49b4c2a7a4c7415b60bf784cf', 'System', '2026-08-07 11:55:03', '2026-08-07 13:47:43', '2026-08-07 11:45:03'),
(31, 1, 'login_2fa', '90858f8d89d06736dd2f40b75ff8eb3a998e0c93fcbd8e9933f9e73630d7127f', 'System', '2026-08-07 13:57:27', '2026-08-07 13:47:43', '2026-08-07 13:47:27'),
(32, 1, 'passkey_remove', 'df8c90265057ad814bde1ac13e69cd5d1aa480375cd8a00f9e9b4a29e917b7fe', NULL, '2026-08-07 14:33:29', NULL, '2026-08-07 14:23:29');

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `setting_key` varchar(80) NOT NULL,
  `setting_value` text NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`setting_key`, `setting_value`, `updated_at`) VALUES
('csrf_enabled', '1', '2026-07-22 22:24:44'),
('lockout_minutes', '1', '2026-07-23 08:05:06'),
('lockout_seconds', '15', '2026-07-23 08:05:06'),
('lockout_unit', 'seconds', '2026-07-23 08:05:06'),
('lockout_value', '15', '2026-07-23 08:05:06'),
('mail_admin_email', 'j14677365@gmail.com', '2026-07-23 10:34:27'),
('mail_from_email', 'noreply@bestlink.edu.ph', '2026-07-23 10:33:25'),
('mail_from_name', 'SMS 2', '2026-07-23 10:33:25'),
('mail_show_link_on_failure', '0', '2026-07-23 10:34:27'),
('max_failed_logins', '3', '2026-07-23 07:33:05'),
('min_password_length', '8', '2026-07-22 22:24:44'),
('module_kick_epoch_crad', '1784849304', '2026-07-23 15:28:24'),
('module_maintenance_crad', '0', '2026-07-23 15:29:22'),
('module_maintenance_msg_crad', 'The system is currently under maintenance. Some services may be temporarily unavailable.\r\n\r\nThank you for your patience and understanding.', '2026-07-23 15:05:14'),
('password_expiry_days', '0', '2026-07-22 22:24:44'),
('require_password_change_first_login', '0', '2026-07-22 22:24:44'),
('session_timeout_minutes', '30', '2026-07-22 22:24:44'),
('smtp_encryption', 'tls', '2026-07-23 10:33:25'),
('smtp_host', 'smtp.gmail.com', '2026-07-23 10:51:48'),
('smtp_password', 'sms2enc1.BnNN43RIftF9bLKe7buHTa6/qaxuGXWg5XruC7mKh67ZYei7aPH7AeOKNpdXJ7A=', '2026-08-06 12:08:17'),
('smtp_port', '587', '2026-07-23 10:33:25'),
('smtp_username', 'j14677365@gmail.com', '2026-07-23 10:33:25');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `username` varchar(80) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `role_key` varchar(40) NOT NULL,
  `student_id` varchar(40) DEFAULT NULL,
  `status` enum('active','inactive','locked','suspended') NOT NULL DEFAULT 'active',
  `must_change_password` tinyint(1) NOT NULL DEFAULT 0,
  `failed_login_attempts` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(45) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `full_name`, `role_key`, `student_id`, `status`, `must_change_password`, `failed_login_attempts`, `locked_until`, `password_changed_at`, `last_login_at`, `last_seen_at`, `last_login_ip`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'superadmin', 'kennethabejuela0308@gmail.com', '$2y$10$hmYAIygWZMBkNodgaEFv7OForU0B.PFUWiKtWWdYCJpRK1jDT9OrC', 'Super Admin', 'superadmin', NULL, 'active', 0, 0, NULL, '2026-08-08 01:48:41', '2026-08-08 17:52:07', '2026-08-08 18:04:35', '::1', NULL, '2026-07-22 22:53:59', '2026-08-08 18:04:35'),
(2, 'registrar', 'registrar@bestlink.edu.ph', '$2y$10$LTJ240DjZQtY3N0I8L.D/OzCYx26C3WsD3e3yEhvGrW0tje2yRhBW', 'Registrar', 'registrar', NULL, 'active', 0, 0, NULL, '2026-08-08 17:51:38', '2026-08-08 17:51:44', NULL, '::1', NULL, '2026-07-22 22:53:59', '2026-08-08 17:51:59'),
(3, 'cradofficer', 'angelicadublin340@gmail.com', '$2y$10$MpwtxHnKofWTxV5/axRiPuudxLEFIdLJChvSoykU9poFiH/W9wRPK', 'CRAD Officer', 'crad_officer', NULL, 'active', 0, 0, NULL, '2026-08-06 13:31:50', '2026-08-08 17:35:19', NULL, '::1', NULL, '2026-07-22 22:53:59', '2026-08-08 17:35:22'),
(4, 'finance', 'monvictortesiorna@gmail.com', '$2y$10$mOPKz95hA/OlTNHGzzgLEuvYqMBNAE1RdQFThECQjfv94o.RbvIZq', 'Finance', 'finance', NULL, 'active', 0, 0, NULL, '2026-08-06 20:20:39', '2026-08-07 14:28:00', NULL, '::1', NULL, '2026-07-22 22:54:00', '2026-08-07 14:28:02'),
(5, 'studentaffairs', 'studentaffairs@bestlink.edu.ph', '$2y$10$QSPLuT09VAB/X8J02CRi3erPEuhgAR2fKNCg.YLaOY.o2mnRuULii', 'Student Affairs', 'osa', NULL, 'active', 0, 0, NULL, '2026-08-08 01:38:23', NULL, NULL, NULL, NULL, '2026-07-22 22:54:00', '2026-08-08 01:38:23'),
(6, 'itofficer', 'itofficer@bestlink.edu.ph', '$2y$10$fIFFgaSnSssf4ZdaYupnZ.fzX6dYDfE7escqc/GMedxVZUHCaqCPe', 'IT Officer', 'it_office', NULL, 'active', 0, 0, NULL, '2026-07-22 22:54:00', NULL, NULL, NULL, NULL, '2026-07-22 22:54:00', '2026-07-22 22:54:00'),
(7, 'qualityassurance', 'qualityassurance@bestlink.edu.ph', '$2y$10$Bm/Te5m0uFyTRDhDDV.lf.9HuUEe7qIUOfZtHXF2eufIIXL1N3IVC', 'Quality Assurance', 'qa', NULL, 'active', 0, 0, NULL, '2026-07-22 22:54:00', NULL, NULL, NULL, NULL, '2026-07-22 22:54:00', '2026-07-22 22:54:00'),
(8, 'dean', 'dean@bestlink.edu.ph', '$2y$10$Vnny70aSsPiimmO3/u6WKelc2VvQaKgSOujmZJP4C7q3IUFsUwfcy', 'Dean', 'hr', NULL, 'active', 0, 0, NULL, '2026-08-07 14:10:53', '2026-08-07 14:11:03', NULL, '::1', NULL, '2026-07-22 22:54:00', '2026-08-08 17:15:19'),
(9, 's230000001', 'kenlangmalakas0308@gmail.com', '$2y$10$E0IiZOWMscnUfdX8H7gxt.5YzIkUqLK.qn07WF9MCA0StJhToFn2q', 'Student User', 'student', 'S230000001', 'active', 0, 0, NULL, '2026-08-06 13:17:16', '2026-08-08 17:56:03', '2026-08-08 18:03:37', '::1', NULL, '2026-07-22 22:54:00', '2026-08-08 18:03:37'),
(20, 'admission', 'admission@bestlink.edu.ph', '$2y$10$pF3fNVXy1Nuk01exnJobbO6lilErbTYkcG9AECZ53XNQIHA33iMv2', 'Admission', 'admission', NULL, 'active', 0, 0, NULL, '2026-08-08 17:25:20', NULL, NULL, NULL, NULL, '2026-08-08 17:25:20', '2026-08-08 17:25:20'),
(40, 'researchcoordinator', 'researchcoordinator@bestlink.edu.ph', '$2y$10$f9DQYvDoQknpAcoA3T6u6uEMcIrMP8E704loMPERIk8N6JBDO.nyK', 'Mrs. Kris Guevarra', 'research_coordinator', NULL, 'active', 0, 0, NULL, '2026-08-08 18:09:48', NULL, NULL, NULL, NULL, '2026-08-08 18:09:48', '2026-08-08 18:09:48'),
(41, 'researchdirector', 'research.director@bestlink.edu.ph', '$2y$10$TECtJ7ZZfsvvsD/xF4yRteQ5tKUaNLuLNOZ0SXJWt11bVK3ZpD6/K', 'Research Director', 'research_director', NULL, 'active', 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, '2026-08-09 19:27:00', '2026-08-09 19:27:00');

-- --------------------------------------------------------

--
-- Table structure for table `user_authenticators`
--

CREATE TABLE `user_authenticators` (
  `user_id` int(10) UNSIGNED NOT NULL,
  `secret` varchar(512) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `pending_secret` varchar(512) DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_passkeys`
--

CREATE TABLE `user_passkeys` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `credential_id` varchar(255) NOT NULL,
  `public_key` text NOT NULL,
  `sign_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `device_name` varchar(120) NOT NULL DEFAULT 'Passkey',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `last_used_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_logs_user` (`user_id`),
  ADD KEY `idx_logs_action` (`action`),
  ADD KEY `idx_logs_created` (`created_at`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_reset_user` (`user_id`),
  ADD KEY `idx_reset_token` (`token_hash`),
  ADD KEY `idx_reset_expires` (`expires_at`);

--
-- Indexes for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_prr_user` (`user_id`),
  ADD KEY `idx_prr_status` (`status`),
  ADD KEY `idx_prr_module` (`module_key`),
  ADD KEY `fk_prr_admin` (`admin_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_roles_key` (`role_key`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_role_module` (`role_key`,`module_key`),
  ADD KEY `idx_perm_module` (`module_key`);

--
-- Indexes for table `security_otps`
--
ALTER TABLE `security_otps`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`setting_key`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_username` (`username`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_role` (`role_key`),
  ADD KEY `idx_users_status` (`status`),
  ADD KEY `idx_users_student_id` (`student_id`),
  ADD KEY `idx_users_last_seen` (`last_seen_at`);

--
-- Indexes for table `user_authenticators`
--
ALTER TABLE `user_authenticators`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `user_passkeys`
--
ALTER TABLE `user_passkeys`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=305;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT for table `role_permissions`
--
ALTER TABLE `role_permissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=147;

--
-- AUTO_INCREMENT for table `security_otps`
--
ALTER TABLE `security_otps`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `user_authenticators`
--
ALTER TABLE `user_authenticators`
  MODIFY `user_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user_passkeys`
--
ALTER TABLE `user_passkeys`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `fk_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `fk_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `password_reset_requests`
--
ALTER TABLE `password_reset_requests`
  ADD CONSTRAINT `fk_prr_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_prr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `fk_perm_role` FOREIGN KEY (`role_key`) REFERENCES `roles` (`role_key`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_key`) REFERENCES `roles` (`role_key`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
