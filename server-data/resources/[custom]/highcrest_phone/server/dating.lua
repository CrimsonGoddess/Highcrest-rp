-- Spark: the dating app. Adult characters only, and numbers are shared only after a mutual match.
local MINIMUM_AGE = 18
local MAXIMUM_AGE = 120

MySQL.ready(function()
    Citizen.Await(PhotoTableReady)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_dating_profiles` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `phone` VARCHAR(15) NOT NULL,
            `name` VARCHAR(40) NOT NULL,
            `age` TINYINT UNSIGNED NOT NULL,
            `bio` VARCHAR(300) NOT NULL,
            `photo_id` BIGINT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `citizenid` (`citizenid`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE,
            FOREIGN KEY (`photo_id`) REFERENCES `highcrest_phone_photos` (`id`) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_dating_swipes` (
            `from_profile` BIGINT NOT NULL,
            `to_profile` BIGINT NOT NULL,
            `liked` TINYINT(1) NOT NULL,
            PRIMARY KEY (`from_profile`, `to_profile`),
            FOREIGN KEY (`from_profile`) REFERENCES `highcrest_dating_profiles` (`id`) ON DELETE CASCADE,
            FOREIGN KEY (`to_profile`) REFERENCES `highcrest_dating_profiles` (`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

local function loadDating(citizenid)
    local profile = MySQL.single.await('SELECT id, name, age, bio, photo_id AS photoId FROM highcrest_dating_profiles WHERE citizenid = ?', { citizenid })
    if not profile then return {} end

    local nextProfile = MySQL.single.await([[
        SELECT id, name, age, bio, photo_id AS photoId FROM highcrest_dating_profiles
        WHERE id <> ? AND id NOT IN (SELECT to_profile FROM highcrest_dating_swipes WHERE from_profile = ?)
        ORDER BY RAND() LIMIT 1
    ]], { profile.id, profile.id })

    local matches = MySQL.query.await([[
        SELECT p.name, p.phone, p.photo_id AS photoId FROM highcrest_dating_swipes mine
        JOIN highcrest_dating_swipes theirs ON theirs.from_profile = mine.to_profile AND theirs.to_profile = mine.from_profile
        JOIN highcrest_dating_profiles p ON p.id = mine.to_profile
        WHERE mine.from_profile = ? AND mine.liked = 1 AND theirs.liked = 1
    ]], { profile.id })

    return { profile = profile, nextProfile = nextProfile, matches = matches or {} }
end

lib.callback.register('highcrest_phone:server:datingGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end
    return loadDating(player.PlayerData.citizenid)
end)

lib.callback.register('highcrest_phone:server:datingSave', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end

    local name = TrimText(data.name)
    local bio = TrimText(data.bio)
    local age = math.floor(tonumber(data.age) or 0)
    if #name < 1 or #name > 40 then return { error = 'Enter a name.' } end
    if #bio > 300 then return { error = 'Bios can be up to 300 characters.' } end
    if age < MINIMUM_AGE or age > MAXIMUM_AGE then return { error = 'Spark is for adult characters, 18 and over.' } end

    local citizenid = player.PlayerData.citizenid
    MySQL.update.await([[
        INSERT INTO highcrest_dating_profiles (citizenid, phone, name, age, bio, photo_id) VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE phone = VALUES(phone), name = VALUES(name), age = VALUES(age), bio = VALUES(bio), photo_id = VALUES(photo_id)
    ]], { citizenid, player.PlayerData.charinfo.phone, name, age, bio, CleanPhotoId(citizenid, data.photoId) })

    return loadDating(citizenid)
end)

lib.callback.register('highcrest_phone:server:datingDelete', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    MySQL.update.await('DELETE FROM highcrest_dating_profiles WHERE citizenid = ?', { citizenid })
    return loadDating(citizenid)
end)

lib.callback.register('highcrest_phone:server:datingSwipe', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' or IsRateLimited(source, 'datingSwipe', 300) then return end

    local citizenid = player.PlayerData.citizenid
    local mine = MySQL.scalar.await('SELECT id FROM highcrest_dating_profiles WHERE citizenid = ?', { citizenid })
    local target = tonumber(data.id)
    if not mine or not target or target == mine then return end

    pcall(function()
        MySQL.update.await([[
            INSERT INTO highcrest_dating_swipes (from_profile, to_profile, liked) VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE liked = VALUES(liked)
        ]], { mine, target, data.liked == true and 1 or 0 })
    end)
    return loadDating(citizenid)
end)
