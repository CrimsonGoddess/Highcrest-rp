function GetItemStats(src, exchangeCfg)
    local totalSourceCount = 0
    local totalRewardAmount = 0
    for itemName, data in pairs(exchangeCfg) do
        local count = Search(src, itemName)
        if count > 0 then
            local rewardPerUnit = math.random(data.min, data.max)
            totalSourceCount = totalSourceCount + count
            totalRewardAmount = totalRewardAmount + (rewardPerUnit * count)
        end
    end
    return totalSourceCount, totalRewardAmount
end

function ExchangeItems(src, exchangeCfg)
    for itemName, data in pairs(exchangeCfg) do
        local count = Search(src, itemName)
        if count > 0 then
            local rewardPerUnit = math.random(data.min, data.max)
            local totalReward = rewardPerUnit * count
            AddItem(src, data.name, totalReward)
            RemoveItem(src, itemName, count)
        end
    end
end

RegisterCallback("pickle_hunting:exchangeLocation", function(src, cb, pointIdx)
    local pointCfg = Config.Exchange.points[pointIdx]
    local exchangeData = pointCfg.exchange
    local totalCount, totalReward = GetItemStats(src, exchangeData)
    
    local function finishExchange()
        SetTimeout(Config.Exchange.exchangeTime * 1000, function()
            ExchangeItems(src, exchangeData)
        end)
        cb(true, totalCount, totalReward)
    end

    if pointCfg.requireLicense then
        Config.LicenseCheck(src, { type = "exchange", index = pointIdx }, function(hasLicense)
            if hasLicense then
                finishExchange()
            else
                cb(false)
            end
        end)
    else
        finishExchange()
    end
end)
