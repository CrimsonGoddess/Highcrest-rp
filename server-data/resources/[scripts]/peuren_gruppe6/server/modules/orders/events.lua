lib.Framework.RegisterCallback('peuren_gruppe6:GetOrders', function(source, cb, type)
    local orders = {}
    local data = Orders.Get(type)  
    local rank = Ranks.Get(source).Level

    if data then
        for k,v in pairs(data) do
            if not v.claimed and v.type == Config.Ranks.Levels[rank].job then 
                orders[#orders + 1] = v
            end
        end
    end
    
    cb(orders)
end)

RegisterNetEvent('peuren_gruppe6:server:ClaimOrder', function(data)
    local result = Orders.Claim(data.type, data.id)
    if not result then return end 

    local job = Jobs.Get(data.groupId)
    if not job then return end 

    lib.Groups.SendEvent(data.groupId, 'peuren_gruppe6:client:ClaimOrder', result)
end)

RegisterNetEvent('peuren_gruppe6:client:RemoveOrder', function(data)
    local result = Orders.Get(data.type, data.id)
    if not result then return end 

    Orders.Data[data.type][data.id].claimed = false

    local job = Jobs.Get(data.groupId)
    if not job then return end
    
    local penalty = Config.Jobs[job.args.job].cancelPenalty
    if penalty then 
        Ranks.RemoveRankXP(source, penalty)
    end

    lib.Groups.SendEvent(data.groupId, 'peuren_gruppe6:client:OrderFinished', result)
end)