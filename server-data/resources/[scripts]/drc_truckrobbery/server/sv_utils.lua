Utils = {}

local ver = '1.0.0'

CreateThread(function()
    if GetResourceState(GetCurrentResourceName()) == 'started' then
        print('DRC TRUCK ROBBERY STARTED ON VERSION: ' .. ver)
    end
end)

local function AutoDetectFramework()
    if GetResourceState("es_extended") == "started" then
        return "esx"
    elseif GetResourceState("qb-core") == "started" then
        return "qbcore"
    else
        return "standalone"
    end
end

if Config.Framework == "auto-detect" then
    Config.Framework = AutoDetectFramework()
end

 if Config.Framework == "esx" then
    if Config.NewESX then
        ESX = exports["es_extended"]:getSharedObject()
    else
        ESX = nil
        CreateThread(function()
            while ESX == nil do
                TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
                Wait(100)
            end
        end)
    end
elseif Config.Framework == "qbcore" then
    QBCore = nil
    QBCore = exports["qb-core"]:GetCoreObject()

elseif Config.Framework == "standalone" then
    -- ADD YOU FRAMEWORK
end 




function GetPlayerName(sourcePlayer)
    if Config.Framework == 'esx' then
        return sourcePlayer and sourcePlayer.getName() or "Unknown"
    elseif Config.Framework == 'qbcore' then
        if sourcePlayer and sourcePlayer.PlayerData and sourcePlayer.PlayerData.charinfo then
            local charInfo = sourcePlayer.PlayerData.charinfo
            return charInfo.firstname .. " " .. charInfo.lastname
        else
            return "Unknown"
        end
    else
        -- Handle other frameworks or default case
    end
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


function CheckJob()
    local PoliceCount = 0
    if Config.Framework == "esx" then
        local xPlayers = ESX.GetPlayers()
        for i = 1, #xPlayers do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            for _, job in pairs(Config.PoliceJobs) do
                if xPlayer and xPlayer.job.name == job then
                    PoliceCount = PoliceCount + 1
                end
            end
        end
        return PoliceCount
    elseif Config.Framework == "qbcore" then
        local xPlayers = QBCore.Functions.GetPlayers()
        for i = 1, #xPlayers do
            local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
            for _, job in pairs(Config.PoliceJobs) do
                if xPlayer and xPlayer.PlayerData.job.name == job then
                    PoliceCount = PoliceCount + 1
                end
            end
        end
        return PoliceCount
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end

function GetPlayerFromId(source)
    if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            return player
        else
            print("Player not found for source: " .. source)
        end
    end
    -- and so on for each framework
end

function GetMoney(count, source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getMoney() >= count then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer.Functions.GetMoney('cash') >= count then
            return true
        else
            return false
        end
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end

function RemoveMoney(count, source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeMoney(count)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.RemoveMoney('cash', count)
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end



function AddItem(name, count, source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem(name, count)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.AddItem(name, count, nil, nil)
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[name], "add", count)

    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end

function AddMoney(count, source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if Config.Reward.DirtyMoney then
            xPlayer.addAccountMoney("black_money", count)
        else
            xPlayer.addMoney(count)
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if Config.Reward.DirtyMoney then
            local info = {worth = count}
            xPlayer.Functions.AddItem('markedbills', 1, false, info)
        else
            xPlayer.Functions.AddMoney('cash', count)
        end
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end


function GetItemCount(name, source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getInventoryItem(name).count
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer.Functions.GetItemByName(name) ~= nil then
            return xPlayer.Functions.GetItemByName(name).amount
        end
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end

function GetItem(name, count, source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local item = xPlayer.getInventoryItem(name)
            if item and item.count >= count then
                return true
            else
                return false
            end
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            local item = xPlayer.Functions.GetItemByName(name)
            if item and item.amount >= count then
                return true
            else
                return false
            end
        else
            return false
        end
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end

function RemoveItem(name, count, source)
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem(name, count)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.RemoveItem(name, count, nil, nil)
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[name], "remove", count)
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end


local webhook = "https://discord.com/api/webhooks/1054730812127449150/3YWEN7VRZCQhijD7OVP4AwF5UK5TEjMoMAIuVo0OEhh59A73cNaWNu3gQVAffDq7iBtO"
function Logs(source, message)
    if message ~= nil then
        if Config.Logs.enabled then
            local license = nil
            for k, v in pairs(GetPlayerIdentifiers(source)) do
                if string.sub(v, 1, string.len("license:")) == "license:" then
                    license = v
                end
            end
            if Config.Logs.type == "ox_lib" then
                lib.logger(source, "TruckRobbery", message)
            elseif Config.Logs.type == "webhook" then
                local embed = {
                    {
                        ["color"] = 2600155,
                        ["title"] = "Player: **" .. GetPlayerName(source) .. " | " .. license .. " **",
                        ["description"] = message,
                        ["footer"] = {
                            ["text"] = "Logs by DRC SCRIPTS for DRC TRUCK ROBBERY!",
                        },
                    }
                }
                PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
                    json.encode({ username = "DRC TRUCK ROBBERY", embeds = embed,
                        avatar_url = "https://i.imgur.com/RclET8O.png" })
                    , { ['Content-Type'] = 'application/json' })
            end
        end
    end
end