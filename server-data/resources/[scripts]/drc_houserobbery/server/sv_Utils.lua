lib.locale()
local ver = '1.0.1'
local onTimer = {}

CreateThread(function()
    if GetResourceState(GetCurrentResourceName()) == 'started' then
        print('DRC_HOUSEROBBERY STARTED ON VERSION: ' .. ver)
    end
end)

local MoneyTable = {"cash", "money"}

if Config.Framework == "ESX" then
    if Config.NewESX then
        ESX = exports["es_extended"]:getSharedObject()
        RegisterUsable = ESX.RegisterUsableItem
    else
        ESX = nil
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        RegisterUsable = ESX.RegisterUsableItem
    end
elseif Config.Framework == "qbcore" then
    QBCore = nil
    QBCore = exports['qb-core']:GetCoreObject()
    RegisterUsable = QBCore.Functions.CreateUseableItem
elseif Config.Framework == "standalone" then
    -- ADD YOU FRAMEWORK
end

function BanPlayer(source, message)
    if Config.AnticheatBan then
        --Example of usage for anticheat
        exports['youranticheat']:BanPlayer(source, message)
    end
end

RegisterUsable("loot_bag", function(source)
    local src = source
    RemoveItem("loot_bag", 1, src)
    TriggerClientEvent('drc_houserobbery:lootbag', src)
end)


RegisterUsable('house_locator', function(source)
    local src = source
    if onTimer[src] and onTimer[src] > GetGameTimer() then
        TriggerClientEvent('drc_houserobbery:notify', src, 'error', locale('houserobbery'), locale('ItemCooldown', math.floor((onTimer[src] - GetGameTimer()) / 1000 + 0.5)))
        return
    end
    TriggerClientEvent('drc_houserobbery:gethelp', src)
    
    onTimer[src] = GetGameTimer() + (20 * 1000)
end)

RegisterUsable("powder", function(source)
    local src = source
    RemoveItem("powder", 1, src)
    TriggerClientEvent("drc_houserobbery:powder", src)
end)


local webhook = "" -- Highcrest: the script shipped with a stranger's webhook here.
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
                lib.logger(source, "HouseRobbery", message)
            elseif Config.Logs.type == "webhook" then
                local embed = {
                    {
                        ["color"] = 2600155,
                        ["title"] = "Player: **" .. GetPlayerName(source) .. " | " .. license .. " **",
                        ["description"] = message,
                        ["footer"] = {
                            ["text"] = "Logs by DRC SCRIPTS for DRC HOUSE ROBBERY!",
                        },
                    }
                }
                PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
                    json.encode({ username = "DRC HOUSE ROBBERY", embeds = embed,
                        avatar_url = "https://i.imgur.com/RclET8O.png" })
                    , { ['Content-Type'] = 'application/json' })
            end
        end
    end
end

function GetJob(source)
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.job.name
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        return xPlayer.PlayerData.job.name
    elseif Config.Framework == "standalone" then
        -- ADD YOU FRAMEWORK
    end
end

function GetItem(name, count, source)
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getInventoryItem(name).count >= count then
            return true
        else
            return false
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer.Functions.GetItemByName(name) ~= nil then
            if xPlayer.Functions.GetItemByName(name).amount >= count then
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

function AddMoney(count, source)
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if Config.DirtyMoney then
            xPlayer.addAccountMoney("black_money", count)
        else
            xPlayer.addMoney(count)
        end
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if Config.DirtyMoney then
            local info = {worth = count}
            xPlayer.Functions.AddItem('markedbills', 1, false, info)
        else
            xPlayer.Functions.AddMoney('cash', count)
        end
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end

function RemoveMoney(count, source)
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeMoney(count)
    elseif Config.Framework == "qbcore" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.RemoveMoney('cash', count)
    elseif Config.Framework == "standalone" then
        -- ADD YOUR FRAMEWORK
    end
end

function GetItemCount(name, source)
    if Config.Framework == "ESX" then
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

function GetMoney(count, source)
    if Config.Framework == "ESX" then
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

function AddItem(name, count, source)
    local src = source
    local ismoney = false
    for _, v in pairs(MoneyTable) do
        if v == name then
            ismoney = true
            AddMoney(count, src)
        end
    end
    if not ismoney then
        if Config.Framework == "ESX" then
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer then
                if Config.WeaponsAsItems then
                    xPlayer.addInventoryItem(name, count)
                else
                    if string.find(name, 'WEAPON_') then
                        xPlayer.addWeapon(name, count)
                    else
                        xPlayer.addInventoryItem(name, count)
                    end
                end
            end
        elseif Config.Framework == "qbcore" then
            local xPlayer = QBCore.Functions.GetPlayer(src)
            if xPlayer then
                xPlayer.Functions.AddItem(name, count, nil, nil)
                TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[name], "add", count)
            end

        elseif Config.Framework == "standalone" then
            -- ADD YOUR FRAMEWORK
        end
    end
end

function RemoveItem(name, count, source)
    if Config.Framework == "ESX" then
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

function CheckJob()
    local PoliceCount = 0
    if Config.Framework == "ESX" then
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
                if xPlayer and xPlayer.PlayerData.job.name == job and xPlayer.PlayerData.job.onduty then
                    PoliceCount = PoliceCount + 1
                end
            end
        end
        return PoliceCount
    elseif Config.Framework == "standalone" then
        -- ADD YOU FRAMEWORK
    end
end

function RegisterUsable()
    return RegisterUsable
end

function GetIdent(source)
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getIdentifier()
    elseif Config.Framework == "qbcore" then
        return QBCore.Functions.GetIdentifier(source, 'license')

    end
end

lib.callback.register('drc_houserobbery:getident', function(source)
    return GetIdent(source)
end)