-- Highcrest /coords. The command is restricted to group.admin; the menu itself runs on the client.

lib.addCommand('coords', {
    help = 'Open the coordinate tool (raycast, preview, adjust, copy)',
    restricted = 'group.admin',
}, function(source)
    TriggerClientEvent('highcrest_coords:client:open', source)
end)
