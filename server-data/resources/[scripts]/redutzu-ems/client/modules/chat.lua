RegisterNetEvent("redutzu-ems:client:addChatMessage", function(data)
    SendNUIMessage({
        action = "addChatMessage",
        data = data
    })
end)

RegisterNuiCallback("GetChatMessages", function(data, callback)
    Framework.TriggerCallback("GetChatMessages", callback)
end)

RegisterNuiCallback("SendMessage", function(data, callback)
    Framework.TriggerCallback("SendMessage", callback, data)
end)
