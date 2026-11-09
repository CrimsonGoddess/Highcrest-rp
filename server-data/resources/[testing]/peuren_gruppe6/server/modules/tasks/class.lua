Tasks = {
    Data = {},

    ---Gets task data
    ---@param id string
    ---@param name string
    ---@return table | nil
    Get = function(id, name)
        if not id or not name then return end
        if not Tasks.Data[id] then return end 
        if not Tasks.Data[id][name] then return end 

        return Tasks.Data[id][name]
    end,

    ---Sets a new task
    ---@param id string
    ---@param name string
    ---@param args table
    Set = function(id, name, args)
        if not id or not name or not args then return end
        if not Tasks.Data[id] then Tasks.Data[id] = {} end

        Tasks.Data[id][name] = {
            min = args.min,
            max = args.max,
            progress = args.min,
            event = args.event,
            serverEvent = args.serverEvent,
            args = args.args
        }
    end,

    ---Adds progress to a task
    ---@param id string
    ---@param name string
    ---@param progress number
    AddProgress = function(id, name, progress, args)
        if not id or not name or not progress then return end
        if not Tasks.Data[id] then return end 
        if not Tasks.Data[id][name] then return end 

        local task = Tasks.Data[id][name]

        for k,v in pairs(args) do 
            task.args[k] = v
        end

        task.progress += progress
        if task.progress >= task.max then Tasks.Remove(id, name) end
    end,

    ---Removes progress from a task
    ---@param id string
    ---@param name string
    ---@param progress number
    RemoveProgress = function(id, name, progress, args)
        if not id or not name or not progress then return end
        if not Tasks.Data[id] then return end 
        if not Tasks.Data[id][name] then return end 

        local task = Tasks.Data[id][name]

        for k,v in pairs(args) do 
            task.args[k] = v
        end

        task.progress -= progress
        if task.progress < task.min then task.progress = task.min end
    end,

    ---Removes task
    ---@param id string
    ---@param name string
    Remove = function(id, name)
        if not id or not name then return end
        if not Tasks.Data[id] then return end 
        if not Tasks.Data[id][name] then return end      
        
        local task = Tasks.Data[id][name]
        Tasks.Data[id][name] = nil

        if task.event then 
            lib.Groups.SendEvent(id, task.event, task.args)
        else
            TriggerEvent(task.serverEvent, task.args)
        end
    end,
}