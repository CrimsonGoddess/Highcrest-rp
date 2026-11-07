-- Live location sharing. Positions only ever go to people the owner chose, and always come from the server.
local UPDATE_INTERVAL_MS = 10000
local MAX_SHARES = 25
local DURATION_HOURS = { [1] = true, [8] = true, [24] = true }

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `highcrest_location_shares` (
            `owner_citizenid` VARCHAR(50) NOT NULL,
            `owner_number` VARCHAR(15) NOT NULL,
            `viewer_number` VARCHAR(15) NOT NULL,
            `expires_at` TIMESTAMP NULL DEFAULT NULL,
            PRIMARY KEY (`owner_citizenid`, `viewer_number`),
            KEY `viewer` (`viewer_number`),
            FOREIGN KEY (`owner_citizenid`) REFERENCES `players` (`citizenid`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

function GetPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end
    local coords = GetEntityCoords(ped)
    return { x = coords.x, y = coords.y }
end

local function fullName(player)
    local info = player.PlayerData.charinfo
    return ('%s %s'):format(info.firstname, info.lastname)
end

local function loadSharing(player)
    local citizenid = player.PlayerData.citizenid
    local mine = player.PlayerData.charinfo.phone

    local sharing = MySQL.query.await([[
        SELECT s.viewer_number AS number, UNIX_TIMESTAMP(s.expires_at) AS expiresAt, c.name
        FROM highcrest_location_shares s
        LEFT JOIN highcrest_phone_contacts c ON c.citizenid = s.owner_citizenid AND c.number = s.viewer_number
        WHERE s.owner_citizenid = ? AND (s.expires_at IS NULL OR s.expires_at > NOW())
    ]], { citizenid }) or {}

    local friends = MySQL.query.await([[
        SELECT s.owner_number AS number, UNIX_TIMESTAMP(s.expires_at) AS expiresAt, c.name
        FROM highcrest_location_shares s
        LEFT JOIN highcrest_phone_contacts c ON c.citizenid = ? AND c.number = s.owner_number
        WHERE s.viewer_number = ? AND (s.expires_at IS NULL OR s.expires_at > NOW())
    ]], { citizenid, mine }) or {}

    for _, friend in ipairs(friends) do
        friend.online = exports.qbx_core:GetPlayerByPhone(friend.number) ~= nil
    end

    return { sharing = sharing, friends = friends }
end

lib.callback.register('highcrest_phone:server:locationGet', function(source)
    local player = GetPhoneOwner(source)
    if not player then return end
    return loadSharing(player)
end)

lib.callback.register('highcrest_phone:server:locationShare', function(source, data)
    local player = GetPhoneOwner(source)
    if not player or type(data) ~= 'table' then return end

    local number = CleanPhoneNumber(data.number)
    local mine = player.PlayerData.charinfo.phone
    if not number then return { error = 'Enter a valid number.' } end
    if number == mine then return { error = 'You cannot share with yourself.' } end
    if not NumberExists(number) then return { error = 'That number is not in service.' } end

    local hours = tonumber(data.hours)
    local forever = data.forever == true
    if not forever and not DURATION_HOURS[hours] then return { error = 'Choose how long to share for.' } end

    local citizenid = player.PlayerData.citizenid
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM highcrest_location_shares WHERE owner_citizenid = ?', { citizenid })
    if count >= MAX_SHARES then return { error = 'You are sharing with too many people.' } end

    MySQL.update.await(([[
        INSERT INTO highcrest_location_shares (owner_citizenid, owner_number, viewer_number, expires_at)
        VALUES (?, ?, ?, %s)
        ON DUPLICATE KEY UPDATE owner_number = VALUES(owner_number), expires_at = VALUES(expires_at)
    ]]):format(forever and 'NULL' or ('NOW() + INTERVAL %d HOUR'):format(hours)), { citizenid, mine, number })

    local viewer = exports.qbx_core:GetPlayerByPhone(number)
    if viewer then
        TriggerClientEvent('highcrest_phone:client:locationNotice', viewer.PlayerData.source, fullName(player))
    end
    return loadSharing(player)
end)

lib.callback.register('highcrest_phone:server:locationStop', function(source, value)
    local player = GetPhoneOwner(source)
    local number = CleanPhoneNumber(value)
    if not player or not number then return end

    MySQL.update.await('DELETE FROM highcrest_location_shares WHERE owner_citizenid = ? AND viewer_number = ?', { player.PlayerData.citizenid, number })
    return loadSharing(player)
end)

-- Removes a friend's share from this viewer's own list.
lib.callback.register('highcrest_phone:server:locationHide', function(source, value)
    local player = GetPhoneOwner(source)
    local number = CleanPhoneNumber(value)
    if not player or not number then return end

    MySQL.update.await('DELETE FROM highcrest_location_shares WHERE owner_number = ? AND viewer_number = ?', { number, player.PlayerData.charinfo.phone })
    return loadSharing(player)
end)

lib.callback.register('highcrest_phone:server:locationFind', function(source, value)
    local player = GetPhoneOwner(source)
    local number = CleanPhoneNumber(value)
    if not player or not number then return end

    local allowed = MySQL.scalar.await([[
        SELECT 1 FROM highcrest_location_shares
        WHERE owner_number = ? AND viewer_number = ? AND (expires_at IS NULL OR expires_at > NOW())
    ]], { number, player.PlayerData.charinfo.phone })
    if not allowed then return { error = 'They are no longer sharing with you.' } end

    local owner = exports.qbx_core:GetPlayerByPhone(number)
    local coords = owner and GetPlayerCoords(owner.PlayerData.source)
    if not coords then return { error = 'They are offline right now.' } end
    return coords
end)

local viewersLastUpdate = {}

CreateThread(function()
    while true do
        Wait(UPDATE_INTERVAL_MS)

        local rows = MySQL.query.await([[
            SELECT owner_number, viewer_number FROM highcrest_location_shares
            WHERE expires_at IS NULL OR expires_at > NOW()
        ]]) or {}

        -- Each owner and viewer is looked up once per update, however many shares they have.
        local lookup = {}
        local function findOnline(number)
            if lookup[number] == nil then
                lookup[number] = exports.qbx_core:GetPlayerByPhone(number) or false
            end
            return lookup[number]
        end

        local updates = {}
        local positions = {}
        for _, row in ipairs(rows) do
            local owner = findOnline(row.owner_number)
            local viewer = findOnline(row.viewer_number)
            if owner and viewer then
                local ownerSrc = owner.PlayerData.source
                if positions[ownerSrc] == nil then positions[ownerSrc] = GetPlayerCoords(ownerSrc) or false end
                local coords = positions[ownerSrc]
                if coords then
                    local viewerSrc = viewer.PlayerData.source
                    updates[viewerSrc] = updates[viewerSrc] or {}
                    updates[viewerSrc][#updates[viewerSrc] + 1] = {
                        number = row.owner_number,
                        name = fullName(owner),
                        x = coords.x,
                        y = coords.y,
                    }
                end
            end
        end

        for src, friends in pairs(updates) do
            TriggerClientEvent('highcrest_phone:client:locationUpdate', src, friends)
        end

        -- Anyone who had friends last time but not now gets one empty update, so old blips clear.
        for src in pairs(viewersLastUpdate) do
            if not updates[src] then
                TriggerClientEvent('highcrest_phone:client:locationUpdate', src, {})
            end
        end
        viewersLastUpdate = updates
    end
end)
