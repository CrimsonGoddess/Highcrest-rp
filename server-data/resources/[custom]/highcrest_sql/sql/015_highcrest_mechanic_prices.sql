-- Highcrest mechanic: price list set by each shop's boss on the mechanic tablet.
CREATE TABLE IF NOT EXISTS `highcrest_mechanic_prices` (
  `shop` varchar(50) NOT NULL,
  `prices` longtext NOT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`shop`)
);

ALTER TABLE `highcrest_mechanic_prices` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
