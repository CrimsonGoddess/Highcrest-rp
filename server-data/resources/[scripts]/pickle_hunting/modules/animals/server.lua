SkinnedAnimals = {}

function ProcessRewards(src, rewardList)
    if #rewardList == 0 then return false end
    
    local selectedRewardIdx = nil
    repeat
        for i = 1, #rewardList do
            local roll = math.random(1, 100)
            if roll <= rewardList[i].chance then
                selectedRewardIdx = i
            end
        end
    until selectedRewardIdx
    
    local reward = rewardList[selectedRewardIdx]
    return AddItem(src, reward.name, reward.count)
end

RegisterCallback("pickle_hunting:skinAnimal", function(src, cb, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    local model = GetEntityModel(entity)
    local animalCfg = Config.Animals[model]
    
    if not animalCfg then
        return cb(false)
    end
    
    if netId and not SkinnedAnimals[netId] then
        SkinnedAnimals[netId] = true
        SetTimeout(animalCfg.skinTime * 1000, function()
            ProcessRewards(src, animalCfg.skinRewards)
        end)
        cb(true)
    else
        cb(false)
    end
end)

RegisterCallback("pickle_hunting:chopAnimal", function(src, cb, pointIdx, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    local model = GetEntityModel(entity)
    local animalCfg = Config.Animals[model]
    local pointCfg = Config.Chopping.points[pointIdx]
    
    if not animalCfg then
        return cb(false)
    end
    
    if netId and SkinnedAnimals[netId] then
        local function finishChop()
            SkinnedAnimals[netId] = nil -- Free up memory/id if needed, though entity is deleted
            SetTimeout(animalCfg.chopTime * 1000, function()
                ProcessRewards(src, animalCfg.chopRewards)
            end)
            cb(true)
        end

        if pointCfg.requireLicense then
            Config.LicenseCheck(src, { type = "chopping", index = pointIdx }, function(hasLicense)
                if hasLicense then
                    finishChop()
                else
                    cb(false)
                end
            end)
        else
            finishChop()
        end
    else
        cb(false)
    end
end)
