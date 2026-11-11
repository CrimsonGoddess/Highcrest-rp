-- Discord profile pictures, looked up with the bot token and refreshed every hour.
-- The token is a server-only convar from secrets.cfg and never reaches players.
local avatars = {}
local AVATAR_REFRESH_MS = 60 * 60 * 1000

local function validDiscordId(id)
    return type(id) == 'string' and id:match('^%d+$') ~= nil and #id >= 15
end

local function defaultAvatar(id)
    local snowflake = math.tointeger(tonumber(id))
    local index = snowflake and ((snowflake >> 22) % 6) or 0
    return ('https://cdn.discordapp.com/embed/avatars/%d.png'):format(index)
end

local function fetchAvatar(id, token)
    PerformHttpRequest(('https://discord.com/api/v10/users/%s'):format(id), function(status, body)
        if status ~= 200 or not body then
            print(('[highcrest_pause] Could not load the Discord profile for %s (HTTP %s)'):format(id, tostring(status)))
            return
        end
        local user = json.decode(body)
        if not user then return end
        if user.avatar then
            local ext = user.avatar:sub(1, 2) == 'a_' and 'gif' or 'png'
            avatars[id] = ('https://cdn.discordapp.com/avatars/%s/%s.%s?size=128'):format(id, user.avatar, ext)
        else
            avatars[id] = defaultAvatar(id)
        end
    end, 'GET', '', { Authorization = 'Bot ' .. token })
end

CreateThread(function()
    while true do
        local token = GetConvar('highcrest_discord_token', '')
        if token ~= '' then
            for _, member in ipairs(Config.staff or {}) do
                if validDiscordId(member.discord) then
                    fetchAvatar(member.discord, token)
                    Wait(1000) -- stay well inside Discord's rate limit
                end
            end
        end
        Wait(AVATAR_REFRESH_MS)
    end
end)

-- Staff list with a live "in the city" flag for anyone with a Discord ID or identifier.
local function getStaff()
    local onlineIds = {}
    for _, playerId in ipairs(GetPlayers()) do
        for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
            onlineIds[id] = true
        end
    end

    local staff = {}
    for _, member in ipairs(Config.staff or {}) do
        local discordId = validDiscordId(member.discord) and member.discord or nil
        local online
        if discordId or member.identifier then
            online = (discordId and onlineIds['discord:' .. discordId] == true)
                or (member.identifier and onlineIds[member.identifier] == true)
                or false
        end
        staff[#staff + 1] = {
            name = member.name,
            role = member.role,
            avatar = discordId and avatars[discordId] or nil,
            -- Without a Discord ID or identifier there's no way to tell, so no dot is shown.
            online = online,
        }
    end
    return staff
end

-- Everything on the character card is read here, on the server, never from the player's game.
lib.callback.register('highcrest_pause:getInfo', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    local info = {
        online = #GetPlayers(),
        maxPlayers = GetConvarInt('sv_maxclients', 48),
        staff = getStaff(),
    }
    if not player then return info end

    local data = player.PlayerData
    local charinfo = data.charinfo or {}
    local job = data.job or {}
    local grade = job.grade or {}

    info.character = {
        name = ('%s %s'):format(charinfo.firstname or '', charinfo.lastname or ''),
        job = job.label or 'Unemployed',
        grade = grade.name or '',
        onDuty = job.onduty == true,
        cash = data.money and data.money.cash or 0,
        bank = data.money and data.money.bank or 0,
        phone = charinfo.phone or '',
        citizenid = data.citizenid or '',
    }
    return info
end)

RegisterNetEvent('highcrest_pause:server:leave', function()
    DropPlayer(source, Config.leaveMessage)
end)
