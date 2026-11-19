-- ZLOMA CORE - Client Initialization
-- Runs detection for client-side systems (notifications, keys, target)

CreateThread(function()
    -- Wait a bit for all resources to load
    Wait(100)
    
    -- Run client-side detection
    ZlomaCore.Cache.Notification = ZlomaCore.DetectNotification()
    ZlomaCore.Cache.Inventory = ZlomaCore.DetectInventory()
    ZlomaCore.Cache.Appearance = ZlomaCore.DetectAppearance()
    ZlomaCore.Cache.Keys = ZlomaCore.DetectKeys()
    ZlomaCore.Cache.Target = ZlomaCore.DetectTarget()
    ZlomaCore.Cache.Fuel = ZlomaCore.DetectFuel()
    
    -- Console output (only client-side systems)
    print("^2========================================^0")
    print("^2ZLOMA CORE - Client Detection^0")
    print("^2========================================^0")
    print(string.format("^3Notification:^0 %s", ZlomaCore.Cache.Notification or "^1NONE DETECTED^0"))
    print(string.format("^3Inventory:^0 %s", ZlomaCore.Cache.Inventory or "^1NONE DETECTED^0"))
    print(string.format("^3Appearance:^0 %s", ZlomaCore.Cache.Appearance or "^1NONE DETECTED^0"))
    print(string.format("^3Keys:^0 %s", ZlomaCore.Cache.Keys or "^1NONE DETECTED^0"))
    print(string.format("^3Target:^0 %s", ZlomaCore.Cache.Target or "^1NONE DETECTED^0"))
    print(string.format("^3Fuel:^0 %s", ZlomaCore.Cache.Fuel or "^1NONE DETECTED^0"))
    print("^2========================================^0")
end)

local function RefreshClientDetection(changedResource)
    local previousKeys = ZlomaCore.Cache.Keys

    ZlomaCore.Cache.Notification = ZlomaCore.DetectNotification()
    ZlomaCore.Cache.Inventory = ZlomaCore.DetectInventory()
    ZlomaCore.Cache.Appearance = ZlomaCore.DetectAppearance()
    ZlomaCore.Cache.Keys = ZlomaCore.DetectKeys()
    ZlomaCore.Cache.Target = ZlomaCore.DetectTarget()
    ZlomaCore.Cache.Fuel = ZlomaCore.DetectFuel()

    if previousKeys ~= ZlomaCore.Cache.Keys then
        print(string.format('^2[ZLOMA CORE]^0 Keys detection refreshed after %s: %s', changedResource or 'resource change', ZlomaCore.Cache.Keys or '^1NONE DETECTED^0'))
    end
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    RefreshClientDetection(resourceName)
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then return end
    RefreshClientDetection(resourceName)
end)

-- EXPORT: IsAdmin(groups) - Check if local player is admin (client-side)
-- groups: Optional table of group names to check (e.g., {'admin', 'superadmin', 'owner'})
-- Uses server callback for security
-- Returns: true if admin, false otherwise
exports('IsAdmin', function(groups)
    return lib.callback.await('zloma_core:isAdmin', false, groups)
end)

-- EXPORT: GetPlayerJob() - Get local player's job (client-side)
-- Uses server callback for accurate data
-- Returns: {name, grade, label} or nil
exports('GetPlayerJob', function()
    return lib.callback.await('zloma_core:getPlayerJob', false)
end)

-- EXPORT: GetPlayerGang() - Get local player's gang (client-side)
-- Uses server callback for accurate data
-- Returns: {name, grade, label} or nil (ESX always returns nil)
exports('GetPlayerGang', function()
    return lib.callback.await('zloma_core:getPlayerGang', false)
end)
