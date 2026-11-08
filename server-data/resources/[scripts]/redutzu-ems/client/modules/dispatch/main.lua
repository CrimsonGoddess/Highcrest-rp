function addDispatchCall(data)
    SendNUIMessage({
        action = "addDispatchCall",
        data = data
    })
    if not opened then
        SetNuiFocus(false, false)
    end
end

RegisterNetEvent("redutzu-ems:client:addDispatchToEMS", function(data)
    addDispatchCall(data)
end)

RegisterNuiCallback("DeleteDispatchCall", function(data, callback)
    TriggerServerEvent("redutzu-ems:server:removeCall", data)
end)

RegisterNuiCallback("SetDispatchCheckpoint", function(data, callback)
    Framework.TriggerCallback("SetDispatchCheckpoint", callback, data)
end)

RegisterNetEvent("redutzu-ems:client:setDispatchCheckpoint", function(data)
    SetNewWaypoint(data.x, data.y)
    SendNUIMessage({
        action = "setDispatchCheckpoint",
        data = {
            x = data.x,
            y = data.y
        }
    })
end)

RegisterNuiCallback("GetDispatchCalls", function(data, callback)
    Framework.TriggerCallback("GetDispatchCalls", function(calls)
        local mappedCalls = array.map(calls, function(call)
            if not call.street then
                call.street = GetStreetNameFromCoords(call.coords)
            end
            return call
        end)
        callback(mappedCalls)
    end)
end)
