Core = nil
nuiLoaded = false
menuOpen = false
stopIndex = 1
garbageTruckVehicle = nil
secureKey = nil
coopData = {}

garbageJobData = {
    startMission = false,
    deliveryvehicle = false,
    incomePrice = 0,
    gatheredCount = 0,
    stopname = nil,
    multiplayerJobs = false,
    isDriver = false
}

activeBlips = {}

function RequestAnimation(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

function StartBagAnimationThread()
    CreateThread(function()
        local ped = PlayerPedId()
        while true do
            if IsEntityPlayingAnim(ped, "missfbi4prepp1", "_bag_throw_garbage_man", 3) then
                break
            end
            if not IsEntityPlayingAnim(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 3) then
                ClearPedTasksImmediately(ped)
                RequestAnimation("missfbi4prepp1")
                TaskPlayAnim(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 6.0, -6.0, -1, 49, 0, false, false, false)
            end
            Wait(1000)
        end
    end)
end

function NuiMessage(action, payload)
    while not nuiLoaded do Wait(0) end
    SendNUIMessage({
        action = action,
        payload = payload
    })
end

RegisterNUICallback("loaded", function(data, cb)
    nuiLoaded = true
    cb("ok")
end)

CreateThread(function()
    while Core == nil do Wait(0) end
    while not nuiLoaded do
        if NetworkIsSessionStarted() then
            SendNUIMessage({ action = "CHECK_NUI" })
        end
        Wait(2000)
    end
end)

RegisterNUICallback("closeMenu", function(data, cb)
    SetNuiFocus(false, false)
    menuOpen = false
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, true)
    ClearFocus()
    cb("ok")
end)

CreateThread(function()
    while Core == nil or not nuiLoaded do Wait(0) end
    
    Config.OpenTrigger()
    
    NuiMessage("requiredXp", Config.RequiredXP)
    NuiMessage("configCurrencyUnit", Config.CurrencyUnit)
    NuiMessage("configlocales", Config.Locales)
    NuiMessage("configDailyMission", Config.GarbagejobSettings.dailyMission)
    NuiMessage("configBadge", Config.GarbagejobSettings.badge)
    
    for _, route in pairs(Config.GarbagejobSettings.garbageRouteSettings) do
        local stops = Config.GarbagejobSettings.garbageStop[route.name]
        route.Profit = 0
        route.stopCount = 0
        if stops then
            for _, stop in ipairs(stops) do
                route.Profit = route.Profit + (stop.garbagePrice * stop.garbageCount)
                route.stopCount = route.stopCount + 1
            end
        end
    end
    
    NuiMessage("configRoutes", Config.GarbagejobSettings.garbageRouteSettings)
end)

function openTrashMenu()
    if not menuOpen then
        CreateCamera()
        SetNuiFocus(true, true)
        menuOpen = true
        local playerData = TriggerCallback("codem-garbage:getPlayerData")
        NuiMessage("OPEN_MENU", {
            playerData = playerData,
            coopData = coopData
        })
    end
end

RegisterNUICallback("createLobby", function(data)
    TriggerServerEvent("codem-garbage:onlineJobsInsertData", data)
end)

RegisterNetEvent("codem-garbage:setDriverData", function()
    garbageJobData.isDriver = true
end)

RegisterNetEvent("codem-garbage:notificaton", function(data)
    NuiMessage("notification", data)
end)

RegisterNUICallback("kickPlayer", function(data)
    TriggerServerEvent("codem-garbage:kickPlayer", data)
end)

RegisterCommand(Config.ResetJobPlayer, function()
    if garbageJobData.multiplayerJobs then
        TriggerServerEvent("codem-garbage:resetjob", garbageJobData)
    else
        if garbageTruckVehicle then
            Config.RemoveVehiclekey(GetVehicleNumberPlateText(garbageTruckVehicle), GetHashKey(Config.GarbagejobSettings.trashvehicle), garbageTruckVehicle)
            DeleteEntity(garbageTruckVehicle)
            
            local stops = Config.GarbagejobSettings.garbageStop[garbageJobData.stopname]
            if stops then
                for _, stop in ipairs(stops) do
                    if stop.blip then
                        RemoveBlip(stop.blip)
                    end
                end
            end
            
            Config.Notification(Config.NotificationText.resetjob.text, Config.NotificationText.resetjob.type, false)
            resetJob()
        end
    end
end)

RegisterNetEvent("codem-garbage:client:ResetJob", function(data)
    if data then
        if garbageTruckVehicle then
            Config.RemoveVehiclekey(GetVehicleNumberPlateText(garbageTruckVehicle), GetHashKey(Config.GarbagejobSettings.trashvehicle), garbageTruckVehicle)
            DeleteEntity(garbageTruckVehicle)
        end
        
        local stops = Config.GarbagejobSettings.garbageStop[data.stopname]
        if stops then
            for _, stop in ipairs(stops) do
                if stop.blip then
                    RemoveBlip(stop.blip)
                end
            end
        end
        
        Config.Notification(Config.NotificationText.resetjob.text, Config.NotificationText.resetjob.type, false)
        NuiMessage("DELETE_TEAMDATA")
        resetJob()
        
        if #activeBlips > 0 then
            for _, blip in pairs(activeBlips) do
                RemoveBlip(blip)
            end
        end
    end
end)

RegisterNetEvent("codem-garbage:startMultiplayerJob", function(stops, vehicleNetId, routeName)
    if not vehicleNetId then
        Config.Notification(Config.NotificationText.vehicleNotFound.text, Config.NotificationText.vehicleNotFound.type, false)
        return
    end
    
    garbageTruckVehicle = NetToVeh(vehicleNetId)
    Config.SetVehicleFuel(garbageTruckVehicle, 100.0)
    Config.GiveVehicleKey(GetVehicleNumberPlateText(garbageTruckVehicle), GetHashKey(Config.GarbagejobSettings.trashvehicle), garbageTruckVehicle)
    
    garbageJobData.startMission = true
    garbageJobData.multiplayerJobs = true
    garbageJobData.stopname = routeName
    
    for i, stop in ipairs(stops) do
        if stop.blip then RemoveBlip(stop.blip) end
        stop.blip = AddBlipForCoord(stop.coords.x, stop.coords.y, stop.coords.z)
        SetBlipAttributes(stop.blip, i)
        table.insert(activeBlips, stop.blip)
    end
    
    if garbageJobData.isDriver then
        for _, stop in pairs(stops) do
            if stop then
                garbageJobData.gatheredCount = garbageJobData.gatheredCount + stop.garbageCount
                garbageJobData.incomePrice = garbageJobData.incomePrice + (stop.garbagePrice * stop.garbageCount)
            end
        end
    end
    
    SetNewWaypoint(stops[stopIndex].coords.x, stops[stopIndex].coords.y)
    NuiMessage("closeMenu")
    
    local ped = PlayerPedId()
    while stopIndex <= #stops and garbageJobData.startMission and not garbageJobData.isDriver do
        local stop = stops[stopIndex]
        local bagCount = stop.garbageCount
        local gathered = 0
        local sleep = 1000
        
        while bagCount > gathered do
            local pCoords = GetEntityCoords(ped)
            local dist = #(pCoords - stop.coords)
            
            if dist < 20 then
                sleep = 0
                DrawMarker(2, stop.coords.x, stop.coords.y, stop.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, false, false, false, true, false, false, false)
                DrawText3D(stop.coords.x, stop.coords.y, stop.coords.z + 0.5, Config.Locales.press_e)
                
                if IsControlJustReleased(1, 38) and dist < 3 then
                    if CanPrees() then
                        collectTrash(ped)
                        gathered = gathered + 1
                        updateScreen(stops, gathered)
                        garbageJobData.incomePrice = garbageJobData.incomePrice + stop.garbagePrice
                        garbageJobData.gatheredCount = garbageJobData.gatheredCount + 1
                        Wait(500)
                    end
                end
            else
                sleep = 1000
            end
            Wait(sleep)
        end
        
        stopIndex = stopIndex + 1
        local nextStop = stops[stopIndex]
        
        if stopIndex <= #stops then
            if stop.blip then
                TriggerServerEvent("codem-garbage:deleteBlip", stopIndex)
                stop.blip = nil
            end
            Config.Notification(Config.NotificationText.nextposition.text, Config.NotificationText.nextposition.type, false)
            SetNewWaypoint(nextStop.coords.x, nextStop.coords.y)
        end
        
        if stopIndex > #stops then
            garbageJobData.deliveryvehicle = true
            Config.Notification(Config.NotificationText.deliveryvehicle.text, Config.NotificationText.deliveryvehicle.type, false)
            TriggerServerEvent("codem-garbage:deleteBlip", stopIndex)
            TriggerServerEvent("codem-garbage:deliveryVehicleForDriver")
            deliveryTheVehicle()
        end
    end
end)

RegisterNetEvent("codem-garbage:deleteBlip", function(index)
    local targetIndex = index - 1
    if #activeBlips > 0 then
        for k, blip in pairs(activeBlips) do
            if k == targetIndex then
                if blip then 
                    RemoveBlip(blip)
                else
                    for _, b in pairs(activeBlips) do RemoveBlip(b) end
                end
            end
        end
    end
end)

RegisterNUICallback("startJob", function(data)
    if garbageJobData.startMission then
        Config.Notification(Config.NotificationText.missioninprogress.text, Config.NotificationText.missioninprogress.type, false)
        return
    end
    
    if spawnGarbageVehicle() then
        garbageJobData.multiplayerJobs = false
        garbageJobData.stopname = data.route
        local stops = Config.GarbagejobSettings.garbageStop[data.route]
        local ped = PlayerPedId()
        
        for i, stop in ipairs(stops) do
            if stop.blip then RemoveBlip(stop.blip) end
            stop.blip = AddBlipForCoord(stop.coords.x, stop.coords.y, stop.coords.z)
            SetBlipAttributes(stop.blip, i)
            table.insert(activeBlips, stop.blip)
        end
        
        SetNewWaypoint(stops[stopIndex].coords.x, stops[stopIndex].coords.y)
        
        if stops then
            garbageJobData.startMission = true
            while stopIndex <= #stops and garbageJobData.startMission do
                local stop = stops[stopIndex]
                local bagCount = stop.garbageCount
                local sleep = 1000
                local gathered = 0
                
                while bagCount > gathered do
                    local pCoords = GetEntityCoords(ped)
                    local dist = #(pCoords - stop.coords)
                    
                    if dist < 7.5 then
                        sleep = 0
                        DrawMarker(2, stop.coords.x, stop.coords.y, stop.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, false, false, false, true, false, false, false)
                        DrawText3D(stop.coords.x, stop.coords.y, stop.coords.z + 0.5, Config.Locales.press_e)
                        
                        if IsControlJustReleased(1, 38) and dist < 3 then
                            if CanPrees() then
                                collectTrash(ped)
                                gathered = gathered + 1
                                updateScreen(stops, gathered)
                                garbageJobData.incomePrice = garbageJobData.incomePrice + stop.garbagePrice
                                garbageJobData.gatheredCount = garbageJobData.gatheredCount + 1
                                Wait(500)
                            end
                        end
                    else
                        sleep = 1000
                    end
                    Wait(sleep)
                end
                
                stopIndex = stopIndex + 1
                local nextStop = stops[stopIndex]
                
                if stopIndex <= #stops then
                    if stop.blip then
                        RemoveBlip(stop.blip)
                        stop.blip = nil
                    end
                    SetNewWaypoint(nextStop.coords.x, nextStop.coords.y)
                    Config.Notification(Config.NotificationText.nextposition.text, Config.NotificationText.nextposition.type, false)
                end
                
                if stopIndex > #stops then
                    garbageJobData.deliveryvehicle = true
                    Config.Notification(Config.NotificationText.deliveryvehicle.text, Config.NotificationText.deliveryvehicle.type, false)
                    RemoveBlip(stop.blip)
                    deliveryTheVehicle()
                end
            end
        else
            Config.Notification(Config.NotificationText.routenotfound.text, Config.NotificationText.routenotfound.type, false)
        end
    end
end)

function CanPrees()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return false
    end
    return true
end

RegisterNetEvent("codem-garbage:finishIsDriver", function()
    garbageJobData.deliveryvehicle = true
    deliveryTheVehicle()
end)

function deliveryTheVehicle()
    CreateThread(function()
        SetNewWaypoint(Config.GarbagejobSettings.jobDeliverTheVehicleCoords.x, Config.GarbagejobSettings.jobDeliverTheVehicleCoords.y)
        while garbageJobData.deliveryvehicle do
            local sleep = 2000
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local dist = #(pCoords - Config.GarbagejobSettings.jobDeliverTheVehicleCoords)
            
            if dist < 15.0 then
                sleep = 0
                if Config.DrawMarkerSettings.deleteVehicleDrawMarker then
                    DrawMarker(22, Config.GarbagejobSettings.jobDeliverTheVehicleCoords.x, Config.GarbagejobSettings.jobDeliverTheVehicleCoords.y, Config.GarbagejobSettings.jobDeliverTheVehicleCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.5, 1.5, 255, 150, 0, 255, 0, 1, 0, 0, 0, 0, 0)
                end
            end
            
            if dist < 7.5 then
                if IsControlJustPressed(0, 38) then
                    if garbageJobData.multiplayerJobs then
                        if garbageJobData.isDriver then
                            TriggerServerEvent("codem-garbage:finishMultiplayerJobs")
                        end
                    else
                        if not garbageJobData.multiplayerJobs then
                            if garbageTruckVehicle then
                                Config.RemoveVehiclekey(GetVehicleNumberPlateText(garbageTruckVehicle), GetHashKey(Config.GarbagejobSettings.trashvehicle), garbageTruckVehicle)
                                DeleteEntity(garbageTruckVehicle)
                            end
                            
                            secureKey = TriggerCallback("codem-garbage:getKey") or false
                            
                            TriggerServerEvent("codem-garbagejob:finishJob", secureKey, garbageJobData.incomePrice, garbageJobData.gatheredCount, garbageJobData.stopname)
                            
                            local stops = Config.GarbagejobSettings.garbageStop[garbageJobData.stopname]
                            for _, stop in ipairs(stops) do
                                if stop.blip then RemoveBlip(stop.blip) end
                            end
                            resetJob()
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end)
end

function resetJob()
    garbageJobData.startMission = false
    garbageJobData.incomePrice = 0
    garbageJobData.gatheredCount = 0
    garbageJobData.stopname = nil
    garbageJobData.multiplayerJobs = false
    garbageJobData.deliveryvehicle = false
    garbageTruckVehicle = nil
    garbageJobData.isDriver = false
    stopIndex = 1
end

RegisterNetEvent("codem-garbage:client:finishMultiplayerJob", function()
    if garbageTruckVehicle then
        Config.RemoveVehiclekey(GetVehicleNumberPlateText(garbageTruckVehicle), GetHashKey(Config.GarbagejobSettings.trashvehicle), garbageTruckVehicle)
        DeleteEntity(garbageTruckVehicle)
    end
    
    local stops = Config.GarbagejobSettings.garbageStop[garbageJobData.stopname]
    if stops then
        for _, stop in ipairs(stops) do
            if stop and stop.blip then
                RemoveBlip(stop.blip)
            end
        end
    end
    
    secureKey = TriggerCallback("codem-garbage:getKey") or false
    
    TriggerServerEvent("codem-garbagejob:finishJob", secureKey, garbageJobData.incomePrice, garbageJobData.gatheredCount, garbageJobData.stopname, garbageJobData.multiplayerJobs)
    
    NuiMessage("DELETE_TEAMDATA")
    resetJob()
end)

function updateScreen(stops, currentBag)
    local currentStop = stops[stopIndex]
    local totalBagsInStop = currentStop.garbageCount
    local remaining = totalBagsInStop - currentBag
    
    if remaining > 0 then
        Config.Notification(string.format(Config.NotificationText.garbagecount.text, totalBagsInStop, remaining), Config.NotificationText.garbagecount.type, false)
    end
end

function collectTrash(ped)
    RequestAnimation("missfbi4prepp1")
    TaskPlayAnim(ped, "missfbi4prepp1", "_bag_walk_garbage_man", 6.0, -6.0, -1, 49, 0, false, false, false)
    
    currentBagProp = CreateObject(1138881502, 0, 0, 0, true, true, true)
    AttachEntityToEntity(currentBagProp, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)
    
    StopAnimTask(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    
    StartBagAnimationThread()
    collectedtrash(currentBagProp)
end

function collectedtrash(bagProp)
    local sleep = 1000
    local ped = PlayerPedId()
    
    while true do
        local trunkPos = GetWorldPositionOfEntityBone(garbageTruckVehicle, GetEntityBoneIndexByName(garbageTruckVehicle, "platelight"))
        local pCoords = GetEntityCoords(ped)
        local dist = #(pCoords - trunkPos)
        
        if dist < 20 then
            DrawMarker(2, trunkPos + vector3(0.0, 0.0, 0.5), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, false, false, false, true, false, false, false)
            if dist < 2 then
                if IsControlJustReleased(1, 38) then
                    disposeOfTrash(ped, bagProp)
                    return
                end
            end
            sleep = 0
        else
            sleep = 1000
        end
        Wait(sleep)
    end
end

function disposeOfTrash(ped, bagProp)
    RequestAnimation("missfbi4prepp1")
    TaskPlayAnim(ped, "missfbi4prepp1", "_bag_throw_garbage_man", 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
    
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, GetEntityHeading(garbageTruckVehicle))
    
    SetTimeout(1250, function()
        DetachEntity(bagProp, 1, false)
        DeleteObject(bagProp)
        TaskPlayAnim(ped, "missfbi4prepp1", "exit", 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
        FreezeEntityPosition(ped, false)
    end)
end

RegisterNUICallback("joinLobby", function(data, cb)
    TriggerServerEvent("codem-gabage:joinLobby", data)
    cb("ok")
end)

RegisterNUICallback("updateLobbys", function(data, cb)
    TriggerServerEvent("codem-garbage:updateLobbys", data)
    cb("ok")
end)

RegisterNUICallback("updateArea", function(data, cb)
    TriggerServerEvent("codem-gabage:updateArea", data)
    cb("ok")
end)

RegisterNUICallback("joinLobbyPassword", function(data, cb)
    TriggerServerEvent("codem-gabage:joinLobbyPassword", data)
    cb("ok")
end)

RegisterNUICallback("leaveLobby", function(data, cb)
    TriggerServerEvent("codem-garbage:leaveLobby", data)
    cb("ok")
end)

RegisterNetEvent("codem-garbage:deleteRoom", function(hostIdentifier)
    if coopData[hostIdentifier] then
        coopData[hostIdentifier] = nil
    end
    NuiMessage("DELETE_TEAMDATA")
end)

RegisterNetEvent("codem-garbage:updateLobbys", function(data)
    coopData = data
    NuiMessage("UPDATA_LOBBYS", coopData)
end)

RegisterNetEvent("codem-garbage:client:UpdateArea", function(data)
    NuiMessage("UPDATE_AREA", data)
end)

RegisterNetEvent("codem-garbage:deleteroomeveryone", function(hostIdentifier)
    if coopData[hostIdentifier] then
        coopData[hostIdentifier] = nil
    end
    NuiMessage("INSERT_LOBBY", coopData)
end)

RegisterNUICallback("startJobMultiplayer", function(data)
    if garbageJobData.startMission then
        Config.Notification(Config.NotificationText.missioninprogress.text, Config.NotificationText.missioninprogress.type, false)
        return
    end
    TriggerServerEvent("codem-garbage:startJobMultiplayer", data)
end)

RegisterNetEvent("codem-garbage:deleteMyTeam", function()
    NuiMessage("DELETE_TEAMDATA")
    resetJob()
end)

RegisterNetEvent("codem-garbage:client:loadnuidata", function(playerData, lobbyData)
    coopData = lobbyData
    NuiMessage("NUI_LOAD_DATA", playerData)
end)

RegisterNUICallback("takeBadge", function(data)
    TriggerServerEvent("codem-garbage:takeBadge", data)
end)

RegisterNetEvent("codem-garbage:insertOnlineData", function(roomDataList, src, hostIdentifier, name)
    if roomDataList then
        if not coopData[hostIdentifier] then
            coopData[hostIdentifier] = {
                roomData = {
                    roomName = roomDataList[1].name,
                    password = roomDataList[1].password,
                    areaName = roomDataList[1].areaName,
                    hostIdentifier = hostIdentifier
                },
                players = {
                    name = name,
                    avatar = roomDataList[1].avatar,
                    src = src,
                    identifier = hostIdentifier,
                    host = true,
                    level = roomDataList[1].level
                }
            }
        end
        NuiMessage("INSERT_LOBBY", coopData)
    end
end)

RegisterNetEvent("codem-garbage:updateClientRoomPlayersData", function(hostIdentifier, players)
    if coopData[hostIdentifier] then
        coopData[hostIdentifier].players = players
    end
    NuiMessage("UPDATE_LOBBY", coopData)
end)

RegisterNetEvent("codem-garbage:top50", function(data)
    if data then
        NuiMessage("top50", data)
    end
end)

function TriggerCallback(name, args)
    local data = false
    local result = "UNKOWN"
    local timeout = 0
    
    while Core == nil do Wait(0) end
    
    if Config.Framework == "esx" then
        Core.TriggerServerCallback(name, function(res)
            result = "SUCCESS"
            data = res
        end, args)
    else
        Core.Functions.TriggerCallback(name, function(res)
            result = "SUCCESS"
            data = res
        end, args)
    end
    
    CreateThread(function()
        while result == "UNKOWN" do
            Wait(1000)
            timeout = timeout + 1
            if timeout == 4 then
                result = "FAILED"
                data = false
                break
            end
        end
    end)
    
    while result == "UNKOWN" do Wait(0) end
    return data
end
