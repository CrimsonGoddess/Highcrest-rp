-- Darkweb: an anonymous board. Players only ever see an alias, but the author is stored for moderation.
local MAX_POST_LENGTH = 500
local POST_DAYS = 7

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_darkweb_aliases` (
            `citizenid` VARCHAR(50) NOT NULL,
            `alias` VARCHAR(20) NOT NULL,
            PRIMARY KEY (`citizenid`),
            UNIQUE KEY `alias` (`alias`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_darkweb_posts` (
            `id` BIGINT NOT NULL AUTO_INCREMENT,
            `citizenid` VARCHAR(50) NOT NULL,
            `alias` VARCHAR(20) NOT NULL,
            `body` VARCHAR(500) NOT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            FOREIGN KEY (`citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    MySQL.update.await(('DELETE FROM highcrest_darkweb_posts WHERE created_at < NOW() - INTERVAL %d DAY'):format(POST_DAYS))
end)

local function getAlias(citizenid)
    local alias = MySQL.scalar.await('SELECT alias FROM highcrest_darkweb_aliases WHERE citizenid = ?', { citizenid })
    if alias then return alias end

    for _ = 1, 20 do
        alias = ('Ghost-%04d'):format(math.random(0, 9999))
        local ok = pcall(function()
            MySQL.insert.await('INSERT INTO highcrest_darkweb_aliases (citizenid, alias) VALUES (?, ?)', { citizenid, alias })
        end)
        if ok then return alias end
    end
end

-- The author is never sent to clients, only whether the post is the viewer's own.
local function loadBoard(citizenid)
    local posts = MySQL.query.await([[
        SELECT id, alias, body, UNIX_TIMESTAMP(created_at) AS createdAt, citizenid = ? AS mine
        FROM highcrest_darkweb_posts ORDER BY id DESC LIMIT 100
    ]], { citizenid })
    return { alias = getAlias(citizenid), posts = posts or {} }
end

lib.callback.register('highcrest_phone:server:darkwebGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end
    return loadBoard(player.PlayerData.citizenid)
end)

lib.callback.register('highcrest_phone:server:darkwebPost', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end
    if IsRateLimited(source, 'darkwebPost', 5000) then return { error = 'Wait a few seconds before posting again.' } end

    local body = TrimText(data.body)
    if #body < 1 or #body > MAX_POST_LENGTH then return { error = 'Posts can be up to 500 characters.' } end

    local citizenid = player.PlayerData.citizenid
    local alias = getAlias(citizenid)
    if not alias then return { error = 'The connection failed. Try again.' } end

    MySQL.insert.await('INSERT INTO highcrest_darkweb_posts (citizenid, alias, body) VALUES (?, ?, ?)', { citizenid, alias, body })
    return loadBoard(citizenid)
end)

-- Authors can delete their own posts. Admins can delete any post.
lib.callback.register('highcrest_phone:server:darkwebDelete', function(source, value)
    local player = GetPhoneOwner(source)
    local id = tonumber(value)
    if not player or not id then return end

    local citizenid = player.PlayerData.citizenid
    if IsPlayerAceAllowed(source, 'admin') then
        MySQL.update.await('DELETE FROM highcrest_darkweb_posts WHERE id = ?', { id })
    else
        MySQL.update.await('DELETE FROM highcrest_darkweb_posts WHERE id = ? AND citizenid = ?', { id, citizenid })
    end
    return loadBoard(citizenid)
end)
