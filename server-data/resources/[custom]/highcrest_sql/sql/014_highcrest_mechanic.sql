CREATE TABLE IF NOT EXISTS `highcrest_mechanic_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop` varchar(50) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `customer` varchar(100) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `model` varchar(60) DEFAULT NULL,
  `changes` longtext NOT NULL,
  `parts` int(11) NOT NULL DEFAULT 0,
  `labour` int(11) NOT NULL DEFAULT 0,
  `mechanic` varchar(50) DEFAULT NULL,
  `mechanic_name` varchar(100) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'new',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `plate` (`plate`)
);

ALTER TABLE `highcrest_mechanic_orders` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
