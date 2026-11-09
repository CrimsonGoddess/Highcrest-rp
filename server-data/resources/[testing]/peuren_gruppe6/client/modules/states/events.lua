
---Event that is sent from the server side, ment to create new states for a group
---@param data any
RegisterNetEvent('peuren_gruppe6:client:CreateStates', function(data)    
    States.Create(data.id, data.type, data.data)
end)

---Event that is sent from the server side, ment to sync updated states to all group members
---@param data any
RegisterNetEvent('peuren_gruppe6:client:UpdateState', function(data)    
    States.Set(data.id, data.netId, data.data)
end)

---Event that is sent from the server side, ment to delete a given state 
---@param data any
RegisterNetEvent('peuren_gruppe6:client:RemoveState', function(data)    
    States.Delete(data.id, data.netId)
end)