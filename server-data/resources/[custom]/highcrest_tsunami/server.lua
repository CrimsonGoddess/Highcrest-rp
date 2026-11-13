-- txAdmin announces each scheduled restart a few times beforehand. At Config.warnAt seconds out,
-- the tsunami arrives: an alert on everyone's phone and the nearest TV, an emergency ticker across
-- the top of the screen, a storm, a city-wide blackout and the sea rising over the city until
-- the restart. Nothing blocks the screen.

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

local function startTsunami(seconds)
    TriggerClientEvent('highcrest_tsunami:client:start', -1, seconds)
    TriggerClientEvent('highcrest_tv:client:emergency', -1, seconds, Config.text)
    alertPhones(everyone())
    -- Server-wide storm and blackout through Renewed-Weathersync (it already stopped its own
    -- weather cycle for the scheduled restart). The restart resets both.
    if Config.storm.enabled then
        GlobalState.weather = { weather = Config.storm.weather, time = 9000000, windSpeed = Config.storm.wind * 2 }
    end
    if Config.blackout.enabled then
        SetTimeout(Config.blackout.after * 1000, function() GlobalState.blackOut = true end)
    end
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 200, 16, 46 },
        args = { 'Emergency Alert', Config.text.chat },
    })
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    local seconds = eventData and tonumber(eventData.secondsRemaining)
    if seconds == Config.warnAt then startTsunami(seconds) end
end)

-- /tsunamitest: only the admin who runs it sees it (ticker, phone, nearest TV, storm, blackout,
-- flood), faster, and everything goes back to normal afterwards. /tsunamistop ends it early.
lib.addCommand('tsunamitest', {
    help = 'Preview the tsunami (only you see it; everything goes back to normal after)',
    restricted = 'group.admin',
}, function(source)
    local f = Config.flood
    TriggerClientEvent('highcrest_tsunami:client:preview', source)
    TriggerClientEvent('highcrest_tv:client:emergency', source, f.previewSeconds + f.previewHold, Config.text)
    alertPhones({ source })
end)

lib.addCommand('tsunamistop', {
    help = 'End your tsunami preview now',
    restricted = 'group.admin',
}, function(source)
    TriggerClientEvent('highcrest_tsunami:client:stopPreview', source)
end)
