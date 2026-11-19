-- ZLOMA CORE - Client Inventory Wrapper
-- Unified interface for client-side inventory checks
-- Supports: ox_inventory, qb-inventory, qs-inventory, ps-inventory, lj-inventory,
-- codem-inventory, tgiann-inventory, origen-inventory, core_inventory, ak47_inventory,
-- jaksam_inventory, jpr-inventory, S-Inventory

local InventoryType = nil
local InventoryResources = {
    ['ox_inventory'] = { 'ox_inventory' },
    ['qb-inventory'] = { 'qb-inventory' },
    ['qs-inventory'] = { 'qs-inventory' },
    ['ps-inventory'] = { 'ps-inventory' },
    ['codem-inventory'] = { 'codem-inventory' },
    ['tgiann-inventory'] = { 'tgiann-inventory' },
    ['origen-inventory'] = { 'origen_inventory', 'origen-inventory' },
    ['core_inventory'] = { 'core_inventory' },
    ['ak47_inventory'] = { 'ak47_inventory' },
    ['jaksam_inventory'] = { 'jaksam_inventory' },
    ['jpr-inventory'] = { 'jpr-inventory' },
    ['S-Inventory'] = { 'S-Inventory', 'S-inventory' }
}

-- ============================================================================
-- QBCore Object Caching (OPTIMIZATION)
-- ============================================================================
-- Cache QBCore object at initialization instead of every function call
local QBCore = nil
local ESX = nil

local function RefreshFrameworkObjects()
    if not QBCore and GetResourceState('qb-core') == 'started' then
        local success, framework = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if success and framework then QBCore = framework end
    end

    if InventoryType == 'S-Inventory' and not ESX and GetResourceState('es_extended') == 'started' then
        local success, framework = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if success and framework then ESX = framework end
    end
end

local function IsInventoryStarted(inventorySystem)
    for _, resourceName in ipairs(InventoryResources[inventorySystem] or {}) do
        if GetResourceState(resourceName) == 'started' then return true end
    end

    return false
end

local function GetActiveInventoryType()
    if InventoryType and IsInventoryStarted(InventoryType) then return InventoryType end

    InventoryType = ZlomaCore.DetectInventory()
    ZlomaCore.Cache.Inventory = InventoryType

    return InventoryType
end

local function RefreshInventoryDetection()
    InventoryType = nil
    InventoryType = GetActiveInventoryType()

    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    else
        QBCore = nil
    end

    if InventoryType == 'S-Inventory' and GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    else
        ESX = nil
    end

    return InventoryType
end


-- Initialize inventory detection and cache framework objects
CreateThread(function()
    -- Give framework and inventory resources time to finish their own start
    -- handlers before caching client objects.
    Wait(ZlomaCore.Config.Timeouts.InitWait or 500)
    RefreshInventoryDetection()

    if InventoryType then
        ZlomaCore.Debug(string.format("Client Inventory loaded: %s", InventoryType))
    end
end)

-- ============================================================================
-- ADD NEW INVENTORY SUPPORT HERE (Client Side)
-- ============================================================================
-- To add client-side support for a new inventory:
-- 1. Add detection in the CreateThread above
-- 2. Add elseif block in GetInventory() below
-- ============================================================================

-- EXPORT: GetInventory() - Get player's full inventory (Client Side)
-- Returns: Table of items (normalized as best as possible)
exports('GetInventory', function()
    local items = {}
    GetActiveInventoryType()
    RefreshFrameworkObjects()

    if InventoryType == 'ox_inventory' then
        -- ox_inventory client export
        if exports.ox_inventory.GetPlayerItems then
            items = exports.ox_inventory:GetPlayerItems()
        end
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        if exports['tgiann-inventory'].GetPlayerItems then
            items = exports['tgiann-inventory']:GetPlayerItems()
        end
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        if exports['origen_inventory'].GetPlayerItems then
            items = exports['origen_inventory']:GetPlayerItems()
        end
        
    elseif InventoryType == 'qb-inventory' then
        -- QBCore / PS / LJ - Get data from cached QBCore object
        -- OPTIMIZED: Uses cached QBCore instead of fetching every call
        if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
            local playerData = QBCore.Functions.GetPlayerData()
            if playerData and playerData.items then
                items = playerData.items
            end
        end
    elseif InventoryType == 'qs-inventory' then
        -- QS Inventory - Client Export
        if exports['qs-inventory'].GetInventory then
            items = exports['qs-inventory']:GetInventory()
        end
    elseif InventoryType == 'codem-inventory' then
        -- Codem might not have client export easily accessible
        if exports['codem-inventory'].GetInventory then
            items = exports['codem-inventory']:GetInventory()
        end
    
    elseif InventoryType == 'core_inventory' then
        -- core_inventory does not have a full inventory client export
        -- Cannot retrieve full inventory client-side
        ZlomaCore.Debug("core_inventory: Full inventory not available client-side")
    
    elseif InventoryType == 'ak47_inventory' then
        -- ak47_inventory does not have a full inventory client export
        ZlomaCore.Debug("ak47_inventory: Full inventory not available client-side")
    
    elseif InventoryType == 'jaksam_inventory' then
        -- jaksam_inventory does not have a full inventory client export
        ZlomaCore.Debug("jaksam_inventory: Full inventory not available client-side")
    
    elseif InventoryType == 'jpr-inventory' then
        -- jpr-inventory uses QBCore PlayerData
        if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
            local playerData = QBCore.Functions.GetPlayerData()
            if playerData and playerData.items then
                items = playerData.items
            end
        end
    
    elseif InventoryType == 'S-Inventory' then
        -- S-Inventory uses ESX player data
        if ESX then
            local playerData = ESX.GetPlayerData()
            if playerData and playerData.inventory then
                items = playerData.inventory
            end
        end
    end

    -- Normalize Metadata (info -> metadata) for generic scripts
    if items then
        -- items might be an array (ox) or dictionary (qb - slots)
        for _, item in pairs(items) do
            if item.info and not item.metadata then
                item.metadata = item.info
            end
        end
    end

    return items
end)

-- EXPORT: HasItem(item, count, metadata) - Client side check
-- Useful for fast checks in loops/UI
exports('HasItem', function(item, count, metadata)
    local items = exports['zloma_core']:GetInventory()
    count = count or 1

    local foundCount = 0

    for _, invItem in pairs(items) do
        if invItem.name == item then
            -- Optional metadata check
            local metaMatch = true
            if metadata then
                if not invItem.metadata then
                    metaMatch = false
                else
                    for k, v in pairs(metadata) do
                        if invItem.metadata[k] ~= v then
                            metaMatch = false
                            break
                        end
                    end
                end
            end

            if metaMatch then
                foundCount = foundCount + (invItem.count or invItem.amount or 1)
            end
        end
    end

    return foundCount >= count
end)

RegisterNetEvent('zloma_core:client:openStash', function(data)
    if source ~= 65535 or type(data) ~= 'table' then return end

    local inventorySystem = data.inventorySystem or GetActiveInventoryType()
    if inventorySystem ~= GetActiveInventoryType()
        or (type(data.stashId) ~= 'string' and type(data.stashId) ~= 'number')
        or tostring(data.stashId) == '' or #tostring(data.stashId) > 128 then
        return
    end

    data.stashId = tostring(data.stashId)

    local stashData = {
        id = data.stashId,
        identifier = data.stashId,
        type = 'stash',
        label = data.label,
        slots = data.slots,
        maxSlots = data.slots,
        maxweight = data.weight,
        maxWeight = data.weight,
        weight = data.weight
    }

    local success, err = xpcall(function()
        if inventorySystem == 'ox_inventory' then
            exports.ox_inventory:openInventory('stash', data.stashId)
        elseif inventorySystem == 'qs-inventory' or inventorySystem == 'codem-inventory' then
            TriggerEvent('inventory:client:SetCurrentStash', data.stashId)
            TriggerServerEvent('inventory:server:OpenInventory', 'stash', data.stashId, stashData)
        elseif inventorySystem == 'core_inventory' then
            TriggerServerEvent('core_inventory:server:openInventory', data.stashId, 'stash', data.label, data.slots, nil, data.weight)
        elseif inventorySystem == 'ak47_inventory' then
            exports['ak47_inventory']:OpenInventory(stashData)
        elseif inventorySystem == 'jaksam_inventory' then
            exports['jaksam_inventory']:openInventory(data.fallbackId or data.stashId)
        elseif inventorySystem == 'S-Inventory' then
            exports['S-Inventory']:OpenStashInventory(nil, stashData)
        end
    end, debug.traceback)

    if not success then
        print(('^1[ZLOMA CORE ERROR]^0 OpenStash failed for %s:\n%s'):format(inventorySystem, err))
    end
end)

local function IsKnownInventoryResource(resourceName)
    if resourceName == 'qb-core' or resourceName == 'es_extended' then return true end

    for _, resourceNames in pairs(InventoryResources) do
        for _, candidate in ipairs(resourceNames) do
            if resourceName == candidate then return true end
        end
    end

    return false
end


AddEventHandler('onClientResourceStart', function(resourceName)
    if not IsKnownInventoryResource(resourceName) then return end
    CreateThread(function()
        Wait(0)
        RefreshInventoryDetection()
    end)
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if IsKnownInventoryResource(resourceName) then RefreshInventoryDetection() end
end)
