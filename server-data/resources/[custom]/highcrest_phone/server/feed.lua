-- Pulse: the social media app.
local MAX_POST_LENGTH = 280
local MAX_COMMENT_LENGTH = 200
local MAX_BIO_LENGTH = 160
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
    MySQL.query.await("ALTER TABLE `highcrest_feed_profiles` ADD COLUMN IF NOT EXISTS `bio` VARCHAR(160) NOT NULL DEFAULT ''")
    MySQL.query.await('ALTER TABLE `highcrest_feed_profiles` ADD COLUMN IF NOT EXISTS `avatar_id` BIGINT NULL')
    MySQL.query.await('ALTER TABLE `highcrest_feed_profiles` ADD COLUMN IF NOT EXISTS `banner_id` BIGINT NULL')
    MySQL.query.await('ALTER TABLE `highcrest_feed_profiles` ADD CONSTRAINT `fk_feed_avatar` FOREIGN KEY IF NOT EXISTS (`avatar_id`) REFERENCES `highcrest_phone_photos` (`id`) ON DELETE SET NULL')
    MySQL.query.await('ALTER TABLE `highcrest_feed_profiles` ADD CONSTRAINT `fk_feed_banner` FOREIGN KEY IF NOT EXISTS (`banner_id`) REFERENCES `highcrest_phone_photos` (`id`) ON DELETE SET NULL')
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
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_feed_follows` (
            `follower` VARCHAR(50) NOT NULL,
            `followee` VARCHAR(50) NOT NULL,
            PRIMARY KEY (`follower`, `followee`),
            KEY `followee` (`followee`),
            FOREIGN KEY (`follower`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE,
            FOREIGN KEY (`followee`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_feed_comments` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `post_id` BIGINT NOT NULL,
            `citizenid` VARCHAR(50) NOT NULL,
            `body` VARCHAR(200) NOT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `post_comments` (`post_id`, `id`),
            FOREIGN KEY (`post_id`) REFERENCES `highcrest_feed_posts` (`id`) ON DELETE CASCADE,
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

-- Citizen ids are never sent to clients. Players are identified by their handle.
local POST_COLUMNS = [[
    p.id, p.body, p.photo_id AS photoId, UNIX_TIMESTAMP(p.created_at) AS createdAt,
    pr.handle, pr.display_name AS displayName, pr.avatar_id AS avatarId, p.citizenid = ? AS mine,
    (SELECT COUNT(*) FROM highcrest_feed_likes l WHERE l.post_id = p.id) AS likes,
    (SELECT COUNT(*) FROM highcrest_feed_comments c WHERE c.post_id = p.id) AS comments,
    EXISTS (SELECT 1 FROM highcrest_feed_likes l WHERE l.post_id = p.id AND l.citizenid = ?) AS liked
]]

local function ownProfile(citizenid)
    return MySQL.single.await('SELECT handle, display_name AS displayName, bio, avatar_id AS avatarId, banner_id AS bannerId FROM highcrest_feed_profiles WHERE citizenid = ?', { citizenid })
end

local function loadFeed(citizenid, tab)
    local filter = ''
    local params = { citizenid, citizenid }
    if tab == 'following' then
        filter = 'WHERE p.citizenid = ? OR p.citizenid IN (SELECT followee FROM highcrest_feed_follows WHERE follower = ?)'
        params[3], params[4] = citizenid, citizenid
    end

    local posts = MySQL.query.await(([[
        SELECT %s FROM highcrest_feed_posts p
        JOIN highcrest_feed_profiles pr ON pr.citizenid = p.citizenid
        %s ORDER BY p.id DESC LIMIT %d
    ]]):format(POST_COLUMNS, filter, FEED_SIZE), params)

    return { profile = ownProfile(citizenid), posts = posts or {}, tab = tab == 'following' and 'following' or 'all' }
end

local function loadProfile(viewer, handle)
    local target = MySQL.single.await([[
        SELECT citizenid, handle, display_name AS displayName, bio, avatar_id AS avatarId, banner_id AS bannerId
        FROM highcrest_feed_profiles WHERE handle = ?
    ]], { handle })
    if not target then return end

    local posts = MySQL.query.await(([[
        SELECT %s FROM highcrest_feed_posts p
        JOIN highcrest_feed_profiles pr ON pr.citizenid = p.citizenid
        WHERE p.citizenid = ? ORDER BY p.id DESC LIMIT %d
    ]]):format(POST_COLUMNS, FEED_SIZE), { viewer, viewer, target.citizenid })

    local isMine = target.citizenid == viewer
    local result = {
        handle = target.handle,
        displayName = target.displayName,
        bio = target.bio,
        avatarId = target.avatarId,
        bannerId = target.bannerId,
        isMine = isMine,
        posts = posts or {},
        postCount = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_feed_posts WHERE citizenid = ?', { target.citizenid }),
        followers = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_feed_follows WHERE followee = ?', { target.citizenid }),
        following = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_feed_follows WHERE follower = ?', { target.citizenid }),
        isFollowing = MySQL.scalar.await('SELECT 1 FROM highcrest_feed_follows WHERE follower = ? AND followee = ?', { viewer, target.citizenid }) ~= nil,
    }
    return result
end

local function loadComments(viewer, postId)
    return MySQL.query.await([[
        SELECT c.id, c.body, UNIX_TIMESTAMP(c.created_at) AS createdAt, pr.handle, pr.display_name AS displayName,
            pr.avatar_id AS avatarId, c.citizenid = ? AS mine
        FROM highcrest_feed_comments c
        JOIN highcrest_feed_profiles pr ON pr.citizenid = c.citizenid
        WHERE c.post_id = ? ORDER BY c.id LIMIT 100
    ]], { viewer, postId }) or {}
end

local function hasProfile(citizenid)
    return MySQL.scalar.await('SELECT 1 FROM highcrest_feed_profiles WHERE citizenid = ?', { citizenid }) ~= nil
end

lib.callback.register('highcrest_phone:server:feedGet', function(source, data)
    local player = GetPhoneOwner(source)
    if not player then return end
    return loadFeed(player.PlayerData.citizenid, type(data) == 'table' and data.tab)
end)

lib.callback.register('highcrest_phone:server:feedProfile', function(source, handle)
    local player = GetPhoneOwner(source)
    if not player or type(handle) ~= 'string' then return end
    return loadProfile(player.PlayerData.citizenid, handle)
end)

lib.callback.register('highcrest_phone:server:feedSaveProfile', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end

    local handle = TrimText(data.handle)
    local displayName = TrimText(data.displayName)
    local bio = TrimText(data.bio)
    if not handle:match('^[%w_]+$') or #handle < 3 or #handle > 20 then
        return { error = 'Handles use 3 to 20 letters, numbers or underscores.' }
    end
    if #displayName < 1 or #displayName > 40 then return { error = 'Enter a display name.' } end
    if #bio > MAX_BIO_LENGTH then return { error = 'Bios can be up to 160 characters.' } end

    local citizenid = player.PlayerData.citizenid
    local ok = pcall(function()
        MySQL.update.await([[
            INSERT INTO highcrest_feed_profiles (citizenid, handle, display_name, bio, avatar_id, banner_id) VALUES (?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE handle = VALUES(handle), display_name = VALUES(display_name), bio = VALUES(bio),
                avatar_id = VALUES(avatar_id), banner_id = VALUES(banner_id)
        ]], { citizenid, handle, displayName, bio, CleanPhotoId(citizenid, data.avatarId), CleanPhotoId(citizenid, data.bannerId) })
    end)
    if not ok then return { error = 'That handle is taken.' } end

    return loadProfile(citizenid, handle)
end)

lib.callback.register('highcrest_phone:server:feedPost', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end
    if IsRateLimited(source, 'feedPost', 5000) then return { error = 'Wait a few seconds before posting again.' } end

    local citizenid = player.PlayerData.citizenid
    local body = TrimText(data.body)
    if #body < 1 or #body > MAX_POST_LENGTH then return { error = 'Posts can be up to 280 characters.' } end
    if not hasProfile(citizenid) then return { error = 'Set up your profile first.' } end

    MySQL.insert.await('INSERT INTO highcrest_feed_posts (citizenid, body, photo_id) VALUES (?, ?, ?)', {
        citizenid, body, CleanPhotoId(citizenid, data.photoId),
    })
    return loadFeed(citizenid, data.tab)
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
    return true
end)

lib.callback.register('highcrest_phone:server:feedFollow', function(source, handle)
    local player = GetPhoneOwner(source)
    if not player or type(handle) ~= 'string' or IsRateLimited(source, 'feedFollow', 300) then return end

    local citizenid = player.PlayerData.citizenid
    if not hasProfile(citizenid) then return end
    local target = MySQL.scalar.await('SELECT citizenid FROM highcrest_feed_profiles WHERE handle = ?', { handle })
    if not target or target == citizenid then return end

    local removed = MySQL.update.await('DELETE FROM highcrest_feed_follows WHERE follower = ? AND followee = ?', { citizenid, target })
    if removed < 1 then
        MySQL.insert.await('INSERT INTO highcrest_feed_follows (follower, followee) VALUES (?, ?)', { citizenid, target })
    end
    return loadProfile(citizenid, handle)
end)

lib.callback.register('highcrest_phone:server:feedComments', function(source, value)
    local player = GetPhoneOwner(source)
    local postId = tonumber(value)
    if not player or not postId then return end
    return { comments = loadComments(player.PlayerData.citizenid, postId) }
end)

lib.callback.register('highcrest_phone:server:feedComment', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end
    if IsRateLimited(source, 'feedComment', 2000) then return { error = 'Wait a moment before commenting again.' } end

    local citizenid = player.PlayerData.citizenid
    local postId = tonumber(data.postId)
    local body = TrimText(data.body)
    if not postId or #body < 1 or #body > MAX_COMMENT_LENGTH then return { error = 'Comments can be up to 200 characters.' } end
    if not hasProfile(citizenid) then return { error = 'Set up your profile first.' } end
    if not MySQL.scalar.await('SELECT 1 FROM highcrest_feed_posts WHERE id = ?', { postId }) then
        return { error = 'That post has been deleted.' }
    end

    MySQL.insert.await('INSERT INTO highcrest_feed_comments (post_id, citizenid, body) VALUES (?, ?, ?)', { postId, citizenid, body })
    return { comments = loadComments(citizenid, postId) }
end)

-- Authors can delete their own posts and comments. Admins can delete any.
lib.callback.register('highcrest_phone:server:feedDelete', function(source, value)
    local player = GetPhoneOwner(source)
    local postId = tonumber(value)
    if not player or not postId then return end

    if IsPlayerAceAllowed(source, 'admin') then
        MySQL.update.await('DELETE FROM highcrest_feed_posts WHERE id = ?', { postId })
    else
        MySQL.update.await('DELETE FROM highcrest_feed_posts WHERE id = ? AND citizenid = ?', { postId, player.PlayerData.citizenid })
    end
    return true
end)

lib.callback.register('highcrest_phone:server:feedDeleteComment', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end
    local id, postId = tonumber(data.id), tonumber(data.postId)
    if not id or not postId then return end

    local citizenid = player.PlayerData.citizenid
    if IsPlayerAceAllowed(source, 'admin') then
        MySQL.update.await('DELETE FROM highcrest_feed_comments WHERE id = ?', { id })
    else
        MySQL.update.await('DELETE FROM highcrest_feed_comments WHERE id = ? AND citizenid = ?', { id, citizenid })
    end
    return { comments = loadComments(citizenid, postId) }
end)
