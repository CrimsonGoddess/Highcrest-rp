RegisterNetEvent("kq_driftsmoke:smoke")

AddEventHandler("kq_driftsmoke:smoke", function(netId, bone, scale, isColored)
    local source = source
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    for _, playerId in ipairs(GetPlayers()) do
        local targetPlayerId = tonumber(playerId)

        if targetPlayerId ~= source then
            local shouldSync = false

            if Config.syncToNearbyPlayersOnly then
                local targetPed = GetPlayerPed(targetPlayerId)
                local targetCoords = GetEntityCoords(targetPed)
                local distance = GetDistanceBetweenCoords(
                    targetCoords.x, targetCoords.y, targetCoords.z,
                    coords.x, coords.y, coords.z
                )

                if distance < Config.syncRadius then
                    shouldSync = true
                end
            else
                shouldSync = true
            end

            if shouldSync then
                TriggerClientEvent("kq_driftsmoke:smoke", tonumber(playerId), netId, bone, scale, isColored)
            end
        end
    end
end)

function GetDistanceBetweenCoords(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end
