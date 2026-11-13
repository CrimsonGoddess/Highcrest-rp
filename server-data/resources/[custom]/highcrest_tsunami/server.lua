-- txAdmin announces each scheduled restart a few times beforehand. At Config.timeline.alertAt
-- seconds out (3 minutes), the tsunami starts for everyone; each client runs the timeline
-- (alert, storm, blackout, flood). The server also sets the storm and the blackout server-wide
-- through Renewed-Weathersync at the same moments. The restart resets everything.

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

local started = false

local function startTsunami()
    if started then return end
    started = true
    local tl = Config.timeline
    TriggerClientEvent('highcrest_tsunami:client:start', -1)
    TriggerClientEvent('highcrest_tv:client:emergency', -1, tl.alertAt, Config.text)
    alertPhones(everyone())
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 200, 16, 46 },
        args = { 'Emergency Alert', Config.text.chat },
    })

    if Config.storm.enabled then
        SetTimeout((tl.alertAt - tl.stormAt) * 1000, function()
            GlobalState.weather = { weather = Config.storm.weather, time = 9000000, windSpeed = Config.storm.wind * 2 }
        end)
    end
    if Config.blackout.enabled then
        SetTimeout((tl.alertAt - tl.lightsAt) * 1000, function() GlobalState.blackOut = true end)
    end
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    local seconds = eventData and tonumber(eventData.secondsRemaining)
    if seconds == Config.timeline.alertAt then startTsunami() end
end)

-- /tsunamitest: the full 3-minute timeline for the admin who runs it only (ticker, phone, nearest
-- TV, storm, blackout, flood), then everything goes back. /tsunamistop ends it early.
lib.addCommand('tsunamitest', {
    help = 'Preview the tsunami (3 minutes, only you see it; everything goes back after)',
    restricted = 'group.admin',
}, function(source)
    TriggerClientEvent('highcrest_tsunami:client:preview', source)
    TriggerClientEvent('highcrest_tv:client:emergency', source, Config.timeline.alertAt, Config.text)
    alertPhones({ source })
end)

lib.addCommand('tsunamistop', {
    help = 'End your tsunami preview now',
    restricted = 'group.admin',
}, function(source)
    TriggerClientEvent('highcrest_tsunami:client:stopPreview', source)
end)
