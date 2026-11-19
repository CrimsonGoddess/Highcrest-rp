-- Ignition: every car has a 1-slot stash (per plate). The engine only runs with that
-- car's key sitting in it. A key left in the ignition stays with the car.
local Config = require 'config.shared'
local Utils = require 'modules.utils.server'

local PREFIX = 'ignition_'
local STATE = 'ignitionKey'
local registered = {}

if not Config.Ignition or not Config.Ignition.enabled then return {} end

local function stashId(plate)
    return PREFIX .. plate
end

local function ensureStash(plate)
    local id = stashId(plate)

    if not registered[id] then
        exports.ox_inventory:RegisterStash(id, Config.Ignition.label or 'Ignition', 1, 1000)
        registered[id] = true
    end

    return id
end

---The vehicle `source` is driving, optionally only if its plate matches.
local function driverVehicle(source, plate)
    local ped = GetPlayerPed(source)
    local vehicle = ped ~= 0 and GetVehiclePedIsIn(ped, false) or 0

    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then return end
    if plate and Utils:trim(GetVehicleNumberPlateText(vehicle)) ~= plate then return end

    return vehicle
end

local function isKeyFor(item, plate)
    return type(item) == 'table'
        and item.name == 'car_key'
        and type(item.metadata) == 'table'
        and type(item.metadata.plate) == 'string'
        and Utils:trim(item.metadata.plate) == plate
end

---Reads the stash back (never trusts a hook payload, another hook may still cancel the move).
local function syncState(vehicle, plate)
    local hasKey = false

    for _, item in pairs(exports.ox_inventory:GetInventoryItems(ensureStash(plate)) or {}) do
        if isKeyFor(item, plate) then
            hasKey = true
            break
        end
    end

    Entity(vehicle).state:set(STATE, hasKey, true)
end

-- Seat changed: the driver gets this car's ignition as the slot in their inventory,
-- anyone else loses it. Also recomputes the key state (lost when a car respawns).
RegisterNetEvent('p_vehiclekeys:syncIgnition', function()
    local src = source
    local vehicle = driverVehicle(src)

    if not vehicle then
        return exports.ox_inventory:setIgnition(src, nil)
    end

    local plate = Utils:trim(GetVehicleNumberPlateText(vehicle))
    local id = ensureStash(plate)

    syncState(vehicle, plate)
    exports.ox_inventory:setIgnition(src, id)
end)

AddEventHandler('playerDropped', function()
    exports.ox_inventory:setIgnition(source, nil)
end)

CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do Wait(500) end

    -- the ignition is only reachable through the inventory slot, never opened as a stash
    exports.ox_inventory:registerHook('openInventory', function()
        return false
    end, { inventoryFilter = { '^' .. PREFIX } })

    -- only this car's key may go in, and only by its driver
    exports.ox_inventory:registerHook('swapItems', function(payload)
        local toId, fromId = tostring(payload.toInventory), tostring(payload.fromInventory)
        local toIgnition = toId:find('^' .. PREFIX) ~= nil
        local fromIgnition = fromId:find('^' .. PREFIX) ~= nil
        local plate = (toIgnition and toId or fromId):sub(#PREFIX + 1)
        local vehicle = driverVehicle(payload.source, plate)

        if not vehicle then return false end

        -- the item that ends up inside the ignition after this move
        local entering = (toIgnition and not fromIgnition and payload.fromSlot)
            or (fromIgnition and not toIgnition and payload.action == 'swap' and payload.toSlot)

        if entering and not isKeyFor(entering, plate) then return false end

        SetTimeout(250, function()
            if DoesEntityExist(vehicle) then syncState(vehicle, plate) end
        end)

        return true
    end, { inventoryFilter = { '^' .. PREFIX } })
end)

return {}
