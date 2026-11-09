CREATE TABLE IF NOT EXISTS `chopshop_players` (
  `identifier` VARCHAR(128) NOT NULL,
  `dealers` TEXT NOT NULL,
  `skills` TEXT NOT NULL,
PRIMARY KEY (`identifier`));
ALTER TABLE `chopshop_players` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
