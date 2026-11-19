local robbedLocal = {}        -- fallback per-client memory
local lastAttempt = 0
local isRobbing = false

-- Relationship group for hostile NPCs
local THUG_GROUP = nil
CreateThread(function()
    local _, grp = AddRelationshipGroup('NPCROB_THUG')
    THUG_GROUP = grp
end)

local function now()
    return GetGameTimer()
end

local function notify(msg, ntype)
    lib.notify({
        title = "Robbery",
        description = msg,
        type = ntype or "inform"
    })
end

local function isPlayerAimingWithGun()
    if not IsPlayerFreeAiming(PlayerId()) then return false end
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    if weapon == `WEAPON_UNARMED` or weapon == 0 then return false end
    return true
end

local function getAimedEntity()
    local _, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if ent and ent ~= 0 and DoesEntityExist(ent) then
        return ent
    end
    return nil
end

local function isValidVictim(ped)
    if not ped or ped == 0 then return false end
    if not DoesEntityExist(ped) then return false end
    if not IsEntityAPed(ped) then return false end
    if IsPedAPlayer(ped) then return false end
    if IsPedDeadOrDying(ped, true) then return false end
    if IsPedInAnyVehicle(ped, false) then return false end

    -- 🚫 Block animals
    if Config.PedBlacklist and Config.PedBlacklist.blockAnimals then
        local pedType = GetPedType(ped)
        if pedType == 28 then -- Animal
            return false
        end
    end

    -- 🚫 Block blacklisted models
    if Config.PedBlacklist and Config.PedBlacklist.models then
        local model = GetEntityModel(ped)
        for _, blacklisted in ipairs(Config.PedBlacklist.models) do
            if model == blacklisted then
                return false
            end
        end
    end

    local myPed = PlayerPedId()
    local dist = #(GetEntityCoords(myPed) - GetEntityCoords(ped))
    if dist > (Config.MaxRobDistance or 3.0) then return false end

    -- Block police/swat
    if Config.BlockPolicePeds then
        local pedType = GetPedType(ped)
        if pedType == 6 or pedType == 27 then
            return false
        end
    end

    -- Already robbed checks
    local entState = Entity(ped).state
    if entState and entState.robbed == true then
        return false
    end

    if robbedLocal[ped] then
        return false
    end

    return true
end

local function setPedRobbed(ped)
    robbedLocal[ped] = true

    if not NetworkGetEntityIsNetworked(ped) then
        NetworkRegisterEntityAsNetworked(ped)
    end

    pcall(function()
        Entity(ped).state:set("robbed", true, true)
    end)
end

local function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(10) end
    end
end

local function handsUp(ped)
    loadAnimDict("missminuteman_1ig_2")
    TaskPlayAnim(ped, "missminuteman_1ig_2", "handsup_base", 8.0, -8.0, -1, 49, 0, false, false, false)
end

local function stopHandsUp(ped)
    ClearPedTasks(ped)
end

local function dispatchAlert(coords)
    if not Config.PSDispatch or not Config.PSDispatch.enabled then return end
    if not exports["ps-dispatch"] then return end

    exports["ps-dispatch"]:CustomAlert({
        coords = coords,
        message = Config.PSDispatch.description,
        dispatchCode = Config.PSDispatch.code,
        description = Config.PSDispatch.title,
        radius = Config.PSDispatch.radius,
        sprite = Config.PSDispatch.sprite,
        color = Config.PSDispatch.color,
        scale = Config.PSDispatch.scale,
        length = Config.PSDispatch.length,
    })
end

local function chooseOutcome()
    local r = math.random()
    local comply = Config.ChanceComply or 0.65
    local run = comply + (Config.ChanceRun or 0.20)
    local fight = run + (Config.ChanceFight or 0.15)

    if r <= comply then return "comply" end
    if r <= run then return "run" end
    if r <= fight then return "fight" end
    return "comply"
end

-- Hard force a civilian to SHOOT instead of panic flee
local function forcePedFight(ped, targetPed)
    ClearPedTasksImmediately(ped)

    -- prevent ambient AI overriding our task
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedKeepTask(ped, true)

    -- reduce flee / panic
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)   -- Always fight
    SetPedCombatAttributes(ped, 46, true)   -- Can fight armed peds
    SetPedCombatAbility(ped, 2)             -- pro
    SetPedCombatMovement(ped, 2)            -- offensive
    SetPedCombatRange(ped, 2)               -- far
    SetPedAccuracy(ped, math.random(20, 45))
    SetPedAlertness(ped, 3)
    SetPedSeeingRange(ped, 80.0)
    SetPedHearingRange(ped, 80.0)

    -- relationship hate
    local playerGroup = GetPedRelationshipGroupHash(targetPed)
    if THUG_GROUP then
        SetPedRelationshipGroupHash(ped, THUG_GROUP)
        SetRelationshipBetweenGroups(5, THUG_GROUP, playerGroup)
        SetRelationshipBetweenGroups(5, playerGroup, THUG_GROUP)
    end
    SetPedAsEnemy(ped, true)

    -- Force aim + shoot task (more reliable than TaskCombatPed for civilians)
    TaskTurnPedToFaceEntity(ped, targetPed, 800)
    Wait(200)
    TaskAimGunAtEntity(ped, targetPed, 1500, true)
    Wait(200)
    TaskShootAtEntity(ped, targetPed, 20000, `FIRING_PATTERN_FULL_AUTO`)
end

local function startRobbery(ped)
    if isRobbing then return end

    -- NOTE: player cooldown is applied ONLY on comply path now (so fight/run doesn't lock you out)
    local t = now()
    if (t - lastAttempt) < ((Config.PlayerCooldown or 10) * 1000) then
        notify("Slow down. You just robbed someone.", "error")
        return
    end

    isRobbing = true

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(ped)

    -- alert police as soon as you initiate
    dispatchAlert(coords)

    -- stabilize ped behavior
    SetPedDropsWeaponsWhenDead(ped, true)

    local outcome = chooseOutcome()

    if outcome == "run" then
        notify("They bolted!", "inform")
        stopHandsUp(ped)
        TaskSmartFleePed(ped, playerPed, 80.0, -1, false, false)
        isRobbing = false
        return
    end

    if outcome == "fight" then
        notify("They pulled a gun!", "error")
        stopHandsUp(ped)

        local weapon = Config.NPCWeapons[math.random(1, #Config.NPCWeapons)]
        GiveWeaponToPed(ped, weapon, 250, false, true)
        SetCurrentPedWeapon(ped, weapon, true)

        forcePedFight(ped, playerPed)

        -- release AI later so they don't stay "frozen in combat forever"
        SetTimeout(20000, function()
            if DoesEntityExist(ped) then
                SetBlockingOfNonTemporaryEvents(ped, false)
                SetPedKeepTask(ped, false)
            end
        end)

        isRobbing = false
        return
    end

    -- ✅ COMPLY PATH: only here do we mark ped robbed + apply cooldown
    setPedRobbed(ped)
    lastAttempt = now()

    SetBlockingOfNonTemporaryEvents(ped, true)

    handsUp(ped)
    TaskTurnPedToFaceEntity(ped, playerPed, 1000)
    FreezeEntityPosition(ped, true)

    local ok = lib.progressBar({
        duration = (Config.RobTime or 8) * 1000,
        label = "Robbing civilian...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = false,
        }
    })

    FreezeEntityPosition(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, false)

    if not ok then
        notify("You stopped the robbery.", "error")

        -- If you cancel, you might want them to be robbable again:
        -- (comment this OUT if you want cancel to still count as robbed)
        robbedLocal[ped] = nil
        pcall(function()
            Entity(ped).state:set("robbed", false, true)
        end)

        if math.random() < 0.50 then
            TaskSmartFleePed(ped, playerPed, 80.0, -1, false, false)
        end

        isRobbing = false
        return
    end

    if Config.RequireGunAim and not isPlayerAimingWithGun() then
        notify("You lowered your weapon.", "error")
        isRobbing = false
        return
    end

    TriggerServerEvent("et_npcrobbery:server:reward")
    notify("You got something.", "success")

    stopHandsUp(ped)
    TaskSmartFleePed(ped, playerPed, 80.0, 15000, false, false)

    isRobbing = false
end

-- TextUI loop that won't stomp other scripts
CreateThread(function()
    math.randomseed(GetGameTimer())

    local robberyTextUI = false

    while true do
        Wait(0)

        local shouldShow = false

        if not (Config.RequireGunAim and not isPlayerAimingWithGun()) then
            local ent = getAimedEntity()

            if ent and isValidVictim(ent) then
                shouldShow = true

                if Config.ShowHelpText then
                    -- If ox_lib supports isTextUIOpen, don't overwrite others.
                    if (not lib.isTextUIOpen) or (not lib.isTextUIOpen()) or robberyTextUI then
                        if not robberyTextUI then
                            lib.showTextUI(Config.HelpText or "[E] Rob civilian")
                            robberyTextUI = true
                        end
                    end
                end

                if IsControlJustPressed(0, 38) then -- E
                    if robberyTextUI then
                        lib.hideTextUI()
                        robberyTextUI = false
                    end
                    startRobbery(ent)
                end
            end
        end

        if Config.ShowHelpText and robberyTextUI and not shouldShow then
            lib.hideTextUI()
            robberyTextUI = false
        end
    end
end)
