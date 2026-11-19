-- Client notification facade. Provider implementations are loaded from providers/.
local notificationType = nil

local function refreshNotificationDetection()
    notificationType = ZlomaCore.DetectNotification() or 'builtin'
    ZlomaCore.Cache.Notification = notificationType == 'builtin' and nil or notificationType
    return notificationType
end

local function adapter()
    if not notificationType then refreshNotificationDetection() end
    return ZlomaCore.GetAdapter('client', 'Notification', notificationType)
        or ZlomaCore.GetAdapter('client', 'Notification', 'builtin')
end

CreateThread(function()
    Wait(0)
    refreshNotificationDetection()
    ZlomaCore.Debug('Notification system loaded: ' .. notificationType)
end)

exports('Notify', function(message, notifyType, duration)
    local rawOptions = type(message) == 'table' and message or nil
    if rawOptions then
        message = rawOptions.description or rawOptions.message or rawOptions.text
        notifyType = rawOptions.type or 'info'
        duration = rawOptions.duration or 5000
    end
    if rawOptions and (not notificationType and refreshNotificationDetection() or notificationType) == 'ox_lib' then
        local current = adapter()
        current.notify(message or '', notifyType, duration, rawOptions)
        return
    end
    if not message then
        print('^1[ZLOMA ERROR]^0 Notify - Message is required')
        return
    end

    local current = adapter()
    if current and type(current.notify) == 'function' then
        current.notify(message, notifyType or 'info', duration or 5000, rawOptions)
    end
    ZlomaCore.Debug(('Notification sent: [%s] %s'):format(notifyType or 'info', message))
end)

exports('NotifyAdvanced', function(title, message, notifyType, duration)
    if not message then
        print('^1[ZLOMA ERROR]^0 NotifyAdvanced - Message is required')
        return
    end
    notifyType, duration = notifyType or 'info', duration or 5000
    if not notificationType then refreshNotificationDetection() end
    if notificationType == 'ox_lib' then
        local current = adapter()
        current.notify(message, notifyType, duration, { title = title or notifyType:upper(), description = message, type = notifyType, duration = duration })
        return
    end
    exports['zloma_core']:Notify(('^3%s^0\n%s'):format(title or notifyType:upper(), message), notifyType, duration)
end)

exports('ShowNotification', function(message, notifyType, duration)
    return exports['zloma_core']:Notify(message, notifyType, duration)
end)
exports('ShowTextUI', function(text, options)
    if type(text) ~= 'string' or text == '' or not lib or type(lib.showTextUI) ~= 'function' then return false end
    lib.showTextUI(text, type(options) == 'table' and options or nil)
    return true
end)
exports('HideTextUI', function()
    if not lib or type(lib.hideTextUI) ~= 'function' then return false end
    lib.hideTextUI()
    return true
end)

RegisterNetEvent('zloma_core:client:notify', function(message, kind, duration)
    if source == 65535 then exports['zloma_core']:Notify(message, kind, duration) end
end)
RegisterNetEvent('zloma_core:client:notifyAdvanced', function(title, message, kind, duration)
    if source == 65535 then exports['zloma_core']:NotifyAdvanced(title, message, kind, duration) end
end)
RegisterNetEvent('zloma_core:notify')
AddEventHandler('zloma_core:notify', function(data)
    if source == 65535 and type(data) == 'table' then exports['zloma_core']:Notify(data) end
end)
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then refreshNotificationDetection() end
end)
AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then refreshNotificationDetection() end
end)
