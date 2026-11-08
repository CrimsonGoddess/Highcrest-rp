local TSE = TriggerServerEvent
local MissionActive = false
local bombInPlace = false
local C4Installing = false
local MenuIsOpen = false
local MenuIsOpenForClient = false
local DidAsk = false
local DoingMinigame = false
local minigameCompleted = false
local GrabbingMooney = false
local moneyStillThere = false
local bombStatus = false
local bombIsBeingPlanted = false

local previousVehicle = nil
local vehicleBlip  = nil
local securityTruck = nil
local MinigameSuccess = nil
local doorCoords = nil
local bag = nil
local Radius = nil
local RadiusBlip = nil

local zones = {}
local teamPlayerIds = {}
local teamPlayerNames = {}

lib.locale()

if Config.InteractionType == "target" then
    local StartMissionCoords = Config.MissionStart.StartMissionCoords
    AddCircleZone("start_job", StartMissionCoords, 0.75, {
        useZ = true,
        name = "start_job",
        Config.Debug
    }, {
        options = {
            {
                action = function()
                    local playerPedId = PlayerPedId()
                    if not MenuIsOpen then
                        lib.callback('drc_truckrobbery:checkItem', false, function(hasItem)
                            if hasItem then
                                lib.callback('drc_truck:checkPoliceOnline', false, function(enoughPolice)
                                    if enoughPolice then
                                        lib.callback('drc_truck:isMissionOnCooldown', false,
                                            function(isOnCooldown, timeLeft)
                                                if isOnCooldown then
                                                    showNotification(
                                                    locale('mission_is_on_cooldown') ..
                                                    timeLeft .. locale("more_seconds"), 'error')
                                                    return
                                                end

                                                MenuIsOpenForClient = true
                                                TSE('drc_truck:MenuIsOpen:Server')
                                                local potentialTeamMembers = {}
                                                local playerPos = GetEntityCoords(playerPedId)
                                                local myServerId = GetPlayerServerId(PlayerId())

                                                table.insert(teamPlayerIds, myServerId)

                                                for _, player in ipairs(GetActivePlayers()) do
                                                    local otherPlayerPed = GetPlayerPed(player)
                                                    if otherPlayerPed ~= playerPedId then
                                                        local otherPlayerCoords = GetEntityCoords(otherPlayerPed)
                                                        local distance = #(playerPos - otherPlayerCoords)

                                                        if distance <= 15.0 then
                                                            local serverId = GetPlayerServerId(player)
                                                            table.insert(potentialTeamMembers, serverId)
                                                        end
                                                    end
                                                end
                                                local maxTeamMembers = Config.MissionStart.MaxTeamMembers
                                                SendNUIMessage({
                                                    action = "receiveMaxTeamMembers",
                                                    maxTeamMembers = maxTeamMembers
                                                })
                                                lib.callback('drc_truck:getNames', false, function(data)
                                                    SetNuiFocus(true, true)

                                                    SendNUIMessage({
                                                        action = "updatePlayers",
                                                        playerNames = data.teamMembers,
                                                        teamLeader = data.teamLeader
                                                    })
                                                end, potentialTeamMembers)
                                            end)
                                    else
                                        showNotification(locale('not_enough_police'), 'error')
                                    end
                                end)
                            else
                                showNotification(locale('you_dont_have_required_items'), 'error')
                            end
                        end)
                    else
                        showNotification(locale('someone_already_have_menu_open'), 'error')
                    end
                end,
                icon = "fas fa-truck-field-un",
                label = locale('start_job'),
                
            }
        },
        distance = 1.5
    })
    if Config.Shop.Blip.RequireToAsk then
    AddCircleZone("ask_about_place", StartMissionCoords, 0.75, {
        useZ = true,
        name = "ask_about_place",
        Config.Debug
    }, {
        options = {
            {
                action = function()
                   TriggerEvent('drc_truckrobbery:getBlip')
                end,
                icon = "fas fa-info",
                label = locale('ask_lester'),
            }
        },
        distance = 1.5
    })
end
    else
        local StartMissionCoords = Config.MissionStart.StartMissionCoords
        zones["truckrobbery_startZone"] = lib.zones.sphere({
            coords = StartMissionCoords,
            radius = 1.0,
            debug = Config.Debug,
            inside = function(self)
                if IsControlJustReleased(0, 38) then
                    local playerPedId = PlayerPedId()
                    if not MenuIsOpen then
                        lib.callback('drc_truckrobbery:checkItem', false, function(hasItem)
                            if hasItem then
                                lib.callback('drc_truck:checkPoliceOnline', false, function(enoughPolice)
                                    if enoughPolice then
                                        lib.callback('drc_truck:isMissionOnCooldown', false,
                                            function(isOnCooldown, timeLeft)
                                                if isOnCooldown then
                                                    showNotification(
                                                    locale('mission_is_on_cooldown') ..
                                                    timeLeft .. locale("more_seconds"), 'error')
                                                    return
                                                end

                                                MenuIsOpenForClient = true
                                                TSE('drc_truck:MenuIsOpen:Server')
                                                local potentialTeamMembers = {}
                                                local playerPos = GetEntityCoords(playerPedId)
                                                local myServerId = GetPlayerServerId(PlayerId())

                                                table.insert(teamPlayerIds, myServerId)

                                                for _, player in ipairs(GetActivePlayers()) do
                                                    local otherPlayerPed = GetPlayerPed(player)
                                                    if otherPlayerPed ~= playerPedId then
                                                        local otherPlayerCoords = GetEntityCoords(otherPlayerPed)
                                                        local distance = #(playerPos - otherPlayerCoords)

                                                        if distance <= 15.0 then
                                                            local serverId = GetPlayerServerId(player)
                                                            table.insert(potentialTeamMembers, serverId)
                                                        end
                                                    end
                                                end
                                                local maxTeamMembers = Config.MissionStart.MaxTeamMembers
                                                SendNUIMessage({
                                                    action = "receiveMaxTeamMembers",
                                                    maxTeamMembers = maxTeamMembers
                                                })
                                                lib.callback('drc_truck:getNames', false, function(data)
                                                    SetNuiFocus(true, true)

                                                    SendNUIMessage({
                                                        action = "updatePlayers",
                                                        playerNames = data.teamMembers,
                                                        teamLeader = data.teamLeader
                                                    })
                                                end, potentialTeamMembers)
                                            end)
                                    else
                                        showNotification(locale('not_enough_police'), 'error')
                                    end
                                end)
                            else
                                showNotification(locale('you_dont_have_required_items'), 'error')
                            end
                        end)
                    else
                        showNotification(locale('someone_already_have_menu_open'), 'error')
                    end
                end 
                if IsControlJustReleased(0, 74) then
                    TriggerEvent('drc_truckrobbery:getBlip')
            end
                if Config.InteractionType == "3dtext" then
                Draw3DText(self.coords + 0.1, string.format("[~g~E~w~] - %s", locale('start_job').. '\n' .. "[~g~H~w~] - ".. locale('ask_lester')))
                end
            end,
            onEnter = function()
                if Config.InteractionType == "textui" then
                    TextUIShow(string.format("[E] - %s", locale('start_job').. "[H] - ".. locale('ask_lester')))
                end    
            end,
            onExit = function()
                if Config.InteractionType == "textui" then
                    TextUIHide()
                end
            end
        })
    end
RegisterNUICallback('startJob', function(data)
    local playerPedId = PlayerPedId()
    local canStart = lib.callback.await('drc_truck:startMissionCooldown')
    if not canStart then
        return
    end
    SetNuiFocus(false, false)
    local animDict = 'timetable@jimmy@doorknock@'
    LoadAnim(animDict)
    PlayAnimation(playerPedId, animDict, 'knockdoor_idle', true, 49)
    FreezeEntityPosition(playerPedId, true)
    ProgressBar(4000, locale('knocking_door'))
    FreezeEntityPosition(playerPedId, false)
    ClearPedTasksImmediately(playerPedId)
    TriggerServerEvent('drc_truck:missionReadyToStart', teamPlayerIds)
    TSE('drc_truck:MenuIsClosed:Server')
end)


RegisterNUICallback('closeMenu', function(data, cb)
    local playerPedId = PlayerPedId()
    teamPlayerIds = {}
    SetNuiFocus(false, false)
    TSE('drc_truck:MenuIsClosed:Server')
    if cb then cb('ok') end
end)

RegisterNUICallback('teamFull', function(data)
    if data.action == 'teamFull' then
        local playerPedId = PlayerPedId()
        showNotification(locale('your_team_is_full'), 'success')
    end
end)

RegisterNetEvent('drc_truck:MenuIsOpen')
AddEventHandler('drc_truck:MenuIsOpen', function()
    MenuIsOpen = true
end)

RegisterNetEvent('drc_truck:MenuIsClosed')
AddEventHandler('drc_truck:MenuIsClosed', function()
    MenuIsOpen = false
end)



RegisterNetEvent('drc_truck:updateTeamLeader')
AddEventHandler('drc_truck:updateTeamLeader', function(newMemberName, playerId)
    table.insert(teamPlayerIds, playerId)
    SendNUIMessage({
        action = "newTeamMember",
        playerName = newMemberName
    })
end)



RegisterNetEvent('drc_truck:removeFromTeam')
AddEventHandler('drc_truck:removeFromTeam', function(playerName)
    for i = #teamPlayerIds, 1, -1 do
        if GetPlayerName(teamPlayerIds[i]) == playerName then
            table.remove(teamPlayerIds, i)
            break
        end
    end
end)



RegisterNetEvent('drc_truck:updatePlayerLists')
AddEventHandler('drc_truck:updatePlayerLists', function(updatedPlayerData)
    updatedPlayerList = updatedPlayerData
end)


RegisterNUICallback('invitePlayer', function(data)
    local teamLeaderId = data.playerServerId
    TSE('drc_truck:invitePlayer', teamLeaderId)
end)

RegisterNetEvent('drc_truck:receiveInvitation')
AddEventHandler('drc_truck:receiveInvitation', function(invitingPlayerId)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showInvitation",
        invitingPlayerId = invitingPlayerId
    })
end)

RegisterNUICallback('closeAlert', function(data)
    if data.action == 'alertClosed' then
        SetNuiFocus(false, false)  
    end
end)

RegisterNUICallback('alreadyInvited', function(data)
    if data.action == 'alreadyInvited' then
        showNotification(locale('you_already_invited'), 'success')
    end
end)


RegisterNUICallback('acceptInvitation', function(data)
    TSE('drc_truck:acceptInvitation', data.playerServerId)
    SetNuiFocus(false, false)
end)


function showCustomText(message, duration)
    local endTime = GetGameTimer() + duration

    CreateThread(function()
        while GetGameTimer() < endTime do
            SetTextFont(0)
            SetTextProportional(1)
            SetTextScale(0.35, 0.35) 
            SetTextColour(255, 255, 255, 255) 
            SetTextDropShadow()
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString(message)
            DrawText(0.5, 0.9) 
            Wait(0)
        end
    end)
end

local explosivesDealerBlip = nil
local proximityThreshold = 20.0  

RegisterNetEvent('drc_truckrobbery:getBlip')
AddEventHandler('drc_truckrobbery:getBlip', function()
    if not DidAsk then
        local playerPedId = PlayerPedId()
        local animDict = 'timetable@jimmy@doorknock@'
        LoadAnim(animDict)
        PlayAnimation(playerPedId, animDict, 'knockdoor_idle', true, 49)
        FreezeEntityPosition(playerPedId, true)
        ProgressBar(4000, locale('knocking_door'))
        FreezeEntityPosition(playerPedId, false)
        ClearPedTasks(playerPedId)
        if Config.Shop.Time.enabled then
            showNotification(locale('lester_told_u_require'), 'success')
        else
            showNotification(locale('lester_told_u'), 'success')
        end

        local dealerCoords = vector3(Config.Shop.Ped.coords.x, Config.Shop.Ped.coords.y, Config.Shop.Ped.coords.z)
        DidAsk = true


        if explosivesDealerBlip == nil then 
            explosivesDealerBlip = AddBlipForCoord(dealerCoords)
            SetBlipSprite(explosivesDealerBlip, Config.Shop.Blip.Sprite)
            SetBlipDisplay(explosivesDealerBlip, 4)
            SetBlipScale(explosivesDealerBlip, Config.Shop.Blip.Scale)
            SetBlipColour(explosivesDealerBlip, Config.Shop.Blip.Colour)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Config.Shop.Blip.Name)
            EndTextCommandSetBlipName(explosivesDealerBlip)

            SetNewWaypoint(dealerCoords.x, dealerCoords.y)

            Citizen.CreateThread(function()
                while true do
                    Wait(1000)
                    local playerCoords = GetEntityCoords(playerPedId)
                    local distance = #(playerCoords - dealerCoords)

                    if distance <= proximityThreshold then
                        DidAsk = false
                        if explosivesDealerBlip then
                            RemoveBlip(explosivesDealerBlip)
                            explosivesDealerBlip = nil
                        end
                        break
                    end
                end
            end)
        end
    else
        showNotification(locale('you_already_ask'), 'error')
    end
end)




RegisterNetEvent('drc_truck:startMission')
AddEventHandler('drc_truck:startMission', function(teamPlayerIds)
    MissionActive = false
    bombIsBeingPlanted = false
    minigameCompleted = false
    DoingMinigame = false
    MinigameSuccess = nil
    
    bombInPlace = false
     C4Installing = false
    GrabbingMooney = false
    moneyStillThere = false
    bombStatus = false
    bombIsBeingPlanted = false
    previousVehicle = nil
    vehicleBlip  = nil
    securityTruck = nil
    doorCoords = nil
    bag = nil
    Radius = nil
    RadiusBlip = nil


    local playerPedId = PlayerPedId()
    local modelHash = GetEntityModel(playerPedId)
    local missionCoords = Config.MissionStart.StartMissionCoords
    local leaveCoords = Config.MissionStart.LeaveTeleportCoords
    local cameraCoords = Config.MissionStart.CameraCoords
    local playerTypeAnim = Config.MissionStart.PlayerTypeAnim
    local lesterPed = GetHashKey('ig_lestercrest_2')
    local clothing = GetSkin()
    DoScreenFadeOut(1000)
    Wait(1000)
    
    if Config.MissionStart.Cutscene then
    DoScreenFadeIn(1000)

    RequestCutscene('lester_1_int', 8)
    while not (HasCutsceneLoaded()) do
        Wait(0)
    end

    SetCutsceneEntityStreamingFlags('Michael', 0, 1)
    RegisterEntityForCutscene(playerPedId, 'Michael', 0, 0, 64)

    SetCutsceneEntityStreamingFlags('Lester', 0, 1)
    RegisterEntityForCutscene(lesterPed, 'Lester', 0, 0, 64)


    StartCutscene(0)

    while not (DoesCutsceneEntityExist('Michael', 0)) do
        Wait(0)
    end

    while not (DoesCutsceneEntityExist('Lester', 0)) do
        Wait(0)
    end

    ApplySkin(playerPedId)
    Wait(8000)

    DoScreenFadeOut(1000)
    Wait(2000)
    StopCutsceneImmediately()
end 


    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(1)
    end

    SetEntityCoords(playerPedId, playerTypeAnim.x, playerTypeAnim.y, playerTypeAnim.z, 0, 0, 0, true)
    SetEntityHeading(playerPedId, playerTypeAnim.w)
    animDict = 'anim@heists@prison_heiststation@cop_reactions'
    LoadAnim(animDict)
    PlayAnimation(playerPedId, animDict, 'cop_b_idle', true, 49)
    FreezeEntityPosition(playerPedId, true)
    DoScreenFadeIn(1000)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cameraCoords.x, cameraCoords.y, cameraCoords.z,
        cameraCoords.rotX, cameraCoords.rotY, cameraCoords.rotZ, cameraCoords.fov, false, 0)
    SetTimecycleModifier('Dont_tazeme_bro')
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    local function ZoomCamera(cam, startFOV, endFOV, duration)
        TriggerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'camera', 1.0)
        local startTime = GetGameTimer()
        local endTime = startTime + duration
        local currentTime = startTime
        while currentTime < endTime do
            local elapsedTime = currentTime - startTime
            local progress = elapsedTime / duration
            local currentFOV = startFOV + (endFOV - startFOV) * progress
            SetCamFov(cam, currentFOV)
            Wait(0)
            currentTime = GetGameTimer()
        end

        SetCamFov(cam, endFOV)
    end
    ZoomCamera(cam, 100.0, 30.0, 2000)
    ProgressBar(4500, locale('turning_on_pc'))
    FreezeEntityPosition(playerPedId, false)
    DoScreenFadeOut(1000)
    Wait(1000)
    ClearTimecycleModifier()

    SetCamActive(cam, false)
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    local heading = GetEntityHeading(ped)
    DeleteEntity(ped)
    SetEntityCoords(playerPedId, playerTypeAnim.x, playerTypeAnim.y, playerTypeAnim.z, 0, 0, 0, true)
    SetEntityHeading(playerPedId, heading)
    Wait(1000)
    DoScreenFadeIn(1000)

    local x, y, z, heading = playerTypeAnim.x, playerTypeAnim.y, playerTypeAnim.z, playerTypeAnim.w
    SetEntityLocallyInvisible(playerPedId)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z + 1.2, 0.0, 0.0, heading, 40.0, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    ZoomCamera(cam, 100.0, 30.0, 2000)

    DoingMinigame = true
    SendNUIMessage({
        action = 'startMinigame',
        hackTime = Config.Times.HackTime
    })
    SetEntityLocallyVisible(playerPedId)
    SetNuiFocus(true, true)

    Citizen.CreateThread(function()
        while DoingMinigame do
            Wait(500)
        end
        DoingMinigame = false
        if MinigameSuccess then
            Wait(2000)
            DoScreenFadeOut(1000)
            SendNUIMessage({
                action = "stopMinigame"
            })
            Wait(2000)
            SetCamActive(cam, false)
            RenderScriptCams(false, false, 0, true, false)
            DestroyCam(cam, false)
            DoingMinigame = false
            SetEntityCoords(playerPedId, leaveCoords.x, leaveCoords.y, leaveCoords.z, 0, 0, 0, false)
            DoScreenFadeIn(1000)
            TSE('drc_truck:serverSpawnTruck', teamPlayerIds)
            if Config.MissionStart.VoiceTalk then
                TSE('InteractSound_SV:PlayWithinDistance', 5.0, 'voiceover_moneytruck', 0.35)
                local text = locale('subtitle_text')
                showCustomText(text, 7000)
            else
                showNotification(locale('subtitle_text'), 'success')
            end
        elseif not MinigameSuccess then
            Wait(5000)
            DoScreenFadeOut(1000)
            SendNUIMessage({
                action = "stopMinigame"
            })
            Wait(2000)
            SetCamActive(cam, false)
            RenderScriptCams(false, false, 0, true, false)
            DestroyCam(cam, false)
            DoingMinigame = false
            DoScreenFadeIn(1000)
            SetEntityCoords(playerPedId, leaveCoords.x, leaveCoords.y, leaveCoords.z, 0, 0, 0, false) 
        end
    end)
end)
local security = {}
local trolley = nil

RegisterNetEvent('drc_truck:spawnTruck')
AddEventHandler('drc_truck:spawnTruck', function(teamPlayerIds)
    if not MissionActive then
        MissionActive = true
    local playerPedId = PlayerPedId()
    local vehiclehash = Config.VehicleModel
    local pedModel = 'mp_s_m_armoured_01'

    local lootOdds = Config.LootOdds

    local function getTrolleyModel()
        local randomNum = math.random(100)
        local cumulativeOdds = 0
    
        cumulativeOdds = cumulativeOdds + lootOdds.diamonds
        if randomNum <= cumulativeOdds then
            return 881130828 
        end
    
        cumulativeOdds = cumulativeOdds + lootOdds.gold
        if randomNum <= cumulativeOdds then
            return 2007413986 
        end
    
        return 269934519 
    end

    local trollyModel = getTrolleyModel()
    local animDict = 'anim@heists@ornate_bank@grab_cash'

    local trolleyVanModel = nil
    if trollyModel == 881130828 then
        trolleyVanModel = 'ch_prop_diamond_trolly_01b'
    elseif trollyModel == 2007413986 then
        trolleyVanModel = 'ch_prop_gold_trolly_01a'
    elseif trollyModel == 269934519 then
        trolleyVanModel = 'hei_prop_hei_cash_trolly_01'
    end


    local function getRandomSpawnLocation(spawnLocations)
        local randomIndex = math.random(#spawnLocations)
        return spawnLocations[randomIndex]
    end

    local spawnLocation = getRandomSpawnLocation(Config.TruckSpawn)
    loadModel(trolleyVanModel)
    
    RequestModel(vehiclehash)
    while not HasModelLoaded(vehiclehash) do
        Wait(1)
    end

    TSE('drc_truck:createFindRadius', teamPlayerIds, spawnLocation.xyz)

    while #(spawnLocation.xyz - GetEntityCoords(playerPedId)) > 140 do
        Wait(1000)
    end

    securityTruck = CreateVehicle(vehiclehash, vector3(spawnLocation.x, spawnLocation.y, spawnLocation.z),
        spawnLocation.w, true, true)
        SetVehicleDoorsLocked(securityTruck, 3)
    netid = NetworkGetNetworkIdFromEntity(securityTruck)
    SetEntityAsMissionEntity(securityTruck, true, true)

    local boneIndex = GetEntityBoneIndexByName(securityTruck, 'bodyshell')
    local trolleyOffsets = {
        { x = -0.0, y = -2.2, z = 0.9, heading = 0.0 },
        { x = -0.0, y = -1.5, z = 0.9, heading = 0.0 }
    }

    local trolleyNetIds = {}

    for _, offset in ipairs(trolleyOffsets) do
        local trolley = CreateObject(trolleyVanModel, GetEntityCoords(securityTruck), true, true, true)
        SetEntityCollision(trolley, true, true)
        AttachEntityToEntity(trolley, securityTruck, boneIndex, offset.x, offset.y, offset.z, 0.0, 0, offset.heading,
            true, false, false, false, 2, true)
        FreezeEntityPosition(trolley, true)
        local trolleyNetId = NetworkGetNetworkIdFromEntity(trolley)
        table.insert(trolleyNetIds, trolleyNetId)
    end


    local id = VehToNet(securityTruck)

    SetVehicleHasBeenOwnedByPlayer(securityTruck, true)
    SetNetworkIdExistsOnAllMachines(id, true)
    SetNetworkIdCanMigrate(id, true)
    SetEntityAsMissionEntity(securityTruck, true, true)

    RequestModel(pedModel)

    while not HasModelLoaded(pedModel) do
        Wait(10)
    end

    local seatPositions = { -1, 0 }
    local securityGroup = AddRelationshipGroup("SECURITY_GUARDS")

    for _, seat in ipairs(seatPositions) do
        local securityPed = CreatePedInsideVehicle(securityTruck, 26, pedModel, seat, true, true)
        SetPedRelationshipGroupHash(securityPed, securityGroup)
        GiveWeaponToPed(securityPed, 'weapon_smg', 60, false, true)
        SetEntityAsMissionEntity(securityPed)
        NetworkRegisterEntityAsNetworked(securityPed)
        SetPedArmour(securityPed, 100)
        SetPedAccuracy(securityPed, 60)
        SetPedAsCop(securityPed)
        SetPedConfigFlag(securityPed, 32, false)
        SetRelationshipBetweenGroups(0, securityGroup, securityGroup)
        SetPedDropsWeaponsWhenDead(securityPed, false)
        SetPedArmour(securityPed, 100)
        SetPedMaxHealth(securityPed, 200)
        C4Installing = true
        local vehicleSpeed = GetVehicleModelMaxSpeed('stockade') / 2
        TaskVehicleDriveWander(securityPed, securityTruck, vehicleSpeed, 786603)
    end
    Wait(1000)
    TSE('drc_truck:notifyTeamMembers', teamPlayerIds, VehToNet(securityTruck), trolleyNetIds, trollyModel)
    end
end)

RegisterNetEvent('drc_truck:addRadiusForFind')
AddEventHandler('drc_truck:addRadiusForFind', function(spawnLocation)
    local playerPedId = PlayerPedId()
    local radius = AddBlipForRadius(spawnLocation.x, spawnLocation.y, spawnLocation.z, Config.TruckBlip.TruckRadius.Radius)
    SetBlipHighDetail(radius, true)
    SetBlipAlpha(radius, 120)

    local truckBlip = AddBlipForCoord(spawnLocation.x, spawnLocation.y, spawnLocation.z)
    SetBlipSprite(truckBlip, Config.TruckBlip.TruckRadius.Sprite)
    SetBlipScale(truckBlip, Config.TruckBlip.TruckRadius.Scale)
    SetBlipColour(truckBlip, Config.TruckBlip.TruckRadius.Colour)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.TruckBlip.TruckRadius.Name)
    EndTextCommandSetBlipName(truckBlip)

    while not DoesBlipExist(vehicleBlip) do
        Wait(1000)
    end

    RemoveBlip(radius)
    RemoveBlip(truckBlip)
end)


RegisterNetEvent('drc_truck:addBlipToTruck')
AddEventHandler('drc_truck:addBlipToTruck', function(entity, netid, teamPlayerIds)
    local securityTruck = NetToVeh(netid)
    vehicleBlip = AddBlipForEntity(securityTruck)
    SetBlipSprite(vehicleBlip, Config.TruckBlip.Truck.Sprite)
    SetBlipDisplay(vehicleBlip, 4)
    SetBlipScale(vehicleBlip, Config.TruckBlip.Truck.Scale)
    SetBlipColour(vehicleBlip, Config.TruckBlip.Truck.Colour)
    SetBlipAsShortRange(vehicleBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.TruckBlip.Truck.Name)
    EndTextCommandSetBlipName(vehicleBlip)
end)

RegisterNetEvent('drc_truck:Target')
AddEventHandler('drc_truck:Target', function(entity, netid, teamPlayerIds, trolleyNetIds, trollyModel)
    local playerPedId = PlayerPedId()
    local targetSpawned = false
    bombIsBeingPlanted = true
    local securityTruck = NetToVeh(netid)
    loadModel(trollyModel)
    Citizen.CreateThread(function()
        while bombIsBeingPlanted do
            if securityTruck and DoesEntityExist(securityTruck) then
                local truckSpeed = GetEntitySpeed(securityTruck)

                if truckSpeed < 0.10 and not targetSpawned then
                    local offsetX, offsetY, offsetZ = 0.0, 1.0, 0.0
                    local worldCoords = GetOffsetFromEntityInWorldCoords(securityTruck, Config.Offset.x, Config.Offset.y,
                        Config.Offset.z)
                    if Config.InteractionType == 'target' then
                        AddCircleZone("truck_addc4", vector3(worldCoords.x, worldCoords.y, worldCoords.z), 1.0, {
                            useZ = true,
                            name = "truck_addc4",
                            Config.Debug
                        }, {
                            options = {
                                {
                                    action = function()
                                        lib.callback('drc_truck:useC4', false, function(canUseC4)
                                            if canUseC4 then
                                                TSE('drc_truck:removeTargetForTeam', teamPlayerIds)
                                                SendNUIMessage({ action = "startMinigameStickyBomb" })
                
                                                SetNuiFocus(true, true)
                                                local animDict = 'anim@gangops@facility@servers@'
                                                LoadAnim(animDict)
                                                PlayAnimation(playerPedId, animDict, 'hotwire', true, 49)
                                                FreezeEntityPosition(playerPedId, true)
                                                
                                                Citizen.CreateThread(function()                 
                                                    while not minigameCompleted do
                                                        Wait(500)
                                                    end
                                                   
                                                    TriggerEvent('drc_truck:c4Install', netid, doorCoords, teamPlayerIds, trolleyNetIds, vehicleBlip, trollyModel)
                                                end)
                                            else
                                                showNotification(locale('you_need_c4'), 'error')
                                            end
                                        end)
                                    end,                                    
                                    icon = 'fas fa-bomb',
                                    label = locale('install_C4'),
                                    distance = 1.2,
                                }
                            },
                            distance = 1.6
                        })
                    else
                        zones["truck_addc4"] = lib.zones.sphere({
                            coords = vector3(worldCoords.x, worldCoords.y, worldCoords.z),
                            radius = 1.3,
                            debug = Config.Debug,
                            inside = function(self)
                                if IsControlJustReleased(0, 38) then
                                    lib.callback('drc_truck:useC4', false, function(canUseC4)
                                        if canUseC4 then
                                            TSE('drc_truck:removeTargetForTeam', teamPlayerIds)
                                            SendNUIMessage({ action = "startMinigameStickyBomb" })
            
                                            SetNuiFocus(true, true)
                                            local animDict = 'anim@gangops@facility@servers@'
                                            LoadAnim(animDict)
                                            PlayAnimation(playerPedId, animDict, 'hotwire', true, 49)
                                            FreezeEntityPosition(playerPedId, true)
                                            
                                            Citizen.CreateThread(function()                 
                                                while not minigameCompleted do
                                                    Wait(500)
                                                end
                                               
                                                TriggerEvent('drc_truck:c4Install', netid, doorCoords, teamPlayerIds, trolleyNetIds, vehicleBlip, trollyModel)
                                            end)
                                        else
                                            showNotification(locale('you_need_c4'), 'error')
                                        end
                                    end)
                                end
                                if Config.InteractionType == "3dtext" then
                                    Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('install_C4')))
                                end
                            end,
                            onEnter = function()
                                if Config.InteractionType == "textui" then
                                    TextUIShow(string.format("[E] - %s", locale('install_C4')))
                                end
                            end,
                            onExit = function()
                                if Config.InteractionType == "textui" then
                                    TextUIHide()
                                end
                            end
                        })
                    end
                    targetSpawned = true
                elseif truckSpeed >= 0.01 and targetSpawned then
                    targetSpawned = false
                    if Config.InteractionType == 'target' then
                        RemoveZone('truck_addc4')
                    else
                        zones['truck_addc4']:remove()
                    end
                end
            else
                break
            end
            Wait(500)
        end
    end)
end)

RegisterNetEvent('drc_truck:c4Install')
AddEventHandler('drc_truck:c4Install', function(netid, doorCoords, teamPlayerIds, trolleyNetIds, vehicleBlip, trollyModel)
        local playerPedId = PlayerPedId()
        local phone = nil
        local securityTruck = NetToVeh(netid)
        if not bombStatus then
            if not bombInPlace then
                        loadModel('prop_c4_final_green')
                        local c4 = CreateObject('prop_c4_final_green', GetEntityCoords(playerPedId), true, true, true)
                        AttachEntityToEntity(c4, playerPedId, GetPedBoneIndex(playerPedId, 18905), 0.1, 0.0, 0.03, 70.0,
                            0.0, 0.0, true, true, false, false, 1, true)
                        ProgressBar(3500, locale('planting_bomb'))
                        bombInPlace = true
                        DeleteEntity(c4)
                        ClearPedTasksImmediately(playerPedId)
                        FreezeEntityPosition(playerPedId, false)


                        local bomb = CreateObject('prop_c4_final_green', GetEntityCoords(playerPedId), true, true, true)
                        FreezeEntityPosition(bomb, true)
                        AttachEntityToEntity(bomb, securityTruck, GetEntityBoneIndexByName(securityTruck, 'door_dside_r'),
                            0.8, -0.02, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                        local colorSwitch = true
                        loadModel('prop_prologue_phone_lod')
                        phone = CreateObject('prop_prologue_phone_lod', GetEntityCoords(playerPedId), true, true, true)
                        AttachEntityToEntity(phone, playerPedId, GetPedBoneIndex(playerPedId, 57005), 0.16, 0.05,
                        -0.03, -162.0, -76.0, -6.0, true, true, false, false, 1, true)
                        Citizen.CreateThread(function()
                            while bombInPlace do
                                TextUIShow(locale('activate_bomb'), {
                                    position = "right-center",
                                    icon = 'bomb',
                                    style = {
                                        borderRadius = 0,
                                        backgroundColor = '#48BB78',
                                        color = 'white'
                                    }
                                })
                        
                                if IsControlJustReleased(0, 38) then
                                    local countdown = Config.Times.CountDown
                                    local playerCoords = GetEntityCoords(playerPedId)
                                    local boneIndex = GetEntityBoneIndexByName(securityTruck, 'door_pside_r')
                                    local bombCoords = GetWorldPositionOfEntityBone(securityTruck, boneIndex)
                                    local distance = #(playerCoords - bombCoords)
                                    
         
                                    local animDict = 'anim@mp_player_intmenu@key_fob@'
                                    LoadAnim(animDict)
                                    PlayAnimation(playerPedId, animDict, 'fob_click_fp', true, 49)
                                    TSE("InteractSound_SV:PlayWithinDistance", 5.0, "beepActivate", 0.55)
                                    Wait(1500)
                                    ClearPedTasks(playerPedId)
                                    DeleteEntity(phone)
                                    
                                    if distance <= 10.0 then
                                        TextUIHide()
                                        ProgressBar(countdown * 1000, '...')
                                        if math.random(1, 100) <= Config.C4.Chance then
                                            showNotification(locale('bomb_failed'), 'error')
                                            TSE("InteractSound_SV:PlayWithinDistance", 5.0, "beepC4Failure", 0.55)
                                            TextUIShow(locale('activate_bomb'), {
                                                position = "right-center",
                                                icon = 'bomb',
                                                style = {
                                                    borderRadius = 0,
                                                    backgroundColor = '#48BB78',
                                                    color = 'white'
                                                }
                                            })
                                            
                                        else
                                            bombInPlace = false
                                            Dispatch(GetEntityCoords(securityTruck), "truck-robbery")
                                            TSE('drc_truck:truckExplosionForTeam', netid, boneIndex, teamPlayerIds, bomb,
                                            trolleyNetIds, trollyModel)
                                            local pedModel = 'mp_s_m_armoured_01'
                                            local seatPositions = { 1, 2 }
                                        
                                            RequestModel(pedModel)
                                        
                                            while not HasModelLoaded(pedModel) do
                                                Wait(10)
                                            end
                                        
                                            for _, seat in ipairs(seatPositions) do
                                                local securityPed = CreatePedInsideVehicle(securityTruck, 26, pedModel, seat, true, true)
                                                SetPedRelationshipGroupHash(securityPed, securityGroup)
                                                GiveWeaponToPed(securityPed, 'weapon_smg', 60, false, true)
                                                SetEntityAsMissionEntity(securityPed)
                                                NetworkRegisterEntityAsNetworked(securityPed)
                                                SetPedArmour(securityPed, 100)
                                                SetPedAccuracy(securityPed, 60)
                                                SetPedAsCop(securityPed)
                                                SetPedConfigFlag(securityPed, 32, false)
                                                SetRelationshipBetweenGroups(0, securityGroup, securityGroup)
                                                SetPedDropsWeaponsWhenDead(securityPed, false)
                                                SetPedArmour(securityPed, 100)
                                                SetPedMaxHealth(securityPed, 200)
                                                TaskLeaveVehicle(securityPed, securityTruck, 0)
                                            end
                                        end
                                    else
                                        showNotification(locale('too_far_away'), 'error')
                                    end
                                end
                        
                                Wait(0)
                            end
                        end)
            else
                showNotification(locale('bomb_is_already_placed'), 'error')
            end
        else
            showNotification(locale('bomb_is_already_placed'), 'error')
        end
    end)
    

RegisterNetEvent('drc_truck:explosion')
AddEventHandler('drc_truck:explosion', function(netid, boneIndex, teamPlayerIds, bomb, trolleyNetIds, trollyModel)
    local playerPedId = PlayerPedId()
    local securityTruck = NetToVeh(netid)
    SetEntityInvincible(securityTruck, true)
    local bx, by, bz = table.unpack(GetWorldPositionOfEntityBone(securityTruck, boneIndex))
    DeleteEntity(bomb)
    SetVehicleDoorBroken(securityTruck, 2, false)
    AddExplosion(bx, by, bz + 0.5, 31, 1.0, true, false, 1.0)
    ApplyForceToEntity(securityTruck, 4, bx, by, bz + 0.5, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
    SetVehicleDoorOpen(securityTruck, 3, false, true)
    Wait(100)
    SetEntityInvincible(securityTruck, false)
    TriggerEvent('drc_truck:addMoneyTarget', netid, teamPlayerIds, trolleyNetIds, trollyModel)
end)

local Trolly = {}
local newTrolly = nil

function GrabTrolly(index, k, trollyModel, teamPlayerIds)
    local playerPedId = PlayerPedId()
    local grabModel = nil
    Trolly = {
        ['objects'] = {
            'hei_p_m_bag_var22_arm_s'
        },
        ['animations'] = {
            { 'intro', 'bag_intro' },
            { 'grab',  'bag_grab', 'cart_cash_dissapear' },
            { 'exit',  'bag_exit' }
        },
        ['scenes'] = {}
    }


    grabNow = true
    FreezeEntityPosition(playerPedId, true)
    robber = true
    local ped = playerPedId
    local pedCo, pedRotation = GetEntityCoords(ped), vector3(0.0, 0.0, 0.0)
    local animDict = 'anim@heists@ornate_bank@grab_cash'
    if trollyModel == 881130828 then
        grabModel = 'ch_prop_vault_dimaondbox_01a'
    elseif trollyModel == 2007413986 then
        grabModel = 'ch_prop_gold_bar_01a'
    elseif trollyModel == 269934519 then
        grabModel = 'hei_prop_heist_cash_pile'
    end
    loadAnimDict(animDict)
    loadModel('hei_p_m_bag_var22_arm_s')

    sceneObject = GetClosestObjectOfType(GetEntityCoords(ped), 2.0, trollyModel, 0, 0, 0)
    bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), pedCo, true, false, false)

    while not NetworkHasControlOfEntity(sceneObject) do
        Wait(1)
        NetworkRequestControlOfEntity(sceneObject)
    end

    local rot = GetEntityRotation(sceneObject)
    for i = 1, #Trolly['animations'] do
        Trolly['scenes'][i] = NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject),
            2, true, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, Trolly['scenes'][i], animDict, Trolly['animations'][i][1], 2.5, -4.0, 1, 16,
            1148846080, 0)
        NetworkAddEntityToSynchronisedScene(bag, Trolly['scenes'][i], animDict, Trolly['animations'][i][2], 4.0, -8.0, 1)
        if i == 2 then
            NetworkAddEntityToSynchronisedScene(sceneObject, Trolly['scenes'][i], animDict, "cart_cash_dissapear", 4.0,
                -8.0, 1)
        end
    end

    NetworkStartSynchronisedScene(Trolly['scenes'][1])
    Wait(1750)
    CashAppear(grabModel, teamPlayerIds)
    NetworkStartSynchronisedScene(Trolly['scenes'][2])
    Wait(37000)
    NetworkStartSynchronisedScene(Trolly['scenes'][3])
    Wait(2000)

    local emptyobj = 769923921
    local sceneObjectCoords = GetEntityCoords(sceneObject)
    local adjustedZ = sceneObjectCoords.z - 0.5
    newTrolly = CreateObject(emptyobj, sceneObjectCoords.x, sceneObjectCoords.y, adjustedZ, true, false, false)
    SetEntityRotation(newTrolly, 0, 0, GetEntityHeading(sceneObject), 1, 0)
    DeleteObject(sceneObject)
    DeleteObject(bag)
    grabNow = false
    FreezeEntityPosition(playerPedId, false)
end

function CashAppear(grabModel, teamPlayerIds)
    local playerPedId = PlayerPedId()
    local ped = playerPedId
    local pedCoords = GetEntityCoords(ped)


    if grabModel == 'ch_prop_vault_dimaondbox_01a' then
        reward = nil
    elseif grabModel == 'ch_prop_gold_bar_01a' then
        reward = nil
    elseif grabModel == 'hei_prop_heist_cash_pile' then
        reward = nil
    end

    local grabmodel = GetHashKey(grabModel)

    loadModel(grabmodel)
    local grabobj = CreateObject(grabmodel, pedCoords, true)
    FreezeEntityPosition(grabobj, true)
    SetEntityInvincible(grabobj, true)
    SetEntityNoCollisionEntity(grabobj, ped)
    SetEntityVisible(grabobj, false, false)


    AttachEntityToEntity(grabobj, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
    local startedGrabbing = GetGameTimer()

    CreateThread(function()
        while GetGameTimer() - startedGrabbing < 37000 do
            Wait(1)
            DisableControlAction(0, 73, true)
            if HasAnimEventFired(ped, GetHashKey("CASH_APPEAR")) then
                if not IsEntityVisible(grabobj) then
                    SetEntityVisible(grabobj, true, false)
                end
            end
            if HasAnimEventFired(ped, GetHashKey("RELEASE_CASH_DESTROY")) then
                if IsEntityVisible(grabobj) then
                    SetEntityVisible(grabobj, false, false)
                    local grabobjCoords = GetEntityCoords(grabobj)
                    TSE('drc_truck:getMoney', grabobjCoords, grabModel, teamPlayerIds)
                end
            end
        end
        DeleteObject(grabobj)
    end)
end


local bag = nil
local GrabbingMooney = false
RegisterNetEvent('drc_truck:addMoneyTarget')
AddEventHandler('drc_truck:addMoneyTarget', function(netid, teamPlayerIds, trolleyNetIds, trollyModel)
    local playerPedId = PlayerPedId()
    local targetAdded = false
    moneyStillThere = true
    local securityTruck = NetToVeh(netid)
    Wait(1000)

    Citizen.CreateThread(function()
        while moneyStillThere do
            Wait(500)
            if securityTruck and DoesEntityExist(securityTruck) then
                if GetEntitySpeed(securityTruck) < 0.01 then
                    if not targetAdded then
                        local worldCoords = GetOffsetFromEntityInWorldCoords(securityTruck, Config.Offset.x,
                            Config.Offset.y, Config.Offset.z)
                        if Config.InteractionType == 'target' then
                            AddCircleZone('truck_grabMoney', vector3(worldCoords.x, worldCoords.y, worldCoords.z), 1.0, {
                                useZ  = true,
                                name  = 'truck_grabMoney',
                                debug = Config.Debug
                            }, {
                                options = {
                                    {
                                        action = function()
                                            TSE('drc_truck:removeTargetForTeam_GrabTrolley', teamPlayerIds)
                                            local animDict = 'mini@repair'
                                            LoadAnim(animDict)
                                            PlayAnimation(playerPedId, animDict, 'fixing_a_ped', true, 49)
                                            FreezeEntityPosition(playerPedId, true)
                                            ProgressBar(4500, locale('getting_trolley'))
                                            showNotification(locale('loot_the_carts'), 'success')
                                            FreezeEntityPosition(playerPedId, false)
                                            ClearPedTasksImmediately(playerPedId)
                                            TSE('drc_truck:removeEntityServer', trolleyNetIds, teamPlayerIds)
                                            TSE('drc_truck:triggerGetMoney', netid, teamPlayerIds, trolleyNetIds,
                                                trollyModel)
                                        end,
                                        icon = 'fas fa-cart-flatbed',
                                        distance = 1.2,
                                        label = locale('grab_trolley'),
                                        bones = { 'door_pside_r', 'door_dside_r' },
                                        
                                    }
                                },
                                distance = 1.5
                            })
                        else
                            zones['truck_grabMoney'] = lib.zones.sphere({
                                coords = vector3(worldCoords.x, worldCoords.y, worldCoords.z),
                                radius = 1.0,
                                debug = Config.Debug,
                                inside = function(self)
                                    if IsControlJustReleased(0, 38) then
                                        TSE('drc_truck:removeTargetForTeam_GrabTrolley', teamPlayerIds)
                                        local animDict = 'mini@repair'
                                        LoadAnim(animDict)
                                        PlayAnimation(playerPedId, animDict, 'fixing_a_ped', true, 49)
                                        FreezeEntityPosition(playerPedId, true)
                                        ProgressBar(4500, locale('getting_trolley'))
                                        showNotification(locale('loot_the_carts'), 'success')
                                        FreezeEntityPosition(playerPedId, false)
                                        ClearPedTasksImmediately(playerPedId)
                                        TSE('drc_truck:removeEntityServer', trolleyNetIds, teamPlayerIds)
                                        TSE('drc_truck:triggerGetMoney', netid, teamPlayerIds, trolleyNetIds,
                                            trollyModel)
                                    end
                                    if Config.InteractionType == "3dtext" then
                                        Draw3DText(self.coords,
                                            string.format("[~g~E~w~] - %s", locale('grab_trolley')))
                                    end
                                end,
                                onEnter = function()
                                    if Config.InteractionType == "textui" then
                                        TextUIShow(string.format("[E] - %s", locale('grab_trolley')))
                                    end
                                end,
                                onExit = function()
                                    if Config.InteractionType == "textui" then
                                        TextUIHide()
                                    end
                                end
                            })
                        end
                        targetAdded = true
                    end
                else
                    if targetAdded then
                        if Config.InteractionType == 'target' then
                            RemoveZone('truck_grabMoney')
                        else
                            zones['truck_grabMoney']:remove()
                        end
                        targetAdded = false
                    end
                end
            else
                if targetAdded then
                    if Config.InteractionType == 'target' then
                        RemoveZone('truck_grabMoney')
                    else
                        zones['truck_grabMoney']:remove()
                    end
                end
            end
        end
    end)
end)


RegisterNetEvent('drc_truck:getMoney')
AddEventHandler('drc_truck:getMoney', function(netid, teamPlayerIds, trolleyNetIds, trollyModel)
    local playerPedId = PlayerPedId()
    local securityTruck = NetToVeh(netid)
    local trolleyData = {
        { offset = vector3(-1.0, -5.0, 0.0), heading = -120.0 },
        { offset = vector3(2.0, -5.0, 0.0),  heading = 120.0 }
    }
    for i, data in ipairs(trolleyData) do
        loadModel(trollyModel)
        local trolleyCoords = GetOffsetFromEntityInWorldCoords(securityTruck, data.offset.x, data.offset.y, data.offset.z)
        Trolly = CreateObject(trollyModel, trolleyCoords.x, trolleyCoords.y, trolleyCoords.z, true, true, false)
        SetEntityAsMissionEntity(Trolly, true, true)

        local newHeading = GetEntityHeading(securityTruck) + data.heading
        SetEntityHeading(Trolly, newHeading)
        PlaceObjectOnGroundProperly(Trolly)

        TSE('drc_truck:GrabMoneyFromTrolly:Server', trolleyCoords, i, teamPlayerIds, trollyModel)
        Wait(100)
    end
end)


RegisterNetEvent('drc_truck:GrabMoneyFromTrolly:Target')
AddEventHandler('drc_truck:GrabMoneyFromTrolly:Target', function(trolleyCoords, i, teamPlayerIds, isPolice, trollyModel)
    local playerPedId = PlayerPedId()
    if not isPolice then
        if Config.InteractionType == 'target' then
            AddCircleZone("money_" .. tostring(i), trolleyCoords, 1.0, {
                useZ = true,
                name = "money_" .. tostring(i),
                Config.Debug
            }, {
                options = {
                    {
                        action = function()
                            TSE('drc_truck:removeTargetForTeam_Money', "money_" .. tostring(i), teamPlayerIds)
                            GrabTrolly(i, k, trollyModel, teamPlayerIds)
                        end,
                        icon = 'fas fa-money-bills',
                        distance = 1.2,
                        label = locale('grab_loot'),
                        bones = { 'door_pside_r', 'door_dside_r' },
                        
                    }
                },
                distance = 1.5
            })
        else
            zones["money_" .. tostring(i)] = lib.zones.sphere({
                coords = trolleyCoords,
                radius = 1.0,
                debug = Config.Debug,
                inside = function(self)
                    if IsControlJustReleased(0, 38) then
                        TSE('drc_truck:removeTargetForTeam_Money', "money_" .. tostring(i), teamPlayerIds)
                        GrabTrolly(i, k, trollyModel, teamPlayerIds)
                    end
                    if Config.InteractionType == "3dtext" then
                        Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('grab_loot')))
                    end
                end,
                onEnter = function()
                    if Config.InteractionType == "textui" then
                        TextUIShow(string.format("[E] - %s", locale('grab_loot')))
                    end
                end,
                onExit = function()
                    if Config.InteractionType == "textui" then
                        TextUIHide()
                    end
                end
            })
        end
    else
        if Config.InteractionType == 'target' then
            AddCircleZone("money_" .. tostring(i), trolleyCoords, 0.75, {
                useZ = true,
                name = "money_" .. tostring(i),
                Config.Debug
            }, {
                options = {
                    {
                        action = function()
                            local closestProp = getClosestProp()
                            if closestProp then
                                TriggerServerEvent('drc_truck:removeEntityServer:PoliceObject', "money_" .. tostring(i),
                                    ObjToNet(closestProp))
                            end
                        end,
                        icon = 'fas fa-money-bills',
                        distance = 1.2,
                        label = locale('remove_prop'),
                        
                    }
                },
                distance = 1.5
            })
        else
            zones["money_" .. tostring(i)] = lib.zones.sphere({
                coords = trolleyCoords,
                radius = 1.0,
                debug = Config.Debug,
                inside = function(self)
                    if IsControlJustReleased(0, 38) then
                        local closestProp = getClosestProp()
                        if closestProp then
                            TriggerServerEvent('drc_truck:removeEntityServer:PoliceObject', "money_" .. tostring(i),
                                ObjToNet(closestProp))
                        end
                    end
                    if Config.InteractionType == "3dtext" then
                        Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('remove_prop')))
                    end
                end,
                onEnter = function()
                    if Config.InteractionType == "textui" then
                        TextUIShow(string.format("[E] - %s", locale('remove_prop')))
                    end
                end,
                onExit = function()
                    if Config.InteractionType == "textui" then
                        TextUIHide()
                    end
                end
            })
        end
    end
end)


function getClosestProp()
    local playerPedId = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPedId)
    local closestProp = nil
    local closestDist = math.huge
    local propList = { "hei_prop_hei_cash_trolly_01", "hei_prop_hei_cash_trolly_03", 'ch_prop_vault_dimaondbox_01a',
        'ch_prop_gold_bar_01a' }

    for _, propName in ipairs(propList) do
        local prop = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 10.0, GetHashKey(propName),
            false, false, false)
        if prop and DoesEntityExist(prop) then
            local propCoords = GetEntityCoords(prop)
            local dist = #(playerCoords - propCoords)

            if dist < closestDist then
                closestDist = dist
                closestProp = prop
            end
        end
    end

    return closestProp
end


RegisterNetEvent('drc_truck:removeTrolleyProp')
AddEventHandler('drc_truck:removeTrolleyProp', function(targetName, closestProp)
    DeleteEntity(closestProp)
    if Config.InteractionType == 'target' then
        RemoveZone(targetName)
    else
        zones[targetName]:remove()
    end
end)



RegisterNetEvent('drc_truck:removeTarget_MoneyTroley')
AddEventHandler('drc_truck:removeTarget_MoneyTroley', function(targetName)
    moneyStillThere = false
    if Config.InteractionType == 'target' then
        RemoveZone('truck_grabMoney')
        RemoveZone(targetName)
    else
        zones['truck_grabMoney']:remove()
        if not targetName == nil then 
        zones[targetName]:remove()
        end
    end
end)

RegisterNetEvent('drc_truck:removeEntity')
AddEventHandler('drc_truck:removeEntity', function(trolleyNetIds)
    for _, trolleyNetId in ipairs(trolleyNetIds) do
        local trolleyEntity = NetworkGetEntityFromNetworkId(trolleyNetId)
        if DoesEntityExist(trolleyEntity) then
            DeleteEntity(trolleyEntity)
        end
    end
end)

RegisterNetEvent("drc_truck:PickUpProp")
AddEventHandler("drc_truck:PickUpProp", function(netId)
    if NetworkDoesEntityExistWithNetworkId(netId) then
        local entity = NetToObj(netId)
        if DoesEntityExist(entity) then
            SetEntityAlpha(entity, 0, false)
            SetEntityCollision(entity, false, true)
            DeleteEntity(entity)
        end
    end
end)

RegisterNetEvent('drc_truck:removeTarget')
AddEventHandler('drc_truck:removeTarget', function()
    bombIsBeingPlanted = false
    RemoveBlip(vehicleBlip)
    if Config.InteractionType == 'target' then
        RemoveZone('truck_addc4')
    else
        zones['truck_addc4']:remove()
    end
end)

RegisterNUICallback('minigameOutcome', function(data, cb)
    if data.outcome == 'success' then
        MinigameSuccess = true
    else
        MinigameSuccess = false
    end
    SetNuiFocus(false, false)
    DoingMinigame = false
    cb('ok')
end)

RegisterNUICallback('minigameCompleted', function()
    SetNuiFocus(false, false)
    minigameCompleted = true
end)


function LoadAnim(dict)
    if not DoesAnimDictExist(dict) then
        return false
    end

    local timeout = 2000
    while not HasAnimDictLoaded(dict) and timeout > 0 do
        RequestAnimDict(dict)
        Wait(5)
        timeout = timeout - 5
    end
    if timeout == 0 then
        DebugPrint("Loading anim dict " .. dict .. " timed out")
        return false
    else
        return true
    end
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(50)
    end
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(0)
    end
end

function PlayAnimation(ped, animDict, animName, shouldPlay, flag)
    if shouldPlay then
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, flag, 0, false, false, false)
    else
        ClearPedTasks(ped)
    end
end