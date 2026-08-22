-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 22, 2026 at 10:21 PM
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
-- Database: `crad_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `chapter_evaluations`
--

CREATE TABLE `chapter_evaluations` (
  `id` int(10) UNSIGNED NOT NULL,
  `submission_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `evaluator_user_id` int(10) UNSIGNED NOT NULL,
  `evaluator_name` varchar(150) NOT NULL DEFAULT '',
  `content_score` decimal(5,2) NOT NULL,
  `methodology_score` decimal(5,2) NOT NULL,
  `references_score` decimal(5,2) NOT NULL,
  `format_score` decimal(5,2) NOT NULL,
  `content_remarks` text DEFAULT NULL,
  `methodology_remarks` text DEFAULT NULL,
  `references_remarks` text DEFAULT NULL,
  `format_remarks` text DEFAULT NULL,
  `overall_feedback` text DEFAULT NULL,
  `result` enum('APPROVED','APPROVED WITH REVISION') NOT NULL,
  `overall_score` decimal(5,2) DEFAULT NULL,
  `evaluated_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chapter_evaluations`
--

INSERT INTO `chapter_evaluations` (`id`, `submission_id`, `research_group_id`, `evaluator_user_id`, `evaluator_name`, `content_score`, `methodology_score`, `references_score`, `format_score`, `content_remarks`, `methodology_remarks`, `references_remarks`, `format_remarks`, `overall_feedback`, `result`, `overall_score`, `evaluated_at`, `created_at`) VALUES
(25, 29, 61, 475, 'Grammarian', 100.00, 100.00, 100.00, 100.00, '', '', '', '', '', 'APPROVED', 100.00, '2026-08-23 04:07:50', '2026-08-23 04:07:50'),
(26, 30, 61, 475, 'Grammarian', 100.00, 100.00, 100.00, 99.97, '', '', '', '', '', 'APPROVED', 99.99, '2026-08-23 04:07:59', '2026-08-23 04:07:59'),
(27, 31, 61, 475, 'Grammarian', 100.00, 100.00, 100.00, 100.00, '', '', '', '', '', 'APPROVED', 100.00, '2026-08-23 04:08:08', '2026-08-23 04:08:08');

-- --------------------------------------------------------

--
-- Table structure for table `chapter_evaluation_notifications`
--

CREATE TABLE `chapter_evaluation_notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `event_key` varchar(120) NOT NULL,
  `recipient_user_id` int(10) UNSIGNED DEFAULT NULL,
  `recipient_role` varchar(60) NOT NULL DEFAULT '',
  `recipient_email` varchar(190) NOT NULL DEFAULT '',
  `submission_id` int(10) UNSIGNED NOT NULL,
  `type` varchar(60) NOT NULL,
  `title` varchar(180) NOT NULL,
  `body` text NOT NULL,
  `url` varchar(255) NOT NULL DEFAULT '',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chapter_evaluation_notifications`
--

INSERT INTO `chapter_evaluation_notifications` (`id`, `event_key`, `recipient_user_id`, `recipient_role`, `recipient_email`, `submission_id`, `type`, `title`, `body`, `url`, `is_read`, `created_at`) VALUES
(1, 'evaluator:new:1:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 1, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=1', 0, '2026-08-14 11:24:27'),
(2, 'evaluator:new:2:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 2, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=2', 0, '2026-08-14 11:24:31'),
(3, 'evaluator:new:3:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 3, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=3', 1, '2026-08-14 11:24:36'),
(4, 'student:under_review:1', 9, 'student', 'kenlangmalakas0308@gmail.com', 1, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 11:24:57'),
(5, 'student:under_review:3', 9, 'student', 'kenlangmalakas0308@gmail.com', 3, 'under_review', 'Chapter 3 is under review', 'Chapter 3 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 11:36:01'),
(6, 'student:needs_revision:3', 9, 'student', 'kenlangmalakas0308@gmail.com', 3, 'needs_revision', 'Chapter 3 needs revision', 'Chapter 3 Version 1 is now Needs Revision.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 1, '2026-08-14 11:36:16'),
(7, 'evaluator:new:4:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 4, 'new_submission', 'Revised Chapter Submitted', 'Group 01 submitted Chapter 3 Version 2 for re-evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=4', 1, '2026-08-14 11:36:41'),
(8, 'evaluator:new:5:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 5, 'new_submission', 'New Chapter Submission', 'Group 33 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=5', 1, '2026-08-14 12:07:57'),
(9, 'evaluator:new:6:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 6, 'new_submission', 'New Chapter Submission', 'Group 33 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=6', 0, '2026-08-14 12:08:00'),
(10, 'evaluator:new:7:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 7, 'new_submission', 'New Chapter Submission', 'Group 33 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=7', 1, '2026-08-14 12:08:03'),
(11, 'student:under_review:5', 9, 'student', 'kenlangmalakas0308@gmail.com', 5, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:16:20'),
(12, 'student:accepted:5', 9, 'student', 'kenlangmalakas0308@gmail.com', 5, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:16:27'),
(13, 'student:under_review:6', 9, 'student', 'kenlangmalakas0308@gmail.com', 6, 'under_review', 'Chapter 2 is under review', 'Chapter 2 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:16:32'),
(14, 'student:accepted:6', 9, 'student', 'kenlangmalakas0308@gmail.com', 6, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:16:37'),
(15, 'evaluator:new:8:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 8, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=8', 0, '2026-08-14 12:46:13'),
(16, 'evaluator:new:9:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 9, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=9', 0, '2026-08-14 12:46:17'),
(17, 'evaluator:new:10:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 10, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=10', 0, '2026-08-14 12:46:20'),
(18, 'student:under_review:8', 9, 'student', 'kenlangmalakas0308@gmail.com', 8, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:47:57'),
(19, 'student:accepted:8', 9, 'student', 'kenlangmalakas0308@gmail.com', 8, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:48:05'),
(20, 'student:under_review:9', 9, 'student', 'kenlangmalakas0308@gmail.com', 9, 'under_review', 'Chapter 3 is under review', 'Chapter 3 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:48:09'),
(21, 'student:accepted:9', 9, 'student', 'kenlangmalakas0308@gmail.com', 9, 'accepted', 'Chapter 3 accepted', 'Chapter 3 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:48:15'),
(22, 'student:under_review:10', 9, 'student', 'kenlangmalakas0308@gmail.com', 10, 'under_review', 'Chapter 2 is under review', 'Chapter 2 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:48:20'),
(23, 'student:accepted:10', 9, 'student', 'kenlangmalakas0308@gmail.com', 10, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:48:26'),
(24, 'evaluator:new:11:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 11, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=11', 0, '2026-08-14 13:23:21'),
(25, 'evaluator:new:12:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 12, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=12', 0, '2026-08-14 13:23:25'),
(26, 'evaluator:new:13:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 13, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=13', 0, '2026-08-14 13:23:28'),
(27, 'student:under_review:11', 9, 'student', 'kenlangmalakas0308@gmail.com', 11, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 13:45:53'),
(28, 'student:accepted:11', 9, 'student', 'kenlangmalakas0308@gmail.com', 11, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 13:46:02'),
(29, 'student:under_review:12', 9, 'student', 'kenlangmalakas0308@gmail.com', 12, 'under_review', 'Chapter 2 is under review', 'Chapter 2 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 13:46:08'),
(30, 'student:accepted:12', 9, 'student', 'kenlangmalakas0308@gmail.com', 12, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 13:46:13'),
(31, 'student:under_review:13', 9, 'student', 'kenlangmalakas0308@gmail.com', 13, 'under_review', 'Chapter 3 is under review', 'Chapter 3 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 13:46:16'),
(32, 'student:accepted:13', 9, 'student', 'kenlangmalakas0308@gmail.com', 13, 'accepted', 'Chapter 3 accepted', 'Chapter 3 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 13:46:22'),
(33, 'evaluator:new:14:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 14, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=14', 0, '2026-08-14 16:40:44'),
(34, 'student:under_review:14', 9, 'student', 'kenlangmalakas0308@gmail.com', 14, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 16:42:06'),
(35, 'student:accepted:14', 9, 'student', 'kenlangmalakas0308@gmail.com', 14, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 1, '2026-08-14 16:42:19'),
(36, 'evaluator:new:15:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 15, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=15', 0, '2026-08-14 17:36:01'),
(37, 'student:under_review:15', 9, 'student', 'kenlangmalakas0308@gmail.com', 15, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 17:36:17'),
(38, 'student:accepted:15', 9, 'student', 'kenlangmalakas0308@gmail.com', 15, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 1, '2026-08-14 17:36:32'),
(39, 'evaluator:new:16:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 16, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=16', 0, '2026-08-14 21:50:29'),
(40, 'student:under_review:16', 9, 'student', 'kenlangmalakas0308@gmail.com', 16, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 21:51:10'),
(41, 'student:accepted:16', 9, 'student', 'kenlangmalakas0308@gmail.com', 16, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 21:51:29'),
(42, 'evaluator:new:17:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 17, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=17', 1, '2026-08-15 16:43:36'),
(43, 'evaluator:new:18:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 18, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=18', 1, '2026-08-15 16:43:40'),
(44, 'evaluator:new:19:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 19, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=19', 1, '2026-08-15 16:43:43'),
(45, 'student:under_review:17', 9, 'student', 'kenlangmalakas0308@gmail.com', 17, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 16:48:40'),
(46, 'student:accepted:17', 9, 'student', 'kenlangmalakas0308@gmail.com', 17, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 16:48:46'),
(47, 'student:under_review:18', 9, 'student', 'kenlangmalakas0308@gmail.com', 18, 'under_review', 'Chapter 2 is under review', 'Chapter 2 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 16:48:51'),
(48, 'student:accepted:18', 9, 'student', 'kenlangmalakas0308@gmail.com', 18, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 16:48:55'),
(49, 'student:under_review:19', 9, 'student', 'kenlangmalakas0308@gmail.com', 19, 'under_review', 'Chapter 3 is under review', 'Chapter 3 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 16:49:00'),
(50, 'student:accepted:19', 9, 'student', 'kenlangmalakas0308@gmail.com', 19, 'accepted', 'Chapter 3 accepted', 'Chapter 3 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 16:49:04'),
(51, 'evaluator:new:20:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 20, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=20', 0, '2026-08-15 22:49:29'),
(52, 'evaluator:new:21:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 21, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=21', 0, '2026-08-15 22:49:33'),
(53, 'evaluator:new:22:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 22, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=22', 0, '2026-08-15 22:49:38'),
(54, 'student:under_review:20', 9, 'student', 'kenlangmalakas0308@gmail.com', 20, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 22:50:04'),
(55, 'student:accepted:20', 9, 'student', 'kenlangmalakas0308@gmail.com', 20, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 22:50:09'),
(56, 'student:under_review:21', 9, 'student', 'kenlangmalakas0308@gmail.com', 21, 'under_review', 'Chapter 2 is under review', 'Chapter 2 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 22:50:13'),
(57, 'student:accepted:21', 9, 'student', 'kenlangmalakas0308@gmail.com', 21, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 22:50:18'),
(58, 'student:under_review:22', 9, 'student', 'kenlangmalakas0308@gmail.com', 22, 'under_review', 'Chapter 3 is under review', 'Chapter 3 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 22:50:21'),
(59, 'student:accepted:22', 9, 'student', 'kenlangmalakas0308@gmail.com', 22, 'accepted', 'Chapter 3 accepted', 'Chapter 3 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-15 22:50:27'),
(60, 'evaluator:new:23:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 23, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=23', 0, '2026-08-16 15:00:39'),
(61, 'evaluator:new:24:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 24, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=24', 0, '2026-08-16 15:00:43'),
(62, 'evaluator:new:25:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 25, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=25', 0, '2026-08-16 15:00:47'),
(63, 'student:under_review:23', 9, 'student', 'kenlangmalakas0308@gmail.com', 23, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 15:01:13'),
(64, 'student:accepted:23', 9, 'student', 'kenlangmalakas0308@gmail.com', 23, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 15:01:21'),
(65, 'student:under_review:24', 9, 'student', 'kenlangmalakas0308@gmail.com', 24, 'under_review', 'Chapter 2 is under review', 'Chapter 2 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 15:01:26'),
(66, 'student:accepted:24', 9, 'student', 'kenlangmalakas0308@gmail.com', 24, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 1, '2026-08-16 15:01:31'),
(67, 'student:under_review:25', 9, 'student', 'kenlangmalakas0308@gmail.com', 25, 'under_review', 'Chapter 3 is under review', 'Chapter 3 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 15:01:35'),
(68, 'student:accepted:25', 9, 'student', 'kenlangmalakas0308@gmail.com', 25, 'accepted', 'Chapter 3 accepted', 'Chapter 3 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 1, '2026-08-16 15:01:40'),
(69, 'evaluator:new:26:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 26, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=26', 0, '2026-08-16 21:42:19'),
(70, 'evaluator:new:27:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 27, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=27', 0, '2026-08-16 21:42:22'),
(71, 'evaluator:new:28:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 28, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=28', 0, '2026-08-16 21:42:25'),
(72, 'student:under_review:26', 9, 'student', 'kenlangmalakas0308@gmail.com', 26, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 21:42:53'),
(73, 'student:accepted:26', 9, 'student', 'kenlangmalakas0308@gmail.com', 26, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 21:43:06'),
(74, 'student:under_review:27', 9, 'student', 'kenlangmalakas0308@gmail.com', 27, 'under_review', 'Chapter 2 is under review', 'Chapter 2 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 21:43:11'),
(75, 'student:accepted:27', 9, 'student', 'kenlangmalakas0308@gmail.com', 27, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 21:43:15'),
(76, 'student:under_review:28', 9, 'student', 'kenlangmalakas0308@gmail.com', 28, 'under_review', 'Chapter 3 is under review', 'Chapter 3 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 21:43:22'),
(77, 'student:accepted:28', 9, 'student', 'kenlangmalakas0308@gmail.com', 28, 'accepted', 'Chapter 3 accepted', 'Chapter 3 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-16 21:43:25'),
(78, 'evaluator:new:29:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 29, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 1 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=29', 0, '2026-08-23 03:50:56'),
(79, 'evaluator:new:30:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 30, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 2 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=30', 0, '2026-08-23 04:07:26'),
(80, 'evaluator:new:31:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 31, 'new_submission', 'New Chapter Submission', 'Group 01 submitted Chapter 3 Version 1 for evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=31', 0, '2026-08-23 04:07:31'),
(81, 'student:under_review:29', 9, 'student', 'kenlangmalakas0308@gmail.com', 29, 'under_review', 'Chapter 1 is under review', 'Chapter 1 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-23 04:07:45'),
(82, 'student:accepted:29', 9, 'student', 'kenlangmalakas0308@gmail.com', 29, 'accepted', 'Chapter 1 accepted', 'Chapter 1 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-23 04:07:50'),
(83, 'student:under_review:30', 9, 'student', 'kenlangmalakas0308@gmail.com', 30, 'under_review', 'Chapter 2 is under review', 'Chapter 2 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-23 04:07:54'),
(84, 'student:accepted:30', 9, 'student', 'kenlangmalakas0308@gmail.com', 30, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-23 04:07:59'),
(85, 'student:under_review:31', 9, 'student', 'kenlangmalakas0308@gmail.com', 31, 'under_review', 'Chapter 3 is under review', 'Chapter 3 Version 1 is now under review.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-23 04:08:03'),
(86, 'student:accepted:31', 9, 'student', 'kenlangmalakas0308@gmail.com', 31, 'accepted', 'Chapter 3 accepted', 'Chapter 3 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-23 04:08:08');

-- --------------------------------------------------------

--
-- Table structure for table `chapter_submissions`
--

CREATE TABLE `chapter_submissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `research_plan_id` int(10) UNSIGNED DEFAULT NULL,
  `chapter_number` tinyint(3) UNSIGNED NOT NULL,
  `version_number` int(10) UNSIGNED NOT NULL,
  `status` enum('Submitted','Under Review','Needs Revision','Accepted') NOT NULL DEFAULT 'Submitted',
  `submitted_by_user` int(10) UNSIGNED DEFAULT NULL,
  `submitted_by_name` varchar(150) NOT NULL DEFAULT '',
  `submitted_by_email` varchar(190) NOT NULL DEFAULT '',
  `submission_notes` text DEFAULT NULL,
  `original_name` varchar(255) NOT NULL DEFAULT '',
  `stored_subdir` varchar(180) NOT NULL DEFAULT '',
  `stored_name` varchar(120) NOT NULL DEFAULT '',
  `file_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `file_mime` varchar(120) NOT NULL DEFAULT '',
  `submission_token` varchar(64) NOT NULL,
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `review_started_at` datetime DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chapter_submissions`
--

INSERT INTO `chapter_submissions` (`id`, `research_group_id`, `research_plan_id`, `chapter_number`, `version_number`, `status`, `submitted_by_user`, `submitted_by_name`, `submitted_by_email`, `submission_notes`, `original_name`, `stored_subdir`, `stored_name`, `file_size`, `file_mime`, `submission_token`, `submitted_at`, `review_started_at`, `reviewed_at`, `updated_at`) VALUES
(29, 61, 22, 1, 1, 'Accepted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '2c66fe8dbd047f238219412c3277ea73.docx', 236268, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '60076d809fe68ad03006c78e3eb0cb7e6b713f49381c9be6f5819e132f909dbe', '2026-08-23 03:50:56', '2026-08-23 04:07:45', '2026-08-23 04:07:50', '2026-08-23 04:07:50'),
(30, 61, 22, 2, 1, 'Accepted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '74ec1209c457db33489fc036d354b869.docx', 236268, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'e18982e452e6050dd4e2eb8de6f2c350a519c3c31ce46abb5d68cb1ab693bada', '2026-08-23 04:07:26', '2026-08-23 04:07:54', '2026-08-23 04:07:59', '2026-08-23 04:07:59'),
(31, 61, 22, 3, 1, 'Accepted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', 'a23d4492676bde4479582b935f03be6e.docx', 236268, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '795962d634b938f5a1aa88751bbea1f4771fa7a908a6fc42152dd0b4266b55f5', '2026-08-23 04:07:31', '2026-08-23 04:08:03', '2026-08-23 04:08:08', '2026-08-23 04:08:08');

-- --------------------------------------------------------

--
-- Table structure for table `chapter_submission_history`
--

CREATE TABLE `chapter_submission_history` (
  `id` int(10) UNSIGNED NOT NULL,
  `submission_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `chapter_number` tinyint(3) UNSIGNED NOT NULL,
  `version_number` int(10) UNSIGNED NOT NULL,
  `status` varchar(40) NOT NULL,
  `event_type` varchar(60) NOT NULL,
  `actor_user_id` int(10) UNSIGNED DEFAULT NULL,
  `actor_name` varchar(150) NOT NULL DEFAULT '',
  `actor_role` varchar(60) NOT NULL DEFAULT '',
  `detail` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chapter_submission_history`
--

INSERT INTO `chapter_submission_history` (`id`, `submission_id`, `research_group_id`, `chapter_number`, `version_number`, `status`, `event_type`, `actor_user_id`, `actor_name`, `actor_role`, `detail`, `created_at`) VALUES
(78, 29, 61, 1, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-23 03:50:56'),
(79, 30, 61, 2, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-23 04:07:26'),
(80, 31, 61, 3, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-23 04:07:31'),
(81, 29, 61, 1, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-23 04:07:45'),
(82, 29, 61, 1, 1, 'Accepted', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED', '2026-08-23 04:07:50'),
(83, 30, 61, 2, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-23 04:07:54'),
(84, 30, 61, 2, 1, 'Accepted', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED', '2026-08-23 04:07:59'),
(85, 31, 61, 3, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-23 04:08:03'),
(86, 31, 61, 3, 1, 'Accepted', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED', '2026-08-23 04:08:08');

-- --------------------------------------------------------

--
-- Table structure for table `final_defense_evaluations`
--

CREATE TABLE `final_defense_evaluations` (
  `id` int(10) UNSIGNED NOT NULL,
  `defense_schedule_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `panel_user_id` int(10) UNSIGNED NOT NULL,
  `panel_name` varchar(150) NOT NULL DEFAULT '',
  `content_score` decimal(5,2) NOT NULL,
  `methodology_score` decimal(5,2) NOT NULL,
  `references_score` decimal(5,2) NOT NULL,
  `format_score` decimal(5,2) NOT NULL,
  `remarks` text DEFAULT NULL,
  `result` enum('APPROVED','APPROVED WITH REVISION','FAILED') NOT NULL,
  `overall_score` decimal(5,2) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'Submitted',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `final_defense_recommendations`
--

CREATE TABLE `final_defense_recommendations` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `group_number` varchar(40) NOT NULL DEFAULT '',
  `adviser_user_id` int(10) UNSIGNED DEFAULT NULL,
  `adviser_name` varchar(150) NOT NULL DEFAULT '',
  `status` enum('Not Ready','Recommended') NOT NULL DEFAULT 'Not Ready',
  `remarks` text DEFAULT NULL,
  `recommended_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `final_manuscript_approvals`
--

CREATE TABLE `final_manuscript_approvals` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `defense_schedule_id` int(10) UNSIGNED DEFAULT NULL,
  `approved_by_user` int(10) UNSIGNED DEFAULT NULL,
  `approved_by_name` varchar(150) NOT NULL DEFAULT '',
  `status` enum('Pending','Approved','Returned') NOT NULL DEFAULT 'Pending',
  `remarks` text DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `grant_applications`
--

CREATE TABLE `grant_applications` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_opportunity_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → grant_opportunities.id',
  `research_group_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK → research_groups.id (nullable for non-capstone applicants)',
  `group_number` varchar(30) DEFAULT NULL,
  `research_title` varchar(500) DEFAULT NULL,
  `applicant_name` varchar(200) NOT NULL DEFAULT '',
  `applicant_user_id` int(10) UNSIGNED DEFAULT NULL,
  `application_notes` text DEFAULT NULL,
  `status` enum('Submitted','Under Review','Approved','Denied','Withdrawn') NOT NULL DEFAULT 'Submitted',
  `submission_token` varchar(64) DEFAULT NULL COMMENT 'One-time token for duplicate-submission prevention',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `grant_opportunities`
--

CREATE TABLE `grant_opportunities` (
  `id` int(10) UNSIGNED NOT NULL,
  `funding_title` varchar(300) NOT NULL,
  `max_funding_cap` decimal(14,2) NOT NULL DEFAULT 0.00,
  `application_deadline` date NOT NULL,
  `eligibility` varchar(100) NOT NULL DEFAULT 'Open',
  `college_program` varchar(200) DEFAULT NULL COMMENT 'Populated when eligibility = Specific College/Program',
  `status` enum('Open for Application','Closed','Expired') NOT NULL DEFAULT 'Open for Application',
  `created_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `created_by_name` varchar(150) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manuscript_evaluations`
--

CREATE TABLE `manuscript_evaluations` (
  `id` int(10) UNSIGNED NOT NULL,
  `submission_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `evaluator_user_id` int(10) UNSIGNED NOT NULL,
  `evaluator_name` varchar(150) NOT NULL DEFAULT '',
  `content_score` decimal(5,2) NOT NULL,
  `methodology_score` decimal(5,2) NOT NULL,
  `results_score` decimal(5,2) NOT NULL,
  `conclusions_score` decimal(5,2) NOT NULL,
  `recommendations_score` decimal(5,2) NOT NULL,
  `references_score` decimal(5,2) NOT NULL,
  `formatting_score` decimal(5,2) NOT NULL,
  `compliance_score` decimal(5,2) NOT NULL,
  `remarks` text DEFAULT NULL,
  `result` enum('APPROVED','FOR REVISION') NOT NULL,
  `overall_score` decimal(5,2) NOT NULL,
  `evaluated_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manuscript_submissions`
--

CREATE TABLE `manuscript_submissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `version_number` int(10) UNSIGNED NOT NULL,
  `status` enum('Submitted','Under Review','For Revision','Approved') NOT NULL DEFAULT 'Submitted',
  `submitted_by_user` int(10) UNSIGNED DEFAULT NULL,
  `submitted_by_name` varchar(150) NOT NULL DEFAULT '',
  `submitted_by_email` varchar(190) NOT NULL DEFAULT '',
  `submission_notes` text DEFAULT NULL,
  `original_name` varchar(255) NOT NULL DEFAULT '',
  `stored_subdir` varchar(180) NOT NULL DEFAULT '',
  `stored_name` varchar(120) NOT NULL DEFAULT '',
  `file_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `file_mime` varchar(120) NOT NULL DEFAULT '',
  `submission_token` varchar(64) NOT NULL,
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `panel_assignment_notifications`
--

CREATE TABLE `panel_assignment_notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `event_key` varchar(140) NOT NULL,
  `recipient_user_id` int(10) UNSIGNED NOT NULL,
  `recipient_role` varchar(60) NOT NULL DEFAULT 'panel',
  `recipient_email` varchar(190) NOT NULL DEFAULT '',
  `panel_assignment_id` int(10) UNSIGNED DEFAULT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `title` varchar(160) NOT NULL DEFAULT '',
  `body` text DEFAULT NULL,
  `url` varchar(500) NOT NULL DEFAULT '',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `panel_assignment_notifications`
--

INSERT INTO `panel_assignment_notifications` (`id`, `event_key`, `recipient_user_id`, `recipient_role`, `recipient_email`, `panel_assignment_id`, `research_group_id`, `title`, `body`, `url`, `is_read`, `created_at`) VALUES
(19, 'preoral-panel-assignment:61:u491', 491, 'panel', 'jobertvalentino@bestlink.edu.ph', 13, 61, 'Pre-Oral Panel Assignment', 'You have been assigned as a Panel Member for Group 01\nDEVELOPMENT OF AI ANALYSIS\nDefense Phase: Pre-Oral Defense', '/SMS2_system/modules/faculty/pages/assigned-defenses.php?group=RG-2026-001', 0, '2026-08-23 04:09:43'),
(20, 'preoral-panel-assignment:61:u492', 492, 'panel', 'jonathanestrada@bestlink.edu.ph', 14, 61, 'Pre-Oral Panel Assignment', 'You have been assigned as a Panel Member for Group 01\nDEVELOPMENT OF AI ANALYSIS\nDefense Phase: Pre-Oral Defense', '/SMS2_system/modules/faculty/pages/assigned-defenses.php?group=RG-2026-001', 0, '2026-08-23 04:09:43'),
(21, 'preoral-panel-assignment:61:u493', 493, 'panel', 'michelleguevarra@bestlink.edu.ph', 15, 61, 'Pre-Oral Panel Assignment', 'You have been assigned as a Panel Member for Group 01\nDEVELOPMENT OF AI ANALYSIS\nDefense Phase: Pre-Oral Defense', '/SMS2_system/modules/faculty/pages/assigned-defenses.php?group=RG-2026-001', 0, '2026-08-23 04:09:43'),
(22, 'preoral-defense-finalized:s30:u491', 491, 'panel', 'jobertvalentino@bestlink.edu.ph', 13, 61, 'Pre-Oral Defense Scheduled', 'RG-2026-001\nDEVELOPMENT OF AI ANALYSIS\nDate/Time: Aug 25, 2026 01:00 PM - 02:00 PM\nVenue: Computer Laboratory 1', '/SMS2_system/modules/faculty/pages/defense-details.php?id=30', 0, '2026-08-23 04:10:47'),
(23, 'preoral-defense-finalized:s30:u492', 492, 'panel', 'jonathanestrada@bestlink.edu.ph', 14, 61, 'Pre-Oral Defense Scheduled', 'RG-2026-001\nDEVELOPMENT OF AI ANALYSIS\nDate/Time: Aug 25, 2026 01:00 PM - 02:00 PM\nVenue: Computer Laboratory 1', '/SMS2_system/modules/faculty/pages/defense-details.php?id=30', 0, '2026-08-23 04:10:47'),
(24, 'preoral-defense-finalized:s30:u493', 493, 'panel', 'michelleguevarra@bestlink.edu.ph', 15, 61, 'Pre-Oral Defense Scheduled', 'RG-2026-001\nDEVELOPMENT OF AI ANALYSIS\nDate/Time: Aug 25, 2026 01:00 PM - 02:00 PM\nVenue: Computer Laboratory 1', '/SMS2_system/modules/faculty/pages/defense-details.php?id=30', 0, '2026-08-23 04:10:47');

-- --------------------------------------------------------

--
-- Table structure for table `panel_member_availability`
--

CREATE TABLE `panel_member_availability` (
  `id` int(10) UNSIGNED NOT NULL,
  `panel_user_id` int(10) UNSIGNED NOT NULL,
  `availability_status` varchar(40) NOT NULL DEFAULT 'Pending',
  `notes` text DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `panel_member_availability`
--

INSERT INTO `panel_member_availability` (`id`, `panel_user_id`, `availability_status`, `notes`, `updated_at`, `created_at`) VALUES
(6, 491, 'Available', '', '2026-08-23 04:08:58', '2026-08-23 04:08:58'),
(7, 492, 'Available', '', '2026-08-23 04:09:10', '2026-08-23 04:09:10'),
(8, 493, 'Available', '', '2026-08-23 04:09:26', '2026-08-23 04:09:26');

-- --------------------------------------------------------

--
-- Table structure for table `preoral_defense_evaluations`
--

CREATE TABLE `preoral_defense_evaluations` (
  `id` int(10) UNSIGNED NOT NULL,
  `defense_schedule_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `panel_user_id` int(10) UNSIGNED NOT NULL,
  `panel_name` varchar(150) NOT NULL DEFAULT '',
  `content_score` decimal(5,2) NOT NULL,
  `methodology_score` decimal(5,2) NOT NULL,
  `references_score` decimal(5,2) NOT NULL,
  `format_score` decimal(5,2) NOT NULL,
  `remarks` text DEFAULT NULL,
  `result` enum('APPROVED','APPROVED WITH REVISION','FAILED') NOT NULL,
  `overall_score` decimal(5,2) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'Submitted',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `preoral_defense_evaluations`
--

INSERT INTO `preoral_defense_evaluations` (`id`, `defense_schedule_id`, `research_group_id`, `panel_user_id`, `panel_name`, `content_score`, `methodology_score`, `references_score`, `format_score`, `remarks`, `result`, `overall_score`, `status`, `submitted_at`, `created_at`) VALUES
(23, 30, 61, 491, 'Dr. Jobert Valentino', 100.00, 100.00, 100.00, 100.00, '', 'APPROVED', 100.00, 'Submitted', '2026-08-23 04:11:06', '2026-08-23 04:11:06'),
(24, 30, 61, 492, 'Dr. Jonathan Estrada', 100.00, 100.00, 100.00, 99.96, '', 'APPROVED', 99.99, 'Submitted', '2026-08-23 04:11:24', '2026-08-23 04:11:24'),
(25, 30, 61, 493, 'Dr. Michelle Guevarra', 100.00, 100.00, 100.00, 99.96, '', 'APPROVED', 99.99, 'Submitted', '2026-08-23 04:11:45', '2026-08-23 04:11:45');

-- --------------------------------------------------------

--
-- Table structure for table `proposal_documents`
--

CREATE TABLE `proposal_documents` (
  `id` int(10) UNSIGNED NOT NULL,
  `proposal_id` int(10) UNSIGNED NOT NULL,
  `doc_key` varchar(60) NOT NULL COMMENT 'Slot key: manuscript, approval, abstract, etc.',
  `doc_title` varchar(200) NOT NULL,
  `original_name` varchar(300) NOT NULL,
  `stored_name` varchar(300) NOT NULL,
  `file_size` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Bytes',
  `uploaded_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proposal_drafts`
--

CREATE TABLE `proposal_drafts` (
  `id` int(10) UNSIGNED NOT NULL,
  `student_id` varchar(50) NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_db users (optional)',
  `form_type` varchar(30) NOT NULL DEFAULT 'document',
  `revision_ref` varchar(30) NOT NULL DEFAULT '' COMMENT 'Returned proposal ref when draft is for revision',
  `draft_data` longtext NOT NULL COMMENT 'JSON encoded draft form fields except upload files',
  `signature_data` mediumtext DEFAULT NULL COMMENT 'Base64 PNG of representative signature draft',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proposal_members`
--

CREATE TABLE `proposal_members` (
  `id` int(10) UNSIGNED NOT NULL,
  `proposal_id` int(10) UNSIGNED NOT NULL,
  `sort_order` tinyint(3) UNSIGNED NOT NULL DEFAULT 1 COMMENT '1 = lead member',
  `student_id` varchar(50) NOT NULL,
  `student_name` varchar(200) NOT NULL,
  `email` varchar(200) NOT NULL,
  `contact` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proposal_status_logs`
--

CREATE TABLE `proposal_status_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `proposal_id` int(10) UNSIGNED NOT NULL,
  `old_status` varchar(30) DEFAULT NULL,
  `new_status` varchar(30) NOT NULL,
  `changed_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_db users',
  `remarks` text DEFAULT NULL,
  `changed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `publications`
--

CREATE TABLE `publications` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(500) NOT NULL DEFAULT '',
  `authors` text DEFAULT NULL,
  `publication_outlet` varchar(255) NOT NULL DEFAULT '',
  `publication_date` date DEFAULT NULL,
  `doi_link` varchar(500) NOT NULL DEFAULT '',
  `status` enum('Draft','For Publication','Published','Archived') NOT NULL DEFAULT 'Draft',
  `notes` text DEFAULT NULL,
  `created_by_user` int(10) UNSIGNED DEFAULT NULL,
  `created_by_name` varchar(150) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `research_adviser_assignments`
--

CREATE TABLE `research_adviser_assignments` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_number` varchar(30) DEFAULT NULL,
  `group_number` varchar(40) DEFAULT NULL,
  `adviser_name` varchar(150) NOT NULL DEFAULT '',
  `adviser_email` varchar(190) NOT NULL DEFAULT '',
  `adviser_user_id` int(10) UNSIGNED DEFAULT NULL,
  `expertise` varchar(255) NOT NULL DEFAULT '',
  `availability_status` varchar(40) NOT NULL DEFAULT 'Pending',
  `assignment_status` varchar(40) NOT NULL DEFAULT 'Pending',
  `notes` text DEFAULT NULL,
  `assigned_by` int(10) UNSIGNED DEFAULT NULL,
  `assigned_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `notification_sent_at` datetime DEFAULT NULL,
  `notification_sent_by` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_adviser_assignments`
--

INSERT INTO `research_adviser_assignments` (`id`, `research_group_id`, `proposal_id`, `proposal_number`, `group_number`, `adviser_name`, `adviser_email`, `adviser_user_id`, `expertise`, `availability_status`, `assignment_status`, `notes`, `assigned_by`, `assigned_at`, `created_at`, `updated_at`, `notification_sent_at`, `notification_sent_by`) VALUES
(107, 61, NULL, 'TAP-2026-00050', 'RG-2026-001', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', 54, 'Artificial Intelligence / Machine Learning / Data Analytics / Data Analysis', 'Available', 'Assigned', 'Synced from fully approved research record.', 40, '2026-08-23 03:49:24', '2026-08-14 12:45:37', '2026-08-23 04:08:33', '2026-08-23 03:49:24', 40);

-- --------------------------------------------------------

--
-- Table structure for table `research_coordinator_assignments`
--

CREATE TABLE `research_coordinator_assignments` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_id` int(10) UNSIGNED DEFAULT NULL,
  `title_approval_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_number` varchar(30) DEFAULT NULL,
  `group_number` varchar(40) DEFAULT NULL,
  `group_name` varchar(120) NOT NULL DEFAULT '',
  `research_title` varchar(255) NOT NULL DEFAULT '',
  `coordinator_user_id` int(10) UNSIGNED DEFAULT NULL,
  `coordinator_name` varchar(200) NOT NULL DEFAULT '',
  `coordinator_email` varchar(200) NOT NULL DEFAULT '',
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `assigned_by` int(10) UNSIGNED DEFAULT NULL,
  `assigned_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_coordinator_assignments`
--

INSERT INTO `research_coordinator_assignments` (`id`, `research_group_id`, `proposal_id`, `title_approval_id`, `proposal_number`, `group_number`, `group_name`, `research_title`, `coordinator_user_id`, `coordinator_name`, `coordinator_email`, `status`, `assigned_by`, `assigned_at`, `created_at`, `updated_at`) VALUES
(38, 61, NULL, 50, 'TAP-2026-00050', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ANALYSIS', 40, 'Mrs. Kris Guevarra', 'researchcoordinator@bestlink.edu.ph', 'Active', 3, '2026-08-23 03:49:36', '2026-08-23 03:49:36', '2026-08-23 03:49:36');

-- --------------------------------------------------------

--
-- Table structure for table `research_defense_schedules`
--

CREATE TABLE `research_defense_schedules` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_number` varchar(30) DEFAULT NULL,
  `group_number` varchar(40) NOT NULL,
  `research_group` varchar(120) NOT NULL,
  `research_title` varchar(255) NOT NULL,
  `adviser_name` varchar(160) DEFAULT NULL,
  `panel_members` text DEFAULT NULL,
  `panel_chair` varchar(160) DEFAULT NULL,
  `venue` varchar(120) DEFAULT NULL,
  `venue_id` int(10) UNSIGNED DEFAULT NULL,
  `defense_datetime` datetime DEFAULT NULL,
  `defense_end_datetime` datetime DEFAULT NULL,
  `defense_type` varchar(40) NOT NULL DEFAULT 'Pre-Oral',
  `status` varchar(40) NOT NULL DEFAULT 'Ready for Scheduling',
  `recorded_by` int(10) UNSIGNED DEFAULT NULL,
  `finalized_by` int(10) UNSIGNED DEFAULT NULL,
  `finalized_at` datetime DEFAULT NULL,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_defense_schedules`
--

INSERT INTO `research_defense_schedules` (`id`, `research_group_id`, `proposal_id`, `proposal_number`, `group_number`, `research_group`, `research_title`, `adviser_name`, `panel_members`, `panel_chair`, `venue`, `venue_id`, `defense_datetime`, `defense_end_datetime`, `defense_type`, `status`, `recorded_by`, `finalized_by`, `finalized_at`, `recorded_at`, `updated_at`) VALUES
(28, 61, NULL, 'TAP-2026-00050', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ANALYSIS', 'Dr. Roberto M. Santos', 'Dr. Jobert Valentino\nDr. Jonathan Estrada\nDr. Michelle Guevarra', 'Dr. Jobert Valentino', 'Computer Laboratory 1', 5, '2026-08-25 09:00:00', '2026-08-25 10:00:00', 'Pre-Oral', 'Rejected', 116, NULL, NULL, '2026-08-23 04:10:39', '2026-08-23 04:10:47'),
(29, 61, NULL, 'TAP-2026-00050', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ANALYSIS', 'Dr. Roberto M. Santos', 'Dr. Jobert Valentino\nDr. Jonathan Estrada\nDr. Michelle Guevarra', 'Dr. Jobert Valentino', 'Computer Laboratory 1', 5, '2026-08-25 11:00:00', '2026-08-25 12:00:00', 'Pre-Oral', 'Rejected', 116, NULL, NULL, '2026-08-23 04:10:39', '2026-08-23 04:10:47'),
(30, 61, NULL, 'TAP-2026-00050', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ANALYSIS', 'Dr. Roberto M. Santos', 'Dr. Jobert Valentino\nDr. Jonathan Estrada\nDr. Michelle Guevarra', 'Dr. Jobert Valentino', 'Computer Laboratory 1', 5, '2026-08-25 13:00:00', '2026-08-25 14:00:00', 'Pre-Oral', 'Finalized', 116, 116, '2026-08-23 04:10:47', '2026-08-23 04:10:39', '2026-08-23 04:10:47');

-- --------------------------------------------------------

--
-- Table structure for table `research_groups`
--

CREATE TABLE `research_groups` (
  `id` int(10) UNSIGNED NOT NULL,
  `proposal_id` int(10) UNSIGNED DEFAULT NULL,
  `title_approval_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_number` varchar(30) DEFAULT NULL,
  `group_number` varchar(40) NOT NULL,
  `group_name` varchar(40) NOT NULL DEFAULT '',
  `research_title` varchar(255) NOT NULL DEFAULT '',
  `college_dept` varchar(120) NOT NULL DEFAULT '',
  `adviser` varchar(120) NOT NULL DEFAULT '',
  `academic_year` varchar(20) NOT NULL DEFAULT '',
  `leader_name` varchar(120) NOT NULL DEFAULT '',
  `leader_id` varchar(40) NOT NULL DEFAULT '',
  `leader_email` varchar(120) NOT NULL DEFAULT '',
  `leader_contact` varchar(40) NOT NULL DEFAULT '',
  `status` varchar(40) NOT NULL DEFAULT 'Approved',
  `date_assigned` date NOT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_groups`
--

INSERT INTO `research_groups` (`id`, `proposal_id`, `title_approval_id`, `proposal_number`, `group_number`, `group_name`, `research_title`, `college_dept`, `adviser`, `academic_year`, `leader_name`, `leader_id`, `leader_email`, `leader_contact`, `status`, `date_assigned`, `created_by`, `created_at`) VALUES
(61, NULL, 50, 'TAP-2026-00050', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ANALYSIS', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-23', 3, '2026-08-22 19:48:57');

--
-- Triggers `research_groups`
--
DELIMITER $$
CREATE TRIGGER `trg_research_groups_panel_notifications_after_delete` AFTER DELETE ON `research_groups` FOR EACH ROW BEGIN
                DELETE FROM panel_assignment_notifications
                WHERE research_group_id = OLD.id;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_research_groups_preoral_evals_after_delete` AFTER DELETE ON `research_groups` FOR EACH ROW BEGIN
                DELETE FROM preoral_defense_evaluations
                WHERE research_group_id = OLD.id;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_research_groups_preoral_evaluations_after_delete` AFTER DELETE ON `research_groups` FOR EACH ROW BEGIN
                DELETE FROM preoral_defense_evaluations
                WHERE research_group_id = OLD.id;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `research_milestones`
--

CREATE TABLE `research_milestones` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_plan_id` int(10) UNSIGNED NOT NULL,
  `milestone_name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `milestone_order` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `progress_percentage` decimal(5,2) NOT NULL DEFAULT 0.00,
  `weight` decimal(5,2) NOT NULL DEFAULT 1.00 COMMENT 'For weighted progress calculation',
  `status` enum('Not Started','In Progress','Submitted for Review','Revision Requested','Approved','Completed') NOT NULL DEFAULT 'Not Started',
  `start_date` date DEFAULT NULL,
  `target_date` date DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `researcher_notes` text DEFAULT NULL,
  `adviser_remarks` text DEFAULT NULL,
  `panel_remarks` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_milestones`
--

INSERT INTO `research_milestones` (`id`, `research_plan_id`, `milestone_name`, `description`, `milestone_order`, `progress_percentage`, `weight`, `status`, `start_date`, `target_date`, `completed_at`, `researcher_notes`, `adviser_remarks`, `panel_remarks`, `created_at`, `updated_at`) VALUES
(175, 21, 'Chapter 4', 'Results / System Design and Development', 4, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, NULL, '2026-08-23 03:47:51', '2026-08-23 03:47:51'),
(176, 21, 'Chapter 5', 'Summary, Conclusions and Recommendations', 5, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, NULL, '2026-08-23 03:47:51', '2026-08-23 03:47:51'),
(177, 22, 'Chapter 1', 'Introduction and Background', 1, 100.00, 1.00, 'Approved', NULL, NULL, '2026-08-23 04:11:53', NULL, 'Progress approved.', 'Approved by Panel.', '2026-08-23 03:49:51', '2026-08-23 04:11:53'),
(178, 22, 'Chapter 2', 'Review of Related Literature', 2, 100.00, 1.00, 'Approved', NULL, NULL, '2026-08-23 04:11:53', NULL, 'Progress approved.', 'Approved by Panel.', '2026-08-23 03:49:51', '2026-08-23 04:11:53'),
(179, 22, 'Chapter 3', 'Methodology', 3, 100.00, 1.00, 'Approved', NULL, NULL, '2026-08-23 04:11:53', NULL, 'Progress approved.', 'Approved by Panel.', '2026-08-23 03:49:51', '2026-08-23 04:11:53'),
(180, 22, 'Chapter 4', 'Results / System Design and Development', 4, 100.00, 1.00, 'Approved', NULL, NULL, '2026-08-23 04:13:25', NULL, 'asd', NULL, '2026-08-23 03:49:51', '2026-08-23 04:13:25'),
(181, 22, 'Chapter 5', 'Summary, Conclusions and Recommendations', 5, 100.00, 1.00, 'Approved', NULL, NULL, '2026-08-23 04:13:35', NULL, 'Progress approved.', NULL, '2026-08-23 03:49:51', '2026-08-23 04:13:35'),
(182, 22, 'System Development', 'System Implementation', 6, 100.00, 1.00, 'Approved', NULL, NULL, '2026-08-23 04:13:45', NULL, 'Progress approved.', NULL, '2026-08-23 03:49:51', '2026-08-23 04:13:45'),
(183, 22, 'Testing', 'Testing and Quality Assurance', 7, 100.00, 1.00, 'Approved', NULL, NULL, '2026-08-23 04:13:52', NULL, 'Progress approved.', NULL, '2026-08-23 03:49:51', '2026-08-23 04:13:52'),
(184, 22, 'Documentation', 'Final Documentation and Report', 8, 100.00, 1.00, 'Approved', NULL, NULL, '2026-08-23 04:13:59', NULL, 'Progress approved.', NULL, '2026-08-23 03:49:51', '2026-08-23 04:13:59');

-- --------------------------------------------------------

--
-- Table structure for table `research_panel_assignments`
--

CREATE TABLE `research_panel_assignments` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `defense_schedule_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_id` int(10) UNSIGNED DEFAULT NULL,
  `title_approval_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_number` varchar(30) DEFAULT NULL,
  `group_number` varchar(40) NOT NULL DEFAULT '',
  `research_title` varchar(255) NOT NULL DEFAULT '',
  `panel_user_id` int(10) UNSIGNED NOT NULL,
  `panel_name` varchar(150) NOT NULL DEFAULT '',
  `panel_email` varchar(190) NOT NULL DEFAULT '',
  `expertise` varchar(255) NOT NULL DEFAULT '',
  `availability_status` varchar(40) NOT NULL DEFAULT 'Pending',
  `assignment_status` varchar(40) NOT NULL DEFAULT 'Assigned',
  `defense_phase` varchar(60) NOT NULL DEFAULT 'Pre-Oral Defense',
  `assigned_by` int(10) UNSIGNED DEFAULT NULL,
  `assigned_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_panel_assignments`
--

INSERT INTO `research_panel_assignments` (`id`, `research_group_id`, `defense_schedule_id`, `proposal_id`, `title_approval_id`, `proposal_number`, `group_number`, `research_title`, `panel_user_id`, `panel_name`, `panel_email`, `expertise`, `availability_status`, `assignment_status`, `defense_phase`, `assigned_by`, `assigned_at`, `created_at`, `updated_at`) VALUES
(1, 52, NULL, NULL, 35, 'TAP-2026-00035', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED OPEN AI GPT 5,5', 491, 'Dr. Jobert Valentino', 'jobertvalentino@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 116, '2026-08-15 18:28:32', '2026-08-15 18:28:32', '2026-08-15 18:28:32'),
(2, 52, NULL, NULL, 35, 'TAP-2026-00035', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED OPEN AI GPT 5,5', 492, 'Dr. Jonathan Estrada', 'jonathanestrada@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 116, '2026-08-15 18:28:32', '2026-08-15 18:28:32', '2026-08-15 18:28:32'),
(3, 52, NULL, NULL, 35, 'TAP-2026-00035', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED OPEN AI GPT 5,5', 493, 'Dr. Michelle Guevarra', 'michelleguevarra@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 116, '2026-08-15 18:28:32', '2026-08-15 18:28:32', '2026-08-15 18:28:32'),
(4, 53, NULL, NULL, 37, 'TAP-2026-00037', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED DOCUMENT ANALYSIS', 491, 'Dr. Jobert Valentino', 'jobertvalentino@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-15 22:51:51', '2026-08-15 22:51:51', '2026-08-15 22:51:51'),
(5, 53, NULL, NULL, 37, 'TAP-2026-00037', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED DOCUMENT ANALYSIS', 492, 'Dr. Jonathan Estrada', 'jonathanestrada@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-15 22:51:51', '2026-08-15 22:51:51', '2026-08-15 22:51:51'),
(6, 53, NULL, NULL, 37, 'TAP-2026-00037', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED DOCUMENT ANALYSIS', 493, 'Dr. Michelle Guevarra', 'michelleguevarra@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-15 22:51:51', '2026-08-15 22:51:51', '2026-08-15 22:51:51'),
(7, 54, 23, NULL, 43, 'TAP-2026-00043', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED DOCUMENT ANALYSIS', 491, 'Dr. Jobert Valentino', 'jobertvalentino@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-16 15:02:09', '2026-08-16 15:02:09', '2026-08-16 15:15:51'),
(8, 54, 23, NULL, 43, 'TAP-2026-00043', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED DOCUMENT ANALYSIS', 492, 'Dr. Jonathan Estrada', 'jonathanestrada@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-16 15:02:09', '2026-08-16 15:02:09', '2026-08-16 15:15:51'),
(9, 54, 23, NULL, 43, 'TAP-2026-00043', 'RG-2026-001', 'DEVELOPMENT OF AI ASSISTED DOCUMENT ANALYSIS', 493, 'Dr. Michelle Guevarra', 'michelleguevarra@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-16 15:02:09', '2026-08-16 15:02:09', '2026-08-16 15:15:51'),
(10, 57, 26, NULL, 46, 'TAP-2026-00046', 'RG-2026-001', 'DEVELOPMENT OF AI ANALYSIS', 491, 'Dr. Jobert Valentino', 'jobertvalentino@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-16 21:44:21', '2026-08-16 21:44:21', '2026-08-16 21:46:14'),
(11, 57, 26, NULL, 46, 'TAP-2026-00046', 'RG-2026-001', 'DEVELOPMENT OF AI ANALYSIS', 492, 'Dr. Jonathan Estrada', 'jonathanestrada@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-16 21:44:21', '2026-08-16 21:44:21', '2026-08-16 21:46:14'),
(12, 57, 26, NULL, 46, 'TAP-2026-00046', 'RG-2026-001', 'DEVELOPMENT OF AI ANALYSIS', 493, 'Dr. Michelle Guevarra', 'michelleguevarra@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-16 21:44:21', '2026-08-16 21:44:21', '2026-08-16 21:46:14'),
(13, 61, 30, NULL, 50, 'TAP-2026-00050', 'RG-2026-001', 'DEVELOPMENT OF AI ANALYSIS', 491, 'Dr. Jobert Valentino', 'jobertvalentino@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-23 04:09:43', '2026-08-23 04:09:43', '2026-08-23 04:10:47'),
(14, 61, 30, NULL, 50, 'TAP-2026-00050', 'RG-2026-001', 'DEVELOPMENT OF AI ANALYSIS', 492, 'Dr. Jonathan Estrada', 'jonathanestrada@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-23 04:09:43', '2026-08-23 04:09:43', '2026-08-23 04:10:47'),
(15, 61, 30, NULL, 50, 'TAP-2026-00050', 'RG-2026-001', 'DEVELOPMENT OF AI ANALYSIS', 493, 'Dr. Michelle Guevarra', 'michelleguevarra@bestlink.edu.ph', '', 'Available', 'Assigned', 'Pre-Oral Defense', 40, '2026-08-23 04:09:43', '2026-08-23 04:09:43', '2026-08-23 04:10:47');

-- --------------------------------------------------------

--
-- Table structure for table `research_plans`
--

CREATE TABLE `research_plans` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to research_groups; nullable to preserve history if group is removed',
  `research_title` varchar(500) NOT NULL DEFAULT '',
  `group_number` varchar(40) NOT NULL DEFAULT '',
  `adviser_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_db users (adviser)',
  `adviser_name` varchar(150) NOT NULL DEFAULT '',
  `adviser_email` varchar(190) NOT NULL DEFAULT '',
  `start_date` date DEFAULT NULL,
  `target_completion_date` date DEFAULT NULL,
  `current_stage` varchar(100) NOT NULL DEFAULT 'Planning',
  `overall_progress` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Auto-calculated from milestones',
  `status` enum('Active','Completed','On Hold','Cancelled') NOT NULL DEFAULT 'Active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_plans`
--

INSERT INTO `research_plans` (`id`, `research_group_id`, `research_title`, `group_number`, `adviser_id`, `adviser_name`, `adviser_email`, `start_date`, `target_completion_date`, `current_stage`, `overall_progress`, `status`, `created_at`, `updated_at`) VALUES
(21, NULL, 'DEVELOPMENT OF AI ASSISTED', 'RG-2026-001', 54, 'Dr. Roberto M. Santos', '', '2026-08-23', NULL, 'Planning', 0.00, 'Active', '2026-08-23 03:16:21', '2026-08-23 03:46:14'),
(22, 61, 'DEVELOPMENT OF AI ANALYSIS', 'RG-2026-001', 54, 'Dr. Roberto M. Santos', '', '2026-08-23', NULL, 'Pre-Oral Defense', 100.00, 'Active', '2026-08-23 03:49:51', '2026-08-23 04:21:54');

-- --------------------------------------------------------

--
-- Table structure for table `research_progress_activity_logs`
--

CREATE TABLE `research_progress_activity_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_plan_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_db users',
  `user_name` varchar(150) NOT NULL DEFAULT '',
  `user_role` varchar(40) NOT NULL DEFAULT '',
  `action` varchar(100) NOT NULL COMMENT 'milestone_created, progress_updated, feedback_added, etc',
  `entity_type` varchar(50) NOT NULL DEFAULT '' COMMENT 'milestone, progress_update, feedback, etc',
  `entity_id` int(10) UNSIGNED DEFAULT NULL,
  `old_value` text DEFAULT NULL COMMENT 'JSON or text of previous state',
  `new_value` text DEFAULT NULL COMMENT 'JSON or text of new state',
  `description` varchar(500) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_progress_activity_logs`
--

INSERT INTO `research_progress_activity_logs` (`id`, `research_plan_id`, `user_id`, `user_name`, `user_role`, `action`, `entity_type`, `entity_id`, `old_value`, `new_value`, `description`, `created_at`) VALUES
(79, 21, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 43, NULL, NULL, 'Progress updated to 0%', '2026-08-23 03:16:35'),
(90, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 53, NULL, NULL, 'Progress updated to 0%', '2026-08-23 03:49:58'),
(91, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 54, NULL, NULL, 'Progress updated to 0%', '2026-08-23 03:50:08'),
(92, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 55, NULL, NULL, 'Progress updated to 0%', '2026-08-23 03:50:18'),
(93, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'progress_approved', 'feedback', 36, NULL, NULL, 'Adviser approved progress', '2026-08-23 03:50:29'),
(94, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'progress_approved', 'feedback', 37, NULL, NULL, 'Adviser approved progress', '2026-08-23 03:50:36'),
(95, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'progress_approved', 'feedback', 38, NULL, NULL, 'Adviser approved progress', '2026-08-23 03:50:45'),
(96, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 56, NULL, NULL, 'Progress updated to 0%', '2026-08-23 04:12:04'),
(97, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 57, NULL, NULL, 'Progress updated to 0%', '2026-08-23 04:12:11'),
(98, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 58, NULL, NULL, 'Progress updated to 0%', '2026-08-23 04:12:18'),
(99, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 59, NULL, NULL, 'Progress updated to 0%', '2026-08-23 04:12:25'),
(100, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 60, NULL, NULL, 'Progress updated to 0%', '2026-08-23 04:12:31'),
(101, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'revision_requested', 'feedback', 39, NULL, NULL, 'Adviser requested revision', '2026-08-23 04:13:01'),
(102, 22, 9, 'Student User', 'student', 'progress_updated', 'progress_update', 61, NULL, NULL, 'Progress updated to 0%', '2026-08-23 04:13:16'),
(103, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'progress_approved', 'feedback', 40, NULL, NULL, 'Adviser approved progress', '2026-08-23 04:13:25'),
(104, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'progress_approved', 'feedback', 41, NULL, NULL, 'Adviser approved progress', '2026-08-23 04:13:35'),
(105, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'progress_approved', 'feedback', 42, NULL, NULL, 'Adviser approved progress', '2026-08-23 04:13:45'),
(106, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'progress_approved', 'feedback', 43, NULL, NULL, 'Adviser approved progress', '2026-08-23 04:13:52'),
(107, 22, 54, 'Dr. Roberto M. Santos', 'adviser', 'progress_approved', 'feedback', 44, NULL, NULL, 'Adviser approved progress', '2026-08-23 04:13:59');

-- --------------------------------------------------------

--
-- Table structure for table `research_progress_attachments`
--

CREATE TABLE `research_progress_attachments` (
  `id` int(10) UNSIGNED NOT NULL,
  `progress_update_id` int(10) UNSIGNED NOT NULL,
  `file_name` varchar(300) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_type` varchar(100) NOT NULL DEFAULT '',
  `file_size` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Bytes',
  `uploaded_by` int(10) UNSIGNED NOT NULL COMMENT 'FK to sms2_db users',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_progress_attachments`
--

INSERT INTO `research_progress_attachments` (`id`, `progress_update_id`, `file_name`, `file_path`, `file_type`, `file_size`, `uploaded_by`, `created_at`) VALUES
(34, 43, 'CRAD_Chapter_1_TO_4_KULANG-PA.docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g60/u9/09a62b2daa1cce84684a82782b95b7df.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 7734354, 9, '2026-08-23 03:16:35'),
(41, 53, 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/df3f82b96645757c73e791012ab36dc4.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 236268, 9, '2026-08-23 03:49:58'),
(42, 54, 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/c17c49e54baa55cad91e60bd58bcad92.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 236268, 9, '2026-08-23 03:50:08'),
(43, 55, 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/7e5a55afefbeda325fee95b26668600b.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 236268, 9, '2026-08-23 03:50:18'),
(44, 56, 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/af25964fcccc0a65b09c503100ab6bd6.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 236268, 9, '2026-08-23 04:12:04'),
(45, 57, 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/b0b3bb6b5becdf66dd97395b68d85f8d.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 236268, 9, '2026-08-23 04:12:11'),
(46, 58, 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/ca491b2b5c87fa0313876eeca2cec331.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 236268, 9, '2026-08-23 04:12:18'),
(47, 59, 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/1eb10d997a17fe2c9f5ee73485b77ae8.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 236268, 9, '2026-08-23 04:12:25'),
(48, 61, 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/cff34883d0dec4263b79eddc43fcc992.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 236268, 9, '2026-08-23 04:13:16');

-- --------------------------------------------------------

--
-- Table structure for table `research_progress_feedback`
--

CREATE TABLE `research_progress_feedback` (
  `id` int(10) UNSIGNED NOT NULL,
  `progress_update_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Can be NULL for general milestone feedback',
  `milestone_id` int(10) UNSIGNED DEFAULT NULL,
  `research_plan_id` int(10) UNSIGNED NOT NULL,
  `adviser_user_id` int(10) UNSIGNED NOT NULL,
  `adviser_name` varchar(200) NOT NULL DEFAULT '',
  `feedback_text` text NOT NULL,
  `new_milestone_status` varchar(60) DEFAULT NULL,
  `submission_token` varchar(64) DEFAULT NULL,
  `feedback_type` enum('Comment','Revision Request','Approval','Progress Approved') NOT NULL DEFAULT 'Comment',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_progress_feedback`
--

INSERT INTO `research_progress_feedback` (`id`, `progress_update_id`, `milestone_id`, `research_plan_id`, `adviser_user_id`, `adviser_name`, `feedback_text`, `new_milestone_status`, `submission_token`, `feedback_type`, `created_at`, `updated_at`) VALUES
(36, 53, 177, 22, 54, 'Dr. Roberto M. Santos', 'Progress approved.', 'Approved', 'cbab7e8bb4297eed5707494db5aca072', 'Progress Approved', '2026-08-23 03:50:29', '2026-08-23 03:50:29'),
(37, 54, 178, 22, 54, 'Dr. Roberto M. Santos', 'Progress approved.', 'Approved', '3db8eccb296ff187522dda8d89406e2e', 'Progress Approved', '2026-08-23 03:50:36', '2026-08-23 03:50:36'),
(38, 55, 179, 22, 54, 'Dr. Roberto M. Santos', 'Progress approved.', 'Approved', '2e9d9355eb6a72370d738e70531d8dbb', 'Progress Approved', '2026-08-23 03:50:45', '2026-08-23 03:50:45'),
(39, 60, 184, 22, 54, 'Dr. Roberto M. Santos', 'asda', 'Revision Requested', '808fb99c2fe3d46ec2c8c159f7c1371a', 'Revision Request', '2026-08-23 04:13:01', '2026-08-23 04:13:01'),
(40, 56, 180, 22, 54, 'Dr. Roberto M. Santos', 'asd', 'Approved', '437099e8103a1903c1f3a709f28ca760', 'Progress Approved', '2026-08-23 04:13:25', '2026-08-23 04:13:25'),
(41, 57, 181, 22, 54, 'Dr. Roberto M. Santos', 'Progress approved.', 'Approved', 'f684e5013bac8056cca3863e47bd7352', 'Progress Approved', '2026-08-23 04:13:35', '2026-08-23 04:13:35'),
(42, 58, 182, 22, 54, 'Dr. Roberto M. Santos', 'Progress approved.', 'Approved', '34a0fbac64e4286ca1562c9deabf4496', 'Progress Approved', '2026-08-23 04:13:45', '2026-08-23 04:13:45'),
(43, 59, 183, 22, 54, 'Dr. Roberto M. Santos', 'Progress approved.', 'Approved', '0199228cd673e9e3bd6a8a294f550e22', 'Progress Approved', '2026-08-23 04:13:52', '2026-08-23 04:13:52'),
(44, 61, 184, 22, 54, 'Dr. Roberto M. Santos', 'Progress approved.', 'Approved', 'fe26a976de6911f07e8c7128c3898650', 'Progress Approved', '2026-08-23 04:13:59', '2026-08-23 04:13:59');

-- --------------------------------------------------------

--
-- Table structure for table `research_progress_notifications`
--

CREATE TABLE `research_progress_notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `recipient_user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_db.users.id (NULL = role-based)',
  `recipient_email` varchar(200) NOT NULL DEFAULT '',
  `recipient_role` varchar(40) NOT NULL DEFAULT '',
  `batch_key` varchar(100) NOT NULL DEFAULT '' COMMENT 'Unique key per event for deduplication',
  `notification_type` varchar(60) NOT NULL DEFAULT 'progress_update',
  `title` varchar(255) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `related_entity_type` varchar(60) NOT NULL DEFAULT '',
  `related_entity_id` int(10) UNSIGNED DEFAULT NULL,
  `action_url` varchar(500) DEFAULT NULL,
  `status` enum('unread','read') NOT NULL DEFAULT 'unread',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `read_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_progress_notifications`
--

INSERT INTO `research_progress_notifications` (`id`, `recipient_user_id`, `recipient_email`, `recipient_role`, `batch_key`, `notification_type`, `title`, `body`, `related_entity_type`, `related_entity_id`, `action_url`, `status`, `created_at`, `read_at`) VALUES
(50, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:53', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for Chapter 1', 'progress_update', 53, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 03:49:58', NULL),
(51, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:54', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for Chapter 2', 'progress_update', 54, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 03:50:08', NULL),
(52, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:55', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for Chapter 3', 'progress_update', 55, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 03:50:18', NULL),
(53, 9, '', 'student', 'approval:36', 'progress_approved', 'Progress Approved', 'Your adviser approved your progress update', 'feedback', 36, NULL, 'unread', '2026-08-23 03:50:29', NULL),
(54, 9, '', 'student', 'approval:37', 'progress_approved', 'Progress Approved', 'Your adviser approved your progress update', 'feedback', 37, NULL, 'unread', '2026-08-23 03:50:36', NULL),
(55, 9, '', 'student', 'approval:38', 'progress_approved', 'Progress Approved', 'Your adviser approved your progress update', 'feedback', 38, NULL, 'unread', '2026-08-23 03:50:45', NULL),
(56, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:56', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for Chapter 4', 'progress_update', 56, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 04:12:04', NULL),
(57, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:57', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for Chapter 5', 'progress_update', 57, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 04:12:11', NULL),
(58, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:58', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for System Development', 'progress_update', 58, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 04:12:18', NULL),
(59, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:59', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for Testing', 'progress_update', 59, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 04:12:25', NULL),
(60, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:60', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for Documentation', 'progress_update', 60, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 04:12:31', NULL),
(61, 9, '', 'student', 'revision:39', 'revision_requested', 'Revision Requested', 'Your adviser requested revisions on your progress update', 'feedback', 39, NULL, 'unread', '2026-08-23 04:13:01', NULL),
(62, 54, 'rsantos@bestlink.edu.ph', 'adviser', 'progress_update:61', 'progress_update', 'New Progress Update', 'RG-2026-001 submitted a progress update for Documentation', 'progress_update', 61, '/SMS2_system/modules/crad/modules/faculty/pages/research-progress.php?group=RG-2026-001', 'unread', '2026-08-23 04:13:16', NULL),
(63, 9, '', 'student', 'approval:40', 'progress_approved', 'Progress Approved', 'Your adviser approved your progress update', 'feedback', 40, NULL, 'unread', '2026-08-23 04:13:25', NULL),
(64, 9, '', 'student', 'approval:41', 'progress_approved', 'Progress Approved', 'Your adviser approved your progress update', 'feedback', 41, NULL, 'unread', '2026-08-23 04:13:35', NULL),
(65, 9, '', 'student', 'approval:42', 'progress_approved', 'Progress Approved', 'Your adviser approved your progress update', 'feedback', 42, NULL, 'unread', '2026-08-23 04:13:45', NULL),
(66, 9, '', 'student', 'approval:43', 'progress_approved', 'Progress Approved', 'Your adviser approved your progress update', 'feedback', 43, NULL, 'unread', '2026-08-23 04:13:52', NULL),
(67, 9, '', 'student', 'approval:44', 'progress_approved', 'Progress Approved', 'Your adviser approved your progress update', 'feedback', 44, NULL, 'unread', '2026-08-23 04:13:59', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `research_progress_updates`
--

CREATE TABLE `research_progress_updates` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_plan_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `milestone_id` int(10) UNSIGNED DEFAULT NULL,
  `submitted_by_user_id` int(10) UNSIGNED NOT NULL,
  `submitted_by_name` varchar(200) NOT NULL DEFAULT '',
  `update_title` varchar(300) NOT NULL,
  `accomplishments` text DEFAULT NULL,
  `problems_blockers` text DEFAULT NULL,
  `next_planned_activity` text DEFAULT NULL,
  `attachment_path` varchar(500) DEFAULT NULL,
  `attachment_original_name` varchar(300) DEFAULT NULL,
  `submission_token` varchar(64) DEFAULT NULL,
  `previous_progress` decimal(5,2) DEFAULT NULL,
  `new_progress` decimal(5,2) NOT NULL,
  `milestone_status` varchar(60) NOT NULL DEFAULT 'In Progress',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_progress_updates`
--

INSERT INTO `research_progress_updates` (`id`, `research_plan_id`, `research_group_id`, `milestone_id`, `submitted_by_user_id`, `submitted_by_name`, `update_title`, `accomplishments`, `problems_blockers`, `next_planned_activity`, `attachment_path`, `attachment_original_name`, `submission_token`, `previous_progress`, `new_progress`, `milestone_status`, `submitted_at`, `updated_at`) VALUES
(43, 21, 60, NULL, 9, 'Student User', 'DEVELOPMENT OF AI ASSISTED', 'sadas', '', 'asdas', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g60/u9/09a62b2daa1cce84684a82782b95b7df.docx', 'CRAD_Chapter_1_TO_4_KULANG-PA.docx', '8f3692e45ee0853f66293b2ec969314d', 0.00, 0.00, 'Submitted for Review', '2026-08-23 03:16:35', '2026-08-23 03:16:35'),
(53, 22, 61, 177, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'SADAS', '', 'ASDA', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/df3f82b96645757c73e791012ab36dc4.docx', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'e90bcc3cc197bb965809cb9c2e0e3080', 0.00, 0.00, 'Approved', '2026-08-23 03:49:58', '2026-08-23 03:50:29'),
(54, 22, 61, 178, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'ADSAD', '', 'ASDAS', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/c17c49e54baa55cad91e60bd58bcad92.docx', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', '7972c30afb20aa7a048bbb0f1d2c3da3', 0.00, 0.00, 'Approved', '2026-08-23 03:50:08', '2026-08-23 03:50:36'),
(55, 22, 61, 179, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'ASDAS', '', 'ADAS', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/7e5a55afefbeda325fee95b26668600b.docx', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', '9b1e3f2664b72052437162d568588703', 0.00, 0.00, 'Approved', '2026-08-23 03:50:18', '2026-08-23 03:50:45'),
(56, 22, 61, 180, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'asdas', '', 'asdas', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/af25964fcccc0a65b09c503100ab6bd6.docx', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', '3bf4afb87e3dbede7e93604e623034ba', 0.00, 0.00, 'Approved', '2026-08-23 04:12:04', '2026-08-23 04:13:25'),
(57, 22, 61, 181, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'asdas', '', 'asdas', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/b0b3bb6b5becdf66dd97395b68d85f8d.docx', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', '5ccb88ca9b4db2be2a773b0c0d9feea0', 0.00, 0.00, 'Approved', '2026-08-23 04:12:11', '2026-08-23 04:13:35'),
(58, 22, 61, 182, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'adasd', '', 'asdas', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/ca491b2b5c87fa0313876eeca2cec331.docx', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', '4c8b62f4160a5c17900fb95039e90ee1', 0.00, 0.00, 'Approved', '2026-08-23 04:12:18', '2026-08-23 04:13:45'),
(59, 22, 61, 183, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'asdas', '', 'das', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/1eb10d997a17fe2c9f5ee73485b77ae8.docx', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', '2ee796709264f5ab003420cd374a5e94', 0.00, 0.00, 'Approved', '2026-08-23 04:12:25', '2026-08-23 04:13:52'),
(60, 22, 61, 184, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'asdas', '', 'das', NULL, NULL, '95b713da492cb4c94648d63edaf98090', 0.00, 0.00, 'Revision Requested', '2026-08-23 04:12:31', '2026-08-23 04:13:01'),
(61, 22, 61, 184, 9, 'Student User', 'DEVELOPMENT OF AI ANALYSIS', 'asdasd', '', 'asdas', 'F:\\xampp\\htdocs\\SMS2_system/storage/uploads/research_progress/g61/u9/cff34883d0dec4263b79eddc43fcc992.docx', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'ed9f89cc33102105cda0fd24e9757687', 0.00, 0.00, 'Approved', '2026-08-23 04:13:16', '2026-08-23 04:13:59');

-- --------------------------------------------------------

--
-- Table structure for table `research_proposals`
--

CREATE TABLE `research_proposals` (
  `id` int(10) UNSIGNED NOT NULL,
  `ref_code` varchar(30) NOT NULL COMMENT 'Auto-generated reference e.g. CRD-2026-00001',
  `proposal_number` varchar(30) DEFAULT NULL COMMENT 'Official number generated after approved proposal registration',
  `research_title` varchar(500) NOT NULL,
  `program_course` varchar(200) NOT NULL,
  `year_section` varchar(100) NOT NULL,
  `college_department` varchar(200) NOT NULL,
  `research_adviser` varchar(200) NOT NULL,
  `academic_year` varchar(20) NOT NULL,
  `rep_name` varchar(200) NOT NULL,
  `rep_id` varchar(50) NOT NULL,
  `rep_email` varchar(200) NOT NULL,
  `rep_contact` varchar(20) NOT NULL,
  `status` enum('Submitted','In Progress','Panel Assigned','Approved','Returned') NOT NULL DEFAULT 'Submitted',
  `progress` tinyint(3) UNSIGNED NOT NULL DEFAULT 10 COMMENT 'Progress % shown in tracking',
  `date_submitted` date NOT NULL,
  `approved_at` datetime DEFAULT NULL COMMENT 'Date/time when tracking proposal was approved',
  `registered_at` datetime DEFAULT NULL COMMENT 'Date/time when approved proposal received official proposal number',
  `registration_status` enum('Pending','Registered') NOT NULL DEFAULT 'Pending',
  `signature_data` mediumtext DEFAULT NULL COMMENT 'Base64 PNG of representative signature',
  `submitted_by_user` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_db users (optional)',
  `notes` text DEFAULT NULL COMMENT 'CRAD officer notes',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `research_revision_cycles`
--

CREATE TABLE `research_revision_cycles` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `defense_schedule_id` int(10) UNSIGNED NOT NULL,
  `official_result` varchar(60) NOT NULL DEFAULT 'APPROVED WITH REVISION',
  `revision_status` varchar(60) NOT NULL DEFAULT 'Needs Revision',
  `opened_at` datetime NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `original_name` varchar(255) NOT NULL DEFAULT '',
  `stored_subdir` varchar(180) NOT NULL DEFAULT '',
  `stored_name` varchar(120) NOT NULL DEFAULT '',
  `file_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `file_mime` varchar(120) NOT NULL DEFAULT '',
  `submission_token` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `research_venues`
--

CREATE TABLE `research_venues` (
  `id` int(10) UNSIGNED NOT NULL,
  `venue_name` varchar(160) NOT NULL,
  `capacity` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `venue_type` varchar(80) NOT NULL DEFAULT '',
  `status` varchar(40) NOT NULL DEFAULT 'Available',
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_venues`
--

INSERT INTO `research_venues` (`id`, `venue_name`, `capacity`, `venue_type`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'CRAD Conference Room', 30, 'Conference Room', 'Available', NULL, '2026-08-10 13:50:31', '2026-08-10 13:50:31'),
(2, 'Research Room 1', 25, 'Research Room', 'Available', NULL, '2026-08-10 13:50:31', '2026-08-10 13:50:31'),
(3, 'Research Room 2', 25, 'Research Room', 'Available', NULL, '2026-08-10 13:50:31', '2026-08-10 13:50:31'),
(4, 'AVR Room', 100, 'Auditorium', 'Available', NULL, '2026-08-10 13:50:31', '2026-08-10 14:20:53'),
(5, 'Computer Laboratory 1', 40, 'Laboratory', 'Available', NULL, '2026-08-10 13:50:31', '2026-08-10 13:50:31');

-- --------------------------------------------------------

--
-- Table structure for table `title_approvals`
--

CREATE TABLE `title_approvals` (
  `id` int(10) UNSIGNED NOT NULL,
  `student_id` varchar(50) NOT NULL DEFAULT '',
  `student_user_id` int(10) UNSIGNED DEFAULT NULL,
  `student_name` varchar(200) NOT NULL DEFAULT '',
  `submission_date` date NOT NULL,
  `department` varchar(200) NOT NULL DEFAULT '',
  `proposed_title` varchar(500) NOT NULL DEFAULT '',
  `discipline_cluster` varchar(200) NOT NULL DEFAULT '',
  `primary_sdg` varchar(120) NOT NULL DEFAULT '',
  `research_agenda` varchar(300) NOT NULL DEFAULT '',
  `sdg_justification` text NOT NULL,
  `members_json` longtext NOT NULL,
  `adviser_name` varchar(200) NOT NULL DEFAULT '',
  `adviser_email` varchar(200) NOT NULL DEFAULT '',
  `coordinator_name` varchar(200) NOT NULL DEFAULT '',
  `proposal_number` varchar(30) DEFAULT NULL,
  `status` enum('Pending','Reviewed','Approved','Returned') NOT NULL DEFAULT 'Pending',
  `adviser_remarks` text DEFAULT NULL,
  `adviser_signature_data` mediumtext DEFAULT NULL,
  `coordinator_status` varchar(30) NOT NULL DEFAULT 'Not Ready',
  `coordinator_remarks` text DEFAULT NULL,
  `coordinator_screening_json` text DEFAULT NULL,
  `coordinator_signature_data` mediumtext DEFAULT NULL,
  `coordinator_reviewed_at` datetime DEFAULT NULL,
  `crad_status` varchar(30) NOT NULL DEFAULT 'Not Ready',
  `crad_signature_data` mediumtext DEFAULT NULL,
  `crad_reviewed_at` datetime DEFAULT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `title_approvals`
--

INSERT INTO `title_approvals` (`id`, `student_id`, `student_user_id`, `student_name`, `submission_date`, `department`, `proposed_title`, `discipline_cluster`, `primary_sdg`, `research_agenda`, `sdg_justification`, `members_json`, `adviser_name`, `adviser_email`, `coordinator_name`, `proposal_number`, `status`, `adviser_remarks`, `adviser_signature_data`, `coordinator_status`, `coordinator_remarks`, `coordinator_screening_json`, `coordinator_signature_data`, `coordinator_reviewed_at`, `crad_status`, `crad_signature_data`, `crad_reviewed_at`, `sent_at`, `reviewed_at`, `created_at`, `updated_at`) VALUES
(50, 'S230000001', 9, 'Student User', '2026-08-23', 'College of Computer Studies', 'DEVELOPMENT OF AI ANALYSIS', 'Engineering, Information Technology, and Computing', 'SDG 9 — Industry, Innovation and Infrastructure', 'Science, Technology, Digital Transformation, and Innovation', 'ASDASDASDAS', '[[\"User, Student A.\",\"BSIT 4101\",\"OR-2611315\"],[\"User, Student B.\",\"BSIT 4101\",\"OR-2685473\"]]', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', 'Mrs. Kris Guevarra', 'TAP-2026-00050', 'Approved', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAABkCAYAAACoy2Z3AAAQAElEQVR4AeydC5xN5frHfzPVdOGcQphySnEIKfIpurnlXkk3UQ6ni8io5E8hCnFIQmRQuctfujlU7nfJEGPc6egiEoaM5NL/lPmvtfbMtmd71+x1ed+13netZ3+svdd69/s+l+/zvO+z11p7m+TckD/OkP+hJhD2+MsZfIqKnHE516pkhPyRRP6HmkDY4y9n8CkqcsblXKvsFZBcQPt3rhRqCQgBiq6ngSRlLghQrrqAx22ovQKifTDQ/nFTToJkI0DRlS0iZI8ZAcpVMzJettsrIF5aRrqIAIOArJ87ZbWLgZCaiAA3AgoXEG4MLAuiRcIyKmEdZf3cydcuyjRhCUSCuRKQp4AoMGf4LhJc40jCAkVAkUxTYM4GKi0kdEaeAqLCnKEJ4yKF5YInlzUusPo01FCrwpw1DKUnUQTkKSAJPJRiwkcnjBTWJCAm29tReFIYJpc1sUhUzS223ezWWH/z9i13zOtPL1IQUKaAyDXh5bJGikwyMYLWBRMwps2q5hbbbnYrw3nLHRljqckmAX6zUpkCYpOQ2O5u+Yu1TirptC5IFQ4+xlD+8+HomxR+s5IKiJMg8uPvRDuNcU1A3hVQXstioPPOfyWcjvGfdqMEqIBEUdBOeAi4XQHdrnjm491aJnsMmZ5767QNRExrbYwPflcqIMwYU+IwsQSk0X103a54bserGwi1PFfLWs+yImYChaeAxDidGDQlTmJG6vYQHV1bqaYuRheWEyEX8PwfGjOBwlNAYpz2PwLqWqCy5b/+ehwrVmVg/sLlBbay192Oy1KrcNuKabKurXwH+g4YXkBPvF6rx4cOHVYZO8N2mowMKEo2haeAKBkeMrowAoV9jp06/WPUrN0clarVQ6Xq9Y2txm3N8GDrDmjdrnOB7dixY5oafVHjtx09moOR6RMK6InXa/W4Vp37DPsjftRDw7tbY9nKNZrN9E8VAoXlqio+sOykAsKiQm3SEtDPIt6ZMB2vv5mOIdqmv+oLbGrZGris9PXaWURke75bX3zzn+9w4GA2Dhw4iJycY6hb+za82LUjenZPM7ZeL3bGoR+zkHNgm7Bt07oFGPRaT/Tt3RW6vnzdPbtFbIge59nEOi5duiQOHjik+aFv2VifuQWzZs+TNka2DQvq6hoDQv9oEnPocFe+YVRA5IsJWZRH4MTJU4gUgEO4rW4LrUBUwdUVb0WP3oO0AjImuv3yy1FcVuxSpKaWQqq22N57d0NkrJwTUxS248APmZgwbqhWODpHtx7aIp6SckGeNpcvJotg2av/hrQObdH1ufbQ9fXsnqdfK17R/fw2k9eMFbNxNK7IjRr2mkuDvRxuAiffhKCurvn+BfiVCkiAg6uia//97x9o+2QX49KPfqmmct7lpx27dgNJSbhCKxIfTE1H/jZzWjqy1i3Ezqxl2LlJ35bj/YkjUalieZzzSLCOndPfTgMtgoXQUgWOyAQpBI/Cb3EpIIRd4QzwyXT97GLV6nXGTeZOz/fGleVuNi4/lbyqGj6buxiLlqzCn3+cQZNGddGsSX38Z8tK44xih1Yomjauh/ytSaN6KHLJxVa8AFRZx0APfwhQgtjlzi4gNitCWLDbxGI3FqHon6YVC/3GdvWaTfBAq/bGmcaMD/+Nk9rlKuTmoly5stDPJrZnLsHSBTONM40ZU0ajZMkSoeBDThIBlQiwC0hYKoLNSAnFEuDqlJm1FSPeHo+qNRrgf7Viod/XSE5OQvcXIje0p2mXnPbtXoecg9uR+dVc416GfuO4aJFLbEaIuvMiEOB05IVIgBz1qLMLCAMNNQkmILQ6CbadIT5XO5vIzj6C8ZNm4K6mrdD/XyNw6vTvKHNlaejfetq1eUX0ZnZz7aZ30aJFGFK8blJvAosiFLB0FIWJs1z1qPtSQNjTlN0aHyFrveJH0bHXBFo+9gxurNkY3XsNRFJSEtI6tsP6r77AtsylXptiQ596E9iGc9SVCOQR4LeK+lJA2NOU3ZrncfQlvhc/FFEVtOOQwKYt29HkvrYofuUNWLzsS1yYkoIBfbvj6M9bMah/DxS77FKHksM+jJ//0fkS3eEnW0pJUvgphREx4YlfRWPesrib75EvBcSijZa6uUeRQE0+qQTdwvy2XixurdsCTZu3xdp1mThz5oxxI3zDmrl4rtMTUqEJZDhtOBWdL9EdqcLD3xgp/JTCCK5s8z1Kho3k42qBKsLySalir8d27vrmW/QbOAI7d+1Gowa1jV9b6z/aS00thRLFi3lsTWJ1SYm7qNdDWqfCurj457fXmpMhbfJxm8ckSBCBX47m4OE2z2Drtp3G5alHW7Uwfm190UUXCtJIYtUiIOPi4sUS65/fXmtO9iUhvYihL46FS2nHZ3ti7979qHNnLSyeOwPNGtcPFwAu3tJk4ILRshCvl1jLhinZkVFAPEhoiqFpsoiiz1vu4qWrjF+L6zfGmzWuh/Llypr6RG8URiDgk6Ew1+k95QkwCkhAE5r3Cioo9KLo85b7eIduBoEqlSugU4d2xn54nhRJpvAExJqnFDZrnGz0UusmupsE4L2C2oCsQlcnaEuVLIEvZk1RwT3ONtpNJid0OZvsSpwH9nuggu73ukoC5uBkpaBambdeJCITpYhG72RaQeudNcHRFElH1el6YL8HKoKTVbJ4kotkWUzhZgclIjeUJMg9gcCnY6RCugflkwTFzfeJWr7apAAWENDDKwLHfzuBt8dOtq+OZq19ZrKOULxCFma+MOQByv/AnIEEKCbC8panYP23HqdOncbkaR8iY91Ge6J9mbUmJlLimIChZmEEZMp/l04GpoAEKCYuQ+rN8N1bV+H888/Ht9/twYi33zP+9Kw3mjlrocThDJQqMmegDHHyMA5MAWFQpibBBHZsXIqkpCQsWLQCE6fMxB9//nlWI+2FlABVZPGBt8LYmyJDBUR8tAOr4dJL/4LXXu1u+Kdfylq2fLWxT0+yEPBmEZHFW6Xt4B4qK0XGPTEqIO4ZhlZCSkoKmjaqi5uqV8Wh7CNo2aYTRo+bjO/37GUy4T5HmFpkaZTBW28WEVmIK20H31B5hoIKiGeog6Do3EWxwt+vxdxZU9Dp6baGg336DUWdhg/jk9nzjOPYJ0XnSKwLNvbD5a0NMNRVWgLnzu9EpiYn6sDvffvG8dNNkvgQYC+KF198EQYP6IlPZryDmjdXx4kTJ9G+00to0Kw15ny+iI9qT6RQjnqCmZRISiDJtl0uC4idCWffONve0ABfCTSofycWfj4d/fr8D0pdXhwbNm5Bu/Yv4L6Hn0TW5m3GH5ry1cCEyiM5mrCb8A525pVwY0iBLASkSwvXv0SXZcLJEmGyQyfwfNoT2LphMYYMfBn6jfaVX65Fm8efx0svDzLOTvQ+0U34pHCowOGwqF+udmheucInxWABCSRdWiTRL9FBDyEELrjgAnRs30a7PzIV9zZrgGO/Hsf4yTNQpvwtaNaiHRYv/RLfff8jIHxSOFTgcBjoQQQMAsFKILNy6PISlkGq4BMdmRMwi4L5iITvCBCZUKedDtdXqYgJ77yJrIz5uOfuBjjvvPOwZu0GPNLmGdRt3BJNmv8Dq9estyOS+hIB9QmImri85MbJMSuHVEC8TEWzKLiwQYBIF9awh16YkoLLtXsi0yeOwpGfNuONQS/jqcdbIzc3F2u/3oh7Hvgnrq/RAH0HDMOsOfPZQqiVCASJgO2JG7eim7GwLddEkEU5VEBM+HnbbJIcJs3e2sZfW4cn22Do4D7Yt3sd3hszBBUqXAv976uPTJ+IJzp0My5z9Rs4HNmHj+D33/+PvwHBlUieBZaAxRXdY/+pgHgMnK3OJDlMmtky1Gxt+eC9+HrV51jw2fuYOW0MrriilHGj/a3RE1CtZhPj7OTZrq8YBUZND8nqWAIB/UwU62Ko9n0vIE4SyskYWaMaJF/cML6xamU0aVQXOzYuw85Ny/BY6/tR/tqy2LRlO96f8SnKVb4Dl6VejxtuboTBQ9Mxf9EKLF+5BkdzjrlRS2M9JhCCz0QeE/VXne8FxElCORljBbMffYLkCy9+qaVLYcxb/zJ+U7J1wxKMHTUINWpUhXbTBHv37ceQYWPQum0aHnq0I26+/R5Uql4fdRo+hM/mLuZlgqdy6EOEp7hJGQ8CeUnrewHh4QvJCCYB/RfupUtdjkcfaYGlc2ci5+B27Pv2a6Og9O7xnNFerNilyM4+jM1bd6Ltk11Q7IqqKFPuFvxD23/9zXSMGjPR+EGjzIToQ4TM0SHbmATykpYKCJMONeoE8j5k6LvSbEWLXGIUjhe7PoPRIwZg/eovcOSnLcj5eRvatH4AZa8ug4svuQhLln2pnamMxauvDTP+SxW9sFxVoRb69H8TBw4cimwHs7Xik3+jXkZvpcHugSGkQkUCVEBYUaO1xKCS9yHD2Jf+STM2/a2ByFq7APpvTvSb8h9NH4sPpqajzh21kJJyAY4f/w2jx04yLnnpl70qa5e+qtVsjLvvb4fW7Z7Fo+06o91TLxj3WLKzj0jvMl8DKen58gyHNCogrDhrixGrmdo4EhC4XhUtWgT6TfmGd9VG08b1MOeTiTi4ZyNyDmzDtswlGPBqdzxwX1M0bVQPdWrfihMnT2FNxgYsXLIKc75YpJ25jEGFG+oYN+31M5drKt2GFi2fwvhJMzB/4XLjD2itWJWBg4cOcwTityg3SZ/rt/Gk3ycCVEB8As9ZrXrimOuV+IWozJWpeC7tCUx6dxhmTB1tnKEsmfcBMtfMw3atuOzMWgZ96/rc0yh3zdVITk5GTs6v0AtG914DtTOVzmjVNg0Ptu6AW+vcZ5zNRM5kmuCuZq3Q69Uh+EorRuoFxI3FzGC6EUhjCyOQaJoker8w2TbfowJiE5j17h5G0bpRkvf0ZyEqcsnFKFGiGEqXLonU1FLG1rf3C8jMmKfdX9kM/czl+x1f4aPp4zCofw/0evFZ6Pdgnny8FZKRhMNHjmLPj/uQuXErxr471bgkpn/lOHbTz2RKlLkRpcvehIra2U2Vm+7CA62eRs9XBkO/2X92G2OcAQ0b+S7S35mCSVM/1M6MVhhFKUfwV5ZPnTptfMvttxMnQQ+JCSSaJone5+haMlsWLX5sLnZaPYyiHbME9VUuY2warH/bq1GD2kjr2A49unVCz+5peKVnF2zPWorsvVlGkdELTf42ZtQgdHm2PW6rVQOVr/s7rr6qDPRvlBUvXgzJ552HM7m52LFrNz6eNRfp46Zg+KjxeGP4OG0bA/13LgMGj0Tvvm+g60v98UibNKMoXVPpduOyWmxh0vf14lT8yhugb6Wuqo6/lb8FFarWRqVq2iW6hg8ZP8Z8+LGOMNs6d+mDp9N6GF82uPGWxqh5573YmLVVUKYEUGyIXTIpIAotfjYXghDHWqjrCmVMhINggx97pAX69+mKebOnYc2K2di0bgG2b1yKHdq2M+8ymf66MWM+li/8CJ9/Otn4g1wfcDZY5AAABjhJREFUvj/O+EX+B9PSjctr+pcAYrfJ7w3HP9u2xCMPN0edO2uhUsXyRmH661+L4i/avR/9/xc7ffp346xIv0ejf71Zv6S2ZNlqmG0zPpqNT/89Fz9oZ1FtH3tIO9MaiyqVK0Y4CXimKSsAqk8iTQqIT9Y4USt4IXBiEo0hArEE4hfM2GN90S9frixq3lwN9evejoZ33Wn8Il+/wd+0cT3jSwCxr/c3b4KRQ/vh3dGvY87HE5Gxcg52blqOH3auwZ5vMpC9bxMO/7QZR3/eamz6GVH+fvR1f+S9/ONf9m/BEW3b/916jBrWH9dXuQ4XXpgS6wLXfe5TNhZoQkttdU4oLewdOBYQCozUyWQhPBa6CHAx+CLjF8z4Y88JODFA5uSw5Y+tzp6HRjWFHAsIBUbq4FsIj4UuUrtIxlkl4KAaUHJYhRvMfiYpw7GABJMbeUUE/CJgMmc5mEPVgAPEQIiId8I050xSxiggpoPipdMxESACnhEwmbOe6SdF4SNgN+eMAmJ3UPiwksdqEaCPRGrFi6xVlYBRQFQ1Ppx20+KYOO4efSRKbIiHPSgvPITtQFUQ45MLKiAOUsHfIWFcHP0lroZ2ygu548SKj/pFhQqI3FlH1hEBIhBYAqyiUrizcpWcJD/PQGD7IRc82+aHagDFKlThVs5Z9/npXoITaPklh49291KUOgPJh+cEvK0xcVzjDm2JCmRnC0A8i1UgAZNTogm4z08HEizMG6t+O9DOEO1eilIFhEFATFMc17hDMTpVkhpKIKzZz2pTI5CyWSkHScFWBG7e0E10DvOIZ9LxlMXBNRIRQ4A1+1ltMUNCtOs2c+UgybbCrW+ypUG8P/HH1u1NUuseCKR8sJPOmak8ZTmzgEYRAScEgpy5QfMt3p/440j8rZUVuoQVoWXvmXoTgUATsLZ4BBpB6J1jl5V4LFRA4onQsQACtCAJgCpQpLXFQ6ABJFoJAnQPpGCYaJ0ryIPbES1I3FCSICIgDYEkugeC2Aetc7E0aN9rAp5/gPFcoddESZ9gAnQJSzBgOcTTQiFHHBJY4fkHGM8VFg6A0rRwPhK+q1gBCVqGeeXP2YVCwhy0YJJXnCyY4kmXsPmbB1X1NM1zI0wvyhSQyJQKWoYFzR9RUydsnMLmr6i8IbmiCShTQLycUpFiJRo9H/m+2eqbYj7cZJZCaCPRCR6HiF9BelamgHgJ3cti5dYv32z1TbFbYn6Mj18K448L2kRoIzyIQ4SDzM9UQKSMTuELjJQmizKqAIoCB6I0xsjlpS9+KYw/jlFJu0RAVgKM6aBUAWHYLytql3bRAhMFeBaF1lTgQDsW/c9rfaL9ESs/PPNTLEevpCeOV1wPxnRQqoAw7PeKNekhAp4SiJu6tnS7GWtLUVzn0M5Pv4DH8bd7mDheiXvwLSB2QNrpa5dMCPsTzmAFPfHUNffXzVhzqSLeCUjWqgPceRBNRvItICyQZjnC6mtiJDUnJkA4EzNSpofZnFHGAauGypy1oQmC1WAx+/EtICwVMucIy15qIwI6AT/Xj7g546cpOopwbnoQFCDvs4niC4h02eczcel4kEFMAvr6wXzDvNE8s8zHWHnHgSlWxPrURxQlEe4oQN5nE0NYQHwmLiLPSaYUBM5mlo+LpB+qbek8S0mKoJERrgiEsIC44kWDiYAFAj4ukn6oZuq0VVUsMKUuMhJQoYBIw42mhDSh4GOILAGVwQ7uNjCrCp+4OZTC3UWHdgRpmIAC4jZMVsZb6cM/TPJNCf4+2pPoTxzs2VhIbyEBdcBEiB2F+M16SwYbWHZxbPPLRQcZwdFrsaIEFBC3YbIy3kofseDESFct1ezFQTXvnMXYHhNnOqyM4kTbiirqUygBWTKiUCMdvimggDi0hIZpBESmGntBYbdqpgj4J9I7AeYqLpJoFxpALxOfaYjvBjCtstuoTgEJBm/L8eHvLntBYbdaNjPEHflHyDJMH1VbtlH2jr4nvu8GcImQOgVESd7OYxRkd4Ox/vkYIceqg0He+ayikbwJqFNAeHtO8nwj4Hj942AxjyWUhwwOrjgQ4Sd5B+byGsIxYBxF8fLOVzlUQHzFT8q9JsBjCeUhw2u/w6gv6jPHgHEUFTVP5Z3/BwAA//8Ozd6UAAAABklEQVQDAOL09i7m6XIlAAAAAElFTkSuQmCC', 'Approved', NULL, '{\"agenda_alignment\":\"yes\",\"feasible_original\":\"yes\",\"ethical_sdg\":\"yes\"}', 'data:image/png;base64,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', '2026-08-23 03:48:42', 'Approved', 'data:image/png;base64,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', '2026-08-23 03:48:55', '2026-08-23 03:48:21', '2026-08-23 03:48:28', '2026-08-23 03:48:21', '2026-08-23 03:48:57');

--
-- Triggers `title_approvals`
--
DELIMITER $$
CREATE TRIGGER `trg_title_approvals_after_delete` AFTER DELETE ON `title_approvals` FOR EACH ROW BEGIN
            UPDATE research_adviser_assignments a
               SET a.assignment_status = 'Pending'
             WHERE a.assignment_status = 'Assigned'
               AND (
                    (OLD.proposal_number IS NOT NULL
                     AND OLD.proposal_number <> ''
                     AND a.proposal_number = OLD.proposal_number)
                 OR (a.research_group_id IS NOT NULL
                     AND a.research_group_id IN (
                        SELECT g.id
                        FROM research_groups g
                        WHERE g.title_approval_id = OLD.id
                     ))
                 OR (a.group_number IS NOT NULL
                     AND a.group_number <> ''
                     AND a.group_number IN (
                        SELECT g2.group_number
                        FROM research_groups g2
                        WHERE g2.title_approval_id = OLD.id
                     ))
               );
        END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `chapter_evaluations`
--
ALTER TABLE `chapter_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_chapter_evaluation_submission` (`submission_id`),
  ADD KEY `idx_chapter_eval_evaluator` (`evaluator_user_id`),
  ADD KEY `idx_chapter_eval_group` (`research_group_id`),
  ADD KEY `idx_chapter_eval_created` (`created_at`);

--
-- Indexes for table `chapter_evaluation_notifications`
--
ALTER TABLE `chapter_evaluation_notifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_chapter_notification_event` (`event_key`),
  ADD KEY `idx_chapter_notification_recipient` (`recipient_user_id`,`recipient_role`,`recipient_email`),
  ADD KEY `idx_chapter_notification_submission` (`submission_id`),
  ADD KEY `idx_chapter_notification_created` (`created_at`);

--
-- Indexes for table `chapter_submissions`
--
ALTER TABLE `chapter_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_chapter_version` (`research_group_id`,`chapter_number`,`version_number`),
  ADD UNIQUE KEY `uniq_chapter_token` (`submission_token`),
  ADD KEY `idx_chapter_status` (`status`),
  ADD KEY `idx_chapter_group` (`research_group_id`),
  ADD KEY `idx_chapter_student` (`submitted_by_user`),
  ADD KEY `idx_chapter_updated` (`updated_at`);

--
-- Indexes for table `chapter_submission_history`
--
ALTER TABLE `chapter_submission_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_chapter_history_submission` (`submission_id`),
  ADD KEY `idx_chapter_history_group` (`research_group_id`),
  ADD KEY `idx_chapter_history_created` (`created_at`);

--
-- Indexes for table `final_defense_evaluations`
--
ALTER TABLE `final_defense_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_final_panel_submission` (`defense_schedule_id`,`panel_user_id`),
  ADD KEY `idx_final_group` (`research_group_id`),
  ADD KEY `idx_final_panel` (`panel_user_id`),
  ADD KEY `idx_final_status` (`status`);

--
-- Indexes for table `final_defense_recommendations`
--
ALTER TABLE `final_defense_recommendations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_fdr_group` (`research_group_id`),
  ADD KEY `idx_fdr_status` (`status`);

--
-- Indexes for table `final_manuscript_approvals`
--
ALTER TABLE `final_manuscript_approvals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_fma_group` (`research_group_id`);

--
-- Indexes for table `grant_applications`
--
ALTER TABLE `grant_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_ga_token` (`submission_token`),
  ADD KEY `idx_ga_opportunity` (`grant_opportunity_id`),
  ADD KEY `idx_ga_group` (`research_group_id`),
  ADD KEY `idx_ga_status` (`status`),
  ADD KEY `idx_ga_submitted` (`submitted_at`);

--
-- Indexes for table `grant_opportunities`
--
ALTER TABLE `grant_opportunities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_go_status` (`status`),
  ADD KEY `idx_go_deadline` (`application_deadline`),
  ADD KEY `idx_go_created_by` (`created_by_user_id`);

--
-- Indexes for table `manuscript_evaluations`
--
ALTER TABLE `manuscript_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_meval_submission` (`submission_id`),
  ADD KEY `idx_meval_group` (`research_group_id`);

--
-- Indexes for table `manuscript_submissions`
--
ALTER TABLE `manuscript_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_manuscript_version` (`research_group_id`,`version_number`),
  ADD UNIQUE KEY `uniq_manuscript_token` (`submission_token`),
  ADD KEY `idx_manuscript_status` (`status`),
  ADD KEY `idx_manuscript_group` (`research_group_id`);

--
-- Indexes for table `panel_assignment_notifications`
--
ALTER TABLE `panel_assignment_notifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_panel_assignment_notification` (`event_key`),
  ADD KEY `idx_panel_notification_recipient` (`recipient_user_id`,`recipient_role`,`recipient_email`),
  ADD KEY `idx_panel_notification_created` (`created_at`);

--
-- Indexes for table `panel_member_availability`
--
ALTER TABLE `panel_member_availability`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_panel_availability_user` (`panel_user_id`),
  ADD KEY `idx_panel_availability_status` (`availability_status`);

--
-- Indexes for table `preoral_defense_evaluations`
--
ALTER TABLE `preoral_defense_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_preoral_panel_submission` (`defense_schedule_id`,`panel_user_id`),
  ADD KEY `idx_preoral_group` (`research_group_id`),
  ADD KEY `idx_preoral_panel` (`panel_user_id`),
  ADD KEY `idx_preoral_status` (`status`);

--
-- Indexes for table `proposal_documents`
--
ALTER TABLE `proposal_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pd_proposal` (`proposal_id`);

--
-- Indexes for table `proposal_drafts`
--
ALTER TABLE `proposal_drafts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_proposal_draft_student_type` (`student_id`,`form_type`);

--
-- Indexes for table `proposal_members`
--
ALTER TABLE `proposal_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_proposal` (`proposal_id`);

--
-- Indexes for table `proposal_status_logs`
--
ALTER TABLE `proposal_status_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_psl_proposal` (`proposal_id`);

--
-- Indexes for table `publications`
--
ALTER TABLE `publications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pub_group` (`research_group_id`),
  ADD KEY `idx_pub_status` (`status`);

--
-- Indexes for table `research_adviser_assignments`
--
ALTER TABLE `research_adviser_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_raa_adviser_identity` (`adviser_email`,`adviser_name`),
  ADD KEY `idx_raa_group` (`research_group_id`),
  ADD KEY `idx_raa_proposal` (`proposal_id`),
  ADD KEY `idx_raa_group_number` (`group_number`),
  ADD KEY `idx_raa_status` (`assignment_status`),
  ADD KEY `idx_raa_user` (`adviser_user_id`);

--
-- Indexes for table `research_coordinator_assignments`
--
ALTER TABLE `research_coordinator_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rca_group_number` (`group_number`),
  ADD UNIQUE KEY `uniq_rca_group_coordinator` (`research_group_id`,`coordinator_user_id`),
  ADD KEY `idx_rca_group` (`research_group_id`),
  ADD KEY `idx_rca_title_approval` (`title_approval_id`),
  ADD KEY `idx_rca_status` (`status`);

--
-- Indexes for table `research_defense_schedules`
--
ALTER TABLE `research_defense_schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rds_proposal_number` (`proposal_number`),
  ADD KEY `idx_rds_status` (`status`),
  ADD KEY `idx_rds_proposal_id` (`proposal_id`),
  ADD KEY `idx_rds_venue_time` (`venue_id`,`defense_datetime`,`defense_end_datetime`),
  ADD KEY `idx_rds_group_time` (`research_group_id`,`defense_datetime`,`defense_end_datetime`),
  ADD KEY `idx_rds_group_number` (`group_number`);

--
-- Indexes for table `research_groups`
--
ALTER TABLE `research_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `group_number` (`group_number`),
  ADD UNIQUE KEY `proposal_id` (`proposal_id`),
  ADD UNIQUE KEY `title_approval_id` (`title_approval_id`),
  ADD KEY `idx_rg_proposal_number` (`proposal_number`);

--
-- Indexes for table `research_milestones`
--
ALTER TABLE `research_milestones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rm_plan_name` (`research_plan_id`,`milestone_name`),
  ADD KEY `idx_rm_plan` (`research_plan_id`),
  ADD KEY `idx_rm_status` (`status`),
  ADD KEY `idx_rm_sequence` (`research_plan_id`,`milestone_order`);

--
-- Indexes for table `research_panel_assignments`
--
ALTER TABLE `research_panel_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_panel_assignment_phase` (`research_group_id`,`panel_user_id`,`defense_phase`),
  ADD KEY `idx_panel_assignment_group` (`research_group_id`),
  ADD KEY `idx_panel_assignment_user` (`panel_user_id`),
  ADD KEY `idx_panel_assignment_status` (`assignment_status`),
  ADD KEY `idx_panel_assignment_schedule` (`defense_schedule_id`);

--
-- Indexes for table `research_plans`
--
ALTER TABLE `research_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rp_group` (`research_group_id`),
  ADD KEY `idx_rp_group_number` (`group_number`),
  ADD KEY `idx_rp_adviser` (`adviser_id`),
  ADD KEY `idx_rp_status` (`status`);

--
-- Indexes for table `research_progress_activity_logs`
--
ALTER TABLE `research_progress_activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpal_plan` (`research_plan_id`),
  ADD KEY `idx_rpal_user` (`user_id`),
  ADD KEY `idx_rpal_action` (`action`),
  ADD KEY `idx_rpal_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_rpal_created` (`created_at`);

--
-- Indexes for table `research_progress_attachments`
--
ALTER TABLE `research_progress_attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpa_update` (`progress_update_id`),
  ADD KEY `idx_rpa_uploaded` (`uploaded_by`);

--
-- Indexes for table `research_progress_feedback`
--
ALTER TABLE `research_progress_feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpf_update` (`progress_update_id`),
  ADD KEY `idx_rpf_milestone` (`milestone_id`),
  ADD KEY `idx_rpf_plan` (`research_plan_id`),
  ADD KEY `idx_rpf_created` (`created_at`),
  ADD KEY `idx_rpf_adviser` (`adviser_user_id`),
  ADD KEY `idx_rpf_token` (`submission_token`),
  ADD KEY `idx_rpf_update_adviser` (`progress_update_id`,`adviser_user_id`),
  ADD KEY `idx_rpf_plan_type` (`research_plan_id`,`feedback_type`);

--
-- Indexes for table `research_progress_notifications`
--
ALTER TABLE `research_progress_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpn_recipient_user` (`recipient_user_id`),
  ADD KEY `idx_rpn_recipient_email` (`recipient_email`),
  ADD KEY `idx_rpn_recipient_role` (`recipient_role`),
  ADD KEY `idx_rpn_batch_key` (`batch_key`),
  ADD KEY `idx_rpn_status` (`status`),
  ADD KEY `idx_rpn_created` (`created_at`);

--
-- Indexes for table `research_progress_updates`
--
ALTER TABLE `research_progress_updates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpu_plan` (`research_plan_id`),
  ADD KEY `idx_rpu_milestone` (`milestone_id`),
  ADD KEY `idx_rpu_researcher` (`submitted_by_user_id`),
  ADD KEY `idx_rpu_submitted` (`submitted_at`),
  ADD KEY `idx_rpu_group` (`research_group_id`),
  ADD KEY `idx_rpu_token` (`submission_token`),
  ADD KEY `idx_rpu_group_milestone` (`research_group_id`,`milestone_id`),
  ADD KEY `idx_rpu_plan_submitted` (`research_plan_id`,`submitted_at`);

--
-- Indexes for table `research_proposals`
--
ALTER TABLE `research_proposals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ref_code` (`ref_code`),
  ADD UNIQUE KEY `proposal_number` (`proposal_number`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_dept` (`college_department`(50)),
  ADD KEY `idx_submitted` (`date_submitted`);

--
-- Indexes for table `research_revision_cycles`
--
ALTER TABLE `research_revision_cycles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rrc_schedule` (`defense_schedule_id`),
  ADD KEY `idx_rrc_group` (`research_group_id`),
  ADD KEY `idx_rrc_status` (`revision_status`);

--
-- Indexes for table `research_venues`
--
ALTER TABLE `research_venues`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_research_venue_name` (`venue_name`),
  ADD KEY `idx_research_venues_status` (`status`);

--
-- Indexes for table `title_approvals`
--
ALTER TABLE `title_approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ta_student_id` (`student_id`),
  ADD KEY `idx_ta_adviser_email` (`adviser_email`(100)),
  ADD KEY `idx_ta_status` (`status`),
  ADD KEY `idx_ta_sent_at` (`sent_at`),
  ADD KEY `idx_ta_proposal_number` (`proposal_number`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `chapter_evaluations`
--
ALTER TABLE `chapter_evaluations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `chapter_evaluation_notifications`
--
ALTER TABLE `chapter_evaluation_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- AUTO_INCREMENT for table `chapter_submissions`
--
ALTER TABLE `chapter_submissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `chapter_submission_history`
--
ALTER TABLE `chapter_submission_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- AUTO_INCREMENT for table `grant_applications`
--
ALTER TABLE `grant_applications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `grant_opportunities`
--
ALTER TABLE `grant_opportunities`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `panel_assignment_notifications`
--
ALTER TABLE `panel_assignment_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `panel_member_availability`
--
ALTER TABLE `panel_member_availability`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `preoral_defense_evaluations`
--
ALTER TABLE `preoral_defense_evaluations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `proposal_documents`
--
ALTER TABLE `proposal_documents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=204;

--
-- AUTO_INCREMENT for table `proposal_drafts`
--
ALTER TABLE `proposal_drafts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `proposal_members`
--
ALTER TABLE `proposal_members`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `proposal_status_logs`
--
ALTER TABLE `proposal_status_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=148;

--
-- AUTO_INCREMENT for table `research_adviser_assignments`
--
ALTER TABLE `research_adviser_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT for table `research_coordinator_assignments`
--
ALTER TABLE `research_coordinator_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `research_defense_schedules`
--
ALTER TABLE `research_defense_schedules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `research_groups`
--
ALTER TABLE `research_groups`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `research_milestones`
--
ALTER TABLE `research_milestones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=185;

--
-- AUTO_INCREMENT for table `research_panel_assignments`
--
ALTER TABLE `research_panel_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `research_plans`
--
ALTER TABLE `research_plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `research_progress_activity_logs`
--
ALTER TABLE `research_progress_activity_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT for table `research_progress_attachments`
--
ALTER TABLE `research_progress_attachments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT for table `research_progress_feedback`
--
ALTER TABLE `research_progress_feedback`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `research_progress_notifications`
--
ALTER TABLE `research_progress_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `research_progress_updates`
--
ALTER TABLE `research_progress_updates`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `research_proposals`
--
ALTER TABLE `research_proposals`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `research_revision_cycles`
--
ALTER TABLE `research_revision_cycles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `research_venues`
--
ALTER TABLE `research_venues`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10087;

--
-- AUTO_INCREMENT for table `title_approvals`
--
ALTER TABLE `title_approvals`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `proposal_documents`
--
ALTER TABLE `proposal_documents`
  ADD CONSTRAINT `fk_pd_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `proposal_members`
--
ALTER TABLE `proposal_members`
  ADD CONSTRAINT `fk_pm_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `proposal_status_logs`
--
ALTER TABLE `proposal_status_logs`
  ADD CONSTRAINT `fk_psl_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_adviser_assignments`
--
ALTER TABLE `research_adviser_assignments`
  ADD CONSTRAINT `fk_raa_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `research_proposals` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `research_coordinator_assignments`
--
ALTER TABLE `research_coordinator_assignments`
  ADD CONSTRAINT `fk_rca_title_approval` FOREIGN KEY (`title_approval_id`) REFERENCES `title_approvals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_defense_schedules`
--
ALTER TABLE `research_defense_schedules`
  ADD CONSTRAINT `fk_rds_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_groups`
--
ALTER TABLE `research_groups`
  ADD CONSTRAINT `fk_rg_title_approval` FOREIGN KEY (`title_approval_id`) REFERENCES `title_approvals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_milestones`
--
ALTER TABLE `research_milestones`
  ADD CONSTRAINT `fk_rm_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_plans`
--
ALTER TABLE `research_plans`
  ADD CONSTRAINT `fk_rp_research_group` FOREIGN KEY (`research_group_id`) REFERENCES `research_groups` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `research_progress_activity_logs`
--
ALTER TABLE `research_progress_activity_logs`
  ADD CONSTRAINT `fk_rpal_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_progress_attachments`
--
ALTER TABLE `research_progress_attachments`
  ADD CONSTRAINT `fk_rpa_progress_update` FOREIGN KEY (`progress_update_id`) REFERENCES `research_progress_updates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_progress_feedback`
--
ALTER TABLE `research_progress_feedback`
  ADD CONSTRAINT `fk_rpf_milestone` FOREIGN KEY (`milestone_id`) REFERENCES `research_milestones` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rpf_progress_update` FOREIGN KEY (`progress_update_id`) REFERENCES `research_progress_updates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rpf_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_progress_updates`
--
ALTER TABLE `research_progress_updates`
  ADD CONSTRAINT `fk_rpu_milestone` FOREIGN KEY (`milestone_id`) REFERENCES `research_milestones` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rpu_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
