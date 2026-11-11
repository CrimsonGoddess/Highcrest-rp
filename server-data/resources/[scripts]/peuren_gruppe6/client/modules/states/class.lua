States = {
    Data = {},

    ---Gets given entity states
    ---@param id string
    ---@param netId number | nil
    ---@return table | nil
    Get = function(id, netId)
        if not id then return end 
        if not States.Data[id] then return end
        if not netId then return States.Data[id] end
        return States.Data[id][tonumber(netId)]
    end,

    ---Sets state data for an entity in a job state table
    ---@param id string
    ---@param netId number
    ---@param data table
    Set = function(id, netId, data)
        if not id or not netId or not data then return end
        if not States.Data[id] then return end

        local states = States.Data[id][tonumber(netId)].states
        if not states then return end

        for k,v in pairs(data) do 
            states[k] = v
        end        
    end, 

    ---Creates states for given entities
    ---@param id string
    ---@param type string
    ---@param data table
    Create = function(id, type, data)
        if not id or not type or not data then return end
        if not States.Data[id] then States.Data[id] = {} end
        local entities = States.Data[id]        

        entities[data.netId] = { netId = data.netId, type = type, states = data.states or {} }   

        AddStateBagChangeHandler(id, nil, function(bagName, key, value)
            local netId = string.match(bagName, "entity:(.*)")
            TriggerServerEvent('peuren_gruppe6:server:UpdateState', id, netId, value)
        end)
    end,

    ---Removes entity state from a given job state table
    ---@param id string
    ---@param netId number
    Delete = function(id, netId)
        if not id or not netId then return end
        if not States.Data[id] then return end
        
        local entity = States.Data[id][tonumber(netId)]
        if not entity then return end
        
        entity = nil
    end,

    ---Function that registers new states for given entities for all group members
    ---@param id string
    ---@param type string
    ---@param data table
    Register = function(id, type, data)
        if not id or not type or not data then return end
        TriggerServerEvent('peuren_gruppe6:server:CreateStates', id, type, data)
    end,

    ---Function that removes a entity state for all group members
    ---@param id string
    ---@param netId number
    Remove = function(id, netId)
        if not id or not netId then return end
        TriggerServerEvent('peuren_gruppe6:server:RemoveState', id, netId)
    end
}