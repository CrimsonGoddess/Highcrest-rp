local callId = 0
calls = {}

Framework.RegisterCallback("GetDispatchCalls", function(source, callback, data)
    callback(calls)
end)

RegisterNetEvent("redutzu-ems:server:addDispatchToEMS", function(data)
    callId = callId + 1
    data.id = callId
    data.createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
    calls[callId] = data
    
    for i = 1, #Config.WhitelistedJobs do
        local jobPlayers = Framework.GetJobPlayers(Config.WhitelistedJobs[i])
        for _, player in ipairs(jobPlayers) do
            if Config.RequireDuty then
                if not IsDuty(player.source) then
                    return
                end
            end
            TriggerClientEvent("redutzu-ems:client:addDispatchToEMS", player.source, data)
        end
    end
end)

RegisterNetEvent("redutzu-ems:server:removeCall", function(callId)
    table.remove(calls, callId)
end)

Framework.RegisterCallback("SetDispatchCheckpoint", function(source, callback, data)
    local call = array.find(calls, function(c)
        return c.id == data
    end)
    
    TriggerClientEvent("redutzu-ems:client:setDispatchCheckpoint", source, call.coords)
    callback("ok")
end)
