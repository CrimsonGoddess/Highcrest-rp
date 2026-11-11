lib.Framework.RegisterCallback('peuren_chopshop:GetNewJob', function(source, cb, dealer)
    if not dealer then return end

    for _, data in pairs(Jobs.Data) do
        for player, _ in pairs(data) do
            if tonumber(player) == tonumber(source) then 
                return cb('you_have_job')
            end
        end 
    end

    local hasItems = Utils.RequiredItems(dealer)
    if not hasItems then return cb('no_required_job_items') end
    if Jobs.Get(source, dealer) then return cb('you_have_house') end

    local policeOn = lib.Framework.GetJobPlayerCount(Config.Jobs.policeJobs)
    if policeOn < Config.Jobs.policeRequired then return cb('not_enough_police_to_start') end

    print('passed')
    local result = Jobs.Set(source, dealer)
    if not result then return cb('failed_to_find_job') end

    if Config.Dealers[dealer].PersonalCooldown then 
        Cooldown.Set(source, 'personal', dealer)
    end

    if Config.Dealers[dealer].GlobalCooldown then 
        Cooldown.Set(source, 'global', dealer)
    end

    Config.JobMail(source, result.location.model, result.client.vehicle.plate)
    JobLogger(source, result.dealer, result.location.class)

    cb(result)
end)

lib.Framework.RegisterCallback('peuren_chopshop:AddItem', function(source, cb, dealer, class, bone)
    if not Config.Rewards[dealer] then return cb(false) end
    if not Config.Rewards[dealer][class] then return cb(false) end
    local rewards = Config.Rewards[dealer][class]

    for k,data in pairs(rewards) do
        if string.find(bone, k) then
            for _,v in pairs(data) do
                if v.chance then
                    if math.random(1, 100) <= v.chance then
                        lib.Inventory.AddItem(source, v.item, math.random(v.min, v.max))
                    end
                else
                    lib.Inventory.AddItem(source, v.item, math.random(v.min, v.max))
                end
            end
        end
    end

    return true
end)

lib.Framework.RegisterCallback('peuren_chopshop:GetActiveJobs', function(source, cb)
    cb(Jobs.Data)
end)

lib.Framework.RegisterCallback('peuren_chopshop:HasPlayerItem', function(source, cb, item)
    cb(lib.Inventory.HasPlayerItem(source, item, 1))
end)

lib.Framework.RegisterCallback('peuren_chopshop:AddTaskProgress', function(source, cb, dealer, task, count)
    Reputation.AddTaskProgress(source, dealer, task, count)
    cb(true)
end)

lib.Framework.RegisterCallback('peuren_chopshop:RemoveJob', function(source, cb, dealer)
    if not dealer then return cb(false) end
    Jobs.Remove(source, dealer)
    cb(true)
end)

RegisterNetEvent('peuren_chopshop:UpdateMisionData', function(data)
    Jobs.Update(data.id, data.dealer, data)
end)

RegisterNetEvent('peuren_chopshop:CreateDropOff', function(data)
    print(json.encode(data, { indent = true }))
    if not data then return end 
    data.locked = false 
    Jobs.Update(data.id, data.dealer, data)
    TriggerClientEvent('peuren_chopshop:client:MissionUpdate', data.id, 'chop-vehicle', data)
    TriggerClientEvent('peuren_chopshop:client:CreateDropOff', -1, data)
end)