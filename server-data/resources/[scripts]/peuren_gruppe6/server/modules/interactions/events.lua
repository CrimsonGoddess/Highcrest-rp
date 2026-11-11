RegisterNetEvent('peuren_gruppe6:server:CreateInteraction', function(id, type, netId, data)
    lib.Groups.SendEvent(id, 'peuren_gruppe6:client:CreateInteraction', { id = id, type = type, netId = netId, data = data })
end)

RegisterNetEvent('peuren_gruppe6:server:RemoveInteraction', function(id, type, netId, data)
    lib.Groups.SendEvent(id, 'peuren_gruppe6:client:RemoveInteraction', { id = id, type = type, netId = netId, data = data })
end)