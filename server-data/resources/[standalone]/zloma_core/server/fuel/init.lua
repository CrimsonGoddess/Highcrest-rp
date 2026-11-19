-- Server fuel facade. Provider implementations are loaded from providers/.
local activeFuelSystem = nil
local authorityReaders = {}

-- A provider must keep fuel in its server-owned ledger, not read owner-authored state bags.
-- Registration is a trusted server integration contract, never a network request.
exports('RegisterFuelAuthority', function(provider, reader)
    local mt = type(reader) == 'table' and getmetatable(reader)
    local callable = type(reader) == 'function' or (type(reader) == 'table'
        and type(rawget(reader, '__cfx_functionReference')) == 'string'
        and type(mt) == 'table' and type(mt.__call) == 'function')
    if type(provider) ~= 'string' or not callable or not GetInvokingResource() then return false end
    authorityReaders[provider] = {reader=reader,resource=GetInvokingResource()}
    return true
end)
exports('ReadAuthoritativeVehicleFuel', function(entity)
    local provider = ZlomaCore.DetectFuel()
    local contract = authorityReaders[provider]
    if not contract then return nil, 'fuel_authority_integration_required:'..tostring(provider) end
    local ok, value = pcall(contract.reader, entity)
    if not ok or type(value) ~= 'number' or value ~= value or value < 0 or value > 100 then
        return nil, 'invalid_authoritative_fuel_read'
    end
    return value
end)

local function refreshFuelDetection()
    activeFuelSystem = ZlomaCore.DetectFuel()
    ZlomaCore.Cache.Fuel = activeFuelSystem
    return activeFuelSystem
end

local function resolveEntity(vehicle)
    if type(vehicle) == 'string' or vehicle > 65535 then return NetworkGetEntityFromNetworkId(vehicle) end
    return vehicle
end

CreateThread(function()
    Wait(0)
    refreshFuelDetection()
    ZlomaCore.Debug(activeFuelSystem and ('[SERVER] Fuel system loaded: ' .. activeFuelSystem)
        or '[zloma_core] [SERVER] No external fuel system detected, using native GTA fuel')
end)

function SetVehicleFuel(vehicle, fuelLevel)
    if not activeFuelSystem then refreshFuelDetection() end
    local entity = resolveEntity(vehicle)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end

    fuelLevel = fuelLevel or 100
    Entity(entity).state:set('fuel', fuelLevel, true)
    local adapter = activeFuelSystem and ZlomaCore.GetAdapter('server', 'Fuel', activeFuelSystem)
    if adapter and type(adapter.set) == 'function' then
        local success = pcall(adapter.set, entity, fuelLevel)
        if not success and ZlomaCore.Config.Debug then
            print('[zloma_core] [SERVER] SetVehicleFuel: Failed to set fuel for ' .. activeFuelSystem)
        end
    end
    return true
end

function GetVehicleFuel(vehicle)
    if not activeFuelSystem then refreshFuelDetection() end
    local entity = resolveEntity(vehicle)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return 100 end

    local adapter = activeFuelSystem and ZlomaCore.GetAdapter('server', 'Fuel', activeFuelSystem)
    if adapter and type(adapter.get) == 'function' then
        local success, result = pcall(adapter.get, entity)
        if success and result then return result end
    end
    return GetVehicleFuelLevel(entity)
end

exports('SetVehicleFuel', SetVehicleFuel)
exports('GetVehicleFuel', GetVehicleFuel)
exports('GetFuelSystem', function() return refreshFuelDetection() end)
exports('GetFuel', GetVehicleFuel)
exports('SetFuel', SetVehicleFuel)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then refreshFuelDetection() end
end)
AddEventHandler('onResourceStop', function(resourceName)
    for provider, contract in pairs(authorityReaders) do
        if contract.resource == resourceName then authorityReaders[provider] = nil end
    end
    if resourceName ~= GetCurrentResourceName() then refreshFuelDetection() end
end)
