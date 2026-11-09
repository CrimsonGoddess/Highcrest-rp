lib.Framework.RegisterCallback('peuren_chopshop:GetReputation', function(source, cb, dealer)
    cb(Reputation.Get(source, dealer))
end)

lib.Framework.RegisterCallback("peuren_chopshop:GetNewTask", function(source, cb, dealer)
    local dealerData = Reputation.Get(source, dealer)
    if dealerData.Task then
        cb(false)
        return
    end

    local keys = {}
    for k, v in pairs(Config.Tasks[dealer]) do
        keys[#keys+1] = k
    end

    local rndTask = keys[math.random(1, #keys)]

    dealerData.Task = rndTask
    if Config.Tasks[dealer][rndTask].Type == "minigame" then
        dealerData.TaskProgress = 0
    end
    Reputation.Save(source)
    cb(rndTask)
end)

lib.Framework.RegisterCallback("peuren_chopshop:CompleteTask", function(source, cb, dealer)
    local dealerData = Reputation.Get(source, dealer)
    if not dealerData.Task then
        cb(false)
        return
    end

    local taskData = Config.Tasks[dealer][dealerData.Task]

    if taskData.Type == "item" then
        if not lib.Inventory.HasPlayerItem(source, taskData.Item, taskData.Amount) then
            TriggerClientEvent("peuren_lib:notify", source, lib.Locale("notify_dont_have_item"), nil, "error")
            cb(false)
            return
        end

        lib.Inventory.RemoveItem(source, taskData.Item, taskData.Amount)
    end

    if taskData.Type == "minigame" then
        if dealerData.TaskProgress < taskData.Count then
            TriggerClientEvent("peuren_lib:notify", source, lib.Locale("notify_havent_completed_task"), nil, "error")
            cb(false)
            return
        end
    end

    if taskData.Rewards.money then
        local moneyReward = taskData.Rewards.money
        local chance = math.random(1, 100)
        if chance <= moneyReward.chance then
            lib.Framework.Money.Give(source, math.random(moneyReward.amount.min, moneyReward.amount.max), moneyReward.account)
        end
    end

    if taskData.Rewards.items then
        for k, v in pairs(taskData.Rewards.items) do
            local chance = math.random(1, 100)
            if chance <= v.chance then
                lib.Inventory.AddItem(source, v.name, math.random(v.min, v.max))
            end
        end
    end

    dealerData.Task = nil

    if taskData.Rewards.reputation then
        Reputation.AddRep(source, dealer, math.random(taskData.Rewards.reputation.min, taskData.Rewards.reputation.max))
    end

    cb(true)
end)

lib.Framework.RegisterCallback("peuren_chopshop:CancelTask", function(source, cb, dealer)
    local dealerData = Reputation.Get(source, dealer)
    if not dealerData.Task then
        cb(false)
        return
    end

    local penaltyData = Config.Tasks[dealer][dealerData.Task].Penalty
    local penalty = math.random(penaltyData.min, penaltyData.max)

    dealerData.Task = nil
    Reputation.RemoveRep(source, dealer, penalty)
    cb(true)
end)