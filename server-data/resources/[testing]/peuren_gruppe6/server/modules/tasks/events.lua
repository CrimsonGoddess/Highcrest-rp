---Callback that returns task data
---@param source number
---@param cb function
---@param id string
---@param name string
lib.Framework.RegisterCallback('peuren_gruppe6:GetTask', function(source, cb, id, name)
    cb(Tasks.Get(id, name))
end)

---Event that creates a new task
---@param id string
---@param name string
---@param args table
RegisterNetEvent('peuren_gruppe6:server:CreateNewTask', function(id, name, args)
    Tasks.Set(id, name, args)
end)

---Event that adds progress to a task
---@param id string
---@param name string
---@param progress number
RegisterNetEvent('peuren_gruppe6:server:AddProgress', function(id, name, progress, args)
    Tasks.AddProgress(id, name, progress, args)
end)

---Event that removes progress from a task
---@param id string
---@param name string
---@param progress number
RegisterNetEvent('peuren_gruppe6:server:RemoveProgress', function(id, name, progress, args)
    Tasks.RemoveProgress(id, name, progress, args)
end)

---Event that removes task
---@param id string
---@param name string
RegisterNetEvent('peuren_gruppe6:server:RemoveTask', function(id, name)
    Tasks.Remove(id, name)
end)