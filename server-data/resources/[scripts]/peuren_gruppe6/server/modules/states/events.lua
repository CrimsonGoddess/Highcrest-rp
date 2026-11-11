
RegisterNetEvent('peuren_gruppe6:server:CreateStates', function(groupId, type, data)
    lib.Groups.SendEvent(groupId, 'peuren_gruppe6:client:CreateStates', { id = groupId, type = type, data = data })
end)

RegisterNetEvent('peuren_gruppe6:server:UpdateState', function(groupId, netId, data)
    lib.Groups.SendEvent(groupId, 'peuren_gruppe6:client:UpdateState', { id = groupId, netId = netId, data = data })
end)

RegisterNetEvent('peuren_gruppe6:server:RemoveState', function(groupId, netId)
    lib.Groups.SendEvent(groupId, 'peuren_gruppe6:client:RemoveState', { id = groupId, netId = netId })
end)