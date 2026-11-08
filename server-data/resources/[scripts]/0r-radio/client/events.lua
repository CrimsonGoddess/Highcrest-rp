playerSpawned = false
PlayerData = {}
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    local startTime = GetGameTimer()
    while not CoreReady do 
        Citizen.Wait(100)
        if GetGameTimer() - startTime > 5000 then
            break
        end
    end
    while not playerSpawned do 
        Citizen.Wait(100)
        if GetGameTimer() - startTime > 5000 then
            break
        end
    end
    PlayerData = GetPlayerData()
    gPlayer.hasRadio = hasRadioItem()
    leaveRadio()
    LocalPlayer.state.isLoggedIn = true
    print("Done.")
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    leaveRadio()
    resetPlayer()
end)

AddEventHandler("esx:onPlayerDeath", function()
    gPlayer.isDead = true
    if gPlayer.onRadio then
        gPlayer.lastChannel = 0
        leaveRadio()
        notify(_t("leave_channel"), "error")
        toggleRadio(false)
        SendReactMessage("resetRadio")
    end
end)

AddEventHandler("esx:onPlayerSpawn", function()
    gPlayer.isDead = false
    Wait(1000)
    PlayerData =  GetPlayerData()
    gPlayer.hasRadioItem = hasRadioItem()
    playerSpawned = true
    print("ESX player spawned.")
end)

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function()
    gPlayer.isDead = false
end)

RegisterNetEvent("esx:playerLoaded", function(xPlayer)
    Wait(1000)
    PlayerData = xPlayer
    gPlayer.hasRadioItem = hasRadioItem()
    playerSpawned = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if CoreName == "qb-core" then
        PlayerData = Core.Functions.GetPlayerData()
    else
        PlayerData = Core:GetPlayerData()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

AddEventHandler("playerSpawned", function()
    Wait(1000)
    PlayerData = GetPlayerData()
    gPlayer.hasRadioItem = hasRadioItem()
    playerSpawned = true
    print("ESX player spawned.")
end)

RegisterNetEvent("0R-radio:client:playerUnLoaded", function()
    Wait(1000)
    resetPlayer()
end)

RegisterNetEvent("esx:setJob", function(job, lastJob)
    PlayerData.job.name = job.name
end)

RegisterNetEvent('0R-radio:use-radio', function()
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        if not Config.CheckIsDead() then
            toggleRadio(not gPlayer.isMenuOpen)
            Wait(100)
            if not gHasBootAnimation then
                gHasBootAnimation = true
            end
        end
    elseif CoreName == "es_extended" then
        if not Config.CheckIsDead() then
            if not playerSpawned then
                playerSpawned = true
            end
            toggleRadio(not gPlayer.isMenuOpen)
            Wait(100)
            if not gHasBootAnimation then
                gHasBootAnimation = true
            end
        end
    end
end)

RegisterNetEvent('0R-radio:use-jammer', function(item)
    if CoreName == "qb-core" then
        if Config.JammerSettings.enable_jobs then
            local jobName = PlayerData.job.name
            local isOnDuty = PlayerData.job.onduty
            if Config.JammerSettings.restricted_jobs[jobName] and isOnDuty then
                local closestDistance, _ = checkDistanceForJammers(gSpawnedJammerObjects)
                if closestDistance == -1 then
                    Core.Functions.Progressbar("spawn_object", _t("jammer_place_object"), 2500, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "anim@narcotics@trash",
                            anim = "drop_front",
                            flags = 16,
                        }, {}, {},
                        function() -- Done
                            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                            TriggerServerEvent('0R-radio:server:SpawnJammerObject', Config.JammerSettings.object)
                        end,
                        function() -- Cancel
                            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                            notify(_t("jammer_cancel_place_object"), "error")
                        end
                    )
                else
                    notify(_t("jammer_min_distance_error"), "error")
                end
            else
                notify(_t('jammer_restricted_jobs'), 'error')
            end
        else
            local closestDistance, _ = checkDistanceForJammers(gSpawnedJammerObjects)
            if closestDistance == -1 then
                Core.Functions.Progressbar("spawn_object", _t("jammer_place_object"), 2500, false, true, {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = "anim@narcotics@trash",
                        anim = "drop_front",
                        flags = 16,
                    }, {}, {},
                    function() -- Done
                        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                        TriggerServerEvent('0R-radio:server:SpawnJammerObject', Config.JammerSettings.object)
                    end,
                    function() -- Cancel
                        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                        notify(_t("jammer_cancel_place_object"), "error")
                    end
                )
            else
                notify(_t("jammer_min_distance_error"), "error")
            end
        end
    elseif CoreName == "qbx_core" then
        if Config.JammerSettings.enable_jobs then
            local jobName = PlayerData.job.name
            local isOnDuty = PlayerData.job.onduty
            if Config.JammerSettings.restricted_jobs[jobName] and isOnDuty then
                local closestDistance, _ = checkDistanceForJammers(gSpawnedJammerObjects)
                if closestDistance == -1 then
                    if lib.progressBar({
                        duration = 2500,
                        label = _t("jammer_place_object"),
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                        },
                        anim = {
                            dict = 'anim@narcotics@trash',
                            clip = 'drop_front'
                        },
                        prop = {},
                        disable = {
                            move = true,
                            car = true,
                            combat = true,
                            mouse = false
                        }
                    }) then
                        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                        TriggerServerEvent('0R-radio:server:SpawnJammerObject', Config.JammerSettings.object)
                    else
                        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                        notify(_t("jammer_cancel_place_object"), "error")
                    end
                else
                    notify(_t("jammer_min_distance_error"), "error")
                end
            else
                notify(_t('jammer_restricted_jobs'), 'error')
            end
        else
            local closestDistance, _ = checkDistanceForJammers(gSpawnedJammerObjects)
            if closestDistance == -1 then
                if lib.progressBar({
                    duration = 2500,
                    label = _t("jammer_place_object"),
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                    anim = {
                        dict = 'anim@narcotics@trash',
                        clip = 'drop_front'
                    },
                    prop = {},
                    disable = {
                        move = true,
                        car = true,
                        combat = true,
                        mouse = false
                    }
                }) then
                    StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                    TriggerServerEvent('0R-radio:server:SpawnJammerObject', Config.JammerSettings.object)
                else
                    StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                    notify(_t("jammer_cancel_place_object"), "error")
                end
            else
                notify(_t("jammer_min_distance_error"), "error")
            end
        end
    elseif CoreName == "es_extended" then
        if Config.JammerSettings.enable_jobs then
            local jobName = PlayerData.job.name
            if Config.JammerSettings.restricted_jobs[jobName] then
                local closestDistance, _ = checkDistanceForJammers(gSpawnedJammerObjects)
                if closestDistance == -1 then
                    Core.Progressbar(_t("jammer_place_object"), 2500, {
                        FreezePlayer = true,
                        animation = {
                            type = "anim",
                            dict = "anim@mp_player_intmenu@key_fob@",
                            lib = "fob_click"
                        },
                        onFinish = function()
                            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                            TriggerServerEvent("0R-radio:server:SpawnJammerObject", Config.JammerSettings.object)
                        end,
                        onCancel = function()
                            StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                            notify(_t("jammer_cancel_place_object"), "error")
                        end
                    })
                else
                    notify(_t("jammer_min_distance_error"), "error")
                end
            else
                notify(_t("jammer_restricted_jobs"), "error")
            end
        else
            local closestDistance, _ = checkDistanceForJammers(gSpawnedJammerObjects)
            if closestDistance == -1 then
                Core.Progressbar(_t("jammer_place_object"), 2500, {
                    FreezePlayer = true,
                    animation = {
                        type = "anim",
                        dict = "anim@mp_player_intmenu@key_fob@",
                        lib = "fob_click"
                    },
                    onFinish = function()
                        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                        TriggerServerEvent("0R-radio:server:SpawnJammerObject", Config.JammerSettings.object)
                    end,
                    onCancel = function()
                        StopAnimTask(PlayerPedId(), "anim@narcotics@trash", "drop_front", 1.0)
                        notify(_t("jammer_cancel_place_object"), "error")
                    end
                })
            else
                notify(_t("jammer_min_distance_error"), "error")
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if CoreName == "qb-core" then
        PlayerData = Core.Functions.GetPlayerData()
    else
        PlayerData = Core:GetPlayerData()
    end
    gPlayer.hasRadio = hasRadioItem()
    playerSpawned = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    leaveRadio()
    resetPlayer()
    SendReactMessage("resetRadio")
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    gPlayer.hasRadio = hasRadioItem()
    if not gPlayer.hasRadio then
        leaveRadio()
        resetPlayer()
        SendReactMessage("resetRadio")
        if gPlayer.onRadio then
            notify(_t('leave_channel'), 'error')
        end
    end
end)

RegisterNetEvent('0R-radio:client:SpawnJammerObject', function(objectId, model)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local x, y, z = table.unpack(coords + forward * 2)
    local spawnedObj = CreateObject(model, x, y, z, true, false, false)
    PlaceObjectOnGroundProperly(spawnedObj)
    SetEntityHeading(spawnedObj, heading)
    SetEntityInvincible(spawnedObj, true)
    FreezeEntityPosition(spawnedObj, true)
    local spawnedObjData = {
        object = spawnedObj,
        coords = vector3(x, y, z - 0.3),
    }
    TriggerServerEvent('0R-radio:server:SetJammerObject', objectId, spawnedObjData)
end)

RegisterNetEvent('0R-radio:client:SetJammerObjects', function(data)
    gSpawnedJammerObjects = data
end)

RegisterNetEvent('0R-radio:client:RemoveJammerObject', function(objectId)
    local obj = gSpawnedJammerObjects[objectId]
    if obj then
        SetEntityInvincible(obj, false)
        FreezeEntityPosition(obj, false)
        NetworkRequestControlOfEntity(obj.object)
        DeleteObject(obj.object)
        gSpawnedJammerObjects[objectId] = nil
    end
end)

RegisterNetEvent('0R-radio:client:GetPlayersInRadioChannel', function(talking)
    TriggerCallback('0R-radio:server:GetPlayersInRadioChannel', function(playerlist)
        if playerlist then
            if Config.VoiceSystem == 'pma-voice' then
                for _, v in ipairs(playerlist) do
                    v.isMuted = checkPlayerMute(v.source)
                end
            elseif Config.VoiceSystem == "saltychat" then
                for _, player in ipairs(playerlist) do
                    if talking and talking[player.source] and talking[player.source] ~= nil then
                        player.isTalking = talking[player.source]
                    end
                end
            end

            SendReactMessage("setPlayersInRadioChannel", playerlist)
        else
            SendReactMessage("setPlayersInRadioChannel", {})
        end
    end, gPlayer.channel)
end)

RegisterCommand("radio", function()
    if gPlayer.hasRadio and (not PlayerData.metadata.isdead and not PlayerData.metadata.inlaststand) then
        toggleRadio(not gPlayer.isMenuOpen)
    end
end)

RegisterKeyMapping("radio", "Toggle radio item", "keyboard", Config.RadioToggleKey)

if Config.VoiceSystem == "saltychat" then
    AddEventHandler("SaltyChat_TalkStateChanged", function(talking)
        if not gPlayer.onRadio then
            return
        end

        TriggerServerEvent("0R-radio:server:SendPlayersInRadioChannel", gPlayer.channel, talking)
    end)
end
