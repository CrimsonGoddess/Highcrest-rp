if Config.Phone ~= 'custom' then
    return
end

-- Highcrest phone: numbers are the character's charinfo.phone in qbx_core.
function Framework.GetPhoneNumber(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.charinfo.phone or nil
end

function Framework.GetPhoneNumberByIdentifier(identifier)
    local player = exports.qbx_core:GetPlayerByCitizenId(identifier)
    if player then return player.PlayerData.charinfo.phone end
    local charinfo = MySQL.scalar.await('SELECT charinfo FROM players WHERE citizenid = ?', { identifier })
    local decoded = charinfo and json.decode(charinfo)
    return decoded and decoded.phone or nil
end
