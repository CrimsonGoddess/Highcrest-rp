---Event that is sent from the server side, ment to create new interaction for a group
---@param data any
RegisterNetEvent('peuren_gruppe6:client:CreateInteraction', function(data)
    Interactions.Set[data.type](data.id, data.netId, data.data)
end)

---Event that is sent from the server side, ment to delete a given interaction
---@param data any
RegisterNetEvent('peuren_gruppe6:client:RemoveInteraction', function(data)
    if not data then return end
    if not data.type or not data.id then return end
    Interactions.Remove[data.type](data.id, data.netId or nil, data.data or {})
end)