-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 13, 2026 at 02:36 AM
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
(103, 30, NULL, 'TAP-2026-00011', 'RG-2026-030', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', NULL, 'Artificial Intelligence / Machine Learning / Data Analytics / Data Analysis', 'Available', 'Assigned', 'Synced from fully approved research record.', 40, '2026-08-12 18:52:50', '2026-08-12 18:52:47', '2026-08-12 18:52:54', '2026-08-12 18:52:54', 40);

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
(10, 30, NULL, 11, 'TAP-2026-00011', 'RG-2026-030', 'Group 30', 'AI ASSISTED DOCUMENT AND ANALYSIS OPEN GPT 5.5', 40, 'Mrs. Kris Guevarra', 'researchcoordinator@bestlink.edu.ph', 'Active', 3, '2026-08-12 18:53:22', '2026-08-12 18:53:22', '2026-08-12 18:53:22');

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
(18, 25, NULL, 'CRD-2026-00025', 'RG-2026-001', 'Group 01', 'AI ASSISTEND TITLE OPENGPT 4.1', 'College of Computer Studies', 'Dr. Roberto M. Santos', 'A.Y. 2026-2027', 'User, Student A.', 'S230000001', 's230000001@bcp.edu.ph', '09171234567', 'Approved', '2026-08-09', 3, '2026-08-09 10:38:47'),
(19, 26, NULL, 'CRD-2026-00026', 'RG-2026-019', 'Group 19', 'AI ASSISTEND TITLE OPENGPT 4.1', 'College of Computer Studies', 'Dr. Roberto M. Santos', 'A.Y. 2026-2027', 'User, Student A.', 'S230000001', 's230000001@bcp.edu.ph', '09171234567', 'Approved', '2026-08-09', 3, '2026-08-09 10:51:29'),
(20, 27, NULL, 'CRD-2026-00027', 'RG-2026-020', 'Group 20', 'AI ASSISTEND TITLE OPENGPT 4.1', 'College of Computer Studies', 'Dr. Roberto M. Santos', 'A.Y. 2026-2027', 'User, Student A.', 'S230000001', 's230000001@bcp.edu.ph', '09171234567', 'Approved', '2026-08-10', 3, '2026-08-10 12:59:18'),
(21, NULL, 1, 'TAP-2026-00001', 'RG-2026-021', 'Group 21', 'ASDA', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-11', 3, '2026-08-11 10:17:32'),
(22, NULL, 2, 'TAP-2026-00002', 'RG-2026-022', 'Group 22', 'AI ASSISTEND OPEN GPT AI', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-11', 3, '2026-08-11 11:11:27'),
(23, NULL, 4, 'TAP-2026-00004', 'RG-2026-023', 'Group 23', 'DEVELOPMENT OF AI ASSSTEND GOOGLE OR TOOLS , OPEN GPT 5.5', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-11', 3, '2026-08-11 11:32:29'),
(24, NULL, 5, 'TAP-2026-00005', 'RG-2026-024', 'Group 24', 'DEVELOPMENT OF AI ASSISSTED OPEN GPT 5.5', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-11', 3, '2026-08-11 11:46:42'),
(25, NULL, 6, 'TAP-2026-00006', 'RG-2026-025', 'Group 25', 'DEVELOPMENT OF AI ASSISTED DOCUMENT AND SCHEDULING OPEN GPT 5.5', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-12', 3, '2026-08-12 08:27:57'),
(26, NULL, 7, NULL, 'RG-9999-901', 'Group T1', 'CLI TRIGGER TEST TITLE A', '', '', '', '', '', '', '', 'Approved', '2026-08-12', NULL, '2026-08-12 08:43:00'),
(27, NULL, 8, NULL, 'RG-9999-902', 'Group T2', 'CLI TRIGGER TEST TITLE B', '', '', '', '', '', '', '', 'Approved', '2026-08-12', NULL, '2026-08-12 08:43:00'),
(28, NULL, 9, 'TAP-2026-00009', 'RG-2026-028', 'Group 28', 'AI ASSISTED DOCUMENT ANALYSIS', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-12', 3, '2026-08-12 08:59:08'),
(29, NULL, 10, 'TAP-2026-00010', 'RG-2026-029', 'Group 29', 'AI ASSISTED OPEN GPT 4.4', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-12', 40, '2026-08-12 09:34:44'),
(30, NULL, 11, 'TAP-2026-00011', 'RG-2026-030', 'Group 30', 'AI ASSISTED DOCUMENT AND ANALYSIS OPEN GPT 5.5', 'College of Computer Studies', 'Dr. Roberto M. Santos', '2026-2027', 'Student User', 'S230000001', '', '', 'Approved', '2026-08-12', 3, '2026-08-12 10:52:26');

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
(1, 1, 'Chapter 1', 'Introduction and Background of the Study', 1, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-12 22:10:24', '2026-08-12 22:10:24'),
(2, 1, 'Chapter 2', 'Review of Related Literature', 2, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-12 22:10:24', '2026-08-12 22:10:24'),
(3, 1, 'Chapter 3', 'Research Methodology', 3, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-12 22:10:24', '2026-08-12 22:10:24'),
(4, 1, 'System Development', 'Implementation and Development Phase', 4, 0.00, 1.50, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-12 22:10:24', '2026-08-12 22:10:24'),
(5, 1, 'Testing', 'System Testing and Quality Assurance', 5, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-12 22:10:24', '2026-08-12 22:10:24'),
(6, 1, 'Documentation', 'Final Documentation and Manuscript Preparation', 6, 0.00, 1.00, 'Not Started', NULL, NULL, NULL, NULL, NULL, '2026-08-12 22:10:24', '2026-08-12 22:10:24');

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
(1, 25, 'DEVELOPMENT OF AI ASSISTED DOCUMENT AND SCHEDULING OPEN GPT 5.5', 'RG-2026-025', NULL, 'Dr. Roberto M. Santos', '', '2026-08-12', NULL, 'Planning', 0.00, 'Active', '2026-08-12 22:10:24', '2026-08-12 22:10:24');

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
(1, 1, 9, 'Student User', 'student', 'plan_created', 'research_plan', 1, NULL, NULL, 'Research implementation plan created', '2026-08-12 22:10:24');

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
(11, 'S230000001', 9, 'Student User', '2026-08-12', 'College of Computer Studies', 'AI ASSISTED DOCUMENT AND ANALYSIS OPEN GPT 5.5', 'Engineering, Information Technology, and Computing', 'SDG 9 — Industry, Innovation and Infrastructure', 'Science, Technology, Digital Transformation, and Innovation', 'adasdasdas das asdas das das', '[[\"User, Student A.\",\"BSIT 4101\",\"OR-2681246\"]]', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', 'Mrs. Kris Guevarra', 'TAP-2026-00011', 'Approved', NULL, 'data:image/png;base64,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', 'Approved', NULL, '{\"agenda_alignment\":\"yes\",\"feasible_original\":\"yes\",\"ethical_sdg\":\"yes\"}', 'data:image/png;base64,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', '2026-08-12 18:51:41', 'Approved', 'data:image/png;base64,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', '2026-08-12 18:52:22', '2026-08-12 18:51:06', '2026-08-12 18:51:21', '2026-08-12 18:51:06', '2026-08-12 18:52:26');

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

--
-- AUTO_INCREMENT for table `research_coordinator_assignments`
--
ALTER TABLE `research_coordinator_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `research_defense_schedules`
--
ALTER TABLE `research_defense_schedules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `research_groups`
--
ALTER TABLE `research_groups`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `research_milestones`
--
ALTER TABLE `research_milestones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `research_plans`
--
ALTER TABLE `research_plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `research_progress_activity_logs`
--
ALTER TABLE `research_progress_activity_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
