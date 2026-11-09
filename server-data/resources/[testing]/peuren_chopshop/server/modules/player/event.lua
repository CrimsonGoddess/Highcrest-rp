lib.Framework.RegisterCallback('peuren_chopshop:CanAccessDealer', function(source, cb, dealer)
    local data = Config.Dealers[dealer].RequiredRep
    local passed, length = 0, 0

    for k, v in pairs(data) do
        if v <= Reputation.Get(source, k).Level then   
            passed += 1
        end
        length += 1
    end      

    cb(passed >= length)
end)

lib.Framework.RegisterCallback('peuren_chopshop:GetKickingExhaustion', function(source, cb)
    if not Ply.data[source] then Ply.data[source] = {} end
    if not Ply.data[source].exhaustion then return cb(false) end
    local result = Ply.data[source].exhaustion > os.time()

    if not result then 
        Ply.data[source].exhaustion = nil
        cb(false)
    end

    cb(true)
end)

lib.Framework.RegisterCallback('peuren_chopshop:SetKickingExhaustion', function(source, cb)
    if not Ply.data[source] then Ply.data[source] = {} end
    if not Ply.data[source].exhaustion then 
        local cooldown = Config.Kicking.cooldown
        Ply.data[source].exhaustion = os.time() + cooldown.min * 60 + cooldown.sec 
    end

    cb(true)
end)