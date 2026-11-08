
local appearance = nil


local function AutoDetectFramework()
    if GetResourceState("es_extended") == "started" then
        return "esx"
    elseif GetResourceState("qb-core") == "started" then
        return "qbcore"
    else
        return "standalone"
    end
end

local function AutoDetectTarget()
    if GetResourceState("qtarget") == "started" then
        return "qtarget"
    elseif GetResourceState("qb-target") == "started" then
        return "qb-target"
    elseif GetResourceState("ox_target") == "started" then
        return "ox_target"
    end
end

local function AutoDetectClothing()
    if GetResourceState("esx_skin") == "started" and GetResourceState("ox_appearance") ~= "started" and GetResourceState("fivem-appearance") ~= "started" then
        return "esx_skin"
    elseif GetResourceState("qb-clothing") == "started" then
        return "qb-clothing"
    elseif GetResourceState("ox_appearance") == "started" then
        return "ox_appearance"
    elseif GetResourceState("fivem-appearance") == "started" then
        return "fivem-appearance"
    end
end

if Config.Framework == "auto-detect" then
    Config.Framework = AutoDetectFramework()
end

if Config.Target == "auto-detect" then
    Config.Target = AutoDetectTarget()
end


if Config.Clothing == "auto-detect" then
    Config.Clothing = AutoDetectClothing()
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

    AddEventHandler("QBCore:Client:OnJobUpdate", function()
        
    end)
elseif Config.Framework == "standalone" then
    -- ADD YOU FRAMEWORK
end

Citizen.CreateThread(function()
    while true do
        local playerJob = GetPlayerJob()

        while not playerJob do
            playerJob = GetPlayerJob()
            Citizen.Wait(500)
        end
        Citizen.Wait(1000)

        -- Handling Lester House blip
        if blipLester then
            RemoveBlip(blipLester)
        end
        if Config.Blip.Enabled then
        if not Config.RequireJob or (playerJob == Config.Job) then
            local blipPos = vector3(Config.Blip.Pos[1], Config.Blip.Pos[2], Config.Blip.Pos[3])
            blipLester = AddBlipForCoord(blipPos.x, blipPos.y, blipPos.z)

            SetBlipSprite(blipLester, Config.Blip.Sprite)
            SetBlipDisplay(blipLester, Config.Blip.Display)
            SetBlipScale(blipLester, Config.Blip.Scale)
            SetBlipColour(blipLester, Config.Blip.Colour)
            SetBlipAsShortRange(blipLester, Config.Blip.ShortRange)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Blip.Name)
            EndTextCommandSetBlipName(blipLester)
        end
    end

        if blipBuyer then
            RemoveBlip(blipBuyer)
        end

        if Config.SellShop.enabled and Config.SellShop.Blip.Show ~= false then -- Highcrest: blip off
            local buyerPos = vector3(Config.SellShop.Ped.coords.x, Config.SellShop.Ped.coords.y, Config.SellShop.Ped.coords.z)
            blipBuyer = AddBlipForCoord(buyerPos.x, buyerPos.y, buyerPos.z)

            SetBlipSprite(blipBuyer, Config.SellShop.Blip.Sprite)
            SetBlipScale(blipBuyer, Config.SellShop.Blip.Scale)
            SetBlipColour(blipBuyer, Config.SellShop.Blip.Colour)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.SellShop.Blip.Name)
            EndTextCommandSetBlipName(blipBuyer)
        end

        if Config.Shop.Blip.Show ~= false and not Config.Shop.Blip.RequireToAsk then -- Highcrest: blip off
        if blipExplosivesDealer then
            RemoveBlip(blipExplosivesDealer)
        end

        if Config.Shop.enabled then
            local dealerPos = vector3(Config.Shop.Ped.coords.x, Config.Shop.Ped.coords.y, Config.Shop.Ped.coords.z)
            blipExplosivesDealer = AddBlipForCoord(dealerPos.x, dealerPos.y, dealerPos.z)

            SetBlipSprite(blipExplosivesDealer, Config.Shop.Blip.Sprite)
            SetBlipScale(blipExplosivesDealer, Config.Shop.Blip.Scale)
            SetBlipColour(blipExplosivesDealer, Config.Shop.Blip.Colour)
            SetBlipAsShortRange(blipExplosivesDealer, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Shop.Blip.Name)
            EndTextCommandSetBlipName(blipExplosivesDealer)
        end
    end
        
        Citizen.Wait(5000)
    end
end)



function showNotification(message, type)
    if type == 'error' then
        lib.notify({
            title = 'Notification',
            description = message,
            type = 'error'
        })
    elseif type == 'success' then
        lib.notify({
            title = 'Notification',
            description = message,
            type = 'success'
        })
    end
end

ProgressBar = function(duration, label)
    if Config.Progress == "ox_lib" then
        lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false
        })
    elseif Config.Progress == "qbcore" then
        QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Progressbar(label, label, duration - 500, false, true, {
        }, {}, {}, {}, function()
        end)
        Wait(duration)
    elseif Config.Progress == "progressBars" then
        exports['progressBars']:startUI(duration, label)
        Wait(duration)
    end
end


function StartMiniGame(minigame, time, callback)
    local playerPed = PlayerPedId()
    if minigame == "ultra-voltlab" then
        TriggerEvent(minigame, time, function(result, reason)
            callback(result == 1)
            if result == 1 then
            ClearPedTasksImmediately(playerPed)
        end
        end)
    elseif minigame == "calibrate" then
        local success = exports['calibrate-distributor']:startDistributor(true)
        callback(success)
        if success then
            ClearPedTasksImmediately(playerPed)
        end
    else
        -- handle other minigamesa
    end
end

function GetPlayerJob()
    if Config.Framework == 'esx' then
        if ESX and ESX.GetPlayerData and ESX.GetPlayerData().job then
            return ESX.GetPlayerData().job.name
        end
    elseif Config.Framework == 'qbcore' then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job then
            return playerData.job.name
        end
    end
    return nil
end

function AddCircleZone(name, coords, radius, options, eventOptions)
    if Config.FrameworkTarget == 'qtarget' then
        exports.qtarget:AddCircleZone(name, vec3(coords[1], coords[2], coords[3]), radius, options, eventOptions)
    elseif Config.FrameworkTarget == 'ox_target' then
        exports.qtarget:AddCircleZone(name, vec3(coords[1], coords[2], coords[3]), radius, options, eventOptions)
    elseif Config.FrameworkTarget == 'qb-target' then
        exports['qb-target']:AddCircleZone(name, vec3(coords[1], coords[2], coords[3]), radius, options, eventOptions)
    end
end


function AddTargetEntity(name, model, options, eventOptions)
    if Config.FrameworkTarget == 'qtarget' then
        exports.qtarget:AddTargetEntity(name, model, options, eventOptions)
    elseif Config.FrameworkTarget == 'ox_target' then
            exports.qtarget:AddTargetEntity(name, model, options, eventOptions)
    elseif Config.FrameworkTarget == 'qb-target' then
exports['qb-target']:AddTargetEntity(name, model, options, eventOptions)
    end
end

function RemoveZone(name)
    if Config.FrameworkTarget == 'qtarget' then
        exports.qtarget:RemoveZone(name)
    elseif Config.FrameworkTarget == 'ox_target' then
        exports.qtarget:RemoveZone(name)
    elseif Config.FrameworkTarget == 'qb-target' then
        exports['qb-target']:RemoveZone(name)
    end
end


TextUIShow = function(text)
    if Config.TextUI == "ox_lib" then
        lib.showTextUI(text)
    elseif Config.TextUI == "esx" then
        exports["esx_textui"]:TextUI(text)
    elseif Config.TextUI == "luke" then
        TriggerEvent('luke_textui:ShowUI', text)
    elseif Config.TextUI == "custom" then
        print("add your textui system! in cl_Utils.lua")
        -- ADD YOUR TEXTUI | TO SHOW
    end
end

IsTextUIShowed = function()
    if Config.TextUI == "ox_lib" then
        return lib.isTextUIOpen()
    elseif Config.TextUI == "esx" then
        --exports["esx_textui"]:TextUI(text)
    elseif Config.TextUI == "luke" then
        --TriggerEvent('luke_textui:ShowUI', text)
    elseif Config.TextUI == "custom" then
        print("add your textui system! in cl_Utils.lua")
        -- ADD YOUR TEXTUI | TO SHOW
    end
end

TextUIHide = function()
    if Config.TextUI == "ox_lib" then
        lib.hideTextUI()
    elseif Config.TextUI == "esx" then
        exports["esx_textui"]:HideUI()
    elseif Config.TextUI == "luke" then
        TriggerEvent('luke_textui:HideUI')
    elseif Config.TextUI == "custom" then
        print("add your textui system! in cl_Utils.lua")
        -- ADD YOUR TEXTUI | TO HIDE
    end
end

Draw3DText = function(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    
    if onScreen then
        SetTextFont(Config.FontId)
        SetTextScale(0.33, 0.30)
        SetTextDropshadow(10, 100, 100, 100, 255)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 350
        DrawRect(_x,_y+0.0135, 0.025+ factor, 0.03, 0, 0, 0, 10)
    end
end

function GetPlayerJob()
    if Config.Framework == 'esx' then
        if ESX and ESX.GetPlayerData and ESX.GetPlayerData().job then
            return ESX.GetPlayerData().job.name
        end
    elseif Config.Framework == 'qbcore' then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.job then
            return playerData.job.name
        end
    end
    return nil
end


local appearance = nil

GetSkin = function()
    if Config.Clothing == "fivem-appearance" then
        appearance = exports['fivem-appearance']:getPedAppearance(PlayerPedId())
    elseif Config.Clothing == "illenium-appearance" then
        appearance = exports['illenium-appearance']:getPedAppearance(PlayerPedId())
    elseif Config.Clothing == "esx_skin" then
        TriggerEvent('skinchanger:getSkin', function(skin)
            appearance = skin
        end)
    elseif Config.Clothing == "qb-clothing" then
        -- no need
    elseif Config.Clothing == "custom" then
        print("add your clothing system! in cl_Utils.lua")
        -- ADD YOUR CLOTHING SCRIPT
    end
end

ApplySkin = function()
    if Config.Clothing == "fivem-appearance" then
        exports['fivem-appearance']:setPedAppearance(PlayerPedId(), appearance)
    elseif Config.Clothing == "illenium-appearance" then
        exports['illenium-appearance']:setPedAppearance(PlayerPedId(), appearance)
    elseif Config.Clothing == "esx_skin" then
        TriggerEvent('skinchanger:loadSkin', appearance)
    elseif Config.Clothing == "qb-clothing" then
        TriggerServerEvent("drc_drugs:loadPlayerSkin")
        --TriggerServerEvent("qb-clothes:loadPlayerSkin")
    elseif Config.Clothing == "custom" then
        print("add your clothing system! in cl_Utils.lua")
        -- ADD YOUR CLOTHING SCRIPT
    end
end

Dispatch = function(coords, type)
    if Config.Dispatch.enabled then
        if Config.Dispatch.script == "cd_dispatch" then
            if type == "truck-robbery" then
                local data = exports['cd_dispatch']:GetPlayerInfo()
                TriggerServerEvent('cd_dispatch:AddNotification', {
                    job_table = Config.PoliceJobs,
                    coords = coords,
                    title = "10-68 - Truck robbery",
                    message = "Truck transporting money is being ambushed",
                    flash = 0,
                    unique_id = tostring(math.random(0000000, 9999999)),
                    blip = {
                        sprite = 477,
                        scale = 1.2,
                        colour = 3,
                        flashes = false,
                        text = 'Truck robbery',
                        time = (5 * 60 * 1000),
                        sound = 1,
                    }
                })
            end
        elseif Config.Dispatch.script == "linden_outlawalert" then
            if type == "truck-robbery" then
                local data = { displayCode = "10-68", description = "Truck robbery", isImportant = 1,
                    recipientList = Config.PoliceJobs,
                    length = '10000', infoM = 'fa-info-circle', info = "Truck transporting money is being ambushed" }
                local dispatchData = { dispatchData = data, caller = 'citizen', coords = coords }
                TriggerServerEvent('wf-alerts:svNotify', dispatchData)
            end
        elseif Config.Dispatch.script == "ps-dispatch" then
            if type == "truck-robbery" then
                exports['ps-dispatch']:SuspiciousActivity()
            end
        elseif Config.Dispatch.script == "custom" then
            TriggerServerEvent("police:server:policeAlert", "Armored truck robbery in progress")
        end
    end
end
