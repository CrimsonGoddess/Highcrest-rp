ZlomaCore.RegisterClientNotification('t-notify', function(msg, kind, duration)
    exports['t-notify']:Custom({ style = kind, message = msg, duration = duration })
end)
