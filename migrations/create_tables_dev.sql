-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for controldb_dev
CREATE DATABASE IF NOT EXISTS `controldb_dev` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `controldb_dev`;

-- Dumping structure for table controldb_dev.config
CREATE TABLE IF NOT EXISTS `config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `url` varchar(500) NOT NULL,
  `api_key` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table controldb_dev.config: ~0 rows (approximately)
DELETE FROM `config`;
INSERT INTO `config` (`id`, `name`, `url`, `api_key`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
	(1, 'Open-Meteo Weather API', 'https://api.open-meteo.com/v1/forecast', NULL, 'Open source weather API for Vietnam cities', 1, '2025-10-26 12:30:01', '2025-10-26 12:30:01');

-- Dumping structure for table controldb_dev.config_log
CREATE TABLE IF NOT EXISTS `config_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `config_id` int(11) NOT NULL,
  `d_run` date NOT NULL,
  `status` enum('RUNNING','SUCCESS','FAILED','CANCELLED') DEFAULT 'RUNNING',
  `start_time` datetime DEFAULT current_timestamp(),
  `end_time` datetime DEFAULT NULL,
  `records_processed` int(11) DEFAULT 0,
  `error_message` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `config_id` (`config_id`),
  CONSTRAINT `config_log_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `config` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table controldb_dev.config_log: ~24 rows (approximately)
DELETE FROM `config_log`;
INSERT INTO `config_log` (`id`, `config_id`, `d_run`, `status`, `start_time`, `end_time`, `records_processed`, `error_message`, `created_at`) VALUES
	(1, 1, '2025-10-27', 'FAILED', '2025-10-27 11:49:24', '2025-10-27 11:49:24', 0, 'weatherAPIConfig.cities is not iterable', '2025-10-27 11:49:24'),
	(2, 1, '2025-10-27', 'FAILED', '2025-10-27 11:58:38', '2025-10-27 11:58:39', 0, 'No weather data fetched', '2025-10-27 11:58:38'),
	(3, 1, '2025-10-27', 'FAILED', '2025-10-27 12:19:16', '2025-10-27 12:19:18', 0, 'You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near \'\'100\'\' at line 1', '2025-10-27 12:19:16'),
	(4, 1, '2025-10-27', 'SUCCESS', '2025-10-27 12:25:35', '2025-10-27 12:25:37', 0, NULL, '2025-10-27 12:25:35'),
	(5, 1, '2025-10-27', 'SUCCESS', '2025-10-27 12:32:32', '2025-10-27 12:32:34', 0, NULL, '2025-10-27 12:32:32'),
	(6, 1, '2025-10-27', 'SUCCESS', '2025-10-27 12:42:18', '2025-10-27 12:42:19', 0, NULL, '2025-10-27 12:42:18'),
	(7, 1, '2025-10-27', 'SUCCESS', '2025-10-27 14:30:29', '2025-10-27 14:30:35', 0, NULL, '2025-10-27 14:30:29'),
	(8, 1, '2025-10-27', 'SUCCESS', '2025-10-27 14:45:57', '2025-10-27 14:45:59', 0, NULL, '2025-10-27 14:45:57'),
	(9, 1, '2025-10-27', 'FAILED', '2025-10-27 16:47:39', '2025-10-27 16:47:41', 0, 'Unknown column \'elevation\' in \'field list\'', '2025-10-27 16:47:39'),
	(10, 1, '2025-10-27', 'SUCCESS', '2025-10-27 16:56:47', '2025-10-27 16:56:48', 0, NULL, '2025-10-27 16:56:47'),
	(11, 1, '2025-10-27', 'SUCCESS', '2025-10-27 23:13:15', '2025-10-27 23:13:16', 0, NULL, '2025-10-27 23:13:15'),
	(12, 1, '2025-10-30', 'SUCCESS', '2025-10-30 08:20:03', '2025-10-30 08:20:05', 0, NULL, '2025-10-30 08:20:03'),
	(13, 1, '2025-10-30', 'SUCCESS', '2025-10-30 08:54:49', '2025-10-30 08:54:51', 0, NULL, '2025-10-30 08:54:49'),
	(14, 1, '2025-11-04', 'SUCCESS', '2025-11-04 10:27:10', '2025-11-04 10:27:12', 0, NULL, '2025-11-04 10:27:10'),
	(15, 1, '2025-11-05', 'SUCCESS', '2025-11-05 21:46:05', '2025-11-05 21:46:07', 0, NULL, '2025-11-05 21:46:05'),
	(16, 1, '2025-11-06', 'SUCCESS', '2025-11-06 08:33:38', '2025-11-06 08:33:40', 0, NULL, '2025-11-06 08:33:38'),
	(17, 1, '2025-11-06', 'SUCCESS', '2025-11-06 21:56:30', '2025-11-06 21:56:32', 0, NULL, '2025-11-06 21:56:30'),
	(18, 1, '2025-11-07', 'SUCCESS', '2025-11-07 01:08:09', '2025-11-07 01:08:10', 0, NULL, '2025-11-07 01:08:09'),
	(19, 1, '2025-11-07', 'SUCCESS', '2025-11-07 01:11:07', '2025-11-07 01:11:08', 0, NULL, '2025-11-07 01:11:07'),
	(20, 1, '2025-11-07', 'SUCCESS', '2025-11-07 08:41:26', '2025-11-07 08:41:28', 0, NULL, '2025-11-07 08:41:26'),
	(21, 1, '2025-11-07', 'SUCCESS', '2025-11-07 08:48:47', '2025-11-07 08:48:48', 0, NULL, '2025-11-07 08:48:47'),
	(22, 1, '2025-11-07', 'SUCCESS', '2025-11-07 08:57:41', '2025-11-07 08:57:42', 0, NULL, '2025-11-07 08:57:41'),
	(23, 1, '2025-11-07', 'FAILED', '2025-11-07 11:44:07', '2025-11-07 11:44:09', 0, 'Table \'datawarehouse.dim_time\' doesn\'t exist', '2025-11-07 11:44:07'),
	(24, 1, '2025-11-07', 'SUCCESS', '2025-11-07 15:30:51', '2025-11-07 15:30:52', 0, NULL, '2025-11-07 15:30:51'),
	(25, 1, '2025-11-07', 'SUCCESS', '2025-11-07 15:36:45', '2025-11-07 15:36:47', 0, NULL, '2025-11-07 15:36:45'),
	(26, 1, '2025-11-12', 'SUCCESS', '2025-11-12 18:00:34', '2025-11-12 18:00:35', 0, NULL, '2025-11-12 18:00:34'),
	(27, 1, '2025-11-12', 'SUCCESS', '2025-11-12 18:39:45', '2025-11-12 18:39:47', 0, NULL, '2025-11-12 18:39:45');

-- Dumping structure for table controldb_dev.process_log
CREATE TABLE IF NOT EXISTS `process_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `process_name` varchar(255) NOT NULL,
  `process_type` enum('FETCH','LOAD','TRANSFORM','SCHEDULED','LOAD_DW') NOT NULL,
  `status` enum('RUNNING','SUCCESS','FAILED','CANCELLED') DEFAULT 'RUNNING',
  `start_time` datetime DEFAULT current_timestamp(),
  `end_time` datetime DEFAULT NULL,
  `records_processed` int(11) DEFAULT 0,
  `error_message` text DEFAULT NULL,
  `config_log_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `config_log_id` (`config_log_id`),
  CONSTRAINT `process_log_ibfk_1` FOREIGN KEY (`config_log_id`) REFERENCES `config_log` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table controldb_dev.process_log: ~87 rows (approximately)
DELETE FROM `process_log`;
INSERT INTO `process_log` (`id`, `process_name`, `process_type`, `status`, `start_time`, `end_time`, `records_processed`, `error_message`, `config_log_id`, `created_at`) VALUES
	(1, 'Weather Data Fetch', 'FETCH', 'FAILED', '2025-10-27 11:49:24', '2025-10-27 11:49:24', 0, 'weatherAPIConfig.cities is not iterable', NULL, '2025-10-27 11:49:24'),
	(2, 'Weather Data Fetch', 'FETCH', 'FAILED', '2025-10-27 11:58:38', '2025-10-27 11:58:39', 0, 'No weather data fetched', NULL, '2025-10-27 11:58:38'),
	(3, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 12:19:16', '2025-10-27 12:19:18', 2, NULL, NULL, '2025-10-27 12:19:16'),
	(4, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 12:19:18', '2025-10-27 12:19:18', 0, NULL, NULL, '2025-10-27 12:19:18'),
	(5, 'Data Transform', 'TRANSFORM', 'FAILED', '2025-10-27 12:19:18', '2025-10-27 12:19:18', 0, 'You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near \'\'100\'\' at line 1', NULL, '2025-10-27 12:19:18'),
	(6, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 12:25:35', '2025-10-27 12:25:36', 2, NULL, NULL, '2025-10-27 12:25:35'),
	(7, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 12:25:36', '2025-10-27 12:25:37', 0, NULL, NULL, '2025-10-27 12:25:36'),
	(8, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-27 12:25:37', '2025-10-27 12:25:37', 2, NULL, NULL, '2025-10-27 12:25:37'),
	(9, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 12:32:32', '2025-10-27 12:32:33', 2, NULL, 5, '2025-10-27 12:32:32'),
	(10, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 12:32:33', '2025-10-27 12:32:33', 0, NULL, 5, '2025-10-27 12:32:33'),
	(11, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-27 12:32:34', '2025-10-27 12:32:34', 2, NULL, 5, '2025-10-27 12:32:34'),
	(12, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 12:42:18', '2025-10-27 12:42:19', 2, NULL, 6, '2025-10-27 12:42:18'),
	(13, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 12:42:19', '2025-10-27 12:42:19', 2, NULL, 6, '2025-10-27 12:42:19'),
	(14, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-27 12:42:19', '2025-10-27 12:42:19', 2, NULL, 6, '2025-10-27 12:42:19'),
	(15, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 13:00:21', '2025-10-27 13:00:22', 2, NULL, NULL, '2025-10-27 13:00:21'),
	(16, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 14:30:29', '2025-10-27 14:30:32', 768, NULL, 7, '2025-10-27 14:30:29'),
	(17, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 14:30:32', '2025-10-27 14:30:34', 768, NULL, 7, '2025-10-27 14:30:32'),
	(18, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-27 14:30:34', '2025-10-27 14:30:34', 100, NULL, 7, '2025-10-27 14:30:34'),
	(19, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 14:45:57', '2025-10-27 14:45:59', 2, NULL, 8, '2025-10-27 14:45:57'),
	(20, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 14:45:59', '2025-10-27 14:45:59', 2, NULL, 8, '2025-10-27 14:45:59'),
	(21, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-27 14:45:59', '2025-10-27 14:45:59', 2, NULL, 8, '2025-10-27 14:45:59'),
	(22, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 16:47:39', '2025-10-27 16:47:41', 2, NULL, 9, '2025-10-27 16:47:39'),
	(23, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 16:47:41', '2025-10-27 16:47:41', 2, NULL, 9, '2025-10-27 16:47:41'),
	(24, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-27 16:47:41', '2025-10-27 16:47:41', 2, NULL, 9, '2025-10-27 16:47:41'),
	(25, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 16:56:47', '2025-10-27 16:56:48', 2, NULL, 10, '2025-10-27 16:56:47'),
	(26, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 16:56:48', '2025-10-27 16:56:48', 2, NULL, 10, '2025-10-27 16:56:48'),
	(27, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-27 16:56:48', '2025-10-27 16:56:48', 2, NULL, 10, '2025-10-27 16:56:48'),
	(28, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-27 23:13:15', '2025-10-27 23:13:16', 2, NULL, 11, '2025-10-27 23:13:15'),
	(29, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-27 23:13:16', '2025-10-27 23:13:16', 2, NULL, 11, '2025-10-27 23:13:16'),
	(30, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-27 23:13:16', '2025-10-27 23:13:16', 2, NULL, 11, '2025-10-27 23:13:16'),
	(31, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-30 08:20:03', '2025-10-30 08:20:05', 2, NULL, 12, '2025-10-30 08:20:03'),
	(32, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-30 08:20:05', '2025-10-30 08:20:05', 2, NULL, 12, '2025-10-30 08:20:05'),
	(33, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-30 08:20:05', '2025-10-30 08:20:05', 2, NULL, 12, '2025-10-30 08:20:05'),
	(34, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-10-30 08:54:49', '2025-10-30 08:54:50', 2, NULL, 13, '2025-10-30 08:54:49'),
	(35, 'CSV Load', 'LOAD', 'SUCCESS', '2025-10-30 08:54:50', '2025-10-30 08:54:50', 2, NULL, 13, '2025-10-30 08:54:50'),
	(36, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-10-30 08:54:50', '2025-10-30 08:54:50', 2, NULL, 13, '2025-10-30 08:54:50'),
	(37, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-04 10:27:10', '2025-11-04 10:27:11', 2, NULL, 14, '2025-11-04 10:27:10'),
	(38, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-04 10:27:11', '2025-11-04 10:27:11', 2, NULL, 14, '2025-11-04 10:27:11'),
	(39, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-04 10:27:11', '2025-11-04 10:27:11', 2, NULL, 14, '2025-11-04 10:27:11'),
	(40, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-05 21:46:05', '2025-11-05 21:46:06', 2, NULL, 15, '2025-11-05 21:46:05'),
	(41, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-05 21:46:06', '2025-11-05 21:46:06', 2, NULL, 15, '2025-11-05 21:46:06'),
	(42, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-05 21:46:06', '2025-11-05 21:46:07', 2, NULL, 15, '2025-11-05 21:46:06'),
	(43, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-06 08:33:38', '2025-11-06 08:33:39', 2, NULL, 16, '2025-11-06 08:33:38'),
	(44, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-06 08:33:39', '2025-11-06 08:33:39', 2, NULL, 16, '2025-11-06 08:33:39'),
	(45, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-06 08:33:39', '2025-11-06 08:33:40', 2, NULL, 16, '2025-11-06 08:33:39'),
	(46, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-06 21:56:30', '2025-11-06 21:56:31', 2, NULL, 17, '2025-11-06 21:56:30'),
	(47, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-06 21:56:32', '2025-11-06 21:56:32', 2, NULL, 17, '2025-11-06 21:56:32'),
	(48, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-06 21:56:32', '2025-11-06 21:56:32', 2, NULL, 17, '2025-11-06 21:56:32'),
	(49, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-07 01:08:09', '2025-11-07 01:08:10', 2, NULL, 18, '2025-11-07 01:08:09'),
	(50, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-07 01:08:10', '2025-11-07 01:08:10', 2, NULL, 18, '2025-11-07 01:08:10'),
	(51, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-07 01:08:10', '2025-11-07 01:08:10', 2, NULL, 18, '2025-11-07 01:08:10'),
	(52, 'Load to Data Warehouse', '', 'SUCCESS', '2025-11-07 01:08:10', '2025-11-07 01:08:10', 0, NULL, NULL, '2025-11-07 01:08:10'),
	(53, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-07 01:11:07', '2025-11-07 01:11:08', 2, NULL, 19, '2025-11-07 01:11:07'),
	(54, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-07 01:11:08', '2025-11-07 01:11:08', 2, NULL, 19, '2025-11-07 01:11:08'),
	(55, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-07 01:11:08', '2025-11-07 01:11:08', 2, NULL, 19, '2025-11-07 01:11:08'),
	(56, 'Load to Data Warehouse', '', 'RUNNING', '2025-11-07 01:11:08', NULL, 0, NULL, NULL, '2025-11-07 01:11:08'),
	(57, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-07 08:41:26', '2025-11-07 08:41:27', 2, NULL, 20, '2025-11-07 08:41:26'),
	(58, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-07 08:41:27', '2025-11-07 08:41:27', 2, NULL, 20, '2025-11-07 08:41:27'),
	(59, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-07 08:41:27', '2025-11-07 08:41:28', 2, NULL, 20, '2025-11-07 08:41:27'),
	(60, 'Load to Data Warehouse', '', 'RUNNING', '2025-11-07 08:41:28', NULL, 0, NULL, NULL, '2025-11-07 08:41:28'),
	(61, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-07 08:48:47', '2025-11-07 08:48:48', 2, NULL, 21, '2025-11-07 08:48:47'),
	(62, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-07 08:48:48', '2025-11-07 08:48:48', 2, NULL, 21, '2025-11-07 08:48:48'),
	(63, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-07 08:48:48', '2025-11-07 08:48:48', 2, NULL, 21, '2025-11-07 08:48:48'),
	(64, 'Load to Data Warehouse', '', 'SUCCESS', '2025-11-07 08:48:48', '2025-11-07 08:48:48', 0, NULL, NULL, '2025-11-07 08:48:48'),
	(65, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-07 08:57:41', '2025-11-07 08:57:42', 2, NULL, 22, '2025-11-07 08:57:41'),
	(66, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-07 08:57:42', '2025-11-07 08:57:42', 2, NULL, 22, '2025-11-07 08:57:42'),
	(67, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-07 08:57:42', '2025-11-07 08:57:42', 2, NULL, 22, '2025-11-07 08:57:42'),
	(68, 'Load to Data Warehouse', 'LOAD_DW', 'SUCCESS', '2025-11-07 08:57:42', '2025-11-07 08:57:42', 0, NULL, NULL, '2025-11-07 08:57:42'),
	(69, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-07 11:44:07', '2025-11-07 11:44:09', 2, NULL, 23, '2025-11-07 11:44:07'),
	(70, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-07 11:44:09', '2025-11-07 11:44:09', 2, NULL, 23, '2025-11-07 11:44:09'),
	(71, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-07 11:44:09', '2025-11-07 11:44:09', 2, NULL, 23, '2025-11-07 11:44:09'),
	(72, 'Load to Data Warehouse', 'LOAD_DW', 'FAILED', '2025-11-07 11:44:09', '2025-11-07 11:44:09', 0, 'Table \'datawarehouse.dim_time\' doesn\'t exist', NULL, '2025-11-07 11:44:09'),
	(73, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-07 15:30:51', '2025-11-07 15:30:52', 2, NULL, 24, '2025-11-07 15:30:51'),
	(74, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-07 15:30:52', '2025-11-07 15:30:52', 2, NULL, 24, '2025-11-07 15:30:52'),
	(75, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-07 15:30:52', '2025-11-07 15:30:52', 2, NULL, 24, '2025-11-07 15:30:52'),
	(76, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-07 15:36:45', '2025-11-07 15:36:47', 2, NULL, 25, '2025-11-07 15:36:45'),
	(77, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-07 15:36:47', '2025-11-07 15:36:47', 2, NULL, 25, '2025-11-07 15:36:47'),
	(78, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-07 15:36:47', '2025-11-07 15:36:47', 2, NULL, 25, '2025-11-07 15:36:47'),
	(79, 'Load to Data Warehouse', 'LOAD_DW', 'SUCCESS', '2025-11-07 15:36:47', '2025-11-07 15:36:47', 0, NULL, NULL, '2025-11-07 15:36:47'),
	(80, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-12 18:00:34', '2025-11-12 18:00:35', 2, NULL, 26, '2025-11-12 18:00:34'),
	(81, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-12 18:00:35', '2025-11-12 18:00:35', 2, NULL, 26, '2025-11-12 18:00:35'),
	(82, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-12 18:00:35', '2025-11-12 18:00:35', 2, NULL, 26, '2025-11-12 18:00:35'),
	(83, 'Load to Data Warehouse', 'LOAD_DW', 'SUCCESS', '2025-11-12 18:00:35', '2025-11-12 18:00:35', 2, NULL, NULL, '2025-11-12 18:00:35'),
	(84, 'Weather Data Fetch', 'FETCH', 'SUCCESS', '2025-11-12 18:39:45', '2025-11-12 18:39:46', 2, NULL, 27, '2025-11-12 18:39:45'),
	(85, 'CSV Load', 'LOAD', 'SUCCESS', '2025-11-12 18:39:46', '2025-11-12 18:39:47', 2, NULL, 27, '2025-11-12 18:39:46'),
	(86, 'Data Transform', 'TRANSFORM', 'SUCCESS', '2025-11-12 18:39:47', '2025-11-12 18:39:47', 2, NULL, 27, '2025-11-12 18:39:47'),
	(87, 'Load to Data Warehouse', 'LOAD_DW', 'SUCCESS', '2025-11-12 18:39:47', '2025-11-12 18:39:47', 0, NULL, NULL, '2025-11-12 18:39:47');


-- Dumping database structure for weatherdb_dev
CREATE DATABASE IF NOT EXISTS `weatherdb_dev` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `weatherdb_dev`;

-- Dumping structure for table weatherdb_dev.general_weather
CREATE TABLE IF NOT EXISTS `general_weather` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `city` text DEFAULT NULL,
  `latitude` text DEFAULT NULL,
  `longitude` text DEFAULT NULL,
  `elevation` text DEFAULT NULL,
  `utc_offset_seconds` text DEFAULT NULL,
  `timezone` text DEFAULT NULL,
  `timezone_abbreviation` text DEFAULT NULL,
  `time` text DEFAULT NULL,
  `temperature_2m` text DEFAULT NULL,
  `humidity_2m` text DEFAULT NULL,
  `fetched_at` datetime DEFAULT current_timestamp(),
  `is_transformed` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table weatherdb_dev.general_weather: ~2 rows (approximately)
DELETE FROM `general_weather`;
INSERT INTO `general_weather` (`id`, `city`, `latitude`, `longitude`, `elevation`, `utc_offset_seconds`, `timezone`, `timezone_abbreviation`, `time`, `temperature_2m`, `humidity_2m`, `fetched_at`, `is_transformed`) VALUES
	(1, 'Ho Chi Minh City', '10.875', '106.625', '7', '0', 'GMT', 'GMT', '2025-11-12T00:00', '25.6', '94', '2025-11-12 18:39:47', 1),
	(2, 'Hanoi', '21', '105.875', '11', '0', 'GMT', 'GMT', '2025-11-12T00:00', '20.9', '74', '2025-11-12 18:39:47', 1);

-- Dumping structure for table weatherdb_dev.transform_weather
CREATE TABLE IF NOT EXISTS `transform_weather` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `city` varchar(255) DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `elevation` float DEFAULT NULL,
  `utc_offset_seconds` int(11) DEFAULT NULL,
  `timezone` varchar(255) DEFAULT NULL,
  `timezone_abbreviation` varchar(255) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `temperature_2m` float DEFAULT NULL,
  `humidity_2m` int(11) DEFAULT NULL,
  `loaded_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Dumping data for table weatherdb_dev.transform_weather: ~2 rows (approximately)
DELETE FROM `transform_weather`;
INSERT INTO `transform_weather` (`id`, `city`, `latitude`, `longitude`, `elevation`, `utc_offset_seconds`, `timezone`, `timezone_abbreviation`, `time`, `temperature_2m`, `humidity_2m`, `loaded_at`) VALUES
	(1, 'Ho Chi Minh City', 10.875, 106.625, 7, NULL, 'GMT', 'GMT', '2025-11-12 00:00:00', 25.6, 94, '2025-11-12 18:39:47'),
	(2, 'Hanoi', 21, 105.875, 11, NULL, 'GMT', 'GMT', '2025-11-12 00:00:00', 20.9, 74, '2025-11-12 18:39:47');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

-- Insert default config cho weather API
INSERT IGNORE INTO config (name, url, description) VALUES 
('Open-Meteo Weather API', 'https://api.open-meteo.com/v1/forecast', 'Open source weather API for Vietnam cities');
