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
    'garageGet', 'garageLocate',
    'mailGet', 'mailRead', 'mailDelete',
}) do
    RegisterNUICallback(name, function(data, cb)
        cb(lib.callback.await('highcrest_phone:server:' .. name, false, data) or false)
    end)
end

local EMPIRE_ACTIONS = {
    overview = true, business = true, buy = true, sell = true, leave = true,
    deposit = true, withdraw = true, pay = true,
    hire = true, respondOffer = true, fire = true, setRank = true, saveRank = true,
}

RegisterNUICallback('empire', function(data, cb)
    if not EMPIRE_ACTIONS[data.op] then return cb(false) end
    cb(lib.callback.await('highcrest_empire:server:' .. data.op, false, data.args) or false)
end)

local approvedMailEvents = {}
for _, event in ipairs(Config.mailButtonEvents) do
    approvedMailEvents[event] = true
end

RegisterNUICallback('mailAction', function(id, cb)
    local result = lib.callback.await('highcrest_phone:server:mailAction', false, id)
    if result and result.event and approvedMailEvents[result.event] then
        TriggerEvent(result.event, result.data)
    end
    cb(result or false)
end)

RegisterNetEvent('highcrest_phone:client:newMail', function(mail)
    SendNUIMessage({ action = 'newMail' })
    lib.notify({ title = 'New mail', description = mail.subject or mail.sender or '', position = NOTIFY_POSITION })
end)

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

-- Garage valet. The server takes the vehicle out at a road near the player; this client
-- puts a driver in it, drives it over, and lets the driver walk off.
local VALET_BLIP_SPRITE = 225
local VALET_BLIP_COLOUR = 5
local VALET_SPEED = 18.0
local VALET_DRIVING_STYLE = 786603
local VALET_ARRIVE_DISTANCE = 15.0
local VALET_RETARGET_DISTANCE = 25.0
local VALET_STUCK_MS = 20000

local valetActive = false
local valetPed, valetBlip

local function findValetStart()
    local origin = GetEntityCoords(cache.ped)
    local limits = Config.valet.spawnDistance
    for _ = 1, 15 do
        local angle = math.random() * 2 * math.pi
        local distance = math.random(limits.min, limits.max)
        local found, node, heading = GetClosestVehicleNodeWithHeading(
            origin.x + math.cos(angle) * distance, origin.y + math.sin(angle) * distance, origin.z, 1, 3.0, 0)
        if found then
            local away = #(vec2(node.x, node.y) - vec2(origin.x, origin.y))
            if away >= limits.min * 0.6 and away <= limits.max * 1.4 and not IsAnyVehicleNearPoint(node.x, node.y, node.z, 4.0) then
                return node, heading
            end
        end
    end
end

-- The nearest road to the player, so the valet doesn't try to drive into a building.
local function valetDestination()
    local coords = GetEntityCoords(cache.ped)
    local found, node = GetClosestVehicleNode(coords.x, coords.y, coords.z, 1, 3.0, 0)
    if found and #(node - coords) < 60.0 then return node end
    return coords
end

local function waitForVehicle(netId)
    local ok, vehicle = pcall(lib.waitFor, function()
        if NetworkDoesEntityExistWithNetworkId(netId) then
            local entity = NetToVeh(netId)
            if entity ~= 0 and DoesEntityExist(entity) then return entity end
        end
    end, nil, 10000)
    return ok and vehicle or nil
end

local function takeControl(entity)
    local deadline = GetGameTimer() + 3000
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < deadline do
        NetworkRequestControlOfEntity(entity)
        Wait(50)
    end
end

local function driverLeaves(vehicle)
    if not valetPed or not DoesEntityExist(valetPed) then return end
    local ped = valetPed
    valetPed = nil
    if IsPedInVehicle(ped, vehicle, false) then
        TaskVehicleTempAction(ped, vehicle, 27, 3000)
        local deadline = GetGameTimer() + 4000
        while GetEntitySpeed(vehicle) > 0.5 and GetGameTimer() < deadline do Wait(100) end
        TaskLeaveVehicle(ped, vehicle, 0)
        deadline = GetGameTimer() + 6000
        while IsPedInVehicle(ped, vehicle, false) and GetGameTimer() < deadline do Wait(100) end
    end
    SetBlockingOfNonTemporaryEvents(ped, false)
    TaskWanderStandard(ped, 10.0, 10)
    SetPedKeepTask(ped, true)
    SetEntityAsNoLongerNeeded(ped)
end

local function placeAtRoad(vehicle, ped)
    local coords = GetEntityCoords(ped)
    local found, node, heading = GetClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, 1, 3.0, 0)
    if found then
        SetEntityCoords(vehicle, node.x, node.y, node.z, false, false, false, false)
        SetEntityHeading(vehicle, heading)
        SetVehicleOnGroundProperly(vehicle)
    end
end

local function runValet(netId, start)
    local vehicle = waitForVehicle(netId)
    if not vehicle then
        SetNewWaypoint(start.x, start.y)
        lib.notify({ description = 'Your vehicle is parked nearby. A waypoint is set.', position = NOTIFY_POSITION })
        return
    end
    takeControl(vehicle)

    local model = joaat(Config.valet.driverModel)
    lib.requestModel(model)
    valetPed = CreatePedInsideVehicle(vehicle, 26, model, -1, true, false)
    SetModelAsNoLongerNeeded(model)
    SetBlockingOfNonTemporaryEvents(valetPed, true)
    SetDriverAbility(valetPed, 1.0)
    SetDriverAggressiveness(valetPed, 0.0)
    SetVehicleEngineOn(vehicle, true, true, false)

    valetBlip = AddBlipForEntity(vehicle)
    SetBlipSprite(valetBlip, VALET_BLIP_SPRITE)
    SetBlipColour(valetBlip, VALET_BLIP_COLOUR)
    setBlipName(valetBlip, 'Valet')

    local target = valetDestination()
    TaskVehicleDriveToCoordLongrange(valetPed, vehicle, target.x, target.y, target.z, VALET_SPEED, VALET_DRIVING_STYLE, 8.0)

    local giveUpAt = GetGameTimer() + Config.valet.giveUpSeconds * 1000
    local bestDistance, lastProgress = math.huge, GetGameTimer()
    while true do
        Wait(500)
        if not DoesEntityExist(vehicle) or not valetPed or not DoesEntityExist(valetPed) or IsPedDeadOrDying(valetPed, true) then break end
        -- Someone took the wheel from the valet: they are done.
        if GetPedInVehicleSeat(vehicle, -1) ~= valetPed then break end

        local distance = #(GetEntityCoords(vehicle) - GetEntityCoords(cache.ped))
        if distance < VALET_ARRIVE_DISTANCE then break end

        if distance < bestDistance - 5.0 then
            bestDistance, lastProgress = distance, GetGameTimer()
        end
        local now = GetGameTimer()
        if now > giveUpAt or now - lastProgress > VALET_STUCK_MS then
            placeAtRoad(vehicle, cache.ped)
            break
        end

        local newTarget = valetDestination()
        if #(newTarget - target) > VALET_RETARGET_DISTANCE then
            target = newTarget
            TaskVehicleDriveToCoordLongrange(valetPed, vehicle, target.x, target.y, target.z, VALET_SPEED, VALET_DRIVING_STYLE, 8.0)
        end
    end

    if DoesEntityExist(vehicle) then
        driverLeaves(vehicle)
        lib.notify({ description = 'Your vehicle has been dropped off.', type = 'success', position = NOTIFY_POSITION })
    end
end

RegisterNUICallback('garageValet', function(plate, cb)
    if type(plate) ~= 'string' then return cb(false) end
    if valetActive then return cb({ error = 'A valet is already on the way.' }) end

    local start, heading = findValetStart()
    if not start then return cb({ error = 'There is no road nearby for the valet to use.' }) end

    local result = lib.callback.await('highcrest_phone:server:garageValet', false, {
        plate = plate, x = start.x, y = start.y, z = start.z, heading = heading,
    })
    if result and result.netId then
        valetActive = true
        lib.notify({ description = 'A valet is bringing your vehicle.', position = NOTIFY_POSITION })
        CreateThread(function()
            local ok, err = pcall(runValet, result.netId, start)
            if not ok then print(('[highcrest_phone] valet failed: %s'):format(err)) end
            if valetBlip then RemoveBlip(valetBlip) valetBlip = nil end
            if valetPed and DoesEntityExist(valetPed) then SetEntityAsNoLongerNeeded(valetPed) end
            valetPed = nil
            valetActive = false
        end)
    end
    cb(result or false)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if valetBlip then RemoveBlip(valetBlip) end
    if valetPed and DoesEntityExist(valetPed) then DeleteEntity(valetPed) end
end)
