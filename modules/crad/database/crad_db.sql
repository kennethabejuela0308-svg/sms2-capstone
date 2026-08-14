-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 14, 2026 at 05:38 AM
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
(1, 3, 32, 475, 'Grammarian', 65.00, 65.00, 65.00, 65.00, '', '', '', '', 'asdasd', 'APPROVED WITH REVISION', 65.00, '2026-08-14 11:36:16', '2026-08-14 11:36:16');

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
(7, 'evaluator:new:4:u475', 475, 'grammarian', 'grammarian@bestlink.edu.ph', 4, 'new_submission', 'Revised Chapter Submitted', 'Group 01 submitted Chapter 3 Version 2 for re-evaluation.', '/SMS2_system/modules/faculty/pages/evaluation-scoring.php?id=4', 1, '2026-08-14 11:36:41');

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
(4, 32, 4, 3, 2, 'Submitted', 9, 'Student User', 'kenlangmalakas0308@gmail.com', '', 'OJT_PRACTICUM_1_NARRATIVE_REPORT (1) (1).docx', 'student_chapters/u9', '4ba3d3bad009e0c487e578a5093460c3.docx', 350940, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '88d7c8258b1e860786c29e225114cf1b0fa226396e297a75961c1fbdd9100075', '2026-08-14 11:36:41', NULL, NULL, '2026-08-14 11:36:41');

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
(7, 4, 32, 3, 2, 'Submitted', 'submitted', 9, 'Student User', 'student', '', '2026-08-14 11:36:41');

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
(105, 32, NULL, 'TAP-2026-00013', 'RG-2026-001', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', NULL, 'Artificial Intelligence / Machine Learning / Data Analytics / Data Analysis', 'Available', 'Assigned', 'Synced from fully approved research record.', 40, '2026-08-13 09:48:53', '2026-08-13 09:48:50', '2026-08-13 09:48:55', '2026-08-13 09:48:55', 40);

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
(12, 32, NULL, 13, 'TAP-2026-00013', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ASSISTED OF DOCUMENT ANALYSIS', 40, 'Mrs. Kris Guevarra', 'researchcoordinator@bestlink.edu.ph', 'Active', 3, '2026-08-13 09:49:37', '2026-08-13 09:49:37', '2026-08-13 09:49:37');

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
(32, NULL, 13, 'TAP-2026-00013', 'RG-2026-001', 'Group 01', 'DEVELOPMENT OF AI ASSISTED OF DOCUMENT ANALYSIS', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-13', 3, '2026-08-13 01:48:33');

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
(19, 4, 'Chapter 1', 'Introduction and Background', 1, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-13 09:49:40', '2026-08-13 09:49:40'),
(20, 4, 'Chapter 2', 'Review of Related Literature', 2, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-13 09:49:40', '2026-08-13 09:49:40'),
(21, 4, 'Chapter 3', 'Methodology', 3, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-13 09:49:40', '2026-08-13 09:49:40'),
(22, 4, 'System Development', 'System Implementation', 4, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-13 09:49:40', '2026-08-13 09:49:40'),
(23, 4, 'Testing', 'Testing and Quality Assurance', 5, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-13 09:49:40', '2026-08-13 09:49:40'),
(24, 4, 'Documentation', 'Final Documentation and Report', 6, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-13 09:49:40', '2026-08-13 09:49:40');

-- --------------------------------------------------------

--
-- Table structure for table `research_plans`
--

CREATE TABLE `research_plans` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL COMMENT 'FK to research_groups',
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
(4, 32, 'DEVELOPMENT OF AI ASSISTED OF DOCUMENT ANALYSIS', 'RG-2026-001', NULL, 'Dr. Roberto M. Santos', '', '2026-08-13', NULL, 'Planning', 0.00, 'Active', '2026-08-13 09:49:40', '2026-08-13 09:49:40');

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
(13, 'S230000001', 9, 'Student User', '2026-08-13', 'College of Computer Studies', 'DEVELOPMENT OF AI ASSISTED OF DOCUMENT ANALYSIS', 'Business, Entrepreneurship, Hospitality, and Tourism Management', 'SDG 9 — Industry, Innovation and Infrastructure', 'Science, Technology, Digital Transformation, and Innovation', 'SADASDASD ASDSAD ASD AS DAS DAS DAS DA', '[[\"User, Student A.\",\"BSIT 4101\",\"OR-2679862\"]]', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', 'Mrs. Kris Guevarra', 'TAP-2026-00013', 'Approved', NULL, 'data:image/png;base64,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', 'Approved', NULL, '{\"agenda_alignment\":\"yes\",\"feasible_original\":\"yes\",\"ethical_sdg\":\"yes\"}', 'data:image/png;base64,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', '2026-08-13 09:48:13', 'Approved', 'data:image/png;base64,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', '2026-08-13 09:48:32', '2026-08-13 09:46:37', '2026-08-13 09:47:37', '2026-08-13 09:46:37', '2026-08-13 09:48:33');

--
-- Triggers `title_approvals`
--
DELIMITER $$
CREATE TRIGGER `trg_title_approvals_after_delete` AFTER DELETE ON `title_approvals` FOR EACH ROW BEGIN
                    DELETE FROM research_coordinator_assignments
                    WHERE title_approval_id = OLD.id
                       OR research_group_id IN (SELECT id FROM research_groups WHERE title_approval_id = OLD.id)
                       OR group_number IN (SELECT group_number FROM research_groups WHERE title_approval_id = OLD.id);

                    DELETE FROM research_adviser_assignments
                    WHERE research_group_id IN (SELECT id FROM research_groups WHERE title_approval_id = OLD.id)
                       OR group_number IN (SELECT group_number FROM research_groups WHERE title_approval_id = OLD.id);
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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `chapter_evaluation_notifications`
--
ALTER TABLE `chapter_evaluation_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `chapter_submissions`
--
ALTER TABLE `chapter_submissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `chapter_submission_history`
--
ALTER TABLE `chapter_submission_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- AUTO_INCREMENT for table `research_coordinator_assignments`
--
ALTER TABLE `research_coordinator_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `research_defense_schedules`
--
ALTER TABLE `research_defense_schedules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `research_groups`
--
ALTER TABLE `research_groups`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `research_milestones`
--
ALTER TABLE `research_milestones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `research_plans`
--
ALTER TABLE `research_plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

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
-- Constraints for table `research_defense_schedules`
--
ALTER TABLE `research_defense_schedules`
  ADD CONSTRAINT `fk_rds_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_milestones`
--
ALTER TABLE `research_milestones`
  ADD CONSTRAINT `fk_rm_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `research_plans`
--
ALTER TABLE `research_plans`
  ADD CONSTRAINT `fk_rp_research_group` FOREIGN KEY (`research_group_id`) REFERENCES `research_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

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
