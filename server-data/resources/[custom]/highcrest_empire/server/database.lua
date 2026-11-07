-- Empire's tables. All of them are created here, in order, because later ones reference earlier ones.
MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_empire_businesses` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(60) NOT NULL,
            `type` VARCHAR(20) NOT NULL,
            `price` INT NOT NULL,
            `x` FLOAT NOT NULL,
            `y` FLOAT NOT NULL,
            `owner` VARCHAR(50) NULL,
            `balance` BIGINT NOT NULL DEFAULT 0,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `owner` (`owner`),
            CONSTRAINT `empire_balance_not_negative` CHECK (`balance` >= 0),
            FOREIGN KEY (`owner`) REFERENCES `players` (`citizenid`) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_empire_ranks` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `business_id` INT NOT NULL,
            `name` VARCHAR(30) NOT NULL,
            `level` INT NOT NULL,
            `permissions` VARCHAR(200) NOT NULL DEFAULT '[]',
            PRIMARY KEY (`id`),
            UNIQUE KEY `business_level` (`business_id`, `level`),
            FOREIGN KEY (`business_id`) REFERENCES `highcrest_empire_businesses` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_empire_staff` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `business_id` INT NOT NULL,
            `citizenid` VARCHAR(50) NOT NULL,
            `name` VARCHAR(80) NOT NULL,
            `rank_id` INT NOT NULL,
            `hired_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `business_member` (`business_id`, `citizenid`),
            KEY `citizen` (`citizenid`),
            FOREIGN KEY (`business_id`) REFERENCES `highcrest_empire_businesses` (`id`) ON DELETE CASCADE,
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE,
            FOREIGN KEY (`rank_id`) REFERENCES `highcrest_empire_ranks` (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_empire_ledger` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `business_id` INT NOT NULL,
            `type` VARCHAR(20) NOT NULL,
            `amount` BIGINT NOT NULL,
            `balance_after` BIGINT NOT NULL,
            `actor` VARCHAR(80) NOT NULL,
            `note` VARCHAR(120) NOT NULL DEFAULT '',
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `business_entries` (`business_id`, `id`),
            FOREIGN KEY (`business_id`) REFERENCES `highcrest_empire_businesses` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)
