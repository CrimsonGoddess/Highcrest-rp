ZlomaCore.RegisterClientNotification('lation_ui', function(msg, kind) exports.lation_ui:notify({ message = msg, type = kind == 'info' and 'inform' or kind }) end)
