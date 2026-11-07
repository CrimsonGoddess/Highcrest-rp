-- Pulse: the Twitter-style app.
local MAX_POST_LENGTH = 280
local FEED_SIZE = 50

MySQL.ready(function()
    Citizen.Await(PhotoTableReady)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_feed_profiles` (
            `citizenid` VARCHAR(50) NOT NULL,
            `handle` VARCHAR(20) NOT NULL,
            `display_name` VARCHAR(40) NOT NULL,
            PRIMARY KEY (`citizenid`),
            UNIQUE KEY `handle` (`handle`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_feed_posts` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `body` VARCHAR(280) NOT NULL,
            `photo_id` BIGINT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE,
            FOREIGN KEY (`photo_id`) REFERENCES `highcrest_phone_photos` (`id`) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_feed_likes` (
            `post_id` BIGINT NOT NULL,
            `citizenid` VARCHAR(50) NOT NULL,
            PRIMARY KEY (`post_id`, `citizenid`),
            FOREIGN KEY (`post_id`) REFERENCES `highcrest_feed_posts` (`id`) ON DELETE CASCADE,
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

local function loadFeed(citizenid)
    local profile = MySQL.single.await('SELECT handle, display_name AS displayName FROM highcrest_feed_profiles WHERE citizenid = ?', { citizenid })
    local posts = MySQL.query.await(([[
        SELECT p.id, p.body, p.photo_id AS photoId, UNIX_TIMESTAMP(p.created_at) AS createdAt,
            pr.handle, pr.display_name AS displayName, p.citizenid = ? AS mine,
            (SELECT COUNT(*) FROM highcrest_feed_likes l WHERE l.post_id = p.id) AS likes,
            EXISTS (SELECT 1 FROM highcrest_feed_likes l WHERE l.post_id = p.id AND l.citizenid = ?) AS liked
        FROM highcrest_feed_posts p
        JOIN highcrest_feed_profiles pr ON pr.citizenid = p.citizenid
        ORDER BY p.id DESC LIMIT %d
    ]]):format(FEED_SIZE), { citizenid, citizenid })
    return { profile = profile, posts = posts or {} }
end

lib.callback.register('highcrest_phone:server:feedGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end
    return loadFeed(player.PlayerData.citizenid)
end)

lib.callback.register('highcrest_phone:server:feedSaveProfile', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end

    local handle = TrimText(data.handle)
    local displayName = TrimText(data.displayName)
    if not handle:match('^[%w_]+$') or #handle < 3 or #handle > 20 then
        return { error = 'Handles use 3 to 20 letters, numbers or underscores.' }
    end
    if #displayName < 1 or #displayName > 40 then return { error = 'Enter a display name.' } end

    local citizenid = player.PlayerData.citizenid
    local ok = pcall(function()
        MySQL.update.await([[
            INSERT INTO highcrest_feed_profiles (citizenid, handle, display_name) VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE handle = VALUES(handle), display_name = VALUES(display_name)
        ]], { citizenid, handle, displayName })
    end)
    if not ok then return { error = 'That handle is taken.' } end

    return loadFeed(citizenid)
end)

lib.callback.register('highcrest_phone:server:feedPost', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end
    if IsRateLimited(source, 'feedPost', 5000) then return { error = 'Wait a few seconds before posting again.' } end

    local citizenid = player.PlayerData.citizenid
    local body = TrimText(data.body)
    if #body < 1 or #body > MAX_POST_LENGTH then return { error = 'Posts can be up to 280 characters.' } end

    local hasProfile = MySQL.scalar.await('SELECT 1 FROM highcrest_feed_profiles WHERE citizenid = ?', { citizenid })
    if not hasProfile then return { error = 'Set up your profile first.' } end

    MySQL.insert.await('INSERT INTO highcrest_feed_posts (citizenid, body, photo_id) VALUES (?, ?, ?)', {
        citizenid, body, CleanPhotoId(citizenid, data.photoId),
    })
    return loadFeed(citizenid)
end)

lib.callback.register('highcrest_phone:server:feedLike', function(source, value)
    local player = GetPhoneOwner(source)
    local postId = tonumber(value)
    if not player or not postId or IsRateLimited(source, 'feedLike', 300) then return end

    local citizenid = player.PlayerData.citizenid
    local removed = MySQL.update.await('DELETE FROM highcrest_feed_likes WHERE post_id = ? AND citizenid = ?', { postId, citizenid })
    if removed < 1 then
        pcall(function()
            MySQL.insert.await('INSERT INTO highcrest_feed_likes (post_id, citizenid) VALUES (?, ?)', { postId, citizenid })
        end)
    end
    return loadFeed(citizenid)
end)

-- Authors can delete their own posts. Admins can delete any post.
lib.callback.register('highcrest_phone:server:feedDelete', function(source, value)
    local player = GetPhoneOwner(source)
    local postId = tonumber(value)
    if not player or not postId then return end

    local citizenid = player.PlayerData.citizenid
    if IsPlayerAceAllowed(source, 'admin') then
        MySQL.update.await('DELETE FROM highcrest_feed_posts WHERE id = ?', { postId })
    else
        MySQL.update.await('DELETE FROM highcrest_feed_posts WHERE id = ? AND citizenid = ?', { postId, citizenid })
    end
    return loadFeed(citizenid)
end)
