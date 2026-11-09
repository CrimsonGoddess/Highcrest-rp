CREATE TABLE IF NOT EXISTS `gruppe6_players` (
  `identifier` VARCHAR(128) NOT NULL,
  `ranks` TEXT NOT NULL,
PRIMARY KEY (`identifier`));
ALTER TABLE `gruppe6_players` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
