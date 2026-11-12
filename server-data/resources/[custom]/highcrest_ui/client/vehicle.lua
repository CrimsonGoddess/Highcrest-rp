-- Highcrest vehicle UI: the round speedometer (bottom right) and the F2 vehicle menu
-- (seats, doors, hood, trunk, windows, engine, lights, blinkers, hazards, interior light, neon).

local MPH = 2.236936

local function isOn(v) return v == true or v == 1 end

---------------------------------------------------------------------------
-- Speedometer
---------------------------------------------------------------------------

local function gearText(vehicle, speed)
    local gear = GetVehicleCurrentGear(vehicle)
    if speed > 0.5 and GetEntitySpeedVector(vehicle, true).y < -0.5 then return 'R' end
    if gear == 0 then return 'R' end
    if speed < 1.0 then return 'N' end
    return tostring(gear)
end

CreateThread(function()
    local shown = false
    while true do
        local vehicle = cache.vehicle
        local visible = vehicle and LocalPlayer.state.isLoggedIn == true and not IsPauseMenuActive()
            and not IsNuiFocused() and DoesEntityExist(vehicle)
        if not visible then
            if shown then SendNUIMessage({ speedo = { visible = false } }) end
            shown = false
            Wait(300)
        else
            shown = true
            local speed = GetEntitySpeed(vehicle) * MPH
            local class = GetVehicleClass(vehicle)
            local cycle = class == 13
            local air = class == 15 or class == 16
            local signals = GetVehicleIndicatorLights(vehicle)
            local _, lightsOn, highBeams = GetVehicleLightsState(vehicle)
            local fuel = Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
            SendNUIMessage({
                speedo = {
                    visible = true,
                    speed = math.floor(speed + 0.5),
                    rpm = cycle and 0 or GetVehicleCurrentRpm(vehicle),
                    gear = cycle and '' or gearText(vehicle, speed),
                    fuel = not cycle and math.floor(fuel + 0.5) or nil,
                    engine = cycle and nil or math.floor(math.max(0, GetVehicleEngineHealth(vehicle)) / 10),
                    belt = not cycle and not air and (LocalPlayer.state.seatbelt or LocalPlayer.state.harness) == true or nil,
                    beltNeeded = not cycle and not air,
                    lights = isOn(highBeams) and 2 or (isOn(lightsOn) and 1 or 0),
                    left = signals == 1 or signals == 3,
                    right = signals == 2 or signals == 3,
                    engineOn = GetIsVehicleEngineRunning(vehicle),
                    altitude = air and math.floor(GetEntityHeightAboveGround(vehicle) * 3.28084) or nil,
                },
            })
            Wait(60)
        end
    end
end)

---------------------------------------------------------------------------
-- Blinkers and hazards, synced so everyone sees them
---------------------------------------------------------------------------

local function applySignals(vehicle, mask)
    SetVehicleIndicatorLights(vehicle, 1, mask == 1 or mask == 3) -- left
    SetVehicleIndicatorLights(vehicle, 0, mask == 2 or mask == 3) -- right
end

AddStateBagChangeHandler('hcSignals', nil, function(bagName, _, value)
    local entity = GetEntityFromStateBagName(bagName)
    if entity ~= 0 and DoesEntityExist(entity) then applySignals(entity, value or 0) end
end)

---------------------------------------------------------------------------
-- F2 menu
---------------------------------------------------------------------------

local menuVehicle
local SEAT_NAMES = { [-1] = 'Driver', [0] = 'Passenger', [1] = 'Rear left', [2] = 'Rear right' }

local function targetVehicle()
    if cache.vehicle then return cache.vehicle end
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.5, false)
    if vehicle and GetVehicleDoorLockStatus(vehicle) < 2 then return vehicle end
end

local function takeControl(vehicle)
    if NetworkHasControlOfEntity(vehicle) then return true end
    NetworkRequestControlOfEntity(vehicle)
    local timeout = GetGameTimer() + 800
    while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do
        Wait(20)
        NetworkRequestControlOfEntity(vehicle)
    end
    return NetworkHasControlOfEntity(vehicle)
end

local windowsDown = {}

local function menuState(vehicle)
    local inside = cache.vehicle == vehicle
    local seats = {}
    local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
    for seat = -1, maxPassengers - 1 do
        local occupant = GetPedInVehicleSeat(vehicle, seat)
        seats[#seats + 1] = {
            seat = seat,
            name = SEAT_NAMES[seat] or ('Seat %d'):format(seat + 2),
            mine = occupant == cache.ped,
            taken = occupant ~= 0 and occupant ~= cache.ped,
        }
    end
    local doors = {}
    for door = 0, 5 do
        if GetIsDoorValid(vehicle, door) and not IsVehicleDoorDamaged(vehicle, door) then
            doors[#doors + 1] = { door = door, open = GetVehicleDoorAngleRatio(vehicle, door) > 0.1 }
        end
    end
    local key = VehToNet(vehicle)
    local windows = {}
    for window = 0, 3 do
        windows[#windows + 1] = { window = window, down = windowsDown[key] and windowsDown[key][window] == true }
    end
    local _, lightsOn, highBeams = GetVehicleLightsState(vehicle)
    local signals = Entity(vehicle).state.hcSignals or 0
    local hasNeon = false
    for i = 0, 3 do if IsVehicleNeonLightEnabled(vehicle, i) then hasNeon = true end end
    return {
        name = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))),
        plate = GetVehicleNumberPlateText(vehicle),
        inside = inside,
        driver = inside and GetPedInVehicleSeat(vehicle, -1) == cache.ped,
        seats = seats, doors = doors, windows = windows,
        engine = GetIsVehicleEngineRunning(vehicle),
        lights = isOn(lightsOn) or isOn(highBeams),
        signals = signals,
        interior = IsVehicleInteriorLightOn(vehicle),
        neon = hasNeon or (Entity(vehicle).state.hcNeonOff == true),
        neonOn = hasNeon,
    }
end

local function closeMenu()
    menuVehicle = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ vehmenu = { open = false } })
end

local function openMenu()
    if menuVehicle then return closeMenu() end
    if IsPauseMenuActive() or IsNuiFocused() then return end
    local vehicle = targetVehicle()
    if not vehicle then
        return lib.notify({ description = 'Get in a vehicle, or stand next to an unlocked one.', type = 'error' })
    end
    menuVehicle = vehicle
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ vehmenu = { open = true, state = menuState(vehicle) } })
end

RegisterCommand('vehmenu', openMenu, false)
RegisterKeyMapping('vehmenu', 'Vehicle menu (seats, doors, lights, blinkers)', 'keyboard', 'F2')

RegisterNUICallback('vehClose', function(_, cb) closeMenu() cb(1) end)

RegisterNUICallback('vehAction', function(data, cb)
    local vehicle = menuVehicle
    if not vehicle or not DoesEntityExist(vehicle) or type(data) ~= 'table' then closeMenu() return cb(false) end
    local inside = cache.vehicle == vehicle
    local isDriver = inside and GetPedInVehicleSeat(vehicle, -1) == cache.ped
    local action = data.action
    local message

    if action == 'seat' then
        local seat = tonumber(data.seat)
        if not inside then
            message = 'Get in the vehicle first.'
        elseif GetEntitySpeed(vehicle) * MPH > 5.0 then
            message = 'Slow down to change seats.'
        elseif not IsVehicleSeatFree(vehicle, seat) then
            message = 'That seat is taken.'
        else
            SetPedIntoVehicle(cache.ped, vehicle, seat)
        end
    elseif action == 'door' then
        local door = tonumber(data.door)
        if takeControl(vehicle) then
            if GetVehicleDoorAngleRatio(vehicle, door) > 0.1 then
                SetVehicleDoorShut(vehicle, door, false)
            else
                SetVehicleDoorOpen(vehicle, door, false, false)
            end
        end
    elseif action == 'window' then
        local window = tonumber(data.window)
        local key = VehToNet(vehicle)
        windowsDown[key] = windowsDown[key] or {}
        if takeControl(vehicle) then
            if windowsDown[key][window] then
                RollUpWindow(vehicle, window)
                windowsDown[key][window] = nil
            else
                RollDownWindow(vehicle, window)
                windowsDown[key][window] = true
            end
        end
    elseif action == 'engine' then
        if isDriver then ExecuteCommand('toggleengine') else message = 'Only the driver can do that.' end
    elseif action == 'lights' then
        if not isDriver then
            message = 'Only the driver can do that.'
        else
            local _, lightsOn, highBeams = GetVehicleLightsState(vehicle)
            SetVehicleLights(vehicle, (isOn(lightsOn) or isOn(highBeams)) and 1 or 2)
        end
    elseif action == 'left' or action == 'right' or action == 'hazards' then
        if not isDriver then
            message = 'Only the driver can do that.'
        else
            local current = Entity(vehicle).state.hcSignals or 0
            local want = action == 'left' and 1 or action == 'right' and 2 or 3
            local mask = current == want and 0 or want
            Entity(vehicle).state:set('hcSignals', mask, true)
            applySignals(vehicle, mask)
        end
    elseif action == 'interior' then
        if inside then SetVehicleInteriorlight(vehicle, not IsVehicleInteriorLightOn(vehicle)) end
    elseif action == 'neon' then
        if not isDriver then
            message = 'Only the driver can do that.'
        elseif takeControl(vehicle) then
            local state = Entity(vehicle).state
            local saved = state.hcNeonOff
            if saved then
                for i = 0, 3 do SetVehicleNeonLightEnabled(vehicle, i, saved[i + 1] == true) end
                state:set('hcNeonOff', nil, true)
            else
                local was = {}
                for i = 0, 3 do was[i + 1] = IsVehicleNeonLightEnabled(vehicle, i) end
                state:set('hcNeonOff', was, true)
                for i = 0, 3 do SetVehicleNeonLightEnabled(vehicle, i, false) end
            end
        end
    end

    Wait(150)
    if menuVehicle and DoesEntityExist(vehicle) then
        cb({ state = menuState(vehicle), message = message })
    else
        cb({ message = message })
    end
end)

-- Leaving the vehicle (or it disappearing) closes the menu.
CreateThread(function()
    while true do
        Wait(500)
        if menuVehicle and (not DoesEntityExist(menuVehicle)
            or #(GetEntityCoords(cache.ped) - GetEntityCoords(menuVehicle)) > 6.0) then
            closeMenu()
        end
    end
end)
