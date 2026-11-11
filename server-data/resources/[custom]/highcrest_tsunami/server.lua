-- txAdmin announces each scheduled restart a few times beforehand. At Config.warnAt seconds
-- out, everyone gets the tsunami warning.
local function startWarning(seconds)
    TriggerClientEvent('highcrest_tsunami:client:warn', -1, seconds)
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 200, 16, 46 },
        args = { 'Emergency Alert', Config.text.chat },
    })

    -- Phone alert only for players who carry a phone.
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if exports.ox_inventory:Search(src, 'count', Config.phoneItem) > 0 then
            TriggerClientEvent('highcrest_tsunami:client:phone', src)
        end
    end
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    local seconds = eventData and tonumber(eventData.secondsRemaining)
    if seconds == Config.warnAt then
        startWarning(seconds)
    end
end)

-- Admins can try it without a restart: /tsunamitest (only plays for the admin who runs it).
lib.addCommand('tsunamitest', {
    help = 'Preview the tsunami warning (only you see it)',
    restricted = 'group.admin',
}, function(source)
    TriggerClientEvent('highcrest_tsunami:client:warn', source, Config.warnAt, true)
    TriggerClientEvent('highcrest_tsunami:client:phone', source)
end)
