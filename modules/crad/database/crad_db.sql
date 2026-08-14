-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 14, 2026 at 06:56 AM
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
(1, 3, 32, 475, 'Grammarian', 65.00, 65.00, 65.00, 65.00, '', '', '', '', 'asdasd', 'APPROVED WITH REVISION', 65.00, '2026-08-14 11:36:16', '2026-08-14 11:36:16'),
(2, 5, 33, 475, 'Grammarian', 100.00, 100.00, 100.00, 99.97, '', '', '', '', '', 'APPROVED', 99.99, '2026-08-14 12:16:27', '2026-08-14 12:16:27'),
(3, 6, 33, 475, 'Grammarian', 100.00, 100.00, 100.00, 100.00, '', '', '', '', 'sada', 'APPROVED', 100.00, '2026-08-14 12:16:37', '2026-08-14 12:16:37'),
(4, 8, 35, 475, 'Grammarian', 100.00, 100.00, 100.00, 100.00, '', '', '', '', '', 'APPROVED', 100.00, '2026-08-14 12:48:05', '2026-08-14 12:48:05'),
(5, 9, 35, 475, 'Grammarian', 100.00, 100.00, 100.00, 99.98, '', '', '', '', '', 'APPROVED', 100.00, '2026-08-14 12:48:15', '2026-08-14 12:48:15'),
(6, 10, 35, 475, 'Grammarian', 100.00, 100.00, 100.00, 100.00, '', '', '', '', 'qdas', 'APPROVED', 100.00, '2026-08-14 12:48:26', '2026-08-14 12:48:26');

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
(23, 'student:accepted:10', 9, 'student', 'kenlangmalakas0308@gmail.com', 10, 'accepted', 'Chapter 2 accepted', 'Chapter 2 Version 1 is now Accepted.', '/SMS2_system/modules/student-portal/pages/submission-status.php', 0, '2026-08-14 12:48:26');

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
(1, 32, 4, 1, 1, 'Under Review', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', 'd701d806c9562e421e68041533ec87f5.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'f84ccb4c48dc39ef87ff8e7158a01a1e79a8b5e35416ef6cc9fd52693a39c48a', '2026-08-14 11:24:27', '2026-08-14 11:24:57', NULL, '2026-08-14 11:24:57'),
(2, 32, 4, 2, 1, 'Submitted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '19ed7ba46d4caa1521e45b38b487c7ed.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '90b72a115a04f4d05c9d26551aef19f1c4f1d46896201343acd549071294865c', '2026-08-14 11:24:31', NULL, NULL, '2026-08-14 11:24:31'),
(3, 32, 4, 3, 1, 'Needs Revision', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '51db87a2f87cf9170760cdb98ea3bd97.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'beb4b8b880b05e7711db5de83e9725e96ead21a019e1cac892f9019dfadb5a2d', '2026-08-14 11:24:36', '2026-08-14 11:36:01', '2026-08-14 11:36:16', '2026-08-14 11:36:16'),
(4, 32, 4, 3, 2, 'Submitted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '4ba3d3bad009e0c487e578a5093460c3.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '88d7c8258b1e860786c29e225114cf1b0fa226396e297a75961c1fbdd9100075', '2026-08-14 11:36:41', NULL, NULL, '2026-08-14 11:36:41'),
(5, 33, 5, 1, 1, 'Accepted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', 'a2e6c39b6d6008d28709960f87529479.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'ab9c344b88677bede5792e4af27accc0e1ad546e543c6e4cb6c3ac971e6bb4d2', '2026-08-14 12:07:57', '2026-08-14 12:16:20', '2026-08-14 12:16:27', '2026-08-14 12:16:27'),
(6, 33, 5, 2, 1, 'Accepted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '714ddea8d0b6da05f3f738930cb4d6dd.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'e0d19b00c8be43e1ff3ecfb92bcaa5e3cf21e9c9a6035abc5f66df184f3caa6a', '2026-08-14 12:08:00', '2026-08-14 12:16:32', '2026-08-14 12:16:37', '2026-08-14 12:16:37'),
(7, 33, 5, 3, 1, 'Submitted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '3bff4745452b00a73bb080461ee97a61.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '98bc4707a9e028f90b6651f00218ab970d4aabbd3770d73b1e1ef43c17c13f16', '2026-08-14 12:08:03', NULL, NULL, '2026-08-14 12:08:03'),
(8, 35, 6, 1, 1, 'Accepted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', 'ced4fa0e2abc442cf0973a1801a1e3c1.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '87202dc271b459eac090ecaae5da951bbb7bbb58c9049b6865f6deee77ea5ee2', '2026-08-14 12:46:13', '2026-08-14 12:47:57', '2026-08-14 12:48:05', '2026-08-14 12:48:05'),
(9, 35, 6, 3, 1, 'Accepted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '2a7b3dfa4002e9623638ccb3e48f93d0.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '7ea4f80f8e6b9b254116f81f864e3909c16dc6c14a8cf0726354d7ff73325617', '2026-08-14 12:46:17', '2026-08-14 12:48:09', '2026-08-14 12:48:15', '2026-08-14 12:48:15'),
(10, 35, 6, 2, 1, 'Accepted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', 'af17f61436575f4da202112e45034a11.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'b4f2e4a77f95ef6d9a40cd91928ae832d86504eb48d9579fe6018319a77e8e36', '2026-08-14 12:46:20', '2026-08-14 12:48:20', '2026-08-14 12:48:26', '2026-08-14 12:48:26');

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
(1, 1, 32, 1, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 11:24:27'),
(2, 2, 32, 2, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 11:24:31'),
(3, 3, 32, 3, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 11:24:36'),
(4, 1, 32, 1, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-14 11:24:57'),
(5, 3, 32, 3, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-14 11:36:01'),
(6, 3, 32, 3, 1, 'Needs Revision', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED WITH REVISION', '2026-08-14 11:36:16'),
(7, 4, 32, 3, 2, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 11:36:41'),
(8, 5, 33, 1, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 12:07:57'),
(9, 6, 33, 2, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 12:08:00'),
(10, 7, 33, 3, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 12:08:03'),
(11, 5, 33, 1, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-14 12:16:20'),
(12, 5, 33, 1, 1, 'Accepted', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED', '2026-08-14 12:16:27'),
(13, 6, 33, 2, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-14 12:16:32'),
(14, 6, 33, 2, 1, 'Accepted', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED', '2026-08-14 12:16:37'),
(15, 8, 35, 1, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 12:46:13'),
(16, 9, 35, 3, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 12:46:17'),
(17, 10, 35, 2, 1, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 12:46:20'),
(18, 8, 35, 1, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-14 12:47:57'),
(19, 8, 35, 1, 1, 'Accepted', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED', '2026-08-14 12:48:05'),
(20, 9, 35, 3, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-14 12:48:09'),
(21, 9, 35, 3, 1, 'Accepted', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED', '2026-08-14 12:48:15'),
(22, 10, 35, 2, 1, 'Under Review', 'review_started', 475, 'Grammarian', 'grammarian', 'Grammarian started review.', '2026-08-14 12:48:20'),
(23, 10, 35, 2, 1, 'Accepted', 'evaluated', 475, 'Grammarian', 'grammarian', 'APPROVED', '2026-08-14 12:48:26');

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
(107, 35, NULL, 'TAP-2026-00017', 'RG-2026-001', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', NULL, 'Artificial Intelligence / Machine Learning / Data Analytics / Data Analysis', 'Available', 'Assigned', 'Synced from fully approved research record.', 40, '2026-08-14 12:45:38', '2026-08-14 12:45:37', '2026-08-14 12:45:40', '2026-08-14 12:45:40', 40);

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
(14, 35, NULL, 17, 'TAP-2026-00017', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ASSISTED ANALYSIS', 40, 'Mrs. Kris Guevarra', 'researchcoordinator@bestlink.edu.ph', 'Active', 3, '2026-08-14 12:45:59', '2026-08-14 12:45:59', '2026-08-14 12:45:59');

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
  `defense_datetime` datetime DEFAULT NULL,
  `status` varchar(40) NOT NULL DEFAULT 'Ready for Scheduling',
  `recorded_by` int(10) UNSIGNED DEFAULT NULL,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(35, NULL, 17, 'TAP-2026-00017', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ASSISTED ANALYSIS', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-14', 3, '2026-08-14 04:45:26');

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
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `research_milestones`
--

INSERT INTO `research_milestones` (`id`, `research_plan_id`, `milestone_name`, `description`, `milestone_order`, `progress_percentage`, `weight`, `status`, `start_date`, `target_date`, `completed_at`, `researcher_notes`, `adviser_remarks`, `created_at`, `updated_at`) VALUES
(31, 6, 'Chapter 1', 'Introduction and Background', 1, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-14 12:46:03', '2026-08-14 12:46:03'),
(32, 6, 'Chapter 2', 'Review of Related Literature', 2, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-14 12:46:03', '2026-08-14 12:46:03'),
(33, 6, 'Chapter 3', 'Methodology', 3, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-14 12:46:03', '2026-08-14 12:46:03'),
(34, 6, 'System Development', 'System Implementation', 4, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-14 12:46:03', '2026-08-14 12:46:03'),
(35, 6, 'Testing', 'Testing and Quality Assurance', 5, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-14 12:46:03', '2026-08-14 12:46:03'),
(36, 6, 'Documentation', 'Final Documentation and Report', 6, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-14 12:46:03', '2026-08-14 12:46:03');

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
(6, 35, 'DEVELOPMENT OF AI ASSISTED ANALYSIS', 'RG-2026-001', NULL, 'Dr. Roberto M. Santos', '', '2026-08-14', NULL, 'Planning', 0.00, 'Active', '2026-08-14 12:46:03', '2026-08-14 12:46:03');

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
(17, 'S230000001', 9, 'Student User', '2026-08-14', 'College of Computer Studies', 'DEVELOPMENT OF AI ASSISTED ANALYSIS', 'Engineering, Information Technology, and Computing', 'SDG 9 — Industry, Innovation and Infrastructure', 'Science, Technology, Digital Transformation, and Innovation', 'ASDASDASDASDSADAS', '[[\"User, Student A.\",\"BSIT 4101\",\"OR-2645220\"]]', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', 'Mrs. Kris Guevarra', 'TAP-2026-00017', 'Approved', NULL, 'data:image/png;base64,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', 'Approved', NULL, '{\"agenda_alignment\":\"yes\",\"feasible_original\":\"yes\",\"ethical_sdg\":\"yes\"}', 'data:image/png;base64,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', '2026-08-14 12:45:05', 'Approved', 'data:image/png;base64,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', '2026-08-14 12:45:21', '2026-08-14 12:44:22', '2026-08-14 12:44:46', '2026-08-14 12:44:22', '2026-08-14 12:45:26');

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
  ADD KEY `idx_rca_group` (`research_group_id`),
  ADD KEY `idx_rca_title_approval` (`title_approval_id`),
  ADD KEY `idx_rca_status` (`status`);

--
-- Indexes for table `research_defense_schedules`
--
ALTER TABLE `research_defense_schedules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rds_group_number` (`group_number`),
  ADD KEY `idx_rds_proposal_number` (`proposal_number`),
  ADD KEY `idx_rds_status` (`status`),
  ADD KEY `idx_rds_proposal_id` (`proposal_id`);

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
  ADD KEY `idx_rm_plan` (`research_plan_id`),
  ADD KEY `idx_rm_status` (`status`),
  ADD KEY `idx_rm_sequence` (`research_plan_id`,`milestone_order`);

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `chapter_evaluation_notifications`
--
ALTER TABLE `chapter_evaluation_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `chapter_submissions`
--
ALTER TABLE `chapter_submissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `chapter_submission_history`
--
ALTER TABLE `chapter_submission_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `research_defense_schedules`
--
ALTER TABLE `research_defense_schedules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `research_groups`
--
ALTER TABLE `research_groups`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `research_milestones`
--
ALTER TABLE `research_milestones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `research_plans`
--
ALTER TABLE `research_plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `research_progress_activity_logs`
--
ALTER TABLE `research_progress_activity_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `research_progress_attachments`
--
ALTER TABLE `research_progress_attachments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `research_progress_feedback`
--
ALTER TABLE `research_progress_feedback`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `research_progress_notifications`
--
ALTER TABLE `research_progress_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `research_progress_updates`
--
ALTER TABLE `research_progress_updates`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `research_proposals`
--
ALTER TABLE `research_proposals`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `research_venues`
--
ALTER TABLE `research_venues`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=912;

--
-- AUTO_INCREMENT for table `title_approvals`
--
ALTER TABLE `title_approvals`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

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
