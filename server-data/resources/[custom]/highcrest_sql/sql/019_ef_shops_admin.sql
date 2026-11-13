-- ef_shops_admin: shops made in the in-game shop panel. One row per shop. `data` is the whole
-- shop definition as JSON; ef_shops only ever sees it through ef_shops_admin's exports.
CREATE TABLE IF NOT EXISTS `ef_shops_custom` (
  `id` varchar(40) NOT NULL,
  `data` longtext NOT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

ALTER TABLE `ef_shops_custom` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Audit trail for the shop panel: who changed what, newest rows are the ones shown.
CREATE TABLE IF NOT EXISTS `ef_shops_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actor` varchar(100) NOT NULL,
  `action` varchar(20) NOT NULL,
  `shop_id` varchar(40) DEFAULT NULL,
  `detail` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `created_at` (`created_at`)
);

ALTER TABLE `ef_shops_admin_log` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
