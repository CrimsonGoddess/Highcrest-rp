-- Client fuel facade. Provider implementations are loaded from providers/.
local activeFuelSystem = nil

local function refreshFuelDetection()
    activeFuelSystem = ZlomaCore.DetectFuel()
    ZlomaCore.Cache.Fuel = activeFuelSystem
    return activeFuelSystem
end

CreateThread(function()
    Wait(0)
    refreshFuelDetection()
    ZlomaCore.Debug(activeFuelSystem and ('Fuel system loaded: ' .. activeFuelSystem)
        or '[zloma_core] No external fuel system detected, using native GTA fuel')
end)

function GetVehicleFuel(vehicle)
    if not activeFuelSystem then refreshFuelDetection() end
    if not DoesEntityExist(vehicle) then return 100 end

    local adapter = activeFuelSystem and ZlomaCore.GetAdapter('client', 'Fuel', activeFuelSystem)
    if adapter and type(adapter.get) == 'function' then
        local success, result = pcall(adapter.get, vehicle)
        if success and result then return result end
    end
    return GetVehicleFuelLevel(vehicle)
end

function SetVehicleFuel(vehicle, fuelLevel)
    if not activeFuelSystem then refreshFuelDetection() end
    if not DoesEntityExist(vehicle) then return end

    fuelLevel = fuelLevel or 100
    SetVehicleFuelLevel(vehicle, fuelLevel + 0.0)
    local adapter = activeFuelSystem and ZlomaCore.GetAdapter('client', 'Fuel', activeFuelSystem)
    if adapter and type(adapter.set) == 'function' then pcall(adapter.set, vehicle, fuelLevel) end
end

exports('GetVehicleFuel', GetVehicleFuel)
exports('SetVehicleFuel', SetVehicleFuel)
exports('GetFuelSystem', function() return refreshFuelDetection() end)
exports('GetFuel', GetVehicleFuel)
exports('SetFuel', SetVehicleFuel)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then refreshFuelDetection() end
end)
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then refreshFuelDetection() end
end)
