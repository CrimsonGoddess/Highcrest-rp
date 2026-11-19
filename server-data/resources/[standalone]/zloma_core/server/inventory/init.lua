-- ZLOMA CORE - Server Inventory Wrapper
-- Unified interface for ox_inventory, qb-inventory, qs-inventory, ps-inventory, codem-inventory,
-- tgiann-inventory, origen-inventory, core_inventory, ak47_inventory, jaksam_inventory, jpr-inventory, S-Inventory
-- Customer-friendly: Version-agnostic, graceful fallbacks, detailed error logging

local InventoryType = nil
local registeredStashes = {}

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

local function NormalizeInventoryItems(items)
    if not items then
        return {}
    end

    for _, item in pairs(items) do
        if item.info and not item.metadata then
            item.metadata = item.info
        end

        if item.amount and not item.count then
            item.count = item.amount
        end
    end

    return items
end

local function IsQbStyleInventory(inventorySystem)
    return inventorySystem == 'qb-inventory' or inventorySystem == 'ps-inventory' or inventorySystem == 'jpr-inventory'
end

local function RegisterQbStyleStash(resourceName, stashId, label, slots, weight)
    local stashData = {
        id = stashId,
        label = label,
        maxweight = weight,
        maxWeight = weight,
        slots = slots
    }

    if exports[resourceName] and exports[resourceName].RegisterInventory then
        exports[resourceName]:RegisterInventory(stashId, stashData)
        return true
    end

    if exports[resourceName] and exports[resourceName].CreateInventory then
        exports[resourceName]:CreateInventory(stashId, stashData)
        return true
    end

    return false
end

local function CallExport(resourceName, exportName, ...)
    local resourceExports = exports[resourceName]
    if not resourceExports or not resourceExports[exportName] then
        return false, nil
    end

    return pcall(function(...)
        return resourceExports[exportName](resourceExports, ...)
    end, ...)
end

local function TryExportVariants(resourceName, exportName, variants)
    for _, args in ipairs(variants) do
        local ok, result = CallExport(resourceName, exportName, table.unpack(args))
        if ok and result ~= false then
            return true, result
        end
    end

    return false, nil
end

local function BuildStashOpenData(label, slots, weight)
    return {
        label = label,
        slots = slots,
        maxweight = weight,
        maxWeight = weight,
        weight = weight
    }
end

local function BuildStashContext(stashId, owner)
    local rawId = tostring(stashId)
    local sanitizedId = rawId:gsub('%s+', '_'):gsub('%-', '_')
    local ownerSuffix = owner and ('_' .. tostring(owner)) or ''

    return {
        raw = rawId,
        sanitized = sanitizedId,
        qbOwner = rawId .. ownerSuffix,
        stashUnderscore = 'stash_' .. sanitizedId,
        stashCaps = 'Stash_' .. sanitizedId,
        stashDash = ('stash-' .. sanitizedId):gsub('%s+', ''),
        stashColon = 'stash:' .. sanitizedId,
        owner = owner
    }
end

local function ExtractInventoryItems(inventory)
    if not inventory then
        return {}
    end

    if inventory.items then
        return inventory.items
    end

    if inventory.inventory then
        return inventory.inventory
    end

    return inventory
end

local function SupportsStashSystem(inventorySystem)
    local supportedSystems = {
        ['ox_inventory'] = true,
        ['qb-inventory'] = true,
        ['qs-inventory'] = true,
        ['ps-inventory'] = true,
        ['codem-inventory'] = true,
        ['tgiann-inventory'] = true,
        ['origen-inventory'] = true,
        ['core_inventory'] = true,
        ['ak47_inventory'] = true,
        ['jaksam_inventory'] = true,
        ['jpr-inventory'] = true,
        ['S-Inventory'] = true
    }

    return supportedSystems[inventorySystem] == true
end

local function SupportsStashItemRead(inventorySystem)
    local readableSystems = {
        ['ox_inventory'] = true,
        ['qb-inventory'] = true,
        ['qs-inventory'] = true,
        ['ps-inventory'] = true,
        ['origen-inventory'] = true,
        ['core_inventory'] = true,
        ['ak47_inventory'] = true,
        ['jaksam_inventory'] = true,
        ['jpr-inventory'] = true
    }

    return readableSystems[inventorySystem] == true
end

local function RegisterInventoryStash(inventorySystem, stashContext, label, slots, weight, owner, groups, coords)
    if inventorySystem == 'ox_inventory' then
        exports.ox_inventory:RegisterStash(stashContext.raw, label, slots, weight, owner, groups, coords)
        return true
    elseif inventorySystem == 'qb-inventory' then
        return RegisterQbStyleStash('qb-inventory', stashContext.qbOwner, label, slots, weight)
    elseif inventorySystem == 'ps-inventory' then
        return RegisterQbStyleStash('ps-inventory', stashContext.stashUnderscore, label, slots, weight)
            or RegisterQbStyleStash('ps-inventory', stashContext.raw, label, slots, weight)
    elseif inventorySystem == 'jpr-inventory' then
        return RegisterQbStyleStash('jpr-inventory', stashContext.qbOwner, label, slots, weight) or true
    elseif inventorySystem == 'qs-inventory' then
        local ok = TryExportVariants('qs-inventory', 'RegisterStash', {
            {0, stashContext.stashUnderscore, slots, weight},
            {stashContext.stashUnderscore, label, slots, weight},
            {stashContext.raw, label, slots, weight},
            {stashContext.raw, slots, weight}
        })
        return ok
    elseif inventorySystem == 'codem-inventory' then
        return true
    elseif inventorySystem == 'tgiann-inventory' then
        local ok = TryExportVariants('tgiann-inventory', 'RegisterStash', {
            {stashContext.raw, label, slots, weight},
            {{
                id = stashContext.raw,
                label = label,
                maxSlots = slots,
                maxWeight = weight,
                runtimeOnly = true
            }},
            {{
                stashId = stashContext.raw,
                label = label,
                slots = slots,
                weight = weight,
                runtimeOnly = true
            }}
        })
        return ok
    elseif inventorySystem == 'origen-inventory' then
        local ok = TryExportVariants('origen_inventory', 'RegisterStash', {
            {stashContext.raw, { label = label, slots = slots, weight = weight }},
            {stashContext.raw, label, slots, weight}
        })
        return ok
    elseif inventorySystem == 'core_inventory' then
        return true
    elseif inventorySystem == 'ak47_inventory' then
        local ok = TryExportVariants('ak47_inventory', 'LoadInventory', {
            {stashContext.raw, { label = label, maxWeight = weight, maxSlots = slots, type = 'stash' }},
            {stashContext.raw, { label = label, maxweight = weight, slots = slots, type = 'stash' }},
            {stashContext.stashColon, { label = label, maxWeight = weight, maxSlots = slots, type = 'stash' }}
        })
        return ok
    elseif inventorySystem == 'jaksam_inventory' then
        local ok = TryExportVariants('jaksam_inventory', 'registerStash', {
            {{
                id = stashContext.raw,
                label = label,
                maxSlots = slots,
                maxWeight = weight,
                runtimeOnly = true
            }},
            {stashContext.raw, label, slots, weight}
        })
        return ok
    elseif inventorySystem == 'S-Inventory' then
        return true
    end

    return false
end

local function GetStashRegistrationKey(inventorySystem, stashContext, owner)
    return ('%s\31%s\31%s'):format(inventorySystem, stashContext.raw, tostring(owner or 'shared'))
end

local function GetStableConfigValue(value)
    if type(value) ~= 'table' then return tostring(value) end

    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys, function(left, right) return tostring(left) < tostring(right) end)

    local values = {}
    for _, key in ipairs(keys) do
        values[#values + 1] = ('%s=%s'):format(tostring(key), GetStableConfigValue(value[key]))
    end

    return ('{%s}'):format(table.concat(values, ','))
end

local function EnsureInventoryStash(inventorySystem, stashContext, label, slots, weight, owner, groups, coords)
    local key = GetStashRegistrationKey(inventorySystem, stashContext, owner)
    local signature = ('%s\31%s\31%s\31%s\31%s\31%s'):format(
        label, slots, weight, tostring(owner), GetStableConfigValue(groups), GetStableConfigValue(coords)
    )
    if registeredStashes[key] == signature then return true end

    local success, result = xpcall(function()
        return RegisterInventoryStash(inventorySystem, stashContext, label, slots, weight, owner, groups, coords)
    end, debug.traceback)

    if not success then
        print(('^1[ZLOMA CORE ERROR]^0 RegisterStash "%s" failed:\n%s'):format(stashContext.raw, result))
        return false
    end

    if result then registeredStashes[key] = signature end
    return result == true
end

local function ValidateStashArguments(source, stashId, label, slots, weight)
    if source ~= nil and (type(source) ~= 'number' or source <= 0 or GetPlayerName(source) == nil) then
        return nil
    end

    if (type(stashId) ~= 'string' and type(stashId) ~= 'number') or tostring(stashId) == '' then
        return nil
    end

    stashId = tostring(stashId)
    if #stashId > 128 then return nil end

    label = label == nil and stashId or label
    if type(label) ~= 'string' or label == '' or #label > 128 then return nil end

    slots = tonumber(slots) or 50
    weight = tonumber(weight) or 100000
    if slots ~= slots or weight ~= weight or slots == math.huge or weight == math.huge
        or slots <= 0 or slots > 1000 or weight <= 0 or weight > 2000000000 then
        return nil
    end

    return stashId, label, math.floor(slots), math.floor(weight)
end

local function OpenInventoryStash(inventorySystem, source, stashContext, label, slots, weight, owner, groups, coords)
    local stashData = BuildStashOpenData(label, slots, weight)

    if inventorySystem == 'ox_inventory' then
        -- Open through the client API so ox_inventory keeps its distance/group/
        -- ownership checks. forceOpenInventory intentionally bypasses them.
        TriggerClientEvent('zloma_core:client:openStash', source, {
            inventorySystem = inventorySystem,
            stashId = stashContext.raw,
            label = label,
            slots = slots,
            weight = weight
        })
        return true
    elseif inventorySystem == 'qb-inventory' then
        return TryExportVariants('qb-inventory', 'OpenInventory', {
            {source, stashContext.qbOwner, stashData},
            {source, stashData}
        })
    elseif inventorySystem == 'ps-inventory' then
        return TryExportVariants('ps-inventory', 'OpenInventory', {
            {source, stashContext.stashUnderscore, stashData},
            {source, stashContext.raw, stashData},
            {source, stashData}
        })
    elseif inventorySystem == 'jpr-inventory' then
        return TryExportVariants('jpr-inventory', 'OpenInventory', {
            {source, stashContext.qbOwner, stashData},
            {source, stashData}
        })
    elseif inventorySystem == 'qs-inventory' or inventorySystem == 'codem-inventory' or inventorySystem == 'core_inventory' or inventorySystem == 'ak47_inventory' or inventorySystem == 'jaksam_inventory' or inventorySystem == 'S-Inventory' then
        local clientStashId = stashContext.raw

        if inventorySystem == 'qs-inventory' then
            clientStashId = stashContext.stashUnderscore
        elseif inventorySystem == 'core_inventory' then
            clientStashId = stashContext.stashDash
        end

        TriggerClientEvent('zloma_core:client:openStash', source, {
            inventorySystem = inventorySystem,
            stashId = clientStashId,
            fallbackId = stashContext.raw,
            label = label,
            slots = slots,
            weight = weight
        })
        return true
    elseif inventorySystem == 'tgiann-inventory' then
        return TryExportVariants('tgiann-inventory', 'OpenInventory', {
            {source, 'stash', stashContext.raw},
            {source, 'stash', stashContext.raw, stashData},
            {source, stashContext.raw, stashData}
        })
    elseif inventorySystem == 'origen-inventory' then
        return TryExportVariants('origen_inventory', 'OpenInventory', {
            {source, 'stash', stashContext.raw},
            {source, 'stash', stashContext.raw, stashData},
            {source, stashContext.raw, stashData}
        })
    end

    return false
end

local function GetInventoryStashItems(inventorySystem, stashContext)
    if inventorySystem == 'ox_inventory' then
        return NormalizeInventoryItems(exports.ox_inventory:GetInventoryItems(stashContext.raw, false) or {})
    elseif inventorySystem == 'qb-inventory' then
        local ok, inventory = TryExportVariants('qb-inventory', 'GetInventory', {
            {stashContext.qbOwner},
            {stashContext.raw}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and inventory or nil))
    elseif inventorySystem == 'ps-inventory' then
        local ok, items = TryExportVariants('ps-inventory', 'GetStashItems', {
            {stashContext.stashUnderscore},
            {stashContext.raw},
            {stashContext.stashCaps}
        })
        if ok then
            return NormalizeInventoryItems(ExtractInventoryItems(items))
        end

        ok, items = TryExportVariants('ps-inventory', 'GetInventory', {
            {stashContext.stashUnderscore},
            {stashContext.raw}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and items or nil))
    elseif inventorySystem == 'qs-inventory' then
        local ok, items = TryExportVariants('qs-inventory', 'GetStashItems', {
            {stashContext.stashUnderscore},
            {stashContext.raw},
            {stashContext.stashCaps}
        })
        if ok then
            return NormalizeInventoryItems(ExtractInventoryItems(items))
        end

        ok, items = TryExportVariants('qs-inventory', 'GetInventory', {
            {stashContext.stashUnderscore},
            {stashContext.raw}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and items or nil))
    elseif inventorySystem == 'codem-inventory' then
        local ok, items = TryExportVariants('codem-inventory', 'GetStashItems', {
            {stashContext.raw},
            {stashContext.stashUnderscore}
        })
        if ok then
            return NormalizeInventoryItems(ExtractInventoryItems(items))
        end

        ok, items = TryExportVariants('codem-inventory', 'GetInventory', {
            {stashContext.raw}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and items or nil))
    elseif inventorySystem == 'tgiann-inventory' then
        local ok, inventory = TryExportVariants('tgiann-inventory', 'getInventory', {
            {stashContext.raw}
        })
        if ok then
            return NormalizeInventoryItems(ExtractInventoryItems(inventory))
        end

        return {}
    elseif inventorySystem == 'origen-inventory' then
        local ok, items = TryExportVariants('origen_inventory', 'GetStashItems', {
            {stashContext.raw}
        })
        if ok then
            return NormalizeInventoryItems(ExtractInventoryItems(items))
        end

        ok, items = TryExportVariants('origen_inventory', 'GetInventory', {
            {stashContext.raw}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and items or nil))
    elseif inventorySystem == 'core_inventory' then
        local ok, inventory = TryExportVariants('core_inventory', 'getInventory', {
            {stashContext.stashDash},
            {stashContext.raw}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and inventory or nil))
    elseif inventorySystem == 'ak47_inventory' then
        local ok, items = TryExportVariants('ak47_inventory', 'GetInventoryItems', {
            {stashContext.raw},
            {stashContext.stashColon}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and items or nil))
    elseif inventorySystem == 'jaksam_inventory' then
        local ok, inventory = TryExportVariants('jaksam_inventory', 'getInventory', {
            {stashContext.raw}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and inventory or nil))
    elseif inventorySystem == 'jpr-inventory' then
        local ok, inventory = TryExportVariants('jpr-inventory', 'GetInventory', {
            {stashContext.qbOwner},
            {stashContext.raw}
        })
        return NormalizeInventoryItems(ExtractInventoryItems(ok and inventory or nil))
    elseif inventorySystem == 'S-Inventory' then
        return {}
    end

    return {}
end

-- Initialize inventory detection with retry (mirrors framework startup pattern)
CreateThread(function()
    local startup = ZlomaCore.Config.FrameworkStartup or {}
    local timeout = math.max(0, tonumber(startup.TimeoutMs) or 15000)
    local retry = math.max(50, tonumber(startup.RetryMs) or 250)
    local deadline = GetGameTimer() + timeout

    repeat
        InventoryType = GetActiveInventoryType()
        if InventoryType then break end
        Wait(retry)
    until GetGameTimer() >= deadline

    if InventoryType then
        ZlomaCore.Debug(string.format("Inventory system loaded: %s", InventoryType))
    else
        print("^3[ZLOMA WARNING]^0 No inventory system detected. Inventory functions will not work.")
    end
end)

-- ============================================================================
-- ADD NEW INVENTORY SUPPORT HERE
-- ============================================================================
-- To add support for a new inventory system:
-- 1. Add detection in shared/config.lua -> ZlomaCore.DetectInventory()
-- 2. Add the inventory name to ZlomaCore.Config.Manual.Inventory options
-- 3. Add elseif blocks in HasItem, GetItemCount, AddItem, RemoveItem, GetInventory below
--
-- Template:
-- elseif InventoryType == 'your-inventory' then
--     return exports['your-inventory']:YourExportFunction(source, item)
-- ============================================================================

-- EXPORT: HasItem(source, item, count) - Check if player has item with minimum count
-- Returns: true/false
exports('HasItem', function(source, item, count)
    if not GetActiveInventoryType() then
        ZlomaCore.Warn("Inventory", "HasItem")
        return false
    end

    count = count or 1

    if InventoryType == 'ox_inventory' then
        local itemCount = exports.ox_inventory:GetItemCount(source, item)
        return itemCount >= count
    elseif InventoryType == 'qb-inventory' then
        -- OPTIMIZED: Use HasItem export if available (recommended by docs)
        if exports['qb-inventory'] and exports['qb-inventory'].HasItem then
            return exports['qb-inventory']:HasItem(source, item, count)
        end
        -- Fallback to Player.Functions
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        local itemData = Player.Functions.GetItemByName(item)
        if itemData then
            return itemData.amount >= count
        end
        return false
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        local itemCount = exports['tgiann-inventory']:GetItemCount(source, item)
        return itemCount >= count
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        local itemCount = exports['origen_inventory']:GetItemCount(source, item)
        return itemCount >= count
        
    elseif InventoryType == 'qs-inventory' then
        local itemCount = exports['qs-inventory']:GetItemTotalAmount(source, item)
        return itemCount >= count
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end

        local itemData = Player.Functions.GetItemByName(item)
        if itemData then
            return itemData.amount >= count
        end
        return false
    elseif InventoryType == 'codem-inventory' then
        local itemData = exports['codem-inventory']:GetItemByName(source, item)
        if itemData then
            return itemData.amount >= count
        end
        return false
    
    elseif InventoryType == 'core_inventory' then
        local itemCount = exports.core_inventory:getItemCount(source, item)
        return (itemCount or 0) >= count
    
    elseif InventoryType == 'ak47_inventory' then
        local itemCount = exports['ak47_inventory']:getItemCount(source, 'count', item)
        return (itemCount or 0) >= count
    
    elseif InventoryType == 'jaksam_inventory' then
        local itemCount = exports['jaksam_inventory']:getTotalItemAmount(source, item)
        return (itemCount or 0) >= count
    
    elseif InventoryType == 'jpr-inventory' then
        local itemCount = exports['jpr-inventory']:GetItemCount(source, item)
        return (itemCount or 0) >= count
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local itemData = xPlayer.getInventoryItem(item)
            return itemData and (itemData.count or 0) >= count
        end
        return false
    end

    return false
end)

-- EXPORT: GetItemCount(source, item) - Get exact item quantity
-- Returns: Number (0 if not found)
exports('GetItemCount', function(source, item)
    if not GetActiveInventoryType() then
        ZlomaCore.Warn("Inventory", "GetItemCount")
        return 0
    end

    if InventoryType == 'ox_inventory' then
        return exports.ox_inventory:GetItemCount(source, item)
    elseif InventoryType == 'qb-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return 0 end

        local itemData = Player.Functions.GetItemByName(item)
        return itemData and itemData.amount or 0
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        return exports['tgiann-inventory']:GetItemCount(source, item) or 0
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        return exports['origen_inventory']:GetItemCount(source, item) or 0
        
    elseif InventoryType == 'qs-inventory' then
        return exports['qs-inventory']:GetItemTotalAmount(source, item)
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return 0 end

        local itemData = Player.Functions.GetItemByName(item)
        return itemData and itemData.amount or 0
    elseif InventoryType == 'codem-inventory' then
        local itemData = exports['codem-inventory']:GetItemByName(source, item)
        return itemData and itemData.amount or 0
    
    elseif InventoryType == 'core_inventory' then
        return exports.core_inventory:getItemCount(source, item) or 0
    
    elseif InventoryType == 'ak47_inventory' then
        return exports['ak47_inventory']:getItemCount(source, 'count', item) or 0
    
    elseif InventoryType == 'jaksam_inventory' then
        return exports['jaksam_inventory']:getTotalItemAmount(source, item) or 0
    
    elseif InventoryType == 'jpr-inventory' then
        return exports['jpr-inventory']:GetItemCount(source, item) or 0
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local itemData = xPlayer.getInventoryItem(item)
            return itemData and itemData.count or 0
        end
        return 0
    end

    return 0
end)

-- EXPORT: AddItem(source, item, count, metadata) - Add item to player inventory
-- Returns: true if successful, false otherwise
exports('AddItem', function(source, item, count, metadata, slot, maybeSlot)
    if type(source) == 'table' then
        source = item
        item = count
        count = metadata
        metadata = slot
        slot = maybeSlot
    end
    source = tonumber(source) or source

    if not source or (type(source) == 'string' and tonumber(source) == nil) then
        print(string.format('^1[zloma_core] ERROR: AddItem called with invalid source "%s" (caller likely used dot instead of colon: use exports["zloma_core"]:AddItem)^0', tostring(source)))
        return false
    end

    if not GetActiveInventoryType() then
        ZlomaCore.Warn("Inventory", "AddItem")
        return false
    end

    count = count or 1
    metadata = metadata or {}

    local success = false

    if InventoryType == 'ox_inventory' then
        local oxSuccess, oxResponse = exports.ox_inventory:AddItem(source, item, count, metadata, slot)
        success = (oxSuccess == true or type(oxSuccess) == 'table')
        if not success then
            ZlomaCore.Debug(string.format("ox_inventory AddItem failed for player %s, item %s, count %s: %s", tostring(source), tostring(item), tostring(count), tostring(oxResponse)))
        end
    elseif InventoryType == 'qb-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        success = Player.Functions.AddItem(item, count, false, metadata)
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        success = exports['tgiann-inventory']:AddItem(source, item, count, nil, metadata)
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        success = exports['origen_inventory']:AddItem(source, item, count, metadata)
        
    elseif InventoryType == 'qs-inventory' then
        -- FIXED: Correct parameter order for qs-inventory: AddItem(source, item, count, slot, metadata)
        success = exports['qs-inventory']:AddItem(source, item, count, nil, metadata)
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        success = Player.Functions.AddItem(item, count, false, metadata)
    elseif InventoryType == 'codem-inventory' then
        success = exports['codem-inventory']:AddItem(source, item, count, metadata)
    
    elseif InventoryType == 'core_inventory' then
        exports['core_inventory']:addItem(source, item, count, metadata)
        success = true
    
    elseif InventoryType == 'ak47_inventory' then
        exports['ak47_inventory']:AddItem(source, item, count, nil, metadata)
        success = true
    
    elseif InventoryType == 'jaksam_inventory' then
        exports['jaksam_inventory']:addItem(source, item, count, metadata)
        success = true
    
    elseif InventoryType == 'jpr-inventory' then
        exports['jpr-inventory']:AddItem(source, item, count, nil, metadata)
        success = true
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addInventoryItem(item, count)
            success = true
        end
    end

    if success then
        ZlomaCore.Debug(string.format("Added %sx %s to player %s", count, item, source))
    else
        ZlomaCore.Debug(string.format("Failed to add %sx %s to player %s", count, item, source))
    end

    return success
end)

-- EXPORT: RemoveItem(source, item, count, metadata, slot) - Remove item from player inventory
-- Returns: true if successful, false otherwise
exports('RemoveItem', function(source, item, count, metadata, slot, maybeSlot)
    if type(source) == 'table' then
        source = item
        item = count
        count = metadata
        metadata = slot
        slot = maybeSlot
    end
    source = tonumber(source) or source

    if not source or (type(source) == 'string' and tonumber(source) == nil) then
        print(string.format('^1[zloma_core] ERROR: RemoveItem called with invalid source "%s" (caller likely used dot instead of colon: use exports["zloma_core"]:RemoveItem)^0', tostring(source)))
        return false
    end

    if not GetActiveInventoryType() then
        ZlomaCore.Warn("Inventory", "RemoveItem")
        return false
    end

    count = count or 1
    local success = false

    if InventoryType == 'ox_inventory' then
        local oxSuccess, oxResponse = exports.ox_inventory:RemoveItem(source, item, count, metadata, slot)
        success = oxSuccess == true
        if not success then
            ZlomaCore.Debug(string.format("ox_inventory RemoveItem failed for player %s, item %s, count %s: %s", tostring(source), tostring(item), tostring(count), tostring(oxResponse)))
        end
    elseif InventoryType == 'qb-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        -- QBCore RemoveItem(item, amount, slot)
        success = Player.Functions.RemoveItem(item, count, slot)
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        success = exports['tgiann-inventory']:RemoveItem(source, item, count, slot, metadata)
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        success = exports['origen_inventory']:RemoveItem(source, item, count)
        
    elseif InventoryType == 'qs-inventory' then
        -- qs-inventory RemoveItem(source, item, count, slot, metadata) - best guess standardization
        if exports['qs-inventory'].RemoveItem then
            -- Try standard signature if available, otherwise fallback to simple
            pcall(function()
                success = exports['qs-inventory']:RemoveItem(source, item, count, slot, metadata)
            end)
            if not success then
                success = exports['qs-inventory']:RemoveItem(source, item, count)
            end
        else
            success = false
        end
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        success = Player.Functions.RemoveItem(item, count, slot)
    elseif InventoryType == 'codem-inventory' then
        success = exports['codem-inventory']:RemoveItem(source, item, count)
    
    elseif InventoryType == 'core_inventory' then
        exports['core_inventory']:removeItem(source, item, count)
        success = true
    
    elseif InventoryType == 'ak47_inventory' then
        exports['ak47_inventory']:RemoveItem(source, item, count)
        success = true
    
    elseif InventoryType == 'jaksam_inventory' then
        exports['jaksam_inventory']:removeItem(source, item, count)
        success = true
    
    elseif InventoryType == 'jpr-inventory' then
        exports['jpr-inventory']:RemoveItem(source, item, count)
        success = true
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeInventoryItem(item, count)
            success = true
        end
    end

    if success then
        ZlomaCore.Debug(string.format("Removed %sx %s from player %s", count, item, source))
    else
        ZlomaCore.Debug(string.format("Failed to remove %sx %s from player %s (insufficient qty?)", count, item, source))
    end

    return success
end)

-- EXPORT: GetInventory(source) - Get player's full inventory
-- Returns: Table of items (normalized structure where possible)
exports('GetInventory', function(source, maybeSource)
    if type(source) == 'table' then
        source = maybeSource
    end
    source = tonumber(source) or source

    if not source or (type(source) == 'string' and tonumber(source) == nil) then
        print(string.format('^1[zloma_core] ERROR: GetInventory called with invalid source "%s" (caller likely used dot instead of colon: use exports["zloma_core"]:GetInventory)^0', tostring(source)))
        return {}
    end

    if not GetActiveInventoryType() then
        ZlomaCore.Warn("Inventory", "GetInventory")
        return {}
    end

    local items = {}

    if InventoryType == 'ox_inventory' then
        return exports.ox_inventory:GetInventoryItems(source) or {}
    elseif InventoryType == 'qb-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        items = Player and Player.PlayerData.items or {}
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        items = exports['tgiann-inventory']:GetInventory(source) or {}
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        items = exports['origen_inventory']:GetInventory(source) or {}
        
    elseif InventoryType == 'qs-inventory' then
        items = exports['qs-inventory']:GetInventory(source) or {}
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        items = Player and Player.PlayerData.items or {}
    elseif InventoryType == 'codem-inventory' then
        items = exports['codem-inventory']:GetInventory(source) or {}
    
    elseif InventoryType == 'core_inventory' then
        items = exports['core_inventory']:getItems(source) or {}
    
    elseif InventoryType == 'ak47_inventory' then
        items = exports['ak47_inventory']:GetInventoryItems(source) or {}
    
    elseif InventoryType == 'jaksam_inventory' then
        local inv = exports['jaksam_inventory']:getInventory(source)
        items = inv and inv.items or {}
    
    elseif InventoryType == 'jpr-inventory' then
        items = exports['jpr-inventory']:GetInventory(source) or {}
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            items = xPlayer.getInventory() or {}
        end
    end

    -- Normalize 'info' to 'metadata' if missing (for QBCore/QS/PS)
    -- This ensures scripts like zloma_keys can read metadata uniformly
    return NormalizeInventoryItems(items)
end)


-- EXPORT: GetItemMetadata(source, item) - Get item metadata/info
-- Returns: Metadata table or nil
exports('GetItemMetadata', function(source, item)
    if not GetActiveInventoryType() then
        ZlomaCore.Warn("Inventory", "GetItemMetadata")
        return nil
    end

    if InventoryType == 'ox_inventory' then
        -- ox_inventory:GetInventoryItems returns table of items
        local items = exports.ox_inventory:GetInventoryItems(source)
        if items then
            for _, invItem in pairs(items) do
                if invItem.name == item then
                    return invItem.metadata
                end
            end
        end
    elseif InventoryType == 'qb-inventory' or InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return nil end

        local itemData = Player.Functions.GetItemByName(item)
        return itemData and itemData.info or nil
    elseif InventoryType == 'qs-inventory' then
        local itemData = exports['qs-inventory']:GetItemByName(source, item)
        return itemData and itemData.info or nil
    elseif InventoryType == 'codem-inventory' then
        local itemData = exports['codem-inventory']:GetItemByName(source, item)
        return itemData and itemData.info or nil
    end

    return nil
end)


-- ============================================================================
-- System Detection Export
-- ============================================================================

--- Get detected inventory system name
--- @return string|nil - Detected inventory system name or nil
exports('GetInventorySystem', function()
    return GetActiveInventoryType()
end)

-- EXPORT: SupportsStashes() - Check whether the active inventory backend supports stash wrappers
-- Returns: true/false
exports('SupportsStashes', function()
    return SupportsStashSystem(GetActiveInventoryType())
end)

exports('CanReadStashItems', function()
    return SupportsStashItemRead(GetActiveInventoryType())
end)

-- EXPORT: RegisterStash(stashId, label, slots, weight, owner, groups, coords) - Register a stash with the active inventory
-- Returns: true if successful, false otherwise
exports('RegisterStash', function(stashId, label, slots, weight, owner, groups, coords)
    local inventorySystem = GetActiveInventoryType()
    if not inventorySystem then
        ZlomaCore.Warn("Inventory", "RegisterStash")
        return false
    end

    stashId, label, slots, weight = ValidateStashArguments(nil, stashId, label, slots, weight)
    if not stashId then return false end

    local stashContext = BuildStashContext(stashId, owner)
    local success = EnsureInventoryStash(inventorySystem, stashContext, label, slots, weight, owner, groups, coords)
    if success then
        return true
    end

    ZlomaCore.Debug(string.format("RegisterStash unsupported for inventory system: %s", inventorySystem))
    return false
end)

-- EXPORT: OpenStash(source, stashId, label, slots, weight, owner, groups, coords) - Open a stash for a player
-- Returns: true if successful, false otherwise
exports('OpenStash', function(source, stashId, label, slots, weight, owner, groups, coords)
    local inventorySystem = GetActiveInventoryType()
    if not inventorySystem then
        ZlomaCore.Warn("Inventory", "OpenStash")
        return false
    end

    stashId, label, slots, weight = ValidateStashArguments(source, stashId, label, slots, weight)
    if not stashId then return false end

    local stashContext = BuildStashContext(stashId, owner)
    if not EnsureInventoryStash(inventorySystem, stashContext, label, slots, weight, owner, groups, coords) then
        ZlomaCore.Debug(string.format("OpenStash failed to register stash for inventory system: %s", inventorySystem))
        return false
    end

    if OpenInventoryStash(inventorySystem, source, stashContext, label, slots, weight, owner, groups, coords) then
        return true
    end

    ZlomaCore.Debug(string.format("OpenStash unsupported for inventory system: %s", inventorySystem))
    return false
end)

-- EXPORT: GetStashItems(stashId) - Read items from a registered stash
-- Returns: normalized item table
exports('GetStashItems', function(stashId)
    local inventorySystem = GetActiveInventoryType()
    if not inventorySystem then
        ZlomaCore.Warn("Inventory", "GetStashItems")
        return {}
    end

    if not SupportsStashItemRead(inventorySystem) then
        return nil
    end

    if (type(stashId) ~= 'string' and type(stashId) ~= 'number')
        or tostring(stashId) == '' or #tostring(stashId) > 128 then
        return {}
    end

    return GetInventoryStashItems(inventorySystem, BuildStashContext(stashId))
end)

local function IsKnownInventoryResource(resourceName)
    for _, resourceNames in pairs(InventoryResources) do
        for _, candidate in ipairs(resourceNames) do
            if resourceName == candidate then return true end
        end
    end

    return false
end

AddEventHandler('onResourceStart', function(resourceName)
    if not IsKnownInventoryResource(resourceName) then return end
    InventoryType = nil
    ZlomaCore.Cache.Inventory = nil
    registeredStashes = {}
end)

AddEventHandler('onResourceStop', function(resourceName)
    if not IsKnownInventoryResource(resourceName) then return end
    InventoryType = nil
    ZlomaCore.Cache.Inventory = nil
    registeredStashes = {}
end)
