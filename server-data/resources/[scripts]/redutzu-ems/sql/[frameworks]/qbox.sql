ALTER TABLE `players`
ADD IF NOT EXISTS `ems_image` TEXT DEFAULT NULL,
ADD IF NOT EXISTS `ems_notes` TEXT DEFAULT NULL;


-- ALTER TABLE ems_incidents CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ALTER TABLE ems_gallery CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ALTER TABLE ems_invoices CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ALTER TABLE ems_tags CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ALTER TABLE ems_activity CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ALTER TABLE ems_announcements CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ALTER TABLE ems_codes CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- ALTER TABLE ems_citizens CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
