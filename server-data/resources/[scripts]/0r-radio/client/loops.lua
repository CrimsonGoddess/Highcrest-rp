CreateThread(ThreadCheckAndResetRadio)
CreateThread(ThreadUpdateGameTime)

CreateThread(function()
    if Config.JammerSettings.available then
        local removingJammerObject = false
        while not CoreReady do Citizen.Wait(100) end
        if CoreName == "qb-core" or CoreName == "qbx_core" then
            while true do
                local sleep = 2000
                if next(gSpawnedJammerObjects) ~= nil then
                    if Config.JammerSettings.enable_jobs then
                        local jobName = PlayerData.job.name
                        local isOnDuty = PlayerData.job.onduty
                        if Config.JammerSettings.restricted_jobs[jobName] and isOnDuty then
                            local playerPed = PlayerPedId()
                            local playerCoords = GetEntityCoords(playerPed)
                            for k, v in pairs(gSpawnedJammerObjects) do
                                local dist = #(playerCoords - v.coords)
                                if dist <= 2.0 then
                                    sleep = 0
                                    DrawText3D(v.coords.x, v.coords.y, v.coords.z, "Remove [E]")
                                    if IsControlJustReleased(0, 38) and not removingJammerObject then
                                        removingJammerObject = true
                                        Core.Functions.Progressbar("remove_object", _t('jammer_remove_object'), 2500, false, true,
                                            {
                                                disableMovement = true,
                                                disableCarMovement = true,
                                                disableMouse = false,
                                                disableCombat = true,
                                            },
                                            {
                                                animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                anim = "plant_floor",
                                                flags = 16,
                                            },
                                            {},
                                            {},
                                            function() -- Done
                                                removingJammerObject = false
                                                StopAnimTask(PlayerPedId(),
                                                    "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                    "plant_floor", 1.0)
                                                TriggerServerEvent('0R-radio:server:DeleteJammerObject', k)
                                            end,
                                            function() -- Cancel
                                                removingJammerObject = false
                                                StopAnimTask(PlayerPedId(),
                                                    "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                    "plant_floor", 1.0)
                                                notify(_t("jammer_cancel_remove_object"), "error")
                                            end
                                        )
                                    end
                                end
                            end
                        end
                    else
                        local playerPed = PlayerPedId()
                        local playerCoords = GetEntityCoords(playerPed)
                        for k, v in pairs(gSpawnedJammerObjects) do
                            local dist = #(playerCoords - v.coords)
                            if dist <= 2.0 then
                                sleep = 0
                                DrawText3D(v.coords.x, v.coords.y, v.coords.z, "Remove [E]")
                                if IsControlJustReleased(0, 38) and not removingJammerObject then
                                    removingJammerObject = true
                                    Core.Functions.Progressbar("remove_object", _t('jammer_remove_object'), 2500, false, true,
                                        {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                        {
                                            animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                            anim = "plant_floor",
                                            flags = 16,
                                        },
                                        {},
                                        {},
                                        function() -- Done
                                            removingJammerObject = false
                                            StopAnimTask(PlayerPedId(),
                                                "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                "plant_floor", 1.0)
                                            TriggerServerEvent('0R-radio:server:DeleteJammerObject', k)
                                        end,
                                        function() -- Cancel
                                            removingJammerObject = false
                                            StopAnimTask(PlayerPedId(),
                                                "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                "plant_floor", 1.0)
                                            notify(_t("jammer_cancel_remove_object"), "error")
                                        end
                                    )
                                end
                            end
                        end
                    end
                end
                Wait(sleep)
            end
        elseif CoreName == "es_extended" then
            while true do
                local sleep = 2000
                if Config.JammerSettings.available and next(gSpawnedJammerObjects) ~= nil then
                    if Config.JammerSettings.enable_jobs then
                        local jobName = PlayerData.job.name
                        if Config.JammerSettings.restricted_jobs[jobName] then
                            local playerPed = PlayerPedId()
                            local playerCoords = GetEntityCoords(playerPed)
                            for k, v in pairs(gSpawnedJammerObjects) do
                                local dist = #(playerCoords - v.coords)
                                if dist <= 2.0 then
                                    sleep = 5
                                    --[[
                                        "If you want, you can use your own textUI plugin instead of drawText."
                                    ]]
                                    DrawText3D(v.coords.x, v.coords.y, v.coords.z, "Remove [E]")
                                    if IsControlJustReleased(0, 38) and not removingJammerObject then
                                        removingJammerObject = true
                                        Core.Progressbar(_t("jammer_remove_object"), 2500, {
                                            FreezePlayer = true,
                                            animation = {
                                                type = "anim",
                                                dict = "anim@mp_player_intmenu@key_fob@",
                                                lib = "fob_click"
                                            },
                                            onFinish = function()
                                                removingJammerObject = false
                                                StopAnimTask(PlayerPedId(),
                                                    "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                    "plant_floor", 1.0)
                                                TriggerServerEvent('0R-radio:server:DeleteJammerObject', k)
                                            end,
                                            onCancel = function()
                                                removingJammerObject = false
                                                StopAnimTask(PlayerPedId(),
                                                    "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                    "plant_floor", 1.0)
                                                notify(_t("jammer_cancel_remove_object"), "error")
                                            end
                                        })
                                    end
                                end
                            end
                        end
                    else
                        local playerPed = PlayerPedId()
                        local playerCoords = GetEntityCoords(playerPed)
                        for k, v in pairs(gSpawnedJammerObjects) do
                            local dist = #(playerCoords - v.coords)
                            if dist <= 2.0 then
                                sleep = 5
                                --[[
                                    "If you want, you can use your own textUI plugin instead of drawText."
                                ]]
                                DrawText3D(v.coords.x, v.coords.y, v.coords.z, "Remove [E]")
                                if IsControlJustReleased(0, 38) and not removingJammerObject then
                                    removingJammerObject = true
                                    Core.Progressbar(_t("jammer_remove_object"), 2500, {
                                        FreezePlayer = true,
                                        animation = {
                                            type = "anim",
                                            dict = "anim@mp_player_intmenu@key_fob@",
                                            lib = "fob_click"
                                        },
                                        onFinish = function()
                                            removingJammerObject = false
                                            StopAnimTask(PlayerPedId(),
                                                "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                "plant_floor", 1.0)
                                            TriggerServerEvent('0R-radio:server:DeleteJammerObject', k)
                                        end,
                                        onCancel = function()
                                            removingJammerObject = false
                                            StopAnimTask(PlayerPedId(),
                                                "weapons@first_person@aim_rng@generic@projectile@thermal_charge@",
                                                "plant_floor", 1.0)
                                            notify(_t("jammer_cancel_remove_object"), "error")
                                        end
                                    })
                                end
                            end
                        end
                    end
                end
                Wait(sleep)
            end
        end
    end
end)

CreateThread(function()
    if Config.JammerSettings.available then
        while true do
            Wait(1000)
            if gPlayer.hasRadio then
                local jobName = PlayerData.job.name
                local isOnDuty = PlayerData.job.onduty
                if not (Config.JammerSettings.restricted_jobs[jobName] and isOnDuty) then
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local inRange = false
                    for k, v in pairs(gSpawnedJammerObjects) do
                        local dist = #(playerCoords - v.coords)

                        if dist <= Config.JammerSettings.range then
                            inRange = true
                            break
                        end
                    end
                    gPlayer.inJammerRange = inRange
                    SendReactMessage("setJammerHud", inRange)
                else
                    gPlayer.inJammerRange = false
                    SendReactMessage("setJammerHud", false)
                end
            else
                gPlayer.inJammerRange = false
                SendReactMessage("setJammerHud", false)
            end
        end
    end
end)


CreateThread(function()
    if Config.JammerSettings.available then
        local _sendInfo = true
        while true do
            Wait(1000)
            if gPlayer.hasRadio and (gPlayer.channel > 0 or gPlayer.lastChannel > 0) then
                if gPlayer.inJammerRange then
                    if _sendInfo then
                        notify(_t("no_signal_disconnected"), "error")
                        _sendInfo = false
                    end
                    if gPlayer.channel ~= 0 then
                        gPlayer.lastChannel = gPlayer.channel
                        leaveRadio()
                    end
                else
                    if not _sendInfo then
                        notify(_t("no_signal_reconnect"), "success")
                        _sendInfo = true
                    end
                    if gPlayer.lastChannel > 0 then
                        connectToRadio(gPlayer.lastChannel)
                        gPlayer.lastChannel = 0
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        if playerSpawned then
            gPlayer.hasRadio = hasRadioItem()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if Config.CheckIsDead() and gPlayer and gPlayer.channel and gPlayer.channel > 0 then
            leaveRadio()
            notify(_t('leave_channel'), 'error')
            toggleRadio(false)
            SendReactMessage("resetRadio")
        end
    end
end)

CreateThread(function()
    --if Config.VoiceSystem == "pma-voice" then
        while true do
            if gPlayer.onRadio and gPlayer.isMenuOpen then
                TriggerServerEvent("0R-radio:server:SendPlayersInRadioChannel", gPlayer.channel)
            end
            Wait(5000)
        end
    --end
end)