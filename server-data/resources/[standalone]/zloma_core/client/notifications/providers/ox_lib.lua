ZlomaCore.RegisterClientNotification('ox_lib', function(msg, kind, duration, raw)
    exports['ox_lib']:notify(raw or { title = kind:upper(), description = msg, type = kind, duration = duration })
end)
