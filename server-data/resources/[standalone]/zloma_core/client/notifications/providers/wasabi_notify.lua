ZlomaCore.RegisterClientNotification('wasabi_notify', function(msg, kind, duration)
    local normalized = kind == 'inform' and 'info' or kind
    exports.wasabi_notify:notify(normalized:upper(), msg, duration, normalized)
end)
