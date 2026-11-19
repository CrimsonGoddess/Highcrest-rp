QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("yoga:reduceStress", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local currentStress = Player.PlayerData.metadata["stress"] or 0
        Player.Functions.SetMetaData("stress", math.max(0, currentStress - 25))
    end
end)