-- Highcrest VIP: one row per player account (FiveM license), and the custom plates VIPs have used.
CREATE TABLE IF NOT EXISTS `highcrest_vip` (
  `identifier` varchar(80) NOT NULL,
  `tier` varchar(20) NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`identifier`)
);

ALTER TABLE `highcrest_vip` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `highcrest_vip_plates` (
  `plate` varchar(12) NOT NULL,
  `identifier` varchar(80) NOT NULL,
  `old_plate` varchar(12) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`plate`),
  KEY `identifier` (`identifier`)
);

ALTER TABLE `highcrest_vip_plates` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
