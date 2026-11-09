Tasks = {
    Data = {},

    ---Gets task data
    ---@param id string
    ---@param name string
    ---@return table | nil
    Get = function(id, name)
        if not id or not name then return end
        local result = lib.Framework.Callbacks.Trigger("peuren_gruppe6:GetTask", id, name)
        return result
    end,

    ---Sets a new task
    ---@param id string
    ---@param name string
    ---@param args table
    Set = function(id, name, args)
        if not id or not name or not args then return end
        TriggerServerEvent('peuren_gruppe6:server:CreateNewTask', id, name, args)
    end,

    ---Adds progress to a task
    ---@param id string
    ---@param name string
    ---@param progress number
    AddProgress = function(id, name, progress, args)
        if not id or not name or not progress then return end
        TriggerServerEvent('peuren_gruppe6:server:AddProgress', id, name, progress, args or {})
    end,

    ---Removes progress from a task
    ---@param id string
    ---@param name string
    ---@param progress number
    RemoveProgress = function(id, name, progress, args)
        if not id or not name or not progress then return end
        TriggerServerEvent('peuren_gruppe6:server:RemoveProgress', id, name, progress, args or {})
    end,

    ---Removes task
    ---@param id string
    ---@param name string
    Remove = function(id, name)
        if not id or not name then return end
        TriggerServerEvent('peuren_gruppe6:server:RemoveTask', id, name)
    end,
}