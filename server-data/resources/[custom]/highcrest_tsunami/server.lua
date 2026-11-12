-- txAdmin announces each scheduled restart a few times beforehand. At Config.warnAt seconds out,
-- the tsunami arrives: the on-screen emergency broadcast, an alert on everyone's phone, the
-- emergency broadcast on every TV, and the sea rising until the restart.

local function alertPhones(targets)
    for _, src in ipairs(targets) do
        if exports.ox_inventory:Search(src, 'count', Config.phoneItem) > 0 then
            TriggerClientEvent('highcrest_phone:client:emergency', src, Config.text.headline, Config.text.phone, 15)
        end
    end
end

local function everyone()
    local list = {}
    for _, id in ipairs(GetPlayers()) do list[#list + 1] = tonumber(id) end
    return list
end

local function startWarning(seconds)
    TriggerClientEvent('highcrest_tsunami:client:warn', -1, seconds)
    TriggerClientEvent('highcrest_tv:client:emergency', -1, seconds, Config.text)
    TriggerClientEvent('highcrest_tsunami:client:flood', -1, seconds)
    TriggerClientEvent('highcrest_tsunami:client:storm', -1, seconds)
    -- Server-wide thunderstorm with strong wind (Renewed-Weathersync applies it for everyone).
    if Config.storm.enabled then GlobalState.weather = { weather = Config.storm.weather, time = 9000000, windSpeed = Config.storm.wind * 2 } end
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 200, 16, 46 },
        args = { 'Emergency Alert', Config.text.chat },
    })
    alertPhones(everyone())
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    local seconds = eventData and tonumber(eventData.secondsRemaining)
    if seconds == Config.warnAt then
        startWarning(seconds)
    end
end)

-- Admins can try the whole thing without a restart: /tsunamitest. Only the admin who runs it
-- sees it (screen, phone, nearest TV and the flood), and the water drains again afterwards.
lib.addCommand('tsunamitest', {
    help = 'Preview the tsunami (only you see it; the water goes back to normal after)',
    restricted = 'group.admin',
}, function(source)
    local f = Config.flood
    TriggerClientEvent('highcrest_tsunami:client:warn', source, f.previewSeconds, true)
    TriggerClientEvent('highcrest_tv:client:emergency', source, f.previewSeconds + f.previewHold, Config.text)
    TriggerClientEvent('highcrest_tsunami:client:flood', source, f.previewSeconds, f.previewHold)
    TriggerClientEvent('highcrest_tsunami:client:storm', source, f.previewSeconds, f.previewHold)
    alertPhones({ source })
end)
