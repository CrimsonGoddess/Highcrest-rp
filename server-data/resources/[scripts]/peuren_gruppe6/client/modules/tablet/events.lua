RegisterNetEvent('peuren_gruppe6:client:UpdateTablet', function(data)
    Tablet.Update(data)
end)

if Config.TabletCommand then 
    RegisterCommand(Config.TabletCommand, function()
        Tablet.Open()
    end)
end

RegisterNetEvent('peuren_gruppe6:UpdateOrders', function(data)
    if not Tablet.IsOpen then return end 
    SendNUIMessage({ type = "contracts", value = data })
end)

RegisterNUICallback("close", function(_, cb)
    Tablet.Close()
    cb("ok")
end)

RegisterNUICallback("takeOrder", function(data, cb)
    if not data then return end

    local job = Jobs.Data.args
    if not job then return end

    TriggerServerEvent('peuren_gruppe6:server:ClaimOrder', { groupId = job.groupId, type = job.type, id = data.id })
    cb("ok")
end)

RegisterNUICallback("cancelOrder", function(data, cb)
    if not data then return end

    local job = Jobs.Data.args
    if not job then return end

    TriggerServerEvent('peuren_gruppe6:client:RemoveOrder', { groupId = job.groupId, type = job.type, id = data.id })
    cb("ok")
end)

RegisterNUICallback("endJob", function(_, cb)
    local job = Jobs.Data.args
    if not job then return end

    TriggerServerEvent('peuren_gruppe6:server:EndGroupJob', job.groupId)
    cb("ok")
end)

RegisterNUICallback("kickMember", function(data, cb)
    if not data then return end

    local job = Jobs.Data.args
    if not job then return end

    TriggerServerEvent('peuren_gruppe6:server:KickPlayer', job.groupId, data)    
    cb("ok")
end)

RegisterNetEvent('peuren_gruppe6:OpenTablet', Tablet.Open)
exports('OpenTablet', Tablet.Open)