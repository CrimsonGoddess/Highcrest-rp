-- Staff list with a live "in the city" flag for anyone whose identifier is set.
local function getStaff()
    local onlineIds = {}
    for _, playerId in ipairs(GetPlayers()) do
        for _, id in ipairs(GetPlayerIdentifiers(playerId)) do
            onlineIds[id] = true
        end
    end

    local staff = {}
    for _, member in ipairs(Config.staff or {}) do
        staff[#staff + 1] = {
            name = member.name,
            role = member.role,
            -- Without an identifier there's no way to tell, so no dot is shown.
            online = member.identifier and onlineIds[member.identifier] == true or nil,
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
