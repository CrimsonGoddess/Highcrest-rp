ZlomaCore.RegisterClientNotification('fl-notify', function(msg, kind, duration)
    exports['fl-notify']:Notify(kind:upper(), '', msg, duration, kind == 'info' and 'inform' or kind, 'top-right')
end)
