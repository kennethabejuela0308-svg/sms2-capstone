-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 25, 2026 at 09:14 PM
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
-- Table structure for table `crad_chapter_evaluations`
--

CREATE TABLE `crad_chapter_evaluations` (
  `id` int(10) UNSIGNED NOT NULL,
  `submission_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `evaluator_user_id` int(10) UNSIGNED NOT NULL,
  `evaluator_name` varchar(150) NOT NULL DEFAULT '',
  `content_score` decimal(5,2) NOT NULL,
  `methodology_score` decimal(5,2) NOT NULL,
  `references_score` decimal(5,2) NOT NULL,
  `format_score` decimal(5,2) NOT NULL,
  `grammar_score` decimal(5,2) NOT NULL DEFAULT 0.00,
  `content_remarks` text DEFAULT NULL,
  `methodology_remarks` text DEFAULT NULL,
  `references_remarks` text DEFAULT NULL,
  `format_remarks` text DEFAULT NULL,
  `grammar_remarks` text DEFAULT NULL,
  `overall_feedback` text DEFAULT NULL,
  `result` enum('APPROVED','APPROVED WITH REVISION') NOT NULL,
  `overall_score` decimal(5,2) DEFAULT NULL,
  `evaluated_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_chapter_evaluation_notifications`
--

CREATE TABLE `crad_chapter_evaluation_notifications` (
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

-- --------------------------------------------------------

--
-- Table structure for table `crad_chapter_submissions`
--

CREATE TABLE `crad_chapter_submissions` (
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

-- --------------------------------------------------------

--
-- Table structure for table `crad_chapter_submission_history`
--

CREATE TABLE `crad_chapter_submission_history` (
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

-- --------------------------------------------------------

--
-- Table structure for table `crad_final_defense_evaluations`
--

CREATE TABLE `crad_final_defense_evaluations` (
  `id` int(10) UNSIGNED NOT NULL,
  `defense_schedule_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `panel_user_id` int(10) UNSIGNED NOT NULL,
  `panel_name` varchar(150) NOT NULL DEFAULT '',
  `content_score` decimal(5,2) NOT NULL,
  `methodology_score` decimal(5,2) NOT NULL,
  `references_score` decimal(5,2) NOT NULL,
  `format_score` decimal(5,2) NOT NULL,
  `defense_score` decimal(5,2) NOT NULL DEFAULT 0.00,
  `remarks` text DEFAULT NULL,
  `result` enum('APPROVED','APPROVED WITH REVISION','FAILED') NOT NULL,
  `overall_score` decimal(5,2) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'Submitted',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_final_defense_recommendations`
--

CREATE TABLE `crad_final_defense_recommendations` (
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
-- Table structure for table `crad_final_manuscript_approvals`
--

CREATE TABLE `crad_final_manuscript_approvals` (
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
-- Table structure for table `crad_grant_applications`
--

CREATE TABLE `crad_grant_applications` (
  `id` int(10) UNSIGNED NOT NULL,
  `proposal_reference` varchar(30) DEFAULT NULL COMMENT 'Stable proposal ID e.g. GR-2026-001',
  `current_version` int(10) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Active proposal document version',
  `grant_opportunity_id` int(10) UNSIGNED NOT NULL COMMENT 'FK → grant_opportunities.id',
  `research_group_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK → research_groups.id (nullable for non-capstone applicants)',
  `group_number` varchar(30) DEFAULT NULL,
  `research_title` varchar(500) DEFAULT NULL,
  `applicant_name` varchar(200) NOT NULL DEFAULT '',
  `college_dept` varchar(200) DEFAULT NULL COMMENT 'Academic college / department of the lead proponent',
  `requested_budget` decimal(14,2) DEFAULT NULL COMMENT 'Budget requested by the proponent; must not exceed grant max_funding_cap',
  `approved_budget` decimal(14,2) DEFAULT NULL,
  `abstract` text DEFAULT NULL COMMENT 'Executive abstract of the research proposal',
  `objectives` text DEFAULT NULL COMMENT 'Research objectives',
  `proposal_pdf` varchar(255) DEFAULT NULL COMMENT 'Stored filename of the uploaded proposal PDF/DOC under storage/uploads/grant_proposals/',
  `proposal_pdf_original` varchar(300) DEFAULT NULL COMMENT 'Original filename of the uploaded proposal document',
  `supporting_docs` varchar(255) DEFAULT NULL COMMENT 'Stored filename of optional supporting documents',
  `supporting_docs_original` varchar(300) DEFAULT NULL COMMENT 'Original filename of optional supporting documents',
  `ethics_doc` varchar(255) DEFAULT NULL COMMENT 'Stored filename of optional ethics clearance document',
  `ethics_doc_original` varchar(300) DEFAULT NULL COMMENT 'Original filename of optional ethics clearance document',
  `applicant_user_id` int(10) UNSIGNED DEFAULT NULL,
  `application_notes` text DEFAULT NULL,
  `status` enum('Submitted','Under Review','Approved','Approved & Funded','Final Output Submitted','OUTPUT_VERIFIED','Archived','Denied','Withdrawn','Rejected','Revision Required','Resubmitted') NOT NULL DEFAULT 'Submitted',
  `submission_token` varchar(64) DEFAULT NULL COMMENT 'One-time token for duplicate-submission prevention',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_document_repository`
--

CREATE TABLE `crad_grant_document_repository` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `archive_reference` varchar(40) NOT NULL DEFAULT '',
  `status` enum('ARCHIVED') NOT NULL DEFAULT 'ARCHIVED',
  `item_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `archived_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `archived_by_name` varchar(120) DEFAULT NULL,
  `archived_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_document_repository_items`
--

CREATE TABLE `crad_grant_document_repository_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `repository_id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `category` varchar(40) NOT NULL,
  `item_label` varchar(255) NOT NULL DEFAULT '',
  `item_type` enum('file','record') NOT NULL DEFAULT 'record',
  `file_path` varchar(255) DEFAULT NULL,
  `file_original` varchar(255) DEFAULT NULL,
  `download_url` varchar(500) DEFAULT NULL,
  `summary_text` text DEFAULT NULL,
  `metadata_json` text DEFAULT NULL,
  `sort_order` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_final_output_submissions`
--

CREATE TABLE `crad_grant_final_output_submissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `version_number` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `final_research_title` varchar(500) NOT NULL DEFAULT '',
  `authors` varchar(500) NOT NULL DEFAULT '',
  `abstract` text DEFAULT NULL,
  `publication_type` enum('Journal','Conference','Book Chapter','Repository','Other') NOT NULL DEFAULT 'Journal',
  `journal_conference` varchar(255) NOT NULL DEFAULT '',
  `doi` varchar(120) NOT NULL DEFAULT '',
  `publication_url` varchar(500) NOT NULL DEFAULT '',
  `ip_information` text DEFAULT NULL,
  `copyright_info` text DEFAULT NULL,
  `patent_info` text DEFAULT NULL,
  `other_ip_info` text DEFAULT NULL,
  `final_pdf_path` varchar(255) DEFAULT NULL,
  `final_pdf_original` varchar(255) DEFAULT NULL,
  `supporting_files_json` text DEFAULT NULL,
  `status` enum('FINAL_OUTPUT_SUBMITTED','RETURNED_FOR_CORRECTION','OUTPUT_VERIFIED') NOT NULL DEFAULT 'FINAL_OUTPUT_SUBMITTED',
  `return_reason` text DEFAULT NULL,
  `verification_notes` text DEFAULT NULL,
  `submitted_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `submitted_by_name` varchar(120) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `reviewed_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `reviewed_by_name` varchar(120) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_funded_progress_evidence`
--

CREATE TABLE `crad_grant_funded_progress_evidence` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `milestone_id` int(10) UNSIGNED DEFAULT NULL,
  `evidence_title` varchar(200) NOT NULL DEFAULT '',
  `notes` text DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `file_original` varchar(255) DEFAULT NULL,
  `submitted_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `submitted_by_name` varchar(120) DEFAULT NULL,
  `status` enum('Submitted','Acknowledged') NOT NULL DEFAULT 'Submitted',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_funded_project_milestones`
--

CREATE TABLE `crad_grant_funded_project_milestones` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `milestone_order` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `milestone_name` varchar(120) NOT NULL,
  `due_date` date DEFAULT NULL,
  `completion_pct` decimal(5,2) NOT NULL DEFAULT 0.00,
  `status` enum('Pending','In Progress','Completed') NOT NULL DEFAULT 'Pending',
  `supporting_doc` varchar(255) DEFAULT NULL,
  `supporting_doc_original` varchar(255) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `updated_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `updated_by_name` varchar(120) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_funding_disbursements`
--

CREATE TABLE `crad_grant_funding_disbursements` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `tranche_number` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `tranche_label` varchar(80) NOT NULL DEFAULT '',
  `approved_budget` decimal(14,2) NOT NULL DEFAULT 0.00,
  `amount_released` decimal(14,2) NOT NULL DEFAULT 0.00,
  `release_date` date DEFAULT NULL,
  `reference_number` varchar(80) DEFAULT NULL,
  `status` enum('Pending','Released','Cancelled') NOT NULL DEFAULT 'Pending',
  `released_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `released_by_name` varchar(120) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_opportunities`
--

CREATE TABLE `crad_grant_opportunities` (
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
-- Table structure for table `crad_grant_proposal_approval_steps`
--

CREATE TABLE `crad_grant_proposal_approval_steps` (
  `id` int(10) UNSIGNED NOT NULL,
  `workflow_id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `step_key` varchar(40) NOT NULL,
  `step_order` tinyint(3) UNSIGNED NOT NULL,
  `step_label` varchar(80) NOT NULL,
  `approver_role_key` varchar(40) NOT NULL,
  `status` enum('Queued','Pending','Approved','Returned') NOT NULL DEFAULT 'Queued',
  `approver_user_id` int(10) UNSIGNED DEFAULT NULL,
  `approver_name` varchar(150) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `signature_data` mediumtext DEFAULT NULL,
  `acted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_proposal_approval_workflows`
--

CREATE TABLE `crad_grant_proposal_approval_workflows` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `current_step_key` varchar(40) NOT NULL DEFAULT 'adviser',
  `workflow_status` enum('In Progress','Completed','Returned') NOT NULL DEFAULT 'In Progress',
  `started_at` datetime NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_proposal_evaluations`
--

CREATE TABLE `crad_grant_proposal_evaluations` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `proposal_version` int(10) UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Proposal version evaluated',
  `evaluator_user_id` int(10) UNSIGNED NOT NULL,
  `evaluator_name` varchar(150) NOT NULL DEFAULT '',
  `evaluation_type` varchar(20) NOT NULL DEFAULT 'committee' COMMENT 'committee | adviser',
  `score_rationale` decimal(5,2) NOT NULL DEFAULT 0.00,
  `score_methodology` decimal(5,2) NOT NULL DEFAULT 0.00,
  `score_budget` decimal(5,2) NOT NULL DEFAULT 0.00,
  `score_team_capability` decimal(5,2) NOT NULL DEFAULT 0.00,
  `score_compliance` decimal(5,2) NOT NULL DEFAULT 0.00,
  `total_score` decimal(5,2) NOT NULL DEFAULT 0.00,
  `comments` text DEFAULT NULL,
  `recommendations` text DEFAULT NULL,
  `required_corrections` text DEFAULT NULL,
  `recommendation` varchar(40) DEFAULT NULL COMMENT 'Reviewer decision: disapprove | require_revisions',
  `revision_reason` text DEFAULT NULL COMMENT 'Reason for required revisions',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_proposal_notifications`
--

CREATE TABLE `crad_grant_proposal_notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `event_key` varchar(120) NOT NULL,
  `recipient_user_id` int(10) UNSIGNED DEFAULT NULL,
  `recipient_role` varchar(40) NOT NULL DEFAULT '',
  `recipient_email` varchar(190) NOT NULL DEFAULT '',
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `type` varchar(40) NOT NULL DEFAULT '',
  `title` varchar(200) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `url` varchar(500) NOT NULL DEFAULT '',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_proposal_versions`
--

CREATE TABLE `crad_grant_proposal_versions` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `version_number` int(10) UNSIGNED NOT NULL,
  `version_label` varchar(60) NOT NULL DEFAULT '',
  `proposal_pdf` varchar(255) DEFAULT NULL,
  `proposal_pdf_original` varchar(300) DEFAULT NULL,
  `supporting_docs` varchar(255) DEFAULT NULL,
  `supporting_docs_original` varchar(300) DEFAULT NULL,
  `ethics_doc` varchar(255) DEFAULT NULL,
  `ethics_doc_original` varchar(300) DEFAULT NULL,
  `abstract` text DEFAULT NULL,
  `objectives` text DEFAULT NULL,
  `researcher_notes` text DEFAULT NULL,
  `submitted_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_grant_publications_ip_repository`
--

CREATE TABLE `crad_grant_publications_ip_repository` (
  `id` int(10) UNSIGNED NOT NULL,
  `grant_application_id` int(10) UNSIGNED NOT NULL,
  `submission_id` int(10) UNSIGNED NOT NULL,
  `repository_reference` varchar(40) NOT NULL DEFAULT '',
  `final_research_title` varchar(500) NOT NULL DEFAULT '',
  `authors` varchar(500) NOT NULL DEFAULT '',
  `abstract` text DEFAULT NULL,
  `publication_type` varchar(60) NOT NULL DEFAULT '',
  `journal_conference` varchar(255) NOT NULL DEFAULT '',
  `doi` varchar(120) NOT NULL DEFAULT '',
  `publication_url` varchar(500) NOT NULL DEFAULT '',
  `ip_information` text DEFAULT NULL,
  `copyright_info` text DEFAULT NULL,
  `patent_info` text DEFAULT NULL,
  `other_ip_info` text DEFAULT NULL,
  `final_pdf_path` varchar(255) DEFAULT NULL,
  `final_pdf_original` varchar(255) DEFAULT NULL,
  `supporting_files_json` text DEFAULT NULL,
  `verified_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `verified_by_name` varchar(120) DEFAULT NULL,
  `verified_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_manuscript_evaluations`
--

CREATE TABLE `crad_manuscript_evaluations` (
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
-- Table structure for table `crad_manuscript_submissions`
--

CREATE TABLE `crad_manuscript_submissions` (
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
-- Table structure for table `crad_panel_assignment_notifications`
--

CREATE TABLE `crad_panel_assignment_notifications` (
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

-- --------------------------------------------------------

--
-- Table structure for table `crad_panel_member_availability`
--

CREATE TABLE `crad_panel_member_availability` (
  `id` int(10) UNSIGNED NOT NULL,
  `panel_user_id` int(10) UNSIGNED NOT NULL,
  `availability_status` varchar(40) NOT NULL DEFAULT 'Pending',
  `notes` text DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_preoral_defense_evaluations`
--

CREATE TABLE `crad_preoral_defense_evaluations` (
  `id` int(10) UNSIGNED NOT NULL,
  `defense_schedule_id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `panel_user_id` int(10) UNSIGNED NOT NULL,
  `panel_name` varchar(150) NOT NULL DEFAULT '',
  `content_score` decimal(5,2) NOT NULL,
  `methodology_score` decimal(5,2) NOT NULL,
  `references_score` decimal(5,2) NOT NULL,
  `format_score` decimal(5,2) NOT NULL,
  `defense_score` decimal(5,2) NOT NULL DEFAULT 0.00,
  `remarks` text DEFAULT NULL,
  `result` enum('APPROVED','APPROVED WITH REVISION','FAILED') NOT NULL,
  `overall_score` decimal(5,2) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'Submitted',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_proposal_documents`
--

CREATE TABLE `crad_proposal_documents` (
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
-- Table structure for table `crad_proposal_drafts`
--

CREATE TABLE `crad_proposal_drafts` (
  `id` int(10) UNSIGNED NOT NULL,
  `student_id` varchar(50) NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_users (optional)',
  `form_type` varchar(30) NOT NULL DEFAULT 'document',
  `revision_ref` varchar(30) NOT NULL DEFAULT '' COMMENT 'Returned proposal ref when draft is for revision',
  `draft_data` longtext NOT NULL COMMENT 'JSON encoded draft form fields except upload files',
  `signature_data` mediumtext DEFAULT NULL COMMENT 'Base64 PNG of representative signature draft',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_proposal_members`
--

CREATE TABLE `crad_proposal_members` (
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
-- Table structure for table `crad_proposal_status_logs`
--

CREATE TABLE `crad_proposal_status_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `proposal_id` int(10) UNSIGNED NOT NULL,
  `old_status` varchar(30) DEFAULT NULL,
  `new_status` varchar(30) NOT NULL,
  `changed_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_users',
  `remarks` text DEFAULT NULL,
  `changed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_publications`
--

CREATE TABLE `crad_publications` (
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
-- Table structure for table `crad_research_adviser_assignments`
--

CREATE TABLE `crad_research_adviser_assignments` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_number` varchar(30) DEFAULT NULL,
  `group_number` varchar(40) DEFAULT NULL,
  `student_id` varchar(40) DEFAULT NULL,
  `adviser_name` varchar(150) NOT NULL DEFAULT '',
  `adviser_email` varchar(190) NOT NULL DEFAULT '',
  `adviser_user_id` int(10) UNSIGNED DEFAULT NULL,
  `expertise` varchar(255) NOT NULL DEFAULT '',
  `availability_status` varchar(40) NOT NULL DEFAULT 'Pending',
  `assignment_status` varchar(40) NOT NULL DEFAULT 'Pending',
  `confirmation_status` varchar(40) NOT NULL DEFAULT 'pending_confirmation',
  `confirmed_at` datetime DEFAULT NULL,
  `confirmed_by` int(10) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `assigned_by` int(10) UNSIGNED DEFAULT NULL,
  `assigned_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `notification_sent_at` datetime DEFAULT NULL,
  `notification_sent_by` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `crad_research_adviser_assignments`
--

INSERT INTO `crad_research_adviser_assignments` (`id`, `research_group_id`, `proposal_id`, `proposal_number`, `group_number`, `student_id`, `adviser_name`, `adviser_email`, `adviser_user_id`, `expertise`, `availability_status`, `assignment_status`, `confirmation_status`, `confirmed_at`, `confirmed_by`, `notes`, `assigned_by`, `assigned_at`, `created_at`, `updated_at`, `notification_sent_at`, `notification_sent_by`) VALUES
(115, 76, NULL, NULL, 'STU-S230000001', 'S230000001', 'Dr. Roberto M. Santos', 'rsantos@bestlink.edu.ph', 54, 'General Research Methods', 'Available', 'Confirmed', 'confirmed', '2026-09-26 03:00:37', 54, 'Assigned from Research Coordinator Management', 1420, '2026-09-26 03:00:06', '2026-09-26 02:26:00', '2026-09-26 03:00:37', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_assignment_cycles`
--

CREATE TABLE `crad_research_assignment_cycles` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `group_number` varchar(40) NOT NULL DEFAULT '',
  `student_id` varchar(40) NOT NULL DEFAULT '',
  `coordinator_assignment_id` int(10) UNSIGNED DEFAULT NULL,
  `adviser_assignment_id` int(10) UNSIGNED DEFAULT NULL,
  `status` varchar(40) NOT NULL DEFAULT 'pending_confirmation',
  `coordinator_confirmed_at` datetime DEFAULT NULL,
  `coordinator_confirmed_by` int(10) UNSIGNED DEFAULT NULL,
  `adviser_confirmed_at` datetime DEFAULT NULL,
  `adviser_confirmed_by` int(10) UNSIGNED DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by` int(10) UNSIGNED DEFAULT NULL,
  `cancel_role` varchar(40) NOT NULL DEFAULT '',
  `cancel_reason` text DEFAULT NULL,
  `assigned_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `crad_research_assignment_cycles`
--

INSERT INTO `crad_research_assignment_cycles` (`id`, `research_group_id`, `group_number`, `student_id`, `coordinator_assignment_id`, `adviser_assignment_id`, `status`, `coordinator_confirmed_at`, `coordinator_confirmed_by`, `adviser_confirmed_at`, `adviser_confirmed_by`, `cancelled_at`, `cancelled_by`, `cancel_role`, `cancel_reason`, `assigned_by`, `created_at`, `updated_at`) VALUES
(1, 76, 'STU-S230000001', 'S230000001', 53, 115, 'cancelled', NULL, NULL, NULL, NULL, '2026-09-26 02:32:41', 1420, 'system', 'Superseded by new assignment', 1420, '2026-09-26 02:26:00', '2026-09-26 02:32:41'),
(2, 76, 'STU-S230000001', 'S230000001', 53, 115, 'cancelled', NULL, NULL, NULL, NULL, '2026-09-26 02:40:13', 1420, 'system', 'Superseded by new assignment', 1420, '2026-09-26 02:32:41', '2026-09-26 02:40:13'),
(3, 76, 'STU-S230000001', 'S230000001', 53, 115, 'cancelled', NULL, NULL, NULL, NULL, '2026-09-26 02:52:07', 1420, 'system', 'Superseded by new assignment', 1420, '2026-09-26 02:40:13', '2026-09-26 02:52:07'),
(4, 76, 'STU-S230000001', 'S230000001', 53, NULL, 'cancelled', NULL, NULL, NULL, NULL, '2026-09-26 02:54:21', 1420, 'system', 'Superseded by new assignment', 1420, '2026-09-26 02:52:07', '2026-09-26 02:54:21'),
(5, 76, 'STU-S230000001', 'S230000001', 53, 115, 'confirmed', '2026-09-26 03:02:06', 40, '2026-09-26 03:00:37', 54, NULL, NULL, '', NULL, 1420, '2026-09-26 02:54:21', '2026-09-26 03:02:06');

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_clearance_notifications`
--

CREATE TABLE `crad_research_clearance_notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `event_key` varchar(190) NOT NULL,
  `recipient_user_id` int(10) UNSIGNED DEFAULT NULL,
  `recipient_role` varchar(40) NOT NULL DEFAULT '',
  `recipient_email` varchar(190) NOT NULL DEFAULT '',
  `clearance_id` int(10) UNSIGNED DEFAULT NULL,
  `type` varchar(40) NOT NULL DEFAULT '',
  `title` varchar(190) NOT NULL DEFAULT '',
  `body` text DEFAULT NULL,
  `url` varchar(255) NOT NULL DEFAULT '',
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_clearance_payments`
--

CREATE TABLE `crad_research_clearance_payments` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `research_stage` varchar(20) NOT NULL DEFAULT 'research_1',
  `student_user_id` int(10) UNSIGNED DEFAULT NULL,
  `uploaded_file` varchar(255) NOT NULL DEFAULT '',
  `uploaded_blob` mediumblob DEFAULT NULL,
  `uploaded_mime` varchar(100) NOT NULL DEFAULT '',
  `uploaded_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `uploaded_original` varchar(255) NOT NULL DEFAULT '',
  `or_number` varchar(80) NOT NULL DEFAULT '',
  `remarks` varchar(120) NOT NULL DEFAULT '',
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `approved_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `approved_by_name` varchar(160) NOT NULL DEFAULT '',
  `approved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_coordinator_assignments`
--

CREATE TABLE `crad_research_coordinator_assignments` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_id` int(10) UNSIGNED DEFAULT NULL,
  `title_approval_id` int(10) UNSIGNED DEFAULT NULL,
  `proposal_number` varchar(30) DEFAULT NULL,
  `group_number` varchar(40) DEFAULT NULL,
  `group_name` varchar(120) NOT NULL DEFAULT '',
  `research_title` varchar(255) NOT NULL DEFAULT '',
  `student_id` varchar(40) DEFAULT NULL,
  `coordinator_user_id` int(10) UNSIGNED DEFAULT NULL,
  `coordinator_name` varchar(200) NOT NULL DEFAULT '',
  `coordinator_email` varchar(200) NOT NULL DEFAULT '',
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `confirmation_status` varchar(40) NOT NULL DEFAULT 'pending_confirmation',
  `confirmed_at` datetime DEFAULT NULL,
  `confirmed_by` int(10) UNSIGNED DEFAULT NULL,
  `assigned_by` int(10) UNSIGNED DEFAULT NULL,
  `assigned_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `crad_research_coordinator_assignments`
--

INSERT INTO `crad_research_coordinator_assignments` (`id`, `research_group_id`, `proposal_id`, `title_approval_id`, `proposal_number`, `group_number`, `group_name`, `research_title`, `student_id`, `coordinator_user_id`, `coordinator_name`, `coordinator_email`, `status`, `confirmation_status`, `confirmed_at`, `confirmed_by`, `assigned_by`, `assigned_at`, `created_at`, `updated_at`) VALUES
(53, 76, NULL, NULL, NULL, 'STU-S230000001', 'Student User', 'Pending Title Approval', 'S230000001', 40, 'Mrs. Kris Guevarra', 'researchcoordinator@bestlink.edu.ph', 'Active', 'confirmed', '2026-09-26 03:02:06', 40, 1420, '2026-09-26 02:54:21', '2026-09-26 02:09:40', '2026-09-26 03:02:06');

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_defense_schedules`
--

CREATE TABLE `crad_research_defense_schedules` (
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

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_groups`
--

CREATE TABLE `crad_research_groups` (
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
  `flow_status` varchar(40) NOT NULL DEFAULT 'draft',
  `incomplete_reason` text DEFAULT NULL,
  `is_complete` tinyint(1) NOT NULL DEFAULT 0,
  `member_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `min_members_required` int(10) UNSIGNED NOT NULL DEFAULT 3,
  `submitted_by_user_id` int(10) UNSIGNED DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `dh_decision` varchar(20) NOT NULL DEFAULT '',
  `dh_decision_by` int(10) UNSIGNED DEFAULT NULL,
  `dh_decision_at` datetime DEFAULT NULL,
  `dh_remarks` text DEFAULT NULL,
  `date_assigned` date NOT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `crad_research_groups`
--

INSERT INTO `crad_research_groups` (`id`, `proposal_id`, `title_approval_id`, `proposal_number`, `group_number`, `group_name`, `research_title`, `college_dept`, `adviser`, `academic_year`, `leader_name`, `leader_id`, `leader_email`, `leader_contact`, `status`, `flow_status`, `incomplete_reason`, `is_complete`, `member_count`, `min_members_required`, `submitted_by_user_id`, `submitted_at`, `dh_decision`, `dh_decision_by`, `dh_decision_at`, `dh_remarks`, `date_assigned`, `created_by`, `created_at`) VALUES
(76, NULL, NULL, NULL, 'STU-S230000001', 'Student User', 'Pending Title Approval', '', '', '2026-2027', 'Student User', 'S230000001', 's230000001@bestlink.edu.ph', '', 'Pending Assignment', 'ready_for_assignment', NULL, 1, 5, 5, 9, '2026-09-26 00:56:27', 'approved', 1420, '2026-09-26 00:56:44', NULL, '2026-09-26', 9, '2026-09-25 16:41:18');

--
-- Triggers `crad_research_groups`
--
DELIMITER $$
CREATE TRIGGER `trg_research_groups_panel_notifications_after_delete` AFTER DELETE ON `crad_research_groups` FOR EACH ROW BEGIN
                DELETE FROM crad_panel_assignment_notifications
                WHERE research_group_id = OLD.id;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_research_groups_preoral_evals_after_delete` AFTER DELETE ON `crad_research_groups` FOR EACH ROW BEGIN
                DELETE FROM crad_preoral_defense_evaluations
                WHERE research_group_id = OLD.id;
            END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_research_groups_preoral_evaluations_after_delete` AFTER DELETE ON `crad_research_groups` FOR EACH ROW BEGIN
                DELETE FROM crad_preoral_defense_evaluations
                WHERE research_group_id = OLD.id;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_group_members`
--

CREATE TABLE `crad_research_group_members` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `member_order` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `student_id` varchar(40) NOT NULL DEFAULT '',
  `full_name` varchar(160) NOT NULL DEFAULT '',
  `section` varchar(80) NOT NULL DEFAULT '',
  `email` varchar(190) NOT NULL DEFAULT '',
  `or_number` varchar(80) NOT NULL DEFAULT '',
  `is_leader` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `crad_research_group_members`
--

INSERT INTO `crad_research_group_members` (`id`, `research_group_id`, `member_order`, `student_id`, `full_name`, `section`, `email`, `or_number`, `is_leader`, `created_at`, `updated_at`) VALUES
(8, 76, 1, 'S230000001', 'kenneth abejuela', '41005', '', '', 1, '2026-09-26 00:56:27', '2026-09-26 00:56:27'),
(9, 76, 2, 'S230000002', 'simon bernales', '41005', '', '', 0, '2026-09-26 00:56:27', '2026-09-26 00:56:27'),
(10, 76, 3, 'S230000003', 'ivan camacho', '41005', '', '', 0, '2026-09-26 00:56:27', '2026-09-26 00:56:27'),
(11, 76, 4, 'S230000004', 'jopel caday', '410005', '', '', 0, '2026-09-26 00:56:27', '2026-09-26 00:56:27'),
(12, 76, 5, 'S230000005', 'Khen Ausan', '41005', '', '', 0, '2026-09-26 00:56:27', '2026-09-26 00:56:27');

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_milestones`
--

CREATE TABLE `crad_research_milestones` (
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

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_panel_assignments`
--

CREATE TABLE `crad_research_panel_assignments` (
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

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_plans`
--

CREATE TABLE `crad_research_plans` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to research_groups; nullable to preserve history if group is removed',
  `research_title` varchar(500) NOT NULL DEFAULT '',
  `group_number` varchar(40) NOT NULL DEFAULT '',
  `adviser_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_users (adviser)',
  `adviser_name` varchar(150) NOT NULL DEFAULT '',
  `adviser_email` varchar(190) NOT NULL DEFAULT '',
  `start_date` date DEFAULT NULL,
  `target_completion_date` date DEFAULT NULL,
  `current_stage` varchar(100) NOT NULL DEFAULT 'Planning',
  `overall_progress` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Auto-calculated from milestones',
  `status` enum('Active','Completed','On Hold','Cancelled') NOT NULL DEFAULT 'Active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `final_defense_recommended` tinyint(1) NOT NULL DEFAULT 0,
  `final_defense_recommended_by` int(10) UNSIGNED DEFAULT NULL,
  `final_defense_recommended_by_name` varchar(150) DEFAULT NULL,
  `final_defense_recommended_at` datetime DEFAULT NULL,
  `final_defense_recommendation_remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_progress_activity_logs`
--

CREATE TABLE `crad_research_progress_activity_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_plan_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_users',
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
-- Table structure for table `crad_research_progress_ai_analyses`
--

CREATE TABLE `crad_research_progress_ai_analyses` (
  `id` int(10) UNSIGNED NOT NULL,
  `progress_update_id` int(10) UNSIGNED NOT NULL,
  `attachment_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `milestone_name` varchar(180) NOT NULL DEFAULT '',
  `verdict` varchar(40) NOT NULL DEFAULT 'needs_revision',
  `grammar_quality` varchar(40) NOT NULL DEFAULT 'fair',
  `summary` text NOT NULL,
  `notes_json` mediumtext NOT NULL,
  `source` varchar(40) NOT NULL DEFAULT 'cursor',
  `analyzed_by` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `analyzed_by_name` varchar(180) NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_progress_attachments`
--

CREATE TABLE `crad_research_progress_attachments` (
  `id` int(10) UNSIGNED NOT NULL,
  `progress_update_id` int(10) UNSIGNED NOT NULL,
  `file_name` varchar(300) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_type` varchar(100) NOT NULL DEFAULT '',
  `file_size` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Bytes',
  `uploaded_by` int(10) UNSIGNED NOT NULL COMMENT 'FK to sms2_users',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_progress_feedback`
--

CREATE TABLE `crad_research_progress_feedback` (
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
-- Table structure for table `crad_research_progress_notifications`
--

CREATE TABLE `crad_research_progress_notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `recipient_user_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_users.id (NULL = role-based)',
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
-- Table structure for table `crad_research_progress_updates`
--

CREATE TABLE `crad_research_progress_updates` (
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
-- Table structure for table `crad_research_proposals`
--

CREATE TABLE `crad_research_proposals` (
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
  `submitted_by_user` int(10) UNSIGNED DEFAULT NULL COMMENT 'FK to sms2_users (optional)',
  `notes` text DEFAULT NULL COMMENT 'CRAD officer notes',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_revision_cycles`
--

CREATE TABLE `crad_research_revision_cycles` (
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
-- Table structure for table `crad_research_services_clearances`
--

CREATE TABLE `crad_research_services_clearances` (
  `id` int(10) UNSIGNED NOT NULL,
  `research_group_id` int(10) UNSIGNED NOT NULL,
  `research_stage` varchar(20) NOT NULL DEFAULT 'research_1',
  `title_approval_id` int(10) UNSIGNED DEFAULT NULL,
  `status` varchar(40) NOT NULL DEFAULT 'draft',
  `or_number` varchar(80) NOT NULL DEFAULT '',
  `leader_student_no` varchar(40) NOT NULL DEFAULT '',
  `leader_group_no` varchar(40) NOT NULL DEFAULT '',
  `program` varchar(200) NOT NULL DEFAULT '',
  `section` varchar(80) NOT NULL DEFAULT '',
  `research_title` varchar(255) NOT NULL DEFAULT '',
  `members_json` longtext DEFAULT NULL,
  `grammarian_name` varchar(160) NOT NULL DEFAULT '',
  `statistician_name` varchar(160) NOT NULL DEFAULT '',
  `adviser_name` varchar(160) NOT NULL DEFAULT '',
  `adviser_user_id` int(10) UNSIGNED DEFAULT NULL,
  `adviser_email` varchar(190) NOT NULL DEFAULT '',
  `adviser_signature` longtext DEFAULT NULL,
  `adviser_signed_at` datetime DEFAULT NULL,
  `crad_name` varchar(160) NOT NULL DEFAULT '',
  `crad_user_id` int(10) UNSIGNED DEFAULT NULL,
  `crad_signature` longtext DEFAULT NULL,
  `crad_signed_at` datetime DEFAULT NULL,
  `crad_remarks` varchar(500) NOT NULL DEFAULT '',
  `uploaded_file` varchar(255) DEFAULT NULL,
  `uploaded_blob` mediumblob DEFAULT NULL,
  `uploaded_mime` varchar(100) NOT NULL DEFAULT '',
  `uploaded_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `uploaded_original` varchar(255) DEFAULT NULL,
  `uploaded_at` datetime DEFAULT NULL,
  `mis_verified` tinyint(1) NOT NULL DEFAULT 0,
  `aa_verified` tinyint(1) NOT NULL DEFAULT 0,
  `mis_verified_at` datetime DEFAULT NULL,
  `aa_verified_at` datetime DEFAULT NULL,
  `export_hash` varchar(64) NOT NULL DEFAULT '',
  `form_verified` tinyint(1) NOT NULL DEFAULT 0,
  `mis_signature` longtext DEFAULT NULL,
  `aa_signature` longtext DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_research_venues`
--

CREATE TABLE `crad_research_venues` (
  `id` int(10) UNSIGNED NOT NULL,
  `venue_name` varchar(160) NOT NULL,
  `capacity` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `venue_type` varchar(80) NOT NULL DEFAULT '',
  `status` varchar(40) NOT NULL DEFAULT 'Available',
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crad_title_approvals`
--

CREATE TABLE `crad_title_approvals` (
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
-- Triggers `crad_title_approvals`
--
DELIMITER $$
CREATE TRIGGER `trg_title_approvals_after_delete` AFTER DELETE ON `crad_title_approvals` FOR EACH ROW BEGIN
            DELETE FROM crad_research_coordinator_assignments
             WHERE (title_approval_id IS NOT NULL AND title_approval_id = OLD.id)
                OR (OLD.student_id IS NOT NULL AND OLD.student_id <> '' AND student_id = OLD.student_id)
                OR (OLD.student_id IS NOT NULL AND OLD.student_id <> '' AND group_number = CONCAT('STU-', OLD.student_id))
                OR (OLD.proposal_number IS NOT NULL AND OLD.proposal_number <> '' AND proposal_number = OLD.proposal_number);

            DELETE FROM crad_research_adviser_assignments
             WHERE (OLD.student_id IS NOT NULL AND OLD.student_id <> '' AND student_id = OLD.student_id)
                OR (OLD.student_id IS NOT NULL AND OLD.student_id <> '' AND group_number = CONCAT('STU-', OLD.student_id))
                OR (OLD.proposal_number IS NOT NULL AND OLD.proposal_number <> '' AND proposal_number = OLD.proposal_number);
        END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `sms2_activity_logs`
--

CREATE TABLE `sms2_activity_logs` (
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
-- Dumping data for table `sms2_activity_logs`
--

INSERT INTO `sms2_activity_logs` (`id`, `user_id`, `user_name`, `role_key`, `action`, `module_key`, `detail`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:40:17'),
(2, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:40:20'),
(3, 9, 'Student User', 'student', 'research_group_submit', 'System', 'Research Group submitted. Waiting for Department Head approval.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:41:18'),
(4, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:41:50'),
(5, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:41:53'),
(6, 1420, 'Jonathan Kuminga', 'department_head', 'research_group_dh_rejected', 'System', 'Group #76 — Research Group rejected. Student must resubmit.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:42:07'),
(7, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:42:10'),
(8, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:42:13'),
(9, 9, 'Student User', 'student', 'research_group_submit', 'System', 'Research Group submitted. Waiting for Department Head approval.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:42:38'),
(10, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:43:01'),
(11, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:43:04'),
(12, 1420, 'Jonathan Kuminga', 'department_head', 'research_group_dh_rejected', 'System', 'Group #76 — Research Group rejected. Student must resubmit.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:44:07'),
(13, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:44:15'),
(14, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:44:17'),
(15, 9, 'Student User', 'student', 'research_group_submit', 'System', 'Research Group submitted. Waiting for Department Head approval.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:54:14'),
(16, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:54:18'),
(17, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:54:23'),
(18, 1420, 'Jonathan Kuminga', 'department_head', 'research_group_dh_rejected', 'System', 'Group #76 — Research Group rejected. Student must resubmit.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:54:43'),
(19, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:54:46'),
(20, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:54:51'),
(21, 9, 'Student User', 'student', 'research_group_submit', 'System', 'Research Group submitted. Waiting for Department Head approval.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:56:27'),
(22, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:56:34'),
(23, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:56:37'),
(24, 1420, 'Jonathan Kuminga', 'department_head', 'research_group_dh_approved', 'System', 'Group #76 — Research Group approved. Adviser/Coordinator assignment may proceed.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 00:56:44'),
(25, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:04:59'),
(26, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:05:02'),
(27, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:16:07'),
(28, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:16:10'),
(29, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:17:44'),
(30, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:17:49'),
(31, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:18:17'),
(32, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:18:45'),
(33, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:19:03'),
(34, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:19:06'),
(35, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:20:16'),
(36, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:20:54'),
(37, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:36:29'),
(38, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:36:32'),
(39, 9, 'Student User', 'student', 'logout', 'student_portal', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:52:48'),
(40, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 01:52:53'),
(41, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned coordinator \"Mrs. Kris Guevarra\" to student S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:09:40'),
(42, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned research adviser \"Dr. Roberto M. Santos\" to research group STU-S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:26:00'),
(43, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:26:07'),
(44, 54, 'Dr. Roberto M. Santos', 'adviser', 'login', 'faculty', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:26:29'),
(45, 54, 'Dr. Roberto M. Santos', 'adviser', 'assignment_cancel', 'System', 'Cycle #1 - Assignment Declined. Status: Needs Reassignment. Department Head can reassign Coordinator and Adviser.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:26:41'),
(46, 54, 'Dr. Roberto M. Santos', 'adviser', 'logout', 'faculty', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:26:55'),
(47, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:26:59'),
(48, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned coordinator \"Mrs. Kris Guevarra\" to student S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:27:24'),
(49, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:27:35'),
(50, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:27:53'),
(51, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:28:34'),
(52, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:28:38'),
(53, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:29:06'),
(54, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:29:11'),
(55, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:31:47'),
(56, 54, 'Dr. Roberto M. Santos', 'adviser', 'login', 'faculty', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:31:52'),
(57, 54, 'Dr. Roberto M. Santos', 'adviser', 'logout', 'faculty', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:32:15'),
(58, 54, 'Dr. Roberto M. Santos', 'adviser', 'login', 'faculty', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:32:20'),
(59, 54, 'Dr. Roberto M. Santos', 'adviser', 'logout', 'faculty', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:32:30'),
(60, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:32:33'),
(61, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned research adviser \"Dr. Roberto M. Santos\" to research group STU-S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:32:41'),
(62, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:32:44'),
(63, 54, 'Dr. Roberto M. Santos', 'adviser', 'login', 'faculty', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:33:02'),
(64, 54, 'Dr. Roberto M. Santos', 'adviser', 'assignment_cancel', 'System', 'Cycle #2 - Assignment Declined. Status: Needs Reassignment. Department Head can reassign Coordinator and Adviser.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:35:56'),
(65, 54, 'Dr. Roberto M. Santos', 'adviser', 'logout', 'faculty', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:36:04'),
(66, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:36:09'),
(67, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:36:24'),
(68, 3, 'CRAD Officer', 'crad_officer', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:38:17'),
(69, 3, 'CRAD Officer', 'crad_officer', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:39:15'),
(70, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:39:19'),
(71, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned coordinator \"Mrs. Kris Guevarra\" to student S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:39:35'),
(72, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:39:48'),
(73, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:39:54'),
(74, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:40:04'),
(75, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:40:07'),
(76, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned research adviser \"Dr. Roberto M. Santos\" to research group STU-S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:40:13'),
(77, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:40:16'),
(78, 54, 'Dr. Roberto M. Santos', 'adviser', 'login', 'faculty', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:40:19'),
(79, 54, 'Dr. Roberto M. Santos', 'adviser', 'assignment_cancel', 'System', 'Cycle #3 - Assignment Declined. Status: Needs Reassignment. Department Head can reassign Coordinator and Adviser.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:40:57'),
(80, 54, 'Dr. Roberto M. Santos', 'adviser', 'logout', 'faculty', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:41:02'),
(81, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:41:06'),
(82, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned coordinator \"Mrs. Kris Guevarra\" to student S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:44:03'),
(83, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:44:14'),
(84, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:44:17'),
(85, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:46:20'),
(86, 54, 'Dr. Roberto M. Santos', 'adviser', 'login', 'faculty', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:46:29'),
(87, 54, 'Dr. Roberto M. Santos', 'adviser', 'logout', 'faculty', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:47:24'),
(88, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:47:27'),
(89, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:47:48'),
(90, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:47:52'),
(91, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:50:35'),
(92, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:50:38'),
(93, 1420, 'Jonathan Kuminga', 'department_head', 'deactivate', 'crad', 'Coordinator \"Mrs. Kris Guevarra\" assignment for group STU-S230000001 set to Inactive', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:51:29'),
(94, 1420, 'Jonathan Kuminga', 'department_head', 'activate', 'crad', 'Coordinator \"Mrs. Kris Guevarra\" assignment for group STU-S230000001 set to Active', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:51:52'),
(95, 1420, 'Jonathan Kuminga', 'department_head', 'deactivate', 'crad', 'Coordinator \"Mrs. Kris Guevarra\" assignment for group STU-S230000001 set to Inactive', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:51:59'),
(96, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned coordinator \"Mrs. Kris Guevarra\" to student S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:52:07'),
(97, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:52:16'),
(98, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:52:22'),
(99, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'assignment_cancel', 'System', 'Cycle #4 - Assignment Declined. Status: Needs Reassignment. Department Head can reassign Coordinator and Adviser.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:53:11'),
(100, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:53:20'),
(101, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:53:26'),
(102, 1420, 'Jonathan Kuminga', 'department_head', 'activate', 'crad', 'Coordinator \"Mrs. Kris Guevarra\" assignment for group STU-S230000001 set to Active', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:54:03'),
(103, 1420, 'Jonathan Kuminga', 'department_head', 'deactivate', 'crad', 'Coordinator \"Mrs. Kris Guevarra\" assignment for group STU-S230000001 set to Inactive', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:54:12'),
(104, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned coordinator \"Mrs. Kris Guevarra\" to student S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:54:21'),
(105, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:54:24'),
(106, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:54:30'),
(107, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:54:42'),
(108, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:54:46'),
(109, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:59:36'),
(110, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:59:39'),
(111, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 02:59:56'),
(112, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:00:01'),
(113, 1420, 'Jonathan Kuminga', 'department_head', 'assign', 'crad', 'Assigned research adviser \"Dr. Roberto M. Santos\" to research group STU-S230000001', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:00:06'),
(114, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:00:14'),
(115, 54, 'Dr. Roberto M. Santos', 'adviser', 'login', 'faculty', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:00:19'),
(116, 54, 'Dr. Roberto M. Santos', 'adviser', 'assignment_confirm', 'System', 'Cycle #5 - Approval recorded. Waiting for Coordinator.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:00:37'),
(117, 54, 'Dr. Roberto M. Santos', 'adviser', 'logout', 'faculty', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:00:46'),
(118, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:00:51'),
(119, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:01:56'),
(120, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:02:00'),
(121, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'assignment_confirm', 'System', 'Cycle #5 - Fully Assigned. Both Coordinator and Adviser approved. Title Approval may proceed.', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:02:06'),
(122, 40, 'Mrs. Kris Guevarra', 'research_coordinator', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:02:15'),
(123, 1420, 'Jonathan Kuminga', 'department_head', 'login', 'crad', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:02:18'),
(124, 1420, 'Jonathan Kuminga', 'department_head', 'logout', 'crad', 'Logged out', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:02:30'),
(125, 9, 'Student User', 'student', 'login', 'student_portal', 'Logged in successfully', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 03:02:34');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_admin_announcements`
--

CREATE TABLE `sms2_admin_announcements` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `body` text NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `status` enum('published','unpublished') NOT NULL DEFAULT 'published',
  `audience` varchar(40) NOT NULL DEFAULT 'student',
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_by_name` varchar(150) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `published_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sms2_login_throttles`
--

CREATE TABLE `sms2_login_throttles` (
  `id` int(10) UNSIGNED NOT NULL,
  `throttle_key` char(64) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `attempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sms2_password_resets`
--

CREATE TABLE `sms2_password_resets` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_ip` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sms2_password_resets`
--

INSERT INTO `sms2_password_resets` (`id`, `user_id`, `token_hash`, `expires_at`, `used_at`, `created_ip`, `created_at`) VALUES
(2, 1, '550d259303762ee9ce8b5378b3b6b1e212a4b5cf796b005404689bb4c5596866', '2026-08-06 14:05:55', '2026-08-06 13:06:28', '::1', '2026-08-06 13:05:55'),
(3, 9, '691edab739335bc353c7ecaa7d183393ea51e47def723d4f3e68adccdd10fcb9', '2026-08-06 14:18:23', '2026-08-06 13:18:33', '::1', '2026-08-06 13:18:23'),
(4, 9, '55eabae148518a30c44e17552b678572afdda8d79fc2c59f95152780545da52b', '2026-08-06 14:18:33', NULL, '::1', '2026-08-06 13:18:33'),
(5, 1598, '76aa8b71c4cf80db296a44c0cb1fd6e32d7bf202b5e9d8ff343d65b915b61fea', '2026-09-20 23:10:00', '2026-09-20 22:12:05', '::1', '2026-09-20 22:10:00'),
(6, 1598, '24b67e1249a2de27e3a0d29b5796b4ee4b71f5e66e274d94917f07e64c0cfe82', '2026-09-20 23:12:05', '2026-09-20 22:13:33', '::1', '2026-09-20 22:12:05'),
(7, 1598, 'd01e65d1afce7a7c79b4a884dbeba9b240ae4c02255297ee0bfa8ba8a9e69e8f', '2026-09-20 23:13:33', '2026-09-20 23:36:35', '::1', '2026-09-20 22:13:33'),
(8, 1598, 'e2133532d56fd6d2686f992bb96370f45af74b8382b2ce80d21fe1f38a861303', '2026-09-21 00:36:35', '2026-09-20 23:56:12', '::1', '2026-09-20 23:36:35'),
(9, 1598, '4342674130566ecb2408575b9223e015fdf7442d2be2cb2aec72788a044bfd1f', '2026-09-21 00:56:12', '2026-09-21 00:02:02', '::1', '2026-09-20 23:56:12'),
(10, 1598, 'e45930b9b41d8be9c07d0bcf54360acc5d97c853908582587b8bae30c6b0f5a1', '2026-09-21 01:02:02', '2026-09-21 00:02:39', '::1', '2026-09-21 00:02:02'),
(11, 1598, 'd4a9c0fd9b262c25b7c5530c7f3b652d32eea94b980947306d08752fa3aa837c', '2026-09-21 01:02:39', NULL, '::1', '2026-09-21 00:02:39'),
(12, 1354, 'f62dc31004f6594f3e43e6b81ff2d17d7a235c6c8de8c9d7c4763a7b5c64c807', '2026-09-21 01:08:51', '2026-09-21 00:11:42', '::1', '2026-09-21 00:08:51'),
(13, 1354, '6863d2663b7d31e1a97dd63e7b678d13e13ee6e3cd3891fdbfde5b93db70817b', '2026-09-21 01:11:42', NULL, '::1', '2026-09-21 00:11:42');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_password_reset_requests`
--

CREATE TABLE `sms2_password_reset_requests` (
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

--
-- Dumping data for table `sms2_password_reset_requests`
--

INSERT INTO `sms2_password_reset_requests` (`id`, `user_id`, `module_key`, `reason`, `requested_password_hash`, `status`, `admin_id`, `admin_note`, `temp_password_set`, `created_at`, `resolved_at`) VALUES
(1, 1598, 'student_portal', 'lost details', NULL, 'approved', 1, NULL, 0, '2026-09-20 22:30:13', '2026-09-20 22:31:50');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_roles`
--

CREATE TABLE `sms2_roles` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `role_key` varchar(40) NOT NULL,
  `label` varchar(80) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sms2_roles`
--

INSERT INTO `sms2_roles` (`id`, `role_key`, `label`, `description`, `is_system`, `created_at`) VALUES
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
(56, 'research_coordinator', 'Research Coordinator', 'Research coordination access', 1, '2026-08-08 18:13:51'),
(102, 'adviser', 'Adviser', 'Research adviser faculty account', 1, '2026-08-08 21:35:14'),
(213, 'research_director', 'Research Director', 'Research defense scheduling director account', 1, '2026-08-09 19:31:14'),
(384, 'research_grant', 'CRAD Officer', 'Research grant management access', 1, '2026-08-10 20:01:49'),
(770, 'grammarian', 'Grammarian', 'Research grammar and manuscript evaluation account', 1, '2026-08-14 11:06:49'),
(788, 'panel', 'Panel Member', 'Research defense panel account', 1, '2026-08-15 17:07:16'),
(800, 'sms_admin', 'Admin', 'General administrator account', 1, '2026-08-18 00:38:50'),
(901, 'review_committee', 'Review Committee', 'Grant proposal review and rubric evaluation', 1, '2026-08-31 07:04:35'),
(1206, 'department_chair', 'Department Chair', 'Grant approval — department chair sign-off', 1, '2026-08-31 10:29:00'),
(1207, 'research_office', 'Research Office', 'Grant approval — research office sign-off', 1, '2026-08-31 10:29:00'),
(1208, 'vpaa', 'VPAA', 'Grant approval — VPAA sign-off', 1, '2026-08-31 10:29:00'),
(1686, 'department_head', 'Department Head', 'Adviser and panel assignment', 1, '2026-09-19 01:01:39');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_role_permissions`
--

CREATE TABLE `sms2_role_permissions` (
  `id` int(10) UNSIGNED NOT NULL,
  `role_key` varchar(40) NOT NULL,
  `module_key` varchar(60) NOT NULL,
  `granted` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sms2_role_permissions`
--

INSERT INTO `sms2_role_permissions` (`id`, `role_key`, `module_key`, `granted`, `updated_at`) VALUES
(1156, 'superadmin', 'user-management', 1, '2026-08-31 10:29:00'),
(1157, 'admission', 'enrollment', 1, '2026-08-31 10:29:00'),
(1158, 'registrar', 'registrar', 1, '2026-08-31 10:29:00'),
(1159, 'registrar', 'curriculum', 1, '2026-08-31 10:29:00'),
(1160, 'registrar', 'scheduling', 1, '2026-08-31 10:29:00'),
(1161, 'crad_officer', 'crad', 1, '2026-08-31 10:29:00'),
(1162, 'research_coordinator', 'crad', 1, '2026-08-31 10:29:00'),
(1163, 'department_chair', 'crad', 1, '2026-08-31 10:29:00'),
(1164, 'research_office', 'crad', 1, '2026-08-31 10:29:00'),
(1165, 'research_director', 'faculty', 1, '2026-08-31 10:29:00'),
(1166, 'grammarian', 'faculty', 1, '2026-08-31 10:29:00'),
(1167, 'review_committee', 'crad_grant', 1, '2026-08-31 10:29:00'),
(1168, 'panel', 'faculty', 1, '2026-08-31 10:29:00'),
(1169, 'finance', 'payment', 1, '2026-08-31 10:29:00'),
(1170, 'osa', 'cocurricular', 1, '2026-08-31 10:29:00'),
(1171, 'it_office', 'lms', 1, '2026-08-31 10:29:00'),
(1172, 'qa', 'accreditation', 1, '2026-08-31 10:29:00'),
(1173, 'vpaa', 'accreditation', 1, '2026-08-31 10:29:00'),
(1174, 'hr', 'faculty', 1, '2026-08-31 10:29:00'),
(1175, 'student', 'student_portal', 1, '2026-08-31 10:29:00'),
(1179, 'sms_admin', 'enrollment', 1, '2026-09-18 22:08:12'),
(1180, 'sms_admin', 'registrar', 1, '2026-09-18 22:08:12'),
(1181, 'sms_admin', 'curriculum', 1, '2026-09-18 22:08:12'),
(1182, 'sms_admin', 'accreditation', 1, '2026-09-18 22:08:12'),
(1183, 'sms_admin', 'payment', 1, '2026-09-18 22:08:12'),
(1184, 'sms_admin', 'faculty', 1, '2026-09-18 22:08:12'),
(1185, 'sms_admin', 'scheduling', 1, '2026-09-18 22:08:12'),
(1186, 'sms_admin', 'cocurricular', 1, '2026-09-18 22:08:12'),
(1187, 'sms_admin', 'lms', 1, '2026-09-18 22:08:12'),
(1188, 'sms_admin', 'crad', 1, '2026-09-18 22:08:12'),
(1189, 'adviser', 'faculty', 1, '2026-08-31 10:29:24'),
(1193, 'research_grant', 'crad_grant', 1, '2026-08-31 10:29:24'),
(1945, 'department_head', 'crad', 1, '2026-09-19 01:01:39');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_security_otps`
--

CREATE TABLE `sms2_security_otps` (
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
-- Dumping data for table `sms2_security_otps`
--

INSERT INTO `sms2_security_otps` (`id`, `user_id`, `purpose`, `code_hash`, `module_key`, `expires_at`, `used_at`, `created_at`) VALUES
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
(32, 1, 'passkey_remove', 'df8c90265057ad814bde1ac13e69cd5d1aa480375cd8a00f9e9b4a29e917b7fe', NULL, '2026-08-07 14:33:29', NULL, '2026-08-07 14:23:29'),
(33, 1598, 'auth_setup', '3a33bc749930d47eaddc966845e47ba858999f823194644d34c960ee30d7949e', NULL, '2026-09-20 22:24:42', NULL, '2026-09-20 22:14:42'),
(34, 990, 'login_2fa', 'f2d1fe1efaa6ec1695f737c8379831f6de7e1fd9bc6aee75c4890ed0c7ab3811', 'System', '2026-09-20 22:27:31', NULL, '2026-09-20 22:17:31'),
(35, 1354, 'forgot_password', '1a5fa25ed0adabc030b602d0f921b9ce8f4d350b8fba6381cbee96f7bc5ca373', 'login-forgot', '2026-09-21 00:18:39', '2026-09-21 00:26:43', '2026-09-21 00:16:39'),
(36, 1354, 'forgot_password', '8b45b16bb853409ac86cc3cca6a933ceafeb608bb7a31c19a723f5ad5bd594bd', 'login-forgot', '2026-09-21 00:28:43', '2026-09-21 00:31:15', '2026-09-21 00:26:43'),
(37, 1354, 'forgot_password', '6d20a1134df48b669a3446d654537785a481d178b82bfbb36e1ee92c0dbe8a44', 'login-forgot', '2026-09-21 00:33:15', '2026-09-21 00:33:23', '2026-09-21 00:31:15'),
(38, 1354, 'forgot_password', 'dfb4b4fd2aad5e510728bf4c794cc9ff4ce84ec51e2d29a96f1ba3d8c5c6eac6', 'login-forgot', '2026-09-21 00:35:23', '2026-09-21 00:34:09', '2026-09-21 00:33:23'),
(39, 1354, 'forgot_password', '37d4c8664ab63d82e6fd5ef93b23f1f2fd833d31ed28850ae637a4330a228397', 'login-forgot', '2026-09-21 00:36:09', '2026-09-21 00:34:32', '2026-09-21 00:34:09'),
(40, 1354, 'forgot_password', '19e05e49501875540ed47100e2c58275f57af67bab37e15b1c560d927f71710b', 'login-forgot', '2026-09-21 00:36:32', '2026-09-21 00:34:45', '2026-09-21 00:34:32');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_student_profiles`
--

CREATE TABLE `sms2_student_profiles` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `student_id` varchar(40) NOT NULL,
  `program` varchar(200) NOT NULL DEFAULT 'Bachelor of Science in Information Technology',
  `year_level` varchar(40) NOT NULL DEFAULT '4th Year',
  `section` varchar(40) NOT NULL DEFAULT 'BSIT 4A',
  `semester` varchar(40) NOT NULL DEFAULT '1st Semester',
  `school_year` varchar(20) NOT NULL DEFAULT '2026-2027',
  `enrollment_status` varchar(40) NOT NULL DEFAULT 'Enrolled',
  `standing` varchar(40) NOT NULL DEFAULT 'Good Standing',
  `mobile` varchar(40) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `guardian` varchar(150) DEFAULT NULL,
  `guardian_contact` varchar(40) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sms2_student_profiles`
--

INSERT INTO `sms2_student_profiles` (`id`, `user_id`, `student_id`, `program`, `year_level`, `section`, `semester`, `school_year`, `enrollment_status`, `standing`, `mobile`, `address`, `guardian`, `guardian_contact`, `created_at`, `updated_at`) VALUES
(1, 9, 'S230000001', 'Bachelor of Science in Information Technology', '4th Year', 'BSIT 4B', '1st Semester', '2026-2027', 'Enrolled', 'Good Standing', '0917 000 0011', 'Fairview, Quezon City', 'Juan Dela Cruz', '0918 000 0012', '2026-09-19 00:29:23', '2026-09-19 00:29:23'),
(2, 1354, 'S230106713', 'Bachelor of Science in Information Technology', '4th Year', 'BSIT 4A', '1st Semester', '2026-2027', 'Enrolled', 'Good Standing', '0917 000 0001', 'Novaliches, Quezon City', 'Maria Dela Cruz', '0918 000 0002', '2026-09-19 00:29:23', '2026-09-19 00:29:23'),
(3, 1558, 'S240115700', 'Bachelor of Science in Information Technology', '4th Year', 'BSIT 4A', '1st Semester', '2026-2027', 'Enrolled', 'Good Standing', '', '', '', '', '2026-09-20 21:13:12', '2026-09-20 21:13:12'),
(4, 1564, 'S230106714', 'Bachelor of Science in Information Technology', '4th Year', 'BSIT 4A', '1st Semester', '2026-2027', 'Enrolled', 'Good Standing', '', '', '', '', '2026-09-20 21:13:55', '2026-09-20 21:13:55');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_system_settings`
--

CREATE TABLE `sms2_system_settings` (
  `setting_key` varchar(80) NOT NULL,
  `setting_value` text NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sms2_system_settings`
--

INSERT INTO `sms2_system_settings` (`setting_key`, `setting_value`, `updated_at`) VALUES
('crad_active_term', '', '2026-08-28 07:17:54'),
('csrf_enabled', '1', '2026-07-22 22:24:44'),
('lockout_minutes', '1', '2026-07-23 08:05:06'),
('lockout_seconds', '15', '2026-07-23 08:05:06'),
('lockout_unit', 'seconds', '2026-07-23 08:05:06'),
('lockout_value', '15', '2026-07-23 08:05:06'),
('login_captcha_enabled', '1', '2026-09-20 22:39:57'),
('mail_admin_email', 'kennethabejuela0308@gmail.com', '2026-09-21 00:25:26'),
('mail_from_email', 'kennethabejuela0308@gmail.com', '2026-09-21 00:25:26'),
('mail_from_name', 'BCP', '2026-09-21 00:25:26'),
('mail_show_link_on_failure', '1', '2026-09-20 23:40:19'),
('max_failed_logins', '3', '2026-07-23 07:33:05'),
('min_password_length', '8', '2026-07-22 22:24:44'),
('module_kick_epoch_crad', '1784849304', '2026-07-23 15:28:24'),
('module_maintenance_crad', '0', '2026-07-23 15:29:22'),
('module_maintenance_msg_crad', 'The system is currently under maintenance. Some services may be temporarily unavailable.\r\n\r\nThank you for your patience and understanding.', '2026-07-23 15:05:14'),
('module_maintenance_student_portal', '0', '2026-09-20 22:35:46'),
('password_expiry_days', '0', '2026-07-22 22:24:44'),
('require_password_change_first_login', '0', '2026-07-22 22:24:44'),
('session_timeout_minutes', '30', '2026-09-21 02:07:26'),
('smtp_encryption', 'tls', '2026-07-23 10:33:25'),
('smtp_host', 'smtp.gmail.com', '2026-07-23 10:51:48'),
('smtp_password', 'sms2enc1.Oa0f+lo0nzQC028oI5zSiNa6z6C83V62Rv132wC9nACe36djJjr19CcL9Bs=', '2026-09-21 00:25:26'),
('smtp_port', '587', '2026-07-23 10:33:25'),
('smtp_username', 'kennethabejuela0308@gmail.com', '2026-09-21 00:25:26'),
('turnstile_site_key', '', '2026-09-20 22:39:57');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_users`
--

CREATE TABLE `sms2_users` (
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
-- Dumping data for table `sms2_users`
--

INSERT INTO `sms2_users` (`id`, `username`, `email`, `password_hash`, `full_name`, `role_key`, `student_id`, `status`, `must_change_password`, `failed_login_attempts`, `locked_until`, `password_changed_at`, `last_login_at`, `last_seen_at`, `last_login_ip`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'superadmin', 'j14677365@gmail.com', '$2y$10$a4NaRWDw7.1Jt2ps9MNI.uodIEoJfOZGqRflwoapW9OtP8e7SKAoC', 'Super Admin', 'superadmin', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-21 01:28:42', '2026-09-21 18:13:11', '::1', NULL, '2026-07-22 22:53:59', '2026-09-21 02:13:11'),
(2, 'registrar', 'registrar@bestlink.edu.ph', '$2y$10$/HmOuAP54dAuUkNOyNJo/e2GwrAszJqpF0sQmGvjofAtM/.6tcp.m', 'Registrar', 'registrar', NULL, 'active', 0, 0, NULL, '2026-08-31 07:50:19', '2026-08-08 22:06:54', NULL, '::1', NULL, '2026-07-22 22:53:59', '2026-08-31 10:23:26'),
(3, 'cradofficer', 'cradofficer@bestlink.ph', '$2y$10$IpnqwpL9JnMUhHbSOgfxJ.4ra3ccLSYj/jBiRdE5ZcdxVliR2HA3K', 'CRAD Officer', 'crad_officer', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-26 02:38:17', NULL, '::1', 'sdada', '2026-07-22 22:53:59', '2026-09-26 02:39:15'),
(4, 'finance', 'finance@bestlink.edu.ph', '$2y$10$DRoqe4euabvGssHKV0nAoeRBxT4pkP1yVa2NIiND4LYfUJq7VKVRe', 'Finance', 'finance', NULL, 'active', 0, 0, NULL, '2026-08-31 12:10:16', '2026-09-18 03:30:16', NULL, '::1', NULL, '2026-07-22 22:54:00', '2026-09-18 03:31:00'),
(5, 'studentaffairs', 'studentaffairs@bestlink.edu.ph', '$2y$10$ykS9zsSeg8ESbJDrnyaixuRg.OYKWUljfEzgDhwBWsn4MYjdRR9O2', 'Student Affairs', 'osa', NULL, 'active', 0, 0, NULL, '2026-08-31 07:50:19', NULL, NULL, NULL, NULL, '2026-07-22 22:54:00', '2026-08-31 10:23:26'),
(6, 'itofficer', 'itofficer@bestlink.edu.ph', '$2y$10$h1GQBrr0K5SM8whZCT2QxOmvpIN2aPKslctCSX3VMflxoiHVIdWGC', 'IT Officer', 'it_office', NULL, 'active', 0, 0, NULL, '2026-08-31 07:50:19', NULL, NULL, NULL, NULL, '2026-07-22 22:54:00', '2026-08-31 10:23:26'),
(7, 'qualityassurance', 'qualityassurance@bestlink.edu.ph', '$2y$10$cqKm0cN1jMdxpdS5l3yee.ygI3KG05tRBGw5cyagSwNFT.6YaytVq', 'Quality Assurance', 'qa', NULL, 'active', 0, 0, NULL, '2026-08-31 07:50:20', NULL, NULL, NULL, NULL, '2026-07-22 22:54:00', '2026-08-31 10:23:26'),
(8, 'dean', 'dean@bestlink.edu.ph', '$2y$10$ADDDVUeDkcHKTZ90VfeuIOOaEFdFBcybnJNFT.QIMWYcEGnm9cf1m', 'Dean', 'hr', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-18 03:28:45', NULL, '::1', NULL, '2026-07-22 22:54:00', '2026-09-18 03:29:01'),
(9, 's230000001', 's230000001@bestlink.edu.ph', '$2y$10$A94r731PvDnsBaltuho/quGmMR6T6TvsBh5feQx6d6avkQILTNvW2', 'Student User', 'student', 'S230000001', 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-26 03:02:34', '2026-09-26 03:13:58', '::1', NULL, '2026-07-22 22:54:00', '2026-09-26 03:13:58'),
(20, 'admission', 'admission@bestlink.edu.ph', '$2y$10$1M./oyAWOwzHhIjWoxGCWu5wm/6F/Jc3bzmYeF7hLt/jnhzg6KW9u', 'Admission', 'admission', NULL, 'active', 0, 0, NULL, '2026-08-31 07:50:19', NULL, NULL, NULL, NULL, '2026-08-08 17:25:20', '2026-08-31 10:23:26'),
(40, 'researchcoordinator', 'researchcoordinator@bestlink.edu.ph', '$2y$10$cC78.kC9YWDKQmoQ/BhG3Ou5wNb/rCaLooIiMLhwjV05e05w5nC3C', 'Mrs. Kris Guevarra', 'research_coordinator', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-26 03:02:00', NULL, '::1', NULL, '2026-08-08 18:09:48', '2026-09-26 03:02:15'),
(54, 'rsantos', 'rsantos@bestlink.edu.ph', '$2y$10$b/pnRSE8GFojLln4g5It9u946pzW57evxzWArhQso9oUxeqappwYq', 'Dr. Roberto M. Santos', 'adviser', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-26 03:00:19', NULL, '::1', NULL, '2026-08-08 21:35:14', '2026-09-26 03:00:46'),
(475, 'grammarian', 'grammarian@bestlink.edu.ph', '$2y$10$5hr6Wv2B84sMn2aCFcqB6u/36lx8QHnep5c7BJRMd3GyKhAH4xAwi', 'Kyle Kuzma', 'grammarian', NULL, 'active', 0, 0, NULL, '2026-09-19 10:03:34', '2026-09-21 01:25:11', NULL, '::1', NULL, '2026-08-14 11:06:49', '2026-09-21 01:28:06'),
(491, 'jobertvalentino', 'jobertvalentino@bestlink.edu.ph', '$2y$10$ouhKTKDlt29J1UyCrPm9r.I31sv6i4DE/r.mKPbhwK7TVtuxqS0Fm', 'Dr. Jobert Valentino', 'panel', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:13', '2026-09-21 02:15:15', NULL, '::1', NULL, '2026-08-15 17:07:16', '2026-09-21 02:15:32'),
(492, 'jonathanestrada', 'jonathanestrada@bestlink.edu.ph', '$2y$10$dQsnxqrSSWWl2gr3YgFqOuFgS4Z18E1MHOqAh51hhhL3mLFgbnAbS', 'Dr. Jonathan Estrada', 'panel', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:13', '2026-09-21 02:15:41', NULL, '::1', NULL, '2026-08-15 17:07:16', '2026-09-21 02:19:17'),
(493, 'michelleguevarra', 'michelleguevarra@bestlink.edu.ph', '$2y$10$YGhw2uzbxt6ENl46DQ8LkekrJ7Rd5o.mUy/TbNBg/bUUqFD5rfRym', 'Dr. Michelle Guevarra', 'panel', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:13', '2026-09-19 12:35:59', NULL, '::1', NULL, '2026-08-15 17:07:16', '2026-09-19 12:36:03'),
(758, 'admin', 'admin@bestlink.edu.ph', '$2y$10$MkfbK0pT7baUocnxCt9NBONcL1yxJ3SeVBmIBuIWRPRFr1CwUfQCG', 'Admin', 'sms_admin', NULL, 'active', 0, 0, NULL, '2026-09-21 01:28:58', '2026-09-21 02:13:51', NULL, '::1', NULL, '2026-08-18 00:38:50', '2026-09-21 02:14:13'),
(766, 'reviewcommittee', 'reviewcommittee@bestlink.edu.ph', '$2y$10$6iOIYjb89i9ErroqSX/u9ur7qyw2u8zausvK16nSPHkRotXFek8Ne', 'Review Committee', 'review_committee', NULL, 'active', 0, 0, NULL, '2026-09-19 01:26:53', '2026-09-19 01:31:07', NULL, '::1', NULL, '2026-08-31 07:04:36', '2026-09-19 01:31:15'),
(990, 'deptchair', 'deptchair@bestlink.edu.ph', '$2y$10$..8x.zJiNd8J7Nt.ayYpSO4n0okueUM9YcV0KErvmqbS6LcfHi4h6', 'Dr. Joseph Alcantara', 'department_chair', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-21 02:14:45', NULL, '::1', NULL, '2026-08-31 10:19:39', '2026-09-21 02:15:07'),
(991, 'researchoffice', 'researchoffice@bestlink.edu.ph', '$2y$10$Yjc6RQ6xI9hfWhDi5L6X..mXC3B3DE2r1H0xwSvqeyaQlw.tkuzVu', 'Research Office', 'research_office', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-18 03:29:13', NULL, '::1', NULL, '2026-08-31 10:19:39', '2026-09-18 03:29:38'),
(992, 'vpaa', 'vpaa@bestlink.edu.ph', '$2y$10$aBDCU/R1ICzX.oy1SOwT6.pnhhRxRKI4fXGBMM0Wm1mUOPgc/Ae5W', 'VPAA', 'vpaa', NULL, 'active', 0, 0, NULL, '2026-08-31 10:56:14', '2026-09-18 03:29:44', NULL, '::1', NULL, '2026-08-31 10:19:39', '2026-09-18 03:30:09'),
(1354, 's230106713', 'kennethabejuela0308@gmail.com', '$2y$10$hlVtDsX6ruX3NjLwkUeRA.Fel8OfC3MQ3p0Nvz93.tAu3COgbW.Cm', 'John Kenneth Abejuela', 'student', 'S230106713', 'active', 0, 0, NULL, '2026-09-18 21:37:23', '2026-09-21 01:52:30', '2026-09-21 18:33:55', '::1', NULL, '2026-09-18 21:37:23', '2026-09-21 02:33:55'),
(1420, 'depthead', 'depthead@bestlink.edu.ph', '$2y$10$YzKfWRJjdgH7RWtPzle5cest5VbF9VizUzo8O4wGGgbg.OFMvJxSu', 'Jonathan Kuminga', 'department_head', NULL, 'active', 0, 0, NULL, '2026-09-19 01:27:09', '2026-09-26 03:02:18', NULL, '::1', NULL, '2026-09-19 01:01:39', '2026-09-26 03:02:30'),
(1598, 's230106714', 'kenlangmalakas0308@gmail.com', '$2y$10$LAIyCyd4dEGPMcETU7IFxeE/fa3VYtsHLp2rLq4Gh4v8EbjK9B5XC', 'Jopel Caday', 'student', 'S230106714', 'active', 0, 1, NULL, '2026-09-20 22:31:50', '2026-09-20 23:09:19', NULL, '::1', NULL, '2026-09-20 21:15:17', '2026-09-21 00:07:29');

-- --------------------------------------------------------

--
-- Table structure for table `sms2_user_authenticators`
--

CREATE TABLE `sms2_user_authenticators` (
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
-- Table structure for table `sms2_user_passkeys`
--

CREATE TABLE `sms2_user_passkeys` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `credential_id` varchar(1024) NOT NULL,
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
-- Indexes for table `crad_chapter_evaluations`
--
ALTER TABLE `crad_chapter_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_chapter_evaluation_submission` (`submission_id`),
  ADD KEY `idx_chapter_eval_evaluator` (`evaluator_user_id`),
  ADD KEY `idx_chapter_eval_group` (`research_group_id`),
  ADD KEY `idx_chapter_eval_created` (`created_at`);

--
-- Indexes for table `crad_chapter_evaluation_notifications`
--
ALTER TABLE `crad_chapter_evaluation_notifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_chapter_notification_event` (`event_key`),
  ADD KEY `idx_chapter_notification_recipient` (`recipient_user_id`,`recipient_role`,`recipient_email`),
  ADD KEY `idx_chapter_notification_submission` (`submission_id`),
  ADD KEY `idx_chapter_notification_created` (`created_at`);

--
-- Indexes for table `crad_chapter_submissions`
--
ALTER TABLE `crad_chapter_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_chapter_version` (`research_group_id`,`chapter_number`,`version_number`),
  ADD UNIQUE KEY `uniq_chapter_token` (`submission_token`),
  ADD KEY `idx_chapter_status` (`status`),
  ADD KEY `idx_chapter_group` (`research_group_id`),
  ADD KEY `idx_chapter_student` (`submitted_by_user`),
  ADD KEY `idx_chapter_updated` (`updated_at`);

--
-- Indexes for table `crad_chapter_submission_history`
--
ALTER TABLE `crad_chapter_submission_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_chapter_history_submission` (`submission_id`),
  ADD KEY `idx_chapter_history_group` (`research_group_id`),
  ADD KEY `idx_chapter_history_created` (`created_at`);

--
-- Indexes for table `crad_final_defense_evaluations`
--
ALTER TABLE `crad_final_defense_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_final_panel_submission` (`defense_schedule_id`,`panel_user_id`),
  ADD KEY `idx_final_group` (`research_group_id`),
  ADD KEY `idx_final_panel` (`panel_user_id`),
  ADD KEY `idx_final_status` (`status`);

--
-- Indexes for table `crad_final_defense_recommendations`
--
ALTER TABLE `crad_final_defense_recommendations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_fdr_group` (`research_group_id`),
  ADD KEY `idx_fdr_status` (`status`);

--
-- Indexes for table `crad_final_manuscript_approvals`
--
ALTER TABLE `crad_final_manuscript_approvals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_fma_group` (`research_group_id`);

--
-- Indexes for table `crad_grant_applications`
--
ALTER TABLE `crad_grant_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_ga_token` (`submission_token`),
  ADD KEY `idx_ga_opportunity` (`grant_opportunity_id`),
  ADD KEY `idx_ga_group` (`research_group_id`),
  ADD KEY `idx_ga_status` (`status`),
  ADD KEY `idx_ga_submitted` (`submitted_at`);

--
-- Indexes for table `crad_grant_document_repository`
--
ALTER TABLE `crad_grant_document_repository`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gdr_application` (`grant_application_id`),
  ADD KEY `idx_gdr_reference` (`archive_reference`),
  ADD KEY `idx_gdr_archived` (`archived_at`);

--
-- Indexes for table `crad_grant_document_repository_items`
--
ALTER TABLE `crad_grant_document_repository_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_gdri_repository` (`repository_id`),
  ADD KEY `idx_gdri_application` (`grant_application_id`),
  ADD KEY `idx_gdri_category` (`category`);

--
-- Indexes for table `crad_grant_final_output_submissions`
--
ALTER TABLE `crad_grant_final_output_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gfos_application` (`grant_application_id`),
  ADD KEY `idx_gfos_status` (`status`),
  ADD KEY `idx_gfos_submitted` (`submitted_at`);

--
-- Indexes for table `crad_grant_funded_progress_evidence`
--
ALTER TABLE `crad_grant_funded_progress_evidence`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_gfpe_application` (`grant_application_id`),
  ADD KEY `idx_gfpe_milestone` (`milestone_id`),
  ADD KEY `idx_gfpe_created` (`created_at`);

--
-- Indexes for table `crad_grant_funded_project_milestones`
--
ALTER TABLE `crad_grant_funded_project_milestones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gfpm_app_order` (`grant_application_id`,`milestone_order`),
  ADD KEY `idx_gfpm_application` (`grant_application_id`),
  ADD KEY `idx_gfpm_status` (`status`);

--
-- Indexes for table `crad_grant_funding_disbursements`
--
ALTER TABLE `crad_grant_funding_disbursements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gfd_app_tranche` (`grant_application_id`,`tranche_number`),
  ADD KEY `idx_gfd_application` (`grant_application_id`),
  ADD KEY `idx_gfd_status` (`status`);

--
-- Indexes for table `crad_grant_opportunities`
--
ALTER TABLE `crad_grant_opportunities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_go_status` (`status`),
  ADD KEY `idx_go_deadline` (`application_deadline`),
  ADD KEY `idx_go_created_by` (`created_by_user_id`);

--
-- Indexes for table `crad_grant_proposal_approval_steps`
--
ALTER TABLE `crad_grant_proposal_approval_steps`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gpas_workflow_step` (`workflow_id`,`step_key`),
  ADD KEY `idx_gpas_application` (`grant_application_id`),
  ADD KEY `idx_gpas_status` (`status`),
  ADD KEY `idx_gpas_role` (`approver_role_key`);

--
-- Indexes for table `crad_grant_proposal_approval_workflows`
--
ALTER TABLE `crad_grant_proposal_approval_workflows`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gpaw_application` (`grant_application_id`),
  ADD KEY `idx_gpaw_status` (`workflow_status`),
  ADD KEY `idx_gpaw_current_step` (`current_step_key`);

--
-- Indexes for table `crad_grant_proposal_evaluations`
--
ALTER TABLE `crad_grant_proposal_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gpe_app_eval_ver` (`grant_application_id`,`evaluator_user_id`,`proposal_version`),
  ADD KEY `idx_gpe_application` (`grant_application_id`),
  ADD KEY `idx_gpe_evaluator` (`evaluator_user_id`),
  ADD KEY `idx_gpe_submitted` (`submitted_at`);

--
-- Indexes for table `crad_grant_proposal_notifications`
--
ALTER TABLE `crad_grant_proposal_notifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gpn_event` (`event_key`),
  ADD KEY `idx_gpn_recipient_user` (`recipient_user_id`),
  ADD KEY `idx_gpn_application` (`grant_application_id`),
  ADD KEY `idx_gpn_created` (`created_at`);

--
-- Indexes for table `crad_grant_proposal_versions`
--
ALTER TABLE `crad_grant_proposal_versions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gpv_app_ver` (`grant_application_id`,`version_number`),
  ADD KEY `idx_gpv_application` (`grant_application_id`),
  ADD KEY `idx_gpv_submitted` (`submitted_at`);

--
-- Indexes for table `crad_grant_publications_ip_repository`
--
ALTER TABLE `crad_grant_publications_ip_repository`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_gpip_application` (`grant_application_id`),
  ADD KEY `idx_gpip_reference` (`repository_reference`),
  ADD KEY `idx_gpip_verified` (`verified_at`);

--
-- Indexes for table `crad_manuscript_evaluations`
--
ALTER TABLE `crad_manuscript_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_meval_submission` (`submission_id`),
  ADD KEY `idx_meval_group` (`research_group_id`);

--
-- Indexes for table `crad_manuscript_submissions`
--
ALTER TABLE `crad_manuscript_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_manuscript_version` (`research_group_id`,`version_number`),
  ADD UNIQUE KEY `uniq_manuscript_token` (`submission_token`),
  ADD KEY `idx_manuscript_status` (`status`),
  ADD KEY `idx_manuscript_group` (`research_group_id`);

--
-- Indexes for table `crad_panel_assignment_notifications`
--
ALTER TABLE `crad_panel_assignment_notifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_panel_assignment_notification` (`event_key`),
  ADD KEY `idx_panel_notification_recipient` (`recipient_user_id`,`recipient_role`,`recipient_email`),
  ADD KEY `idx_panel_notification_created` (`created_at`);

--
-- Indexes for table `crad_panel_member_availability`
--
ALTER TABLE `crad_panel_member_availability`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_panel_availability_user` (`panel_user_id`),
  ADD KEY `idx_panel_availability_status` (`availability_status`);

--
-- Indexes for table `crad_preoral_defense_evaluations`
--
ALTER TABLE `crad_preoral_defense_evaluations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_preoral_panel_submission` (`defense_schedule_id`,`panel_user_id`),
  ADD KEY `idx_preoral_group` (`research_group_id`),
  ADD KEY `idx_preoral_panel` (`panel_user_id`),
  ADD KEY `idx_preoral_status` (`status`);

--
-- Indexes for table `crad_proposal_documents`
--
ALTER TABLE `crad_proposal_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pd_proposal` (`proposal_id`);

--
-- Indexes for table `crad_proposal_drafts`
--
ALTER TABLE `crad_proposal_drafts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_proposal_draft_student_type` (`student_id`,`form_type`);

--
-- Indexes for table `crad_proposal_members`
--
ALTER TABLE `crad_proposal_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_proposal` (`proposal_id`);

--
-- Indexes for table `crad_proposal_status_logs`
--
ALTER TABLE `crad_proposal_status_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_psl_proposal` (`proposal_id`);

--
-- Indexes for table `crad_publications`
--
ALTER TABLE `crad_publications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pub_group` (`research_group_id`),
  ADD KEY `idx_pub_status` (`status`);

--
-- Indexes for table `crad_research_adviser_assignments`
--
ALTER TABLE `crad_research_adviser_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_raa_adviser_identity` (`adviser_email`,`adviser_name`),
  ADD KEY `idx_raa_group` (`research_group_id`),
  ADD KEY `idx_raa_proposal` (`proposal_id`),
  ADD KEY `idx_raa_group_number` (`group_number`),
  ADD KEY `idx_raa_status` (`assignment_status`),
  ADD KEY `idx_raa_user` (`adviser_user_id`),
  ADD KEY `idx_raa_student` (`student_id`);

--
-- Indexes for table `crad_research_assignment_cycles`
--
ALTER TABLE `crad_research_assignment_cycles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rac_group` (`research_group_id`),
  ADD KEY `idx_rac_group_number` (`group_number`),
  ADD KEY `idx_rac_student` (`student_id`),
  ADD KEY `idx_rac_status` (`status`);

--
-- Indexes for table `crad_research_clearance_notifications`
--
ALTER TABLE `crad_research_clearance_notifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rsc_notif_event` (`event_key`),
  ADD KEY `idx_rsc_notif_recipient` (`recipient_user_id`,`recipient_role`);

--
-- Indexes for table `crad_research_clearance_payments`
--
ALTER TABLE `crad_research_clearance_payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rcp_group_stage` (`research_group_id`,`research_stage`),
  ADD KEY `idx_rcp_group` (`research_group_id`),
  ADD KEY `idx_rcp_status` (`status`);

--
-- Indexes for table `crad_research_coordinator_assignments`
--
ALTER TABLE `crad_research_coordinator_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rca_group_number` (`group_number`),
  ADD UNIQUE KEY `uniq_rca_group_coordinator` (`research_group_id`,`coordinator_user_id`),
  ADD UNIQUE KEY `uniq_rca_student_id` (`student_id`),
  ADD KEY `idx_rca_group` (`research_group_id`),
  ADD KEY `idx_rca_title_approval` (`title_approval_id`),
  ADD KEY `idx_rca_status` (`status`),
  ADD KEY `idx_rca_student` (`student_id`);

--
-- Indexes for table `crad_research_defense_schedules`
--
ALTER TABLE `crad_research_defense_schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rds_proposal_number` (`proposal_number`),
  ADD KEY `idx_rds_status` (`status`),
  ADD KEY `idx_rds_proposal_id` (`proposal_id`),
  ADD KEY `idx_rds_venue_time` (`venue_id`,`defense_datetime`,`defense_end_datetime`),
  ADD KEY `idx_rds_group_time` (`research_group_id`,`defense_datetime`,`defense_end_datetime`),
  ADD KEY `idx_rds_group_number` (`group_number`);

--
-- Indexes for table `crad_research_groups`
--
ALTER TABLE `crad_research_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `group_number` (`group_number`),
  ADD UNIQUE KEY `proposal_id` (`proposal_id`),
  ADD UNIQUE KEY `title_approval_id` (`title_approval_id`),
  ADD KEY `idx_rg_proposal_number` (`proposal_number`);

--
-- Indexes for table `crad_research_group_members`
--
ALTER TABLE `crad_research_group_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rgm_group` (`research_group_id`),
  ADD KEY `idx_rgm_student` (`student_id`);

--
-- Indexes for table `crad_research_milestones`
--
ALTER TABLE `crad_research_milestones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rm_plan_name` (`research_plan_id`,`milestone_name`),
  ADD KEY `idx_rm_plan` (`research_plan_id`),
  ADD KEY `idx_rm_status` (`status`),
  ADD KEY `idx_rm_sequence` (`research_plan_id`,`milestone_order`);

--
-- Indexes for table `crad_research_panel_assignments`
--
ALTER TABLE `crad_research_panel_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_panel_assignment_phase` (`research_group_id`,`panel_user_id`,`defense_phase`),
  ADD KEY `idx_panel_assignment_group` (`research_group_id`),
  ADD KEY `idx_panel_assignment_user` (`panel_user_id`),
  ADD KEY `idx_panel_assignment_status` (`assignment_status`),
  ADD KEY `idx_panel_assignment_schedule` (`defense_schedule_id`);

--
-- Indexes for table `crad_research_plans`
--
ALTER TABLE `crad_research_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rp_group` (`research_group_id`),
  ADD KEY `idx_rp_group_number` (`group_number`),
  ADD KEY `idx_rp_adviser` (`adviser_id`),
  ADD KEY `idx_rp_status` (`status`);

--
-- Indexes for table `crad_research_progress_activity_logs`
--
ALTER TABLE `crad_research_progress_activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpal_plan` (`research_plan_id`),
  ADD KEY `idx_rpal_user` (`user_id`),
  ADD KEY `idx_rpal_action` (`action`),
  ADD KEY `idx_rpal_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_rpal_created` (`created_at`);

--
-- Indexes for table `crad_research_progress_ai_analyses`
--
ALTER TABLE `crad_research_progress_ai_analyses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpai_update` (`progress_update_id`,`id`);

--
-- Indexes for table `crad_research_progress_attachments`
--
ALTER TABLE `crad_research_progress_attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpa_update` (`progress_update_id`),
  ADD KEY `idx_rpa_uploaded` (`uploaded_by`);

--
-- Indexes for table `crad_research_progress_feedback`
--
ALTER TABLE `crad_research_progress_feedback`
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
-- Indexes for table `crad_research_progress_notifications`
--
ALTER TABLE `crad_research_progress_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rpn_recipient_user` (`recipient_user_id`),
  ADD KEY `idx_rpn_recipient_email` (`recipient_email`),
  ADD KEY `idx_rpn_recipient_role` (`recipient_role`),
  ADD KEY `idx_rpn_batch_key` (`batch_key`),
  ADD KEY `idx_rpn_status` (`status`),
  ADD KEY `idx_rpn_created` (`created_at`);

--
-- Indexes for table `crad_research_progress_updates`
--
ALTER TABLE `crad_research_progress_updates`
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
-- Indexes for table `crad_research_proposals`
--
ALTER TABLE `crad_research_proposals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ref_code` (`ref_code`),
  ADD UNIQUE KEY `proposal_number` (`proposal_number`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_dept` (`college_department`(50)),
  ADD KEY `idx_submitted` (`date_submitted`);

--
-- Indexes for table `crad_research_revision_cycles`
--
ALTER TABLE `crad_research_revision_cycles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rrc_schedule` (`defense_schedule_id`),
  ADD KEY `idx_rrc_group` (`research_group_id`),
  ADD KEY `idx_rrc_status` (`revision_status`);

--
-- Indexes for table `crad_research_services_clearances`
--
ALTER TABLE `crad_research_services_clearances`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_rsc_group_stage` (`research_group_id`,`research_stage`),
  ADD KEY `idx_rsc_status` (`status`),
  ADD KEY `idx_rsc_adviser` (`adviser_user_id`);

--
-- Indexes for table `crad_research_venues`
--
ALTER TABLE `crad_research_venues`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_research_venue_name` (`venue_name`),
  ADD KEY `idx_research_venues_status` (`status`);

--
-- Indexes for table `crad_title_approvals`
--
ALTER TABLE `crad_title_approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ta_student_id` (`student_id`),
  ADD KEY `idx_ta_adviser_email` (`adviser_email`(100)),
  ADD KEY `idx_ta_status` (`status`),
  ADD KEY `idx_ta_sent_at` (`sent_at`),
  ADD KEY `idx_ta_proposal_number` (`proposal_number`);

--
-- Indexes for table `sms2_activity_logs`
--
ALTER TABLE `sms2_activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_logs_user` (`user_id`),
  ADD KEY `idx_logs_action` (`action`),
  ADD KEY `idx_logs_created` (`created_at`);

--
-- Indexes for table `sms2_admin_announcements`
--
ALTER TABLE `sms2_admin_announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ann_status_published` (`status`,`published_at`),
  ADD KEY `idx_ann_audience` (`audience`);

--
-- Indexes for table `sms2_login_throttles`
--
ALTER TABLE `sms2_login_throttles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_login_throttle_key` (`throttle_key`),
  ADD KEY `idx_login_throttle_ip` (`ip_address`),
  ADD KEY `idx_login_throttle_locked` (`locked_until`);

--
-- Indexes for table `sms2_password_resets`
--
ALTER TABLE `sms2_password_resets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_reset_user` (`user_id`),
  ADD KEY `idx_reset_token` (`token_hash`),
  ADD KEY `idx_reset_expires` (`expires_at`);

--
-- Indexes for table `sms2_password_reset_requests`
--
ALTER TABLE `sms2_password_reset_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_prr_user` (`user_id`),
  ADD KEY `idx_prr_status` (`status`),
  ADD KEY `idx_prr_module` (`module_key`),
  ADD KEY `fk_prr_admin` (`admin_id`);

--
-- Indexes for table `sms2_roles`
--
ALTER TABLE `sms2_roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_roles_key` (`role_key`);

--
-- Indexes for table `sms2_role_permissions`
--
ALTER TABLE `sms2_role_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_role_module` (`role_key`,`module_key`),
  ADD KEY `idx_perm_module` (`module_key`);

--
-- Indexes for table `sms2_security_otps`
--
ALTER TABLE `sms2_security_otps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_otp_user` (`user_id`),
  ADD KEY `idx_otp_expires` (`expires_at`);

--
-- Indexes for table `sms2_student_profiles`
--
ALTER TABLE `sms2_student_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_sp_user` (`user_id`),
  ADD UNIQUE KEY `uq_sp_student_id` (`student_id`);

--
-- Indexes for table `sms2_system_settings`
--
ALTER TABLE `sms2_system_settings`
  ADD PRIMARY KEY (`setting_key`);

--
-- Indexes for table `sms2_users`
--
ALTER TABLE `sms2_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_username` (`username`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `idx_users_role` (`role_key`),
  ADD KEY `idx_users_status` (`status`),
  ADD KEY `idx_users_student_id` (`student_id`),
  ADD KEY `idx_users_last_seen` (`last_seen_at`);

--
-- Indexes for table `sms2_user_authenticators`
--
ALTER TABLE `sms2_user_authenticators`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `sms2_user_passkeys`
--
ALTER TABLE `sms2_user_passkeys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_passkey_cred` (`credential_id`(255)),
  ADD KEY `idx_passkey_user` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `crad_chapter_evaluations`
--
ALTER TABLE `crad_chapter_evaluations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_chapter_evaluation_notifications`
--
ALTER TABLE `crad_chapter_evaluation_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_chapter_submissions`
--
ALTER TABLE `crad_chapter_submissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_chapter_submission_history`
--
ALTER TABLE `crad_chapter_submission_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_final_defense_evaluations`
--
ALTER TABLE `crad_final_defense_evaluations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_final_defense_recommendations`
--
ALTER TABLE `crad_final_defense_recommendations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_final_manuscript_approvals`
--
ALTER TABLE `crad_final_manuscript_approvals`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_grant_applications`
--
ALTER TABLE `crad_grant_applications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `crad_grant_document_repository`
--
ALTER TABLE `crad_grant_document_repository`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `crad_grant_document_repository_items`
--
ALTER TABLE `crad_grant_document_repository_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_grant_final_output_submissions`
--
ALTER TABLE `crad_grant_final_output_submissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `crad_grant_funded_progress_evidence`
--
ALTER TABLE `crad_grant_funded_progress_evidence`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_grant_funded_project_milestones`
--
ALTER TABLE `crad_grant_funded_project_milestones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_grant_funding_disbursements`
--
ALTER TABLE `crad_grant_funding_disbursements`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_grant_opportunities`
--
ALTER TABLE `crad_grant_opportunities`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `crad_grant_proposal_approval_steps`
--
ALTER TABLE `crad_grant_proposal_approval_steps`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_grant_proposal_approval_workflows`
--
ALTER TABLE `crad_grant_proposal_approval_workflows`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `crad_grant_proposal_evaluations`
--
ALTER TABLE `crad_grant_proposal_evaluations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `crad_grant_proposal_notifications`
--
ALTER TABLE `crad_grant_proposal_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT for table `crad_grant_proposal_versions`
--
ALTER TABLE `crad_grant_proposal_versions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `crad_grant_publications_ip_repository`
--
ALTER TABLE `crad_grant_publications_ip_repository`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `crad_manuscript_evaluations`
--
ALTER TABLE `crad_manuscript_evaluations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `crad_manuscript_submissions`
--
ALTER TABLE `crad_manuscript_submissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `crad_panel_assignment_notifications`
--
ALTER TABLE `crad_panel_assignment_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_panel_member_availability`
--
ALTER TABLE `crad_panel_member_availability`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=333;

--
-- AUTO_INCREMENT for table `crad_preoral_defense_evaluations`
--
ALTER TABLE `crad_preoral_defense_evaluations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `crad_proposal_documents`
--
ALTER TABLE `crad_proposal_documents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=204;

--
-- AUTO_INCREMENT for table `crad_proposal_drafts`
--
ALTER TABLE `crad_proposal_drafts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `crad_proposal_members`
--
ALTER TABLE `crad_proposal_members`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `crad_proposal_status_logs`
--
ALTER TABLE `crad_proposal_status_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=148;

--
-- AUTO_INCREMENT for table `crad_publications`
--
ALTER TABLE `crad_publications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `crad_research_adviser_assignments`
--
ALTER TABLE `crad_research_adviser_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=116;

--
-- AUTO_INCREMENT for table `crad_research_assignment_cycles`
--
ALTER TABLE `crad_research_assignment_cycles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `crad_research_clearance_notifications`
--
ALTER TABLE `crad_research_clearance_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_research_clearance_payments`
--
ALTER TABLE `crad_research_clearance_payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `crad_research_coordinator_assignments`
--
ALTER TABLE `crad_research_coordinator_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `crad_research_defense_schedules`
--
ALTER TABLE `crad_research_defense_schedules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_research_groups`
--
ALTER TABLE `crad_research_groups`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT for table `crad_research_group_members`
--
ALTER TABLE `crad_research_group_members`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `crad_research_milestones`
--
ALTER TABLE `crad_research_milestones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=273;

--
-- AUTO_INCREMENT for table `crad_research_panel_assignments`
--
ALTER TABLE `crad_research_panel_assignments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_research_plans`
--
ALTER TABLE `crad_research_plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `crad_research_progress_activity_logs`
--
ALTER TABLE `crad_research_progress_activity_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=241;

--
-- AUTO_INCREMENT for table `crad_research_progress_ai_analyses`
--
ALTER TABLE `crad_research_progress_ai_analyses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_research_progress_attachments`
--
ALTER TABLE `crad_research_progress_attachments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=121;

--
-- AUTO_INCREMENT for table `crad_research_progress_feedback`
--
ALTER TABLE `crad_research_progress_feedback`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

--
-- AUTO_INCREMENT for table `crad_research_progress_notifications`
--
ALTER TABLE `crad_research_progress_notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crad_research_progress_updates`
--
ALTER TABLE `crad_research_progress_updates`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=136;

--
-- AUTO_INCREMENT for table `crad_research_proposals`
--
ALTER TABLE `crad_research_proposals`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `crad_research_revision_cycles`
--
ALTER TABLE `crad_research_revision_cycles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `crad_research_services_clearances`
--
ALTER TABLE `crad_research_services_clearances`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `crad_research_venues`
--
ALTER TABLE `crad_research_venues`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16622;

--
-- AUTO_INCREMENT for table `crad_title_approvals`
--
ALTER TABLE `crad_title_approvals`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT for table `sms2_activity_logs`
--
ALTER TABLE `sms2_activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=126;

--
-- AUTO_INCREMENT for table `sms2_admin_announcements`
--
ALTER TABLE `sms2_admin_announcements`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sms2_login_throttles`
--
ALTER TABLE `sms2_login_throttles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sms2_password_resets`
--
ALTER TABLE `sms2_password_resets`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `sms2_password_reset_requests`
--
ALTER TABLE `sms2_password_reset_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sms2_roles`
--
ALTER TABLE `sms2_roles`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2151;

--
-- AUTO_INCREMENT for table `sms2_role_permissions`
--
ALTER TABLE `sms2_role_permissions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2593;

--
-- AUTO_INCREMENT for table `sms2_security_otps`
--
ALTER TABLE `sms2_security_otps`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `sms2_student_profiles`
--
ALTER TABLE `sms2_student_profiles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `sms2_users`
--
ALTER TABLE `sms2_users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1703;

--
-- AUTO_INCREMENT for table `sms2_user_authenticators`
--
ALTER TABLE `sms2_user_authenticators`
  MODIFY `user_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1599;

--
-- AUTO_INCREMENT for table `sms2_user_passkeys`
--
ALTER TABLE `sms2_user_passkeys`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `crad_proposal_documents`
--
ALTER TABLE `crad_proposal_documents`
  ADD CONSTRAINT `fk_pd_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `crad_research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_proposal_members`
--
ALTER TABLE `crad_proposal_members`
  ADD CONSTRAINT `fk_pm_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `crad_research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_proposal_status_logs`
--
ALTER TABLE `crad_proposal_status_logs`
  ADD CONSTRAINT `fk_psl_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `crad_research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_adviser_assignments`
--
ALTER TABLE `crad_research_adviser_assignments`
  ADD CONSTRAINT `fk_raa_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `crad_research_proposals` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_coordinator_assignments`
--
ALTER TABLE `crad_research_coordinator_assignments`
  ADD CONSTRAINT `fk_rca_title_approval` FOREIGN KEY (`title_approval_id`) REFERENCES `crad_title_approvals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_defense_schedules`
--
ALTER TABLE `crad_research_defense_schedules`
  ADD CONSTRAINT `fk_rds_proposal` FOREIGN KEY (`proposal_id`) REFERENCES `crad_research_proposals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_groups`
--
ALTER TABLE `crad_research_groups`
  ADD CONSTRAINT `fk_rg_title_approval` FOREIGN KEY (`title_approval_id`) REFERENCES `crad_title_approvals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_milestones`
--
ALTER TABLE `crad_research_milestones`
  ADD CONSTRAINT `fk_rm_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `crad_research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_plans`
--
ALTER TABLE `crad_research_plans`
  ADD CONSTRAINT `fk_rp_research_group` FOREIGN KEY (`research_group_id`) REFERENCES `crad_research_groups` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_progress_activity_logs`
--
ALTER TABLE `crad_research_progress_activity_logs`
  ADD CONSTRAINT `fk_rpal_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `crad_research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_progress_attachments`
--
ALTER TABLE `crad_research_progress_attachments`
  ADD CONSTRAINT `fk_rpa_progress_update` FOREIGN KEY (`progress_update_id`) REFERENCES `crad_research_progress_updates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_progress_feedback`
--
ALTER TABLE `crad_research_progress_feedback`
  ADD CONSTRAINT `fk_rpf_milestone` FOREIGN KEY (`milestone_id`) REFERENCES `crad_research_milestones` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rpf_progress_update` FOREIGN KEY (`progress_update_id`) REFERENCES `crad_research_progress_updates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rpf_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `crad_research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `crad_research_progress_updates`
--
ALTER TABLE `crad_research_progress_updates`
  ADD CONSTRAINT `fk_rpu_milestone` FOREIGN KEY (`milestone_id`) REFERENCES `crad_research_milestones` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rpu_research_plan` FOREIGN KEY (`research_plan_id`) REFERENCES `crad_research_plans` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sms2_activity_logs`
--
ALTER TABLE `sms2_activity_logs`
  ADD CONSTRAINT `fk_logs_user` FOREIGN KEY (`user_id`) REFERENCES `sms2_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `sms2_password_resets`
--
ALTER TABLE `sms2_password_resets`
  ADD CONSTRAINT `fk_reset_user` FOREIGN KEY (`user_id`) REFERENCES `sms2_users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sms2_password_reset_requests`
--
ALTER TABLE `sms2_password_reset_requests`
  ADD CONSTRAINT `fk_prr_admin` FOREIGN KEY (`admin_id`) REFERENCES `sms2_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_prr_user` FOREIGN KEY (`user_id`) REFERENCES `sms2_users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
