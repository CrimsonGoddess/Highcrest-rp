lib.Framework.RegisterCallback('peuren_gruppe6:startNewJob', function(source, cb, data)
    local inGroups = lib.Groups.IsPlayerInAnyGroup(source) 

    if inGroups then 
        TriggerClientEvent("peuren_lib:notify", source, lib.Locale("you_have_job"), nil, "error")
        return 
    end

    local group = Jobs.Create(source, data)

    if type(group) == 'string' then 
        TriggerClientEvent("peuren_lib:notify", source, lib.Locale(group), nil, "error")
        return
    end

    cb({ group = group })
end)

lib.Framework.RegisterCallback('peuren_gruppe6:getAvailableJobs', function(source, cb, location)
    cb(Jobs.GetAvailableJobs(source, location))
end)

lib.Framework.RegisterCallback('peuren_gruppe6:isPlayerInGroup', function(source, cb, location)
    cb(Jobs.IsPLayerInGroup(source, location))
end)

lib.Framework.RegisterCallback('peuren_gruppe6:currentJobData', function(source, cb, id)
    local user = Users.GetIdentifier(source)
    local result = Jobs.Get(id)

    cb({
        owner = user == result.owner,
        started = result.args.started 
    })
end)

lib.Framework.RegisterCallback('peuren_gruppe6:getAvailableGroups', function(source, cb)
    cb(Jobs.GetAvailableGroups())
end)

lib.Framework.RegisterCallback('peuren_gruppe6:joinGroup', function(source, cb, data, pass)
    if not data then return end

    if pass then 
        if not Jobs.Data[data.groupId] then return cb(false) end 
        if tostring(Jobs.Data[data.groupId].pass) ~= tostring(pass) then return cb(false) end
        Jobs.AddPlayer(data.groupId, source)
    else 
        if not Jobs.Data[data.groupId] then return cb(false) end 
        Jobs.AddPlayer(data.groupId, source)
    end

    cb(true)
end)

lib.Framework.RegisterCallback('peuren_gruppe6:isPlayerInJob', function(source, cb)
    cb(Jobs.IsPLayerInGroup(source))
end)

lib.Framework.RegisterCallback('peuren_gruppe6:GetGroupJob', function(source, cb, id)
    local user = Users.GetIdentifier(source)
    local result = Jobs.Get(id)
    if not result then return cb({}) end
    cb({
        pass = result.pass,
        id = result.args.groupId,
        owner = user == result.owner,
        type = Config.Jobs[result.args.job].label,
        description = Config.Jobs[result.args.job].description,
        members = result.players
    })
end)

lib.Framework.RegisterCallback('peuren_gruppe6:AddItem', function(source, cb, item, amount)
    lib.Inventory.AddItem(source, item, amount)
    cb(true)
end)

lib.Framework.RegisterCallback('peuren_gruppe6:RemoveItem', function(source, cb, item, amount)
    lib.Inventory.RemoveItem(source, item, amount)
    cb(true)
end)

RegisterNetEvent('peuren_gruppe6:startGroupJob', function(data)
    local result = Jobs.Get(data.id)    
    result.args.started = true
    TriggerClientEvent('peuren_gruppe6:StartJob', source, result)
    lib.Groups.SendEvent(data.id, 'peuren_gruppe6:SyncStartJob', result)
end)

RegisterNetEvent('peuren_gruppe6:server:EndGroupJob', function(id)
    if not id then return end

    local job = Jobs.Get(id)
    if not job then return end  

    lib.Groups.SendEvent(id, 'peuren_gruppe6:client:EndGroupJob', id)  
end)

RegisterNetEvent('peuren_gruppe6:server:EndJob', function(data)
    if not data then return end

    local id = data.id
    local job = Jobs.Get(id)
    if not job then return end   

    if data.finished then
        Jobs.GiveRewards(job, job.args.bags)
    end   
    
    lib.Groups.SendEvent(id, 'peuren_gruppe6:client:ClearJobData', {})  
    Jobs.Remove(id)
end)

RegisterNetEvent('peuren_gruppe6:server:KickPlayer', function(id, player)
    if not id or player then return end

    local job = Jobs.Get(id)
    if not job then return end   

    Jobs.RemovePlayer(player.source)
    TriggerClientEvent('peuren_gruppe6:client:ClearJobData', player.source, {}, false) 
end)

RegisterNetEvent('peuren_gruppe6:server:OrderFinished', function(data)
    if not data then return end

    local job = Jobs.Get(data.groupId)
    if not job then return end   

    Orders.Data[job.args.type][data.id].claimed = false
    Jobs.Data[data.groupId].args.bags += data.bags
    lib.Groups.SendEvent(data.groupId, 'peuren_gruppe6:client:OrderFinished', data)  
end)