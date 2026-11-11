-- Everything on the character card is read here, on the server, never from the player's game.
lib.callback.register('highcrest_pause:getInfo', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    local info = {
        online = #GetPlayers(),
        maxPlayers = GetConvarInt('sv_maxclients', 48),
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
