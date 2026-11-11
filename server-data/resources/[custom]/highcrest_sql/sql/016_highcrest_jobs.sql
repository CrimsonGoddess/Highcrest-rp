-- Highcrest jobs: jobs created or edited in-game (/jobs), and their clock-in, stash and boss spots.
CREATE TABLE IF NOT EXISTS `highcrest_jobs` (
  `name` varchar(50) NOT NULL,
  `data` longtext NOT NULL,
  `created_in_game` tinyint(1) NOT NULL DEFAULT 0,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`)
);

ALTER TABLE `highcrest_jobs` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `highcrest_job_points` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job` varchar(50) NOT NULL,
  `kind` varchar(10) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `data` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `job` (`job`)
);

ALTER TABLE `highcrest_job_points` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
