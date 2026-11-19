ZlomaCore.RegisterClientNotification('wasabi_uikit', function(msg, kind) exports.wasabi_uikit:Notification({ title = msg, type = kind == 'inform' and 'info' or kind }) end)
