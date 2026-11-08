Framework.RegisterCallback("GetPlayerPosition", function(source, callback, data)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    callback({
        x = coords.x,
        y = coords.y,
        z = coords.z
    })
end)
