-- Client appearance facade. Provider implementations are loaded from providers/.
local appearanceType = nil

local function refreshAppearanceDetection()
    appearanceType = ZlomaCore.DetectAppearance()
    ZlomaCore.Cache.Appearance = appearanceType
    return appearanceType
end

local function adapter(action)
    if not appearanceType then refreshAppearanceDetection() end
    local current = appearanceType and ZlomaCore.GetAdapter('client', 'Appearance', appearanceType)
    if not current and action then ZlomaCore.Warn('Appearance', action) end
    return current
end

CreateThread(function()
    Wait(0)
    refreshAppearanceDetection()
    ZlomaCore.Debug(appearanceType and ('Appearance system loaded: ' .. appearanceType) or '[zloma_core] No appearance system detected')
end)

exports('GetAppearanceSystem', function() return refreshAppearanceDetection() end)
exports('GetCurrentSkin', function()
    local current = adapter('GetCurrentSkin')
    return current and type(current.get) == 'function' and current.get() or nil
end)
exports('GetPlayerAppearance', function() return exports['zloma_core']:GetCurrentSkin() end)
exports('GetPlayerClothing', function() return exports['zloma_core']:GetCurrentSkin() end)

exports('SetPlayerSkin', function(skinData)
    local current, data = adapter('SetPlayerSkin'), ZlomaCore.AppearanceHelpers.decode(skinData)
    if not current or not data or type(current.setSkin) ~= 'function' then return false end
    return current.setSkin(data) ~= false
end)
exports('SetPlayerAppearance', function(data) return exports['zloma_core']:SetPlayerSkin(data) end)
exports('SetPlayerClothing', function(clothingData)
    local current, data = adapter('SetPlayerClothing'), ZlomaCore.AppearanceHelpers.decode(clothingData)
    if not current or not data or type(current.setClothing) ~= 'function' then return false end
    return current.setClothing(data) ~= false
end)
exports('OpenWardrobe', function(options)
    local current = adapter('OpenWardrobe')
    if current and type(current.openWardrobe) == 'function' then return current.openWardrobe(options or {}) ~= false end
    exports['zloma_core']:Notify('Wardrobe opening is not available for the detected appearance system', 'error')
    return false
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then refreshAppearanceDetection() end
end)
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then refreshAppearanceDetection() end
end)
