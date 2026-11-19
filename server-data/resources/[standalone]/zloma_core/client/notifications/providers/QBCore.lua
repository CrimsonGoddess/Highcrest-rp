ZlomaCore.RegisterClientNotification('QBCore', function(msg, kind, duration)
    local mapped = kind == 'info' and 'primary' or kind
    TriggerEvent('QBCore:Notify', msg, mapped, duration)
end)
