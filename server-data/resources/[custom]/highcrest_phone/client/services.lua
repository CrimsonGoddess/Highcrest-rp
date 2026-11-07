local NOTIFY_POSITION = 'top-left'
local FRIEND_BLIP_SPRITE = 280
local FRIEND_BLIP_COLOUR = 5
local EMERGENCY_BLIP_SPRITE = 161
local EMERGENCY_BLIP_LIFETIME_MS = 300000
local BLIP_COLOUR = { police = 38, ems = 1 }

local friendBlips = {}

local function setBlipName(blip, name)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)
end

for _, name in ipairs({
    'locationGet', 'locationShare', 'locationStop', 'locationHide', 'locationFind',
    'taxiGet', 'taxiRequest', 'taxiAccept', 'taxiEnd',
    'emergencyCall', 'emergencyGet',
}) do
    RegisterNUICallback(name, function(data, cb)
        cb(lib.callback.await('highcrest_phone:server:' .. name, false, data) or false)
    end)
end

RegisterNUICallback('setWaypoint', function(data, cb)
    local x, y = tonumber(data.x), tonumber(data.y)
    if x and y then
        SetNewWaypoint(x, y)
        lib.notify({ description = 'Waypoint set on your map.', position = NOTIFY_POSITION })
    end
    cb(1)
end)

-- Friend positions arrive every few seconds, and anyone missing from the update loses their blip.
RegisterNetEvent('highcrest_phone:client:locationUpdate', function(friends)
    local seen = {}
    for _, friend in ipairs(friends) do
        seen[friend.number] = true
        local blip = friendBlips[friend.number]
        if blip then
            SetBlipCoords(blip, friend.x, friend.y, 0.0)
        else
            blip = AddBlipForCoord(friend.x, friend.y, 0.0)
            SetBlipSprite(blip, FRIEND_BLIP_SPRITE)
            SetBlipColour(blip, FRIEND_BLIP_COLOUR)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, false)
            setBlipName(blip, friend.name)
            friendBlips[friend.number] = blip
        end
    end

    for number, blip in pairs(friendBlips) do
        if not seen[number] then
            RemoveBlip(blip)
            friendBlips[number] = nil
        end
    end
end)

RegisterNetEvent('highcrest_phone:client:locationNotice', function(name)
    lib.notify({ title = 'Location shared', description = ('%s is sharing their location with you.'):format(name), position = NOTIFY_POSITION })
end)

RegisterNetEvent('highcrest_phone:client:taxiAlert', function(request)
    local note = request.note ~= '' and (': ' .. request.note) or ''
    lib.notify({ title = 'Taxi request', description = ('%s needs a ride%s'):format(request.name, note), position = NOTIFY_POSITION })
end)

RegisterNetEvent('highcrest_phone:client:taxiAccepted', function(driver)
    lib.notify({ title = 'Taxi on the way', description = ('%s is coming to pick you up. Their number is %s.'):format(driver.name, driver.number), position = NOTIFY_POSITION })
end)

RegisterNetEvent('highcrest_phone:client:taxiEnded', function(reason)
    lib.notify({ title = 'Taxi', description = reason, position = NOTIFY_POSITION })
end)

RegisterNetEvent('highcrest_phone:client:emergency', function(call)
    lib.notify({
        title = ('911: %s'):format(call.label),
        description = ('%s (%s): %s'):format(call.name, call.number, call.message),
        type = 'error',
        duration = 15000,
        position = NOTIFY_POSITION,
    })

    local blip = AddBlipForCoord(call.x, call.y, 0.0)
    SetBlipSprite(blip, EMERGENCY_BLIP_SPRITE)
    SetBlipColour(blip, BLIP_COLOUR[call.service] or 1)
    SetBlipScale(blip, 1.2)
    SetBlipFlashes(blip, true)
    setBlipName(blip, ('911: %s'):format(call.label))
    SetTimeout(EMERGENCY_BLIP_LIFETIME_MS, function() RemoveBlip(blip) end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, blip in pairs(friendBlips) do RemoveBlip(blip) end
end)
