-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Every framework or inventory call goes through zloma_core, so the resource
-- runs the same on ESX, QBCore and QBox with any inventory zloma_core supports.
Bridge = {}

local function core() return exports.zloma_core end

function Bridge.identifier(src)
    src = tonumber(src)
    if not src or src <= 0 then return nil end
    local ok, id = pcall(function() return core():GetIdentifier(src) end)
    return ok and type(id) == 'string' and id ~= '' and id or nil
end

function Bridge.source(identifier)
    if not identifier then return nil end
    local ok, src = pcall(function() return core():GetPlayerFromIdentifier(identifier) end)
    return ok and tonumber(src) or nil
end

function Bridge.money(src)
    local ok, amount = pcall(function() return core():GetPlayerMoney(src, Config.PaymentAccount) end)
    return ok and tonumber(amount) or 0
end

function Bridge.removeMoney(src, amount)
    if amount <= 0 then return true end
    local ok, removed = pcall(function() return core():RemoveMoney(src, amount, Config.PaymentAccount) end)
    return ok and removed == true
end

function Bridge.addMoney(src, amount)
    if amount <= 0 then return true end
    local ok, added = pcall(function() return core():AddMoney(src, amount, Config.PaymentAccount) end)
    return ok and added == true
end

function Bridge.notify(src, message, kind, duration)
    if not src then return end
    pcall(function() core():Notify(src, message, kind or 'info', duration or 5000) end)
end

function Bridge.name(identifier, src)
    local ok, name = pcall(function() return core():GetCharacterName(identifier) end)
    if ok and type(name) == 'string' and name ~= '' and name ~= identifier then return name end
    return src and GetPlayerName(src) or identifier
end

function Bridge.onlinePlayers()
    local ok, players = pcall(function() return core():GetOnlinePlayers() end)
    return ok and type(players) == 'table' and players or {}
end

-- Admin means: the player's group/permission is listed in Config.AdminGroups.
function Bridge.isAdmin(src)
    if tonumber(src) == 0 then return true end
    local ok, allowed = pcall(function() return core():IsAdmin(src, Config.AdminGroups, true) end)
    return ok and allowed == true
end

function Bridge.registerStash(id, label, slots, weight)
    local ok, result = pcall(function() return core():RegisterStash(id, label, slots, weight) end)
    return ok and result ~= false
end

function Bridge.openStash(src, id, label, slots, weight)
    local ok, result = pcall(function() return core():OpenStash(src, id, label, slots, weight) end)
    return ok and result ~= false
end

function Bridge.hasItem(src, item)
    if not item then return true end
    local ok, has = pcall(function() return core():HasItem(src, item, 1) end)
    return ok and has == true
end

function Bridge.removeItem(src, item)
    if not item then return true end
    local ok, removed = pcall(function() return core():RemoveItem(src, item, 1) end)
    return ok and removed ~= false
end

-- Whether an item is defined in the inventory. zloma_core has no export for
-- this yet, so the inventory's own item list is read where there is one;
-- without one the item is assumed to exist.
local itemCache = {}
function Bridge.itemExists(item)
    if not item then return true end
    local cached = itemCache[item]
    if cached and cached.expires > os.time() then return cached.exists end
    local exists = true
    local ok, result = pcall(function() return core():ItemExists(item) end)
    if ok and type(result) == 'boolean' then
        exists = result
    elseif GetResourceState('ox_inventory') == 'started' then
        local okOx, data = pcall(function() return exports.ox_inventory:Items(item) end)
        exists = okOx and data ~= nil
    elseif GetResourceState('qb-core') == 'started' then
        local okQb, items = pcall(function() return exports['qb-core']:GetCoreObject().Shared.Items end)
        if okQb and type(items) == 'table' then exists = items[item] ~= nil end
    end
    itemCache[item] = { exists = exists, expires = os.time() + 60 }
    return exists
end

-- Police alert through zloma_core's dispatch bridge.
function Bridge.dispatch(src, data)
    local ok, sent = pcall(function() return core():SendDispatchAlert(src, data) end)
    return ok and sent == true
end
