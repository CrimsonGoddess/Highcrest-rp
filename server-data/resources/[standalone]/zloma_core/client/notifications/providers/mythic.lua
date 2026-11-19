ZlomaCore.RegisterClientNotification('mythic', function(msg, kind)
    exports['mythic_notify']:DoHudText(kind == 'info' and 'inform' or kind, msg)
end)
