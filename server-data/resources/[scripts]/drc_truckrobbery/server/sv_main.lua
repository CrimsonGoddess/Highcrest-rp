local onTimer = {}
local playerTriggerCounts = {}


function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

RegisterServerEvent("drc_truck:getMoney")
AddEventHandler("drc_truck:getMoney", function(grabobjCoords, grabModel, teamPlayerIds)
    local src = source
    local xPlayer = GetPlayerFromId(src)
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local trolleyCoords = grabobjCoords
    local playerID = src

    if #(playerCoords - trolleyCoords) > 10.0 then
        print('You are too far away from the vehicle.')
        return
    end
    
        if not teamPlayerIds or not table.contains(teamPlayerIds, playerID) then
            print("Player " .. playerID .. " is not part of the team.")
            return
        end

    -- Highcrest: the client reports each grab, so the server caps how many pay and how fast.
    -- A robbery's grabs count for 30 minutes, which also stops anyone requesting endless loot.
    local now, nowMs = os.time(), GetGameTimer()
    local record = playerTriggerCounts[playerID]
    if not record or now - record.started > 1800 then
        record = { started = now, count = 0, last = 0 }
        playerTriggerCounts[playerID] = record
    end
    if nowMs - record.last < 300 then return end
    record.last = nowMs
    if record.count >= (Config.Reward.MaxGrabs or 40) then return end
    record.count = record.count + 1

    local function getRandomMoneyAmount()
        local minMoney = Config.Reward.Money.Min
        local maxMoney = Config.Reward.Money.Max
        return math.random(minMoney, maxMoney)
    end
    
    local function getRandomGoldCount()
        local minGold = Config.Reward.Gold.Min
        local maxGold = Config.Reward.Gold.Max
        return math.random(minGold, maxGold)
    end
    
    local function getRandomDiamondCount()
        local minDiamond = Config.Reward.Diamond.Min
        local maxDiamond = Config.Reward.Diamond.Max
        return math.random(minDiamond, maxDiamond)
    end

    if grabModel == 'ch_prop_vault_dimaondbox_01a' then
        local count = getRandomDiamondCount()
        AddItem('diamond', count, playerID)
    elseif grabModel == 'ch_prop_gold_bar_01a' then
        local count = getRandomGoldCount()
        AddItem('gold', count, playerID)
    elseif grabModel == 'hei_prop_heist_cash_pile' then
        local money = getRandomMoneyAmount()
        AddMoney(money, playerID)
    end
end)

lib.callback.register('drc_truck:useC4', function(source)
    local hasC4 = GetItem(Config.C4.itemName, 1, source)
    if hasC4 then
        RemoveItem(Config.C4.itemName, 1, source) 
        return true 
    else
        return false 
    end
end)

lib.callback.register('drc_truck:getNames', function(source, potentialTeamMembers)
    local playerNames = {}
    local sourcePlayer = GetPlayerFromId(source)
    local sourcePlayerName = GetPlayerName(sourcePlayer)

    for _, playerId in ipairs(potentialTeamMembers) do
        local xPlayer = GetPlayerFromId(playerId)
        local playerName = GetPlayerName(xPlayer)
        if playerName ~= "Unknown" then
            table.insert(playerNames, playerName)
        end
    end

    return {teamLeader = sourcePlayerName, teamMembers = playerNames}
end)


local missionActive = false
local lastMissionStartTime = 0
local missionCooldown = Config.Times.CoolDown * 60 


lib.callback.register('drc_truck:startMissionCooldown', function()
    if not missionActive then
        lastMissionStartTime = os.time()
        missionActive = true
        return true, "Mission started and cooldown timer initiated"
    else
        return false, "Mission is already active"
    end
end)


lib.callback.register('drc_truck:isMissionOnCooldown', function()
    local currentTime = os.time()
    if currentTime < lastMissionStartTime + missionCooldown then
        local timeLeft = lastMissionStartTime + missionCooldown - currentTime
        local timeLeftInMinutes = math.ceil(timeLeft / 60)
        return true, timeLeftInMinutes
    else
        missionActive = false 
        return false, 0
    end
end)


local MIN_POLICE_REQUIRED = Config.MissionStart.PoliceRequire

lib.callback.register('drc_truck:checkPoliceOnline', function(source)
    local policeCount = CheckJob() 

    return policeCount >= MIN_POLICE_REQUIRED
end)



lib.callback.register('drc_truckrobbery:checkItem', function(source)
    local hasC4 = GetItem(Config.C4.itemName, 1, source)
    if hasC4 then
        return true 
    else
        return false 
    end
end)


RegisterNetEvent('drc_truck:invitePlayer')
AddEventHandler('drc_truck:invitePlayer', function(invitedPlayerName)
    local sourcePlayerId = source
    local invitedPlayerServerId = nil

    for _, playerId in ipairs(getPlayerList()) do
        local xPlayer = GetPlayerFromId(playerId)
        if xPlayer then
            local currentPlayerName = GetPlayerName(xPlayer)
            if currentPlayerName == invitedPlayerName then
                invitedPlayerServerId = playerId
                break
            end
        end
    end

    if invitedPlayerServerId then
        TriggerClientEvent('drc_truck:receiveInvitation', invitedPlayerServerId, sourcePlayerId)
    else
        print("Player not found: " .. invitedPlayerName)
    end
end)

RegisterNetEvent('drc_truck:acceptInvitation')
AddEventHandler('drc_truck:acceptInvitation', function(teamLeaderId)
    local xPlayer = GetPlayerFromId(source)
    local playerName = GetPlayerName(xPlayer)
    local playerId = source
    
    TriggerClientEvent('drc_truck:updatePlayerLists', teamLeaderId, source)
    TriggerClientEvent('drc_truck:updateTeamLeader', teamLeaderId, playerName, playerId)
end)



RegisterNetEvent('drc_truck:missionReadyToStart')
AddEventHandler('drc_truck:missionReadyToStart', function(teamPlayerIds)
    local source = source
        TriggerClientEvent('drc_truck:startMission', source, teamPlayerIds)
end)

RegisterNetEvent('drc_truck:createFindRadius')
AddEventHandler('drc_truck:createFindRadius', function(teamPlayerIds, spawnLocation)
    local source = source
        for _, playerId in ipairs(teamPlayerIds) do
        TriggerClientEvent('drc_truck:addRadiusForFind', playerId, spawnLocation)
    end
end)

RegisterNetEvent('drc_truck:serverSpawnTruck')
AddEventHandler('drc_truck:serverSpawnTruck', function(teamPlayerIds)
    local source = source
    TriggerClientEvent('drc_truck:spawnTruck', source, teamPlayerIds)
end)

RegisterNetEvent('drc_truck:MenuIsOpen:Server')
AddEventHandler('drc_truck:MenuIsOpen:Server', function()
    TriggerClientEvent('drc_truck:MenuIsOpen', -1)
end)

RegisterNetEvent('drc_truck:MenuIsClosed:Server')
AddEventHandler('drc_truck:MenuIsClosed:Server', function()
    TriggerClientEvent('drc_truck:MenuIsClosed', -1)
end)

RegisterNetEvent('drc_truck:removeTargetForTeam_GrabTrolley')
AddEventHandler('drc_truck:removeTargetForTeam_GrabTrolley', function(teamPlayerIds)
    for _, playerId in ipairs(teamPlayerIds) do
        TriggerClientEvent('drc_truck:removeTarget_MoneyTroley', playerId)
    end
end)

RegisterNetEvent('drc_truck:notifyTeamMembers')
AddEventHandler('drc_truck:notifyTeamMembers', function(teamPlayerIds, netId, trolleyNetIds, trollyModel)
    local entity = NetworkGetEntityFromNetworkId(netId)
     if DoesEntityExist(entity) then
        local owner = NetworkGetEntityOwner(entity)

        for _, playerId in ipairs(teamPlayerIds) do
            TriggerClientEvent('drc_truck:addBlipToTruck', playerId, entity, netId, teamPlayerIds)
            TriggerClientEvent('drc_truck:Target', playerId, entity, netId, teamPlayerIds, trolleyNetIds, trollyModel)
        end
    end
end)

RegisterNetEvent('drc_truck:triggerGetMoney')
AddEventHandler('drc_truck:triggerGetMoney', function(netid, teamPlayerIds, trolleyNetIds, trollyModel)
    local source = source
        TriggerClientEvent('drc_truck:getMoney', source, netid, teamPlayerIds, trolleyNetIds, trollyModel)
        for _, playerId in ipairs(teamPlayerIds) do
        TriggerClientEvent('drc_truck:removeTarget_MoneyTroley', playerId)
    end
end)

RegisterNetEvent('drc_truck:GrabMoneyFromTrolly:Server')
AddEventHandler('drc_truck:GrabMoneyFromTrolly:Server', function(trollyCoords, i, teamPlayerIds, trollyModel)
    for _, playerId in ipairs(teamPlayerIds) do
        TriggerClientEvent('drc_truck:GrabMoneyFromTrolly:Target', playerId, trollyCoords, i, teamPlayerIds, false, trollyModel)
    end

    local players = getPlayerList()
    for _, playerId in ipairs(players) do
        if IsPlayerPolice(playerId) then
            TriggerClientEvent('drc_truck:GrabMoneyFromTrolly:Target', playerId, trollyCoords, i, teamPlayerIds, true, trollyModel)
        end
    end
end)

function IsPlayerPolice(playerId)
    local xPlayer = GetPlayerFromId(playerId)
    if xPlayer then
        local jobName
        if Config.Framework == 'esx' then
            jobName = xPlayer.job.name
        elseif Config.Framework == 'qbcore' then
            jobName = xPlayer.PlayerData.job.name
        end

        for _, policeJob in pairs(Config.PoliceJobs) do
            if jobName == policeJob then
                return true
            end
        end
    end
    return false
end

function getPlayerList()
    if Config.Framework == 'esx' then
        return ESX.GetPlayers()
    elseif Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayers()
    end
    -- and so on for each framework
end


RegisterNetEvent('drc_truck:removeEntityServer:PoliceObject')
AddEventHandler('drc_truck:removeEntityServer:PoliceObject', function(targetName, closestProp)
    local entity = NetworkGetEntityFromNetworkId(closestProp)
    if DoesEntityExist(entity) then
        local owner = NetworkGetEntityOwner(entity)
        if owner <= 0 then
            DeleteEntity(entity)
            SetEntityAlpha(entity, 0, false)
            SetEntityCollision(entity, false, true)
        else
            TriggerClientEvent("drc_truck:PickUpProp", owner, closestProp)
        end
    end


    TriggerClientEvent('drc_truck:removeTrolleyProp', -1, targetName, closestProp)
end)


RegisterNetEvent('drc_truck:removeEntityServer')
AddEventHandler('drc_truck:removeEntityServer', function(trolleyNetIds, teamPlayerIds)
    for _, playerId in ipairs(teamPlayerIds) do
        TriggerClientEvent('drc_truck:removeEntity', playerId, trolleyNetIds)
    end
end)

RegisterNetEvent('drc_truck:removeTargetForTeam_Money')
AddEventHandler('drc_truck:removeTargetForTeam_Money', function(targetName, teamPlayerIds)
    for _, playerId in ipairs(teamPlayerIds) do
        TriggerClientEvent('drc_truck:removeTarget_MoneyTroley', playerId, targetName)
    end
end)

RegisterNetEvent('drc_truck:removeTargetForTeam')
AddEventHandler('drc_truck:removeTargetForTeam', function(teamPlayerIds)
    for _, playerId in ipairs(teamPlayerIds) do
        TriggerClientEvent('drc_truck:removeTarget', playerId)
    end
end)

RegisterNetEvent('drc_truck:truckExplosionForTeam')
AddEventHandler('drc_truck:truckExplosionForTeam', function(truckNetId, boneIndex, teamPlayerIds, bomb, trolleyNetIds, trollyModel)
    for _, playerId in ipairs(teamPlayerIds) do
        TriggerClientEvent('drc_truck:explosion', playerId, truckNetId, boneIndex, teamPlayerIds, bomb, trolleyNetIds, trollyModel)
    end
end)

