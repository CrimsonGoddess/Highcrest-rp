function ZlomaCore.RegisterClientNotification(provider, notify)
    ZlomaCore.RegisterAdapter('client', 'Notification', provider, { notify = notify })
end

ZlomaCore.RegisterClientNotification('builtin', function(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, true)
end)
