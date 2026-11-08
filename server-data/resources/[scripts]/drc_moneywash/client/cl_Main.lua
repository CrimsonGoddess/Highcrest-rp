local currentHouse = nil
local housesData = {}
local doingAction = false
local carrying = false
local Lasers = {}
local HouseHacked = {}
local leaving = false
local entering = false
local tabletObj = nil
local tabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local tabletAnim = "base"
local tabletProp = `prop_cs_tablet`
local tabletBone = 60309
local tabletOffset = vector3(0.03, 0.002, -0.0)
local tabletRot = vector3(10.0, 160.0, 0.0)
local Hacking = false
local Lockpicking = false
local hittedbylaser = false

local cameraCanAccess = false
local cameraLeft = true
local screenEffectActive = false
local cameraScaleform = nil
local laundry = false
local Spheres = {}
local zonesmaked = {}

--DEV
--SetTimeout(1500, function()
    -- DevWarehouse()
--end)

CreateThread(function()
    while true do
        local sleep = 5000
        if currentHouse then
            while entering do
                Wait(1000)
            end
            sleep = 1000
            local playerPosition = GetEntityCoords(PlayerPedId())
           if #(playerPosition - Config.Warehouses[currentHouse].MoneyWash.InsidePositions.Exit.coords.xyz) > 40.0 and not leaving then
                local house = currentHouse 
                TriggerServerEvent("drc_moneywash_instance:quitInstance")
                for b, g in pairs(Lasers) do
                    g.setActive(false)
                    g.setVisible(false)
                end
                TriggerServerEvent("drc_moneywash:leaveHouse", house)
                Wait(1000)
                currentHouse = nil
                Lights(house, false)
                leaving = false
                OnHouseLeave()
                if Config.InteractionType == "3dtext" or Config.InteractionType == "textui" then



                elseif Config.InteractionType == 'target' then
                    target = Target()
                    zonesmaked = {}
                    target:RemoveZone("drc_camera" .. house)
                    target:RemoveZone("drc_dry_collect" .. house)
                    target:RemoveZone("drc_dry_start" .. house)
                    target:RemoveZone("drc_dry_load" .. house)
                    for place, v in pairs(Config.Warehouses[house].MoneyWash.InsidePositions) do
                        target:RemoveZone("drc_moneywash_robberyplace" .. place .. house)
                    end
                    for k, v in pairs(Config.Warehouses[house].MoneyWash.HackDevice) do
                        target:RemoveZone("drc_moneywash_robberyplace" .. k)
                    end
                        target:RemoveZone("drc_manage" .. house)
                    for place, v in pairs(Config.Warehouses[house].MoneyWash.Wash) do
                        target:RemoveZone("drc_moneywash_wash" .. place .. house)
                    end
                    for place, v in pairs(Config.Warehouses[house].MoneyWash.Cut) do
                        target:RemoveZone("drc_moneywash_cut" .. place .. house)
                    end
                    for place, v in pairs(Config.Warehouses[house].MoneyWash.Count) do
                        target:RemoveZone("drc_moneywash_count" .. place .. house)
                    end
                    for k, v in pairs(Config.Warehouses[house].MoneyWash.Stashes) do
                        target:RemoveZone(house .. " stash " .. k)
                    end
                    for k, v in pairs(Config.Warehouses[house].MoneyWash.CloakRoom) do
                        target:RemoveZone(house .. " cloak " .. k)
                    end

                end
            end
        end
        Wait(sleep) 
    end
end)


-- CAMERA
Camera = function(house)
    local camera = Config.Warehouses[house].Camera
    local x = camera.pos.x
    local y = camera.pos.y
    local z = camera.pos.z

    if not cameraCanAccess then
        -- Enable camera

        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, x, y, z + 1.0)
        SetCamRot(cam, camera.rot.x, camera.rot.y, camera.rot.z, 2)
        SetFocusArea(x, y, z, 0.0, 0.0, 0.0)
        SetCamFov(cam, camera.fov)
        RenderScriptCams(true, false, 0, true, true)
        cameraLeft = false
        cameraCanAccess = true
        TextUIShow(locale("ExitCamera"))
        Notify("success", locale("success"), locale("cctvON"))

        -- Load the Scaleform movie
        cameraScaleform = RequestScaleformMovie("TRAFFIC_CAM")
        while not HasScaleformMovieLoaded(cameraScaleform) do
            Wait(10)
        end

        -- Play the Scaleform movie
        PushScaleformMovieFunction(cameraScaleform, "PLAY_CAM_MOVIE")
        PopScaleformMovieFunctionVoid()
        lastinstance = getPlayerInstance()
        TriggerServerEvent("drc_moneywash_instance:quitInstance")
    else
        TriggerServerEvent("drc_moneywash_instance:joinInstance", "rob_house_" .. house)
        TriggerServerEvent("drc_moneywash:joinHouse", house)
        -- Disable camera
        RenderScriptCams(false, true, 0, true, true)

        SetTimeout(5000, function()
            cameraCanAccess = false
        end)
        Notify("success", locale("success"), locale("cctvOFF"))

        -- Release the Scaleform movie
        SetScaleformMovieAsNoLongerNeeded(cameraScaleform)
        cameraScaleform = nil
    end
end

local cameraProps = {}
CreateThread(function()
    while true do
        local sleep = 15000

        local playerPos = GetEntityCoords(PlayerPedId())
        for _, warehouse in pairs(Config.Warehouses) do
            local cameraPos = warehouse.Camera.PropPos
            local distance = #(playerPos - cameraPos)

            if distance <= 50.0 then
                sleep = 500
                if not DoesEntityExist(cameraProps[warehouse]) then
                    local propModel = GetHashKey("prop_cctv_cam_01a")
                    RequestModel(propModel)
                    while not HasModelLoaded(propModel) do
                        Wait(10)
                    end

                    local propEntity = CreateObject(propModel, cameraPos.x, cameraPos.y, cameraPos.z, false, false, false)
                    SetEntityRotation(propEntity, warehouse.Camera.PropRot.x, warehouse.Camera.PropRot.y,
                        warehouse.Camera.PropRot.z, 2, true)
                    SetModelAsNoLongerNeeded(propModel)

                    cameraProps[warehouse] = propEntity
                end
            else
                if DoesEntityExist(cameraProps[warehouse]) then
                    DeleteEntity(cameraProps[warehouse])
                    cameraProps[warehouse] = nil
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("drc_moneywash:removekeys")
AddEventHandler("drc_moneywash:removekeys", function(data)
    lib.callback('drc_moneywash:removekeys', false, function(value)
        if value then
            dict = "anim@heists@prison_heiststation@cop_reactions"
            clip = "cop_b_idle"
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("removingaccess"))
            ClearPedTasks(cache.ped)
        else
        end
    end, data.house, data.value, data.name)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent("drc_moneywash_instance:quitInstance")
        for _, propEntity in pairs(cameraProps) do
            if DoesEntityExist(propEntity) then
                DeleteEntity(propEntity)
            end
        end
    end
end)


CreateThread(function()
    while true do
        local sleep = 500
        if not cameraLeft then
            sleep = 0
            -- Handle camera controls
            DisableControlAction(0, 1, true)   -- LookLeftRight
            DisableControlAction(0, 2, true)   -- LookUpDown
            DisableControlAction(0, 24, true)  -- Attack
            DisableControlAction(0, 257, true) -- Attack2
            DisableControlAction(0, 25, true)  -- Aim
            DisableControlAction(0, 263, true) -- MeleeAttack1
            DisableControlAction(0, 32, true)  -- W
            DisableControlAction(0, 34, true)  -- A
            DisableControlAction(0, 33, true)  -- S
            DisableControlAction(0, 35, true)  -- D
            DisableControlAction(0, 29, true)  -- LeftShift
            DisableControlAction(0, 36, true)  -- LeftCtrl
            DisableControlAction(0, 22, true)  -- Jump
            DisableControlAction(0, 44, true)  -- Cover
            DisableControlAction(0, 37, true)  -- SelectWeapon
            DisableControlAction(0, 59, true)  -- RadioWheel
            DisableControlAction(0, 60, true)  -- RadioWheelUpDown

            -- Draw Scaleform movie
            DrawScaleformMovieFullscreen(cameraScaleform, 255, 255, 255, 255)

            -- Show exit control text UI

            -- Check if exit control is pressed
            if IsControlJustReleased(0, 51) then -- "E" key
                ClearPedTasks(cache.ped)
                CameraExit()
                TriggerServerEvent("drc_moneywash_instance:joinInstance", "rob_house_" .. currentHouse)
                TriggerServerEvent("drc_moneywash:joinHouse", currentHouse)
            end
        end
        Wait(sleep)
    end
end)

CameraExit = function()
    if cameraCanAccess then
        cameraLeft = true
        SetFocusEntity(PlayerPedId())
        DestroyCam(cam, false)
        RenderScriptCams(false, true, 0, true, true)
        SetTimeout(5000, function()
            cameraCanAccess = false
        end)
        Notify("success", locale("success"), locale("cctvOFF"))

        -- Release the Scaleform movie
        if cameraScaleform ~= nil then
            SetScaleformMovieAsNoLongerNeeded(cameraScaleform)
            cameraScaleform = nil
        end

        -- Hide the exit text UI
        TextUIHide()
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Disable camera and clean up resources
        CameraExit()

        -- Clean up screen effects
        if screenEffectActive then
            screenEffectActive = false
            ClearTimecycleModifier()
            SetNightvision(false)
            SetSeethrough(false)
        end
    end
end)


local ownedHouses = {}
local acessHouses = {}


RegisterNetEvent("drc_moneywash:setowner")
AddEventHandler("drc_moneywash:setowner", function(houses)
    for _, house in ipairs(houses) do
        table.insert(ownedHouses, house)
    end
end)

RegisterNetEvent("drc_moneywash:setaccess")
AddEventHandler("drc_moneywash:setaccess", function(houses)
    for _, house in ipairs(houses) do
        table.insert(acessHouses, house)
    end
end)

function CheckOwnership(house)
    for _, ownedHouse in ipairs(ownedHouses) do
        if ownedHouse == house then
            return true
        end
    end
    return false
end

function RemoveOwnership(house)
    for i = #ownedHouse, 1, -1 do
        if ownedHouse[i] == house then
            table.remove(ownedHouses, i)
            break
        end
    end
    for i = #acessHouses, 1, -1 do
        if accessHouse[i] == house then
            table.remove(accessHouse, i)
            break
        end
    end
end


function CheckAcess(house)
    for _, accessHouse in ipairs(acessHouses) do
        if accessHouse == house then
            return true
        end
    end
    return false
end

RegisterNetEvent("drc_moneywash:reset")
AddEventHandler("drc_moneywash:reset", function(house)
    housesData[house] = nil
    Lasers[house] = nil
    HouseHacked[house] = nil
end)

RegisterNetEvent("drc_moneywash:sync")
AddEventHandler("drc_moneywash:sync", function(data, requestedInstance)
    housesData = data
    if requestedInstance then
        lib.callback('drc_moneywash:getident', false, function(value)
            local char = value
            for house, houseData in pairs(housesData) do
                if houseData.players then
                    for _, player in each(houseData.players) do
                        if player == char then
                            teleport(Config.Warehouses[house].Coords.xyz)
                            TriggerServerEvent("drc_moneywash:leaveHouse", house)
                            break
                        end
                    end
                end
            end
        end)
    end
end)

if Config.InteractionType == 'textui' or Config.InteractionType == "3dtext" then
    for house, data in pairs(Config.Warehouses) do
        lib.zones.sphere({
            coords = data.Coords.xyz,
            radius = 1,
            debug = Config.Debug,
            inside = function(self)
                if IsControlJustReleased(0, 38) and not doingAction then
                    if Config.Context == "ox_lib" then
                        lib.registerContext({
                            id = 'warehouse:interact:menu:01',
                            title = locale('doors'),
                            options = {
                                {
                                    title = locale('enter_label'),
                                    icon = "fas fa-right-to-bracket",
                                    disabled = not (housesData[house] and not housesData[house].locked),
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 20, coords = data.Coords.xyz }
                                },
                                {
                                    title = locale('unlock_label'),
                                    icon = "fas fa-door-open",
                                    disabled = not ((CheckOwnership(house) or CheckAcess(house)) and (housesData[house] and housesData[house].locked) or (CheckOwnership(house) or CheckAcess(house)) and housesData[house] == nil),
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 18, coords = data.Coords.xyz }
                                },
                                {
                                    title = locale('lock_label'),
                                    icon = "fas fa-lock",
                                    disabled = not ((CheckOwnership(house) or CheckAcess(house)) and housesData[house] and not housesData[house].locked),
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 19, coords = data.Coords.xyz }
                                },
                                {
                                    title = locale('knock_label'),
                                    icon = "fas fa-door-closed",
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 17, coords = data.Coords.xyz }
                                },
                                {
                                    title = locale('breakdoor_label'),
                                    icon = "fas fa-house",
                                    disabled = not (housesData and not enterable(house) and not (CheckOwnership(house) or CheckAcess(house))),
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 16, coords = data.Coords.xyz }
                                },
                            }
                        })
                        lib.showContext('warehouse:interact:menu:01')
                    else
                        exports['qb-menu']:openMenu({
                            {
                                isMenuHeader = true,
                                header = locale("doors")
                            },
                            {
                                header = locale('enter_label'),
                                arrow = false,
                                txt = "",
                                disabled = not (housesData[house] and not housesData[house].locked),
                                params = {
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 20, coords = data.Coords.xyz }
                                }
                            },
                            {
                                header = locale('unlock_label'),
                                arrow = false,
                                txt = "",
                                disabled = not (((CheckOwnership(house) or CheckAcess(house)) and (housesData[house] and housesData[house].locked)) or ((CheckOwnership(house) or CheckAcess(house)) and housesData[house] == nil)),
                                params = {
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 18, coords = data.Coords.xyz }
                                }
                            },
                            {
                                header = locale('lock_label'),
                                arrow = false,
                                txt = "",
                                disabled = not ((CheckOwnership(house) or CheckAcess(house)) and housesData[house] and not housesData[house].locked),
                                params = {
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 19, coords = data.Coords.xyz }
                                }
                            },
                            {
                                header = locale('knock_label'),
                                arrow = false,
                                txt = "",
                                params = {
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 17, coords = data.Coords.xyz }
                                }
                            },
                            {
                                header = locale('breakdoor_label'),
                                arrow = false,
                                txt = "",
                                disabled = not (housesData and not enterable(house) and not (CheckOwnership(house) or CheckAcess(house))),
                                params = {
                                    event = 'warehouse:interact:menu:buttons',
                                    args = { house = house, id = 16, coords = data.Coords.xyz }
                                }
                            },
                        })
                    end
                end

                if Config.InteractionType == "3dtext" then
                    Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale("doors")))
                end
            end,
            onEnter = function()
                if Config.InteractionType == "textui" then
                    TextUIShow("[E] - " .. locale('doors'))
                end
            end,
            onExit = function()
                if Config.InteractionType == "textui" then
                    TextUIHide()
                end
            end
        })
    end
elseif Config.InteractionType == 'target' then
    for house, data in pairs(Config.Warehouses) do
        SetTimeout(1000, function()
            target = Target()
            target:AddCircleZone("drc_moneywash_place" .. house, data.Coords.xyz, 1.5, {
                name = "drc_moneywash_place" .. house,
                debugPoly = Config.Debug,
            }, {
                options = {
                    {
                        icon = 'fas fa-house',
                        label = locale('breakdoor_label'),
                        action = function(entity)
                            enterHouse(house, true)
                        end,
                        canInteract = function(entity, distance, data)
                            return (housesData and not enterable(house) and not (CheckOwnership(house) or CheckAcess(house)))
                        end
                    },
                    {
                        icon = 'fas fa-door-closed',
                        label = locale('knock_label'),
                        action = function(entity)
                            if not doingAction then
                                doingAction = true
                                dict = "timetable@jimmy@doorknock@"
                                clip = "knockdoor_idle"
                                local coords = data.Coords
                                TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                SetTimeout(1100, function()
                                    FreezeEntityPosition(cache.ped, true)
                                end)
                                RequestAnimDict(dict)
                                while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                ProgressBar(2500, locale("knocking"))
                                FreezeEntityPosition(cache.ped, false)
                                KnockOnDoors(house)
                                ClearPedTasks(cache.ped)
                                doingAction = false
                            end
                        end,
                        canInteract = function(entity, distance, data)
                            return true -- (not CheckOwnership(house))
                        end
                    },
                    {
                        icon = 'fas fa-door-open',
                        label = locale('unlock_label'),
                        action = function(entity)
                            if not doingAction then
                                doingAction = true
                                dict = "mp_arresting"
                                clip = "a_uncuff"
                                local coords = data.Coords
                                TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                SetTimeout(1100, function()
                                    FreezeEntityPosition(cache.ped, true)
                                end)
                                RequestAnimDict(dict)
                                while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                ProgressBar(2500, locale("unlocking"))
                                FreezeEntityPosition(cache.ped, false)
                                UnlockHouse(house)
                                ClearPedTasks(cache.ped)
                                doingAction = false
                            end
                        end,
                        canInteract = function(entity, distance, data)
                            return ((CheckOwnership(house) or CheckAcess(house)) and
                                (housesData[house] and housesData[house].locked)) or
                                ((CheckOwnership(house) or CheckAcess(house)) and housesData[house] == nil)
                        end
                    },
                    {
                        icon = 'fas fa-lock',
                        label = locale('lock_label'),
                        action = function(entity)
                            if not doingAction then
                                doingAction = true
                                dict = "mp_arresting"
                                clip = "a_uncuff"
                                local coords = data.Coords
                                TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                SetTimeout(1100, function()
                                    FreezeEntityPosition(cache.ped, true)
                                end)
                                RequestAnimDict(dict)
                                while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                ProgressBar(2500, locale("locking"))
                                FreezeEntityPosition(cache.ped, false)
                                LockHouse(house)
                                ClearPedTasks(cache.ped)
                                doingAction = false
                            end
                        end,
                        canInteract = function(entity, distance, data)
                            return (CheckOwnership(house) or CheckAcess(house)) and housesData[house] and
                                not housesData[house].locked
                        end
                    },
                    {
                        icon = 'fas fa-right-to-bracket',
                        label = locale('enter_label'),
                        action = function(entity)
                            enterHouse(house, false)
                        end,
                        canInteract = function(entity, distance, data)
                            return housesData[house] and not housesData[house].locked
                        end
                    }
                },
                distance = 2.5,
            })
        end)
    end
end

function UnlockHouse(house)
    Notify("info", locale("info"), locale("unlocked"))
    TriggerServerEvent("drc_moneywash:unlockHouse", house)
end

function LockHouse(house)
    Notify("info", locale("info"), locale("locked"))
    TriggerServerEvent("drc_moneywash:lockHouse", house)
end

function KnockOnDoors(house)
    Notify("info", locale("info"), locale("knocked"))
    TriggerServerEvent("drc_moneywash:knockOnDoors", house)
end

function TurnLights(house, enabled)
    if enabled then
        TriggerServerEvent("drc_moneywash:lights", house, enabled)
    else
        TriggerServerEvent("drc_moneywash:lights", house, enabled)
    end
end

function TurnAlarm(house, enabled)
    if enabled then
        TriggerServerEvent("drc_moneywash:alarm", house, enabled)
    else
        TriggerServerEvent("drc_moneywash:alarm", house, enabled)
    end
end

function enterable(house)
    if housesData[house] == nil or housesData[house].locked == nil or housesData[house].locked then
        return false
    end
    return true
end

function enterHouse(house, locked)
    if locked then
        if Config.Context == "ox_lib" then
            lib.registerContext({
                id = 'RobberyHouse',
                title = locale('header'),
                options = {
                    [locale('breakdoor_label')] = {
                        arrow = false,
                        event = 'drc_moneywash:serverlockpick',
                        args = { house = house },
                        description = locale('reqitems_label'),
                    }
                }
            })
            lib.showContext('RobberyHouse')
        elseif Config.Context == "qbcore" then
            exports['qb-menu']:openMenu({
                {
                    header = locale('header'),
                    isMenuHeader = true,
                },
                {
                    header = locale('breakdoor_label'),
                    txt = locale('reqitems_label'),
                    params = {
                        isServer = false,
                        event    = 'drc_moneywash:serverlockpick',
                        args     = { house = house },
                    }
                },
            })
        end
    else
        entering = true
        currentHouse = house
        teleport(Config.Warehouses[house].MoneyWash.InsidePositions.Exit.coords)
        Lights(house, true)
        createZones(house)
        SetTimeout(3000, function()
            entering = false
        end)
        TriggerServerEvent("drc_moneywash_instance:joinInstance", "rob_house_" .. house)
        TriggerServerEvent("drc_moneywash:joinHouse", house)
        DoorSound()
        OnHouseEnter()
        lib.callback('drc_moneywash:getupgrades', false, function(value)
            BikerCounterfeit = exports['bob74_ipl']:GetBikerCounterfeitObject()
            if value and value.laundry then
                laundry = true
                BikerCounterfeit.Details.Enable(BikerCounterfeit.Details.cutter, true)
                BikerCounterfeit.Dryer1.Set(BikerCounterfeit.Dryer1.open, true)
                BikerCounterfeit.Dryer2.Set(BikerCounterfeit.Dryer2.open, true)
                BikerCounterfeit.Dryer3.Set(BikerCounterfeit.Dryer3.open, true)
                BikerCounterfeit.Dryer4.Set(BikerCounterfeit.Dryer4.open, true)
            end
            if value and value.alarm then
                BikerCounterfeit.Security.Set(BikerCounterfeit.Security.upgrade, true)
            end
            if value and value.laundry and value.printer then
                BikerCounterfeit.Printer.Set(BikerCounterfeit.Printer.upgradeProd, true)
                Drying(house, true)
            end
            if value and value.laundry and not value.printer then
                Drying(house, false)
                BikerCounterfeit.Printer.Set(BikerCounterfeit.Printer.basicProd, true)
            end
            if value and value.laser then
                for k, v in pairs(Config.Warehouses[house].MoneyWash.Lasers) do
                    TriggerServerEvent('drc_moneywash:CheckLaser', house)
                    TriggerServerEvent("drc_moneywash:CheckHackedHouse", house)
                    if not HouseHacked[house] and not v.spawned then
                        hittedbylaser = false
                        v.spawned = true
                        local k = Laser.new(
                            v.FromCoords,
                            v.ToCoords,
                            {
                                travelTimeBetweenTargets = { 6.0, 6.0 },
                                waitTimeAtTargets = { 3.0, 3.00 },
                                randomTargetSelection = true,
                                name = "Laser" .. k
                            }
                        )
                        k.setVisible(true)
                        k.setActive(true)
                        k.setMoving(true)
                        if v.Visible then
                            k.setColor(255, 0, 0, 100)
                        else
                            k.setColor(255, 0, 0, 10)
                        end
                        k.onPlayerHit(function(playerBeingHit, hitPos)
                            if playerBeingHit and not hittedbylaser then
                                if housesData and housesData[house] and housesData[house].alarm then
                                    hittedbylaser = true
                                    AlarmSound()
                                    Dispatch(house)
                                end
                            end
                        end)
                        table.insert(Lasers, k)
                        TriggerServerEvent('drc_moneywash:lasercheck', k, house)
                        TriggerServerEvent("drc_moneywash:CheckHackedHouse", house)

                    elseif not HouseHacked[house] and v.spawned then
                        for b, g in pairs(Lasers) do
                            g.setVisible(true)
                            g.setActive(true)
                            g.setMoving(true)
                        end
                    end
                end
                TriggerServerEvent("drc_moneywash:AddLaser", house)
            end
        end, house)
    end
end

RegisterNetEvent("drc_moneywash:serverlockpick")
AddEventHandler("drc_moneywash:serverlockpick", function(data)
    TriggerServerEvent("drc_moneywash:lockpick", data.house)
end)

function leaveHouse(house)
    leaving = true
    teleport(Config.Warehouses[house].TeleportExit.xyz)
    TriggerServerEvent("drc_moneywash_instance:quitInstance")
    for b, g in pairs(Lasers) do
        g.setActive(false)
        g.setVisible(false)
    end
    TriggerServerEvent("drc_moneywash:leaveHouse", house)
    Wait(1000)
    currentHouse = nil
    Lights(house, false)
    leaving = false
    OnHouseLeave()
    if Config.InteractionType == "3dtext" or Config.InteractionType == "textui" then



    elseif Config.InteractionType == 'target' then
        target = Target()
        zonesmaked = {}
        target:RemoveZone("drc_camera" .. house)
        target:RemoveZone("drc_dry_collect" .. house)
        target:RemoveZone("drc_dry_start" .. house)
        target:RemoveZone("drc_dry_load" .. house)
        for place, v in pairs(Config.Warehouses[house].MoneyWash.InsidePositions) do
            target:RemoveZone("drc_moneywash_robberyplace" .. place .. house)
        end
        for k, v in pairs(Config.Warehouses[house].MoneyWash.HackDevice) do
            target:RemoveZone("drc_moneywash_robberyplace" .. k)
        end
            target:RemoveZone("drc_manage" .. house)
        for place, v in pairs(Config.Warehouses[house].MoneyWash.Wash) do
            target:RemoveZone("drc_moneywash_wash" .. place .. house)
        end
        for place, v in pairs(Config.Warehouses[house].MoneyWash.Cut) do
            target:RemoveZone("drc_moneywash_cut" .. place .. house)
        end
        for place, v in pairs(Config.Warehouses[house].MoneyWash.Count) do
            target:RemoveZone("drc_moneywash_count" .. place .. house)
        end
        for k, v in pairs(Config.Warehouses[house].MoneyWash.Stashes) do
            target:RemoveZone(house .. " stash " .. k)
        end
        for k, v in pairs(Config.Warehouses[house].MoneyWash.CloakRoom) do
            target:RemoveZone(house .. " cloak " .. k)
        end

    end
end

function teleport(coords)
    DoScreenFadeOut(1000)
    Wait(1000)
    FreezeEntityPosition(cache.ped, true)
    SetEntityCoords(cache.ped, coords.xyz)
    SetEntityHeading(cache.ped, coords.w)

    while not HasCollisionLoadedAroundEntity(cache.ped) do
        RequestCollisionAtCoord(coords)
        Wait(0)
    end
    FreezeEntityPosition(cache.ped, false)
    SetTimeout(900, function()
        ClearPedTasks(cache.ped)
    end)
    Wait(500)
    Wait(500)
    ClearPedTasks(cache.ped)
    DoScreenFadeIn(1500)
end

RegisterNetEvent("drc_moneywash:lockpick")
AddEventHandler("drc_moneywash:lockpick", function(house)
    Lockpicking = true
    doLockpickAnimation(Config.Warehouses[house].Coords.xyz)
    success = not cache.vehicle and DoorLockPickMinigame()
    if success then
        doingAction = true
        SetTimeout(1100, function()
            FreezeEntityPosition(cache.ped, true)
        end)
        ProgressBar(1500, locale('lockpicking'))
        Lockpicking = false
        doingAction = false
        local MoneyWash = Config.Warehouses[house].MoneyWash
        if math.random(100) <= MoneyWash.ReportChanceWhenEntering then
            if housesData and housesData[house] and housesData[house].alarm then
                Dispatch(house)
                AlarmSound()
            end
        end
        TriggerServerEvent("drc_moneywash:unlockHouse", house)
        enterHouse(house, false)
        FreezeEntityPosition(cache.ped, false)
    else
        Lockpicking = false
        Notify('error', locale('lockpick'), locale('brokendoor'))
    end
end)

function createZones(house)
    SetTimeout(1000, function()
        if Config.InteractionType == 'target' then
            target = Target()
        end
        for k, v in pairs(Config.Warehouses[house].MoneyWash.Stashes) do
            if Config.InteractionType == 'target' then
                target:AddCircleZone(house .. " stash " .. k, v.coords, v.radius,
                    { name = house .. " stash " .. k, debugPoly = v.debug, useZ = true },
                    {
                        options = {
                            {
                                type = "client",
                                action = function()
                                    OpenStash(house, k)
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = v.TargetIcon,
                                label = v.TargetLabel
                            },
                        },
                        distance = 3.5
                    }
                )
            else
                lib.zones.sphere({
                    coords = v.coords,
                    radius = 1,
                    debug = v.debug,
                    inside = function(self)
                        if currentHouse == house then
                            if IsControlJustReleased(0, 38) then
                                OpenStash(house, k)
                            end

                            if Config.InteractionType == "3dtext" then
                                Draw3DText(self.coords, string.format("[~g~E~w~] - %s", v.TargetLabel))
                            end
                        end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                            if Config.InteractionType == "textui" then
                                TextUIShow('[E] - ' .. v.TargetLabel)
                            end
                        end
                    end,
                    onExit = function()
                        if currentHouse == house then
                            if Config.InteractionType == "textui" then
                                TextUIHide()
                            end
                        end
                    end
                })
            end
        end
        for k, v in pairs(Config.Warehouses[house].MoneyWash.CloakRoom) do
            if Config.InteractionType == 'target' then
                target:AddCircleZone(house .. " cloak " .. k, v.coords, v.radius,
                    { name = house .. " cloak " .. k, debugPoly = v.debug, useZ = true },
                    {
                        options = {
                            {
                                type = "client",
                                action = function()
                                    OpenCloakRoomMenu()
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-shirt",
                                label = locale("CloakRoom"),
                            },
                        },
                        distance = 3.5
                    }
                )
            else
                lib.zones.sphere({
                    coords = v.coords,
                    radius = 1,
                    debug = v.debug,
                    inside = function(self)
                        if currentHouse == house then
                            if IsControlJustReleased(0, 38) then
                                OpenCloakRoomMenu()
                            end

                            if Config.InteractionType == "3dtext" then
                                Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale("CloakRoom")))
                            end
                        end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                            if Config.InteractionType == "textui" then
                                TextUIShow('[E] - ' .. locale("CloakRoom"))
                            end
                        end
                    end,
                    onExit = function()
                        if currentHouse == house then
                            if Config.InteractionType == "textui" then
                                TextUIHide()
                            end
                        end
                    end
                })
            end
        end
        for place, v in pairs(Config.Warehouses[house].MoneyWash.Count) do
            if not zonesmaked[house .. place .. v.pos] then
                zonesmaked[house .. place .. v.pos] = true
                if Config.InteractionType == 'target' then
                    target:AddCircleZone("drc_moneywash_count" .. place .. house, v.pos.xyz, 1.0, {
                        name = "drc_moneywash_count" .. place .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        if Config.Input == "qb-input" then
                                            local dialog = exports['qb-input']:ShowInput({
                                                header = locale("Amount"),
                                                submitText = "Submit",
                                                inputs = {
                                                    {
                                                        text = locale("requirementdry") ..
                                                            '  \n ' ..
                                                            locale("RangeLaundry",
                                                                Config.Warehouses[house].MoneyWash.CountItems
                                                                .RequiredItems
                                                                .minimum,
                                                                Config.Warehouses[house].MoneyWash.CountItems
                                                                .RequiredItems
                                                                .maximum),
                                                        name = "input",
                                                        type = "number",
                                                        isRequired = true,
                                                    }
                                                }
                                            })
                                            if dialog then
                                                input = tonumber(dialog["input"])
                                            else
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return -- Return if dialog is nil
                                            end
                                        elseif Config.Input == "ox_lib" then
                                            local inputDialog = lib.inputDialog(locale("Amount"), {
                                                {
                                                    type = 'number',
                                                    label = locale("requirementdry"),
                                                    description = locale("RangeLaundry",
                                                        Config.Warehouses[house].MoneyWash.CountItems.RequiredItems
                                                        .minimum,
                                                        Config.Warehouses[house].MoneyWash.CountItems.RequiredItems
                                                        .maximum)
                                                },
                                            })
                                            if not inputDialog or not inputDialog[1] then
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return
                                            end
                                            input = tonumber(inputDialog[1])
                                        end
                                        if not input then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                        if input >= Config.Warehouses[house].MoneyWash.CountItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.CountItems.RequiredItems.maximum then
                                            lib.callback('drc_moneywash:checkcount', false, function(value)
                                                if value then
                                                    if value == "occupied" then
                                                        Notify('error', locale('error'), locale('Stationoccupied'))
                                                    else
                                                        SceneHandler(action[1], v.animation.xyz, nil, house, input)
                                                    end
                                                else
                                                    Notify('error', locale('error'), locale('nodrymoney'))
                                                end
                                            end, house, input)
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                        end
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-money-bill",
                                label = locale('Recount')
                            }
                        },
                        distance = 1.0
                    })
                else
                    lib.zones.sphere({
                        coords = v.pos.xyz,
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if currentHouse == house then
                                if IsControlJustReleased(0, 38) then
                                    if (not doingAction) then
                                        if Config.Input == "qb-input" then
                                            local dialog = exports['qb-input']:ShowInput({
                                                header = locale("Amount"),
                                                submitText = "Submit",
                                                inputs = {
                                                    {
                                                        text = locale("requirementdry") ..
                                                            '  \n ' ..
                                                            locale("RangeLaundry",
                                                                Config.Warehouses[house].MoneyWash.CountItems.RequiredItems
                                                                .minimum,
                                                                Config.Warehouses[house].MoneyWash.CountItems.RequiredItems
                                                                .maximum),
                                                        name = "input",
                                                        type = "number",
                                                        isRequired = true,
                                                    }
                                                }
                                            })
                                            if dialog then
                                                input = tonumber(dialog["input"])
                                            else
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return -- Return if dialog is nil
                                            end
                                        elseif Config.Input == "ox_lib" then
                                            local inputDialog = lib.inputDialog(locale("Amount"), {
                                                {
                                                    type = 'number',
                                                    label = locale("requirementdry"),
                                                    description = locale("RangeLaundry",
                                                        Config.Warehouses[house].MoneyWash.CountItems.RequiredItems.minimum,
                                                        Config.Warehouses[house].MoneyWash.CountItems.RequiredItems.maximum)
                                                },
                                            })
                                            if not inputDialog or not inputDialog[1] then
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return -- Return if input or input[1] is nil
                                            end
                                            input = tonumber(inputDialog[1])
                                        end
                                        if not input then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                        if input >= Config.Warehouses[house].MoneyWash.CountItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.CountItems.RequiredItems.maximum then
                                            lib.callback('drc_moneywash:checkcount', false, function(value)
                                                if value then
                                                    if value == "occupied" then
                                                        Notify('error', locale('error'), locale('Stationoccupied'))
                                                    else
                                                        SceneHandler(action[1], v.animation.xyz, nil, house, input)
                                                    end
                                                else
                                                    Notify('error', locale('error'), locale('nodrymoney'))
                                                end
                                            end, house, input)
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                        end
                                    end
                                end

                                if Config.InteractionType == "3dtext" then
                                    Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('Recount')))
                                end
                            end
                        end,
                        onEnter = function()
                            if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIShow('[E] - ' .. locale('Recount'))
                                end
                            end
                        end,
                        onExit = function()
                            if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIHide()
                                end
                            end
                        end
                    })
                end
            end
        end
        for place, v in pairs(Config.Warehouses[house].MoneyWash.Cut) do
            if not zonesmaked[house .. place .. v.pos] then
                zonesmaked[house .. place .. v.pos] = true
                if Config.InteractionType == 'target' then
                    target:AddCircleZone("drc_moneywash_cut" .. place .. house, v.pos.xyz, 1.0, {
                        name = "drc_moneywash_cut" .. place .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        if Config.Input == "qb-input" then
                                            local dialog = exports['qb-input']:ShowInput({
                                                header = locale("Amount"),
                                                submitText = "Submit",
                                                inputs = {
                                                    {
                                                        text = locale("requirementdirty") ..
                                                            '  \n ' ..
                                                            locale("RangeLaundry",
                                                                Config.Warehouses[house].MoneyWash.CutItems
                                                                .RequiredItems
                                                                .minimum,
                                                                Config.Warehouses[house].MoneyWash.CutItems
                                                                .RequiredItems
                                                                .maximum),
                                                        name = "input",
                                                        type = "number",
                                                        isRequired = true,
                                                    }
                                                }
                                            })
                                            if dialog then
                                                input = tonumber(dialog["input"])
                                            else
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return -- Return if dialog is nil
                                            end
                                        elseif Config.Input == "ox_lib" then
                                            local inputDialog = lib.inputDialog(locale("Amount"), {
                                                {
                                                    type = 'number',
                                                    label = locale("requirementdirty"),
                                                    description = locale("RangeLaundry",
                                                        Config.Warehouses[house].MoneyWash.CutItems.RequiredItems
                                                        .minimum,
                                                        Config.Warehouses[house].MoneyWash.CutItems.RequiredItems
                                                        .maximum)
                                                },
                                            })
                                            if not inputDialog or not inputDialog[1] then
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return -- Return if input or input[1] is nil
                                            end
                                            input = tonumber(inputDialog[1])
                                        end

                                        if not input then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                        if input >= Config.Warehouses[house].MoneyWash.CutItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.CutItems.RequiredItems.maximum then
                                            lib.callback('drc_moneywash:checkcut', false, function(value)
                                                if value then
                                                    if value == "occupied" then
                                                        Notify('error', locale('error'), locale('Stationoccupied'))
                                                    else
                                                        SceneHandler(action[2], v.animation.xyz, nil, house, input)
                                                    end
                                                else
                                                    Notify('error', locale('error'), locale('nodirtymoney'))
                                                end
                                            end, house, input)
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                        end
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-hand-scissors",
                                label = locale('Cutter')
                            }
                        },
                        distance = 1.0
                    })
                else
                    lib.zones.sphere({
                        coords = v.pos.xyz,
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if currentHouse == house then
                                if IsControlJustReleased(0, 38) then
                                    if (not doingAction) then
                                        if Config.Input == "qb-input" then
                                            local dialog = exports['qb-input']:ShowInput({
                                                header = locale("Amount"),
                                                submitText = "Submit",
                                                inputs = {
                                                    {
                                                        text = locale("requirementdirty") ..
                                                            '  \n ' ..
                                                            locale("RangeLaundry",
                                                                Config.Warehouses[house].MoneyWash.CutItems.RequiredItems
                                                                .minimum,
                                                                Config.Warehouses[house].MoneyWash.CutItems.RequiredItems
                                                                .maximum),
                                                        name = "input",
                                                        type = "number",
                                                        isRequired = true,
                                                    }
                                                }
                                            })
                                            if dialog then
                                                input = tonumber(dialog["input"])
                                            else
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return -- Return if dialog is nil
                                            end
                                        elseif Config.Input == "ox_lib" then
                                            local inputDialog = lib.inputDialog(locale("Amount"), {
                                                {
                                                    type = 'number',
                                                    label = locale("requirementdirty"),
                                                    description = locale("RangeLaundry",
                                                        Config.Warehouses[house].MoneyWash.CutItems.RequiredItems.minimum,
                                                        Config.Warehouses[house].MoneyWash.CutItems.RequiredItems.maximum)
                                                },
                                            })
                                            if not inputDialog or not inputDialog[1] then
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return -- Return if input or input[1] is nil
                                            end
                                            input = tonumber(inputDialog[1])
                                        end

                                        if not input then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                        if input >= Config.Warehouses[house].MoneyWash.CutItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.CutItems.RequiredItems.maximum then
                                            lib.callback('drc_moneywash:checkcut', false, function(value)
                                                if value then
                                                    if value == "occupied" then
                                                        Notify('error', locale('error'), locale('Stationoccupied'))
                                                    else
                                                        SceneHandler(action[2], v.animation.xyz, nil, house, input)
                                                    end
                                                else
                                                    Notify('error', locale('error'), locale('nodirtymoney'))
                                                end
                                            end, house, input)
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                        end
                                    end
                                end


                                if Config.InteractionType == "3dtext" then
                                    Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('Cutter')))
                                end
                            end
                        end,
                        onEnter = function()
                            if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIShow('[E] - ' .. locale('Cutter'))
                                end
                            end
                        end,
                        onExit = function()
                            if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIHide()
                                end
                            end
                        end
                    })
                end
            end
        end
        for place, v in pairs(Config.Warehouses[house].MoneyWash.Wash) do
            if not zonesmaked[house .. place .. v.pos] then
                zonesmaked[house .. place .. v.pos] = true
                if Config.InteractionType == 'target' then
                    target:AddCircleZone("drc_moneywash_wash" .. place .. house, v.pos.xyz, 1.0, {
                        name = "drc_moneywash_wash" .. place .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        local input = nil
                                        if Config.Input == "qb-input" then
                                            local dialog = exports['qb-input']:ShowInput({
                                                header = locale("Amount"),
                                                submitText = "Submit",
                                                inputs = {
                                                    {
                                                        text = locale("requirementunmarked") ..
                                                            '  \n ' ..
                                                            locale("RangeLaundry",
                                                                Config.Warehouses[house].MoneyWash.WashItems
                                                                .RequiredItems
                                                                .minimum,
                                                                Config.Warehouses[house].MoneyWash.WashItems
                                                                .RequiredItems
                                                                .maximum),
                                                        name = "input",
                                                        type = "number",
                                                        isRequired = true,
                                                    }
                                                }
                                            })
                                            if dialog then
                                                input = tonumber(dialog["input"])
                                            else
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return
                                            end
                                        elseif Config.Input == "ox_lib" then
                                            local inputDialog = lib.inputDialog(locale("Amount"), {
                                                {
                                                    type = 'number',
                                                    label = locale("requirementunmarked"),
                                                    description = locale("RangeLaundry",
                                                        Config.Warehouses[house].MoneyWash.WashItems.RequiredItems
                                                        .minimum,
                                                        Config.Warehouses[house].MoneyWash.WashItems.RequiredItems
                                                        .maximum)
                                                },
                                            })
                                            if not inputDialog or not inputDialog[1] then
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return
                                            end

                                            input = tonumber(inputDialog[1])
                                        end

                                        if not input then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end

                                        if input >= Config.Warehouses[house].MoneyWash.WashItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.WashItems.RequiredItems.maximum then
                                            lib.callback('drc_moneywash:checkwash', false, function(value)
                                                if value then
                                                    if value == "occupied" then
                                                        Notify('error', locale('error'), locale('Stationoccupied'))
                                                    elseif value == "started" then
                                                        Notify('error', locale('error'), locale('alreadywash'))
                                                    else
                                                        SceneHandler(action[3], v.animation.xyz, place, house, input)
                                                    end
                                                else
                                                    Notify('error', locale('error'), locale('nounmarkedmoney'))
                                                end
                                            end, house, place, "start", input)
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                        end
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-soap",
                                label = locale('WashDirtyMoney')
                            },
                            {
                                action = function()
                                    if (not doingAction) then
                                        lib.callback('drc_moneywash:checkwash', false, function(value)
                                        end, house, place, "check")
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-clock",
                                label = locale('Checkwash')
                            },
                            {
                                action = function()
                                    if (not doingAction) then
                                        lib.callback('drc_moneywash:checkwash', false, function(value)
                                        end, house, place, "collect")
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-hand-holding-dollar",
                                label = locale('Collectwashed')
                            }
                        },
                        distance = 1.0
                    })
                else
                    lib.zones.sphere({
                        coords = v.pos.xyz,
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if currentHouse == house then
                                if IsControlJustReleased(0, 38) then
                                    if Config.Context == "ox_lib" then
                                        lib.registerContext({
                                            id = 'warehouse:interact:menu:01',
                                            title = locale('washingmachine'),
                                            options = {
                                                {
                                                    title = locale('WashDirtyMoney'),
                                                    icon = "fas fa-soap",
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = {
                                                        house = house,
                                                        place = place,
                                                        animation = v.animation,
                                                        action = action,
                                                        id = 1
                                                    }
                                                },
                                                {
                                                    title = locale('Checkwash'),
                                                    icon = "fas fa-clock",
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, place = place, id = 2 }
                                                },
                                                {
                                                    title = locale('Collectwashed'),
                                                    icon = "fas fa-hand-holding-dollar",
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, place = place, id = 3 }
                                                }
                                            }
                                        })
                                        lib.showContext('warehouse:interact:menu:01')
                                    else
                                        exports['qb-menu']:openMenu({
                                            {
                                                isMenuHeader = true,
                                                header = locale("washingmachine")
                                            },
                                            {
                                                header = locale('WashDirtyMoney'),
                                                arrow = false,
                                                txt = "",
                                                params = {
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = {
                                                        house = house,
                                                        place = place,
                                                        animation = v.animation,
                                                        action = action,
                                                        id = 1
                                                    }
                                                }
                                            },
                                            {
                                                header = locale('Checkwash'),
                                                arrow = false,
                                                txt = "",
                                                params = {
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, place = place, id = 2 }
                                                }
                                            },
                                            {
                                                header = locale('Collectwashed'),
                                                arrow = false,
                                                txt = "",
                                                params = {
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, place = place, id = 3 }
                                                }
                                            }
                                        })
                                    end
                                end

                                if Config.InteractionType == "3dtext" then
                                    Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('washingmachine')))
                                end
                            end
                        end,
                        onEnter = function()
                            if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIShow('[E] - ' .. locale('washingmachine'))
                                end
                            end
                        end,
                        onExit = function()
                            if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIHide()
                                end
                            end
                        end
                    })
                end
            end
        end
        if Config.CCTV ~= "disabled" then
            if not zonesmaked[house .. "camera" .. Config.Warehouses[house].MoneyWash.Camera.xyz] then
                zonesmaked[house .. "camera" .. Config.Warehouses[house].MoneyWash.Camera.xyz] = true
                if Config.InteractionType == 'target' then
                    target:AddCircleZone("drc_camera" .. house, Config.Warehouses[house].MoneyWash.Camera.xyz, 1.0, {
                        name = "drc_camera" .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        if not cameraCanAccess then
                                            lib.callback('drc_moneywash:checkcamera', false, function(value)
                                                if value then
                                                    doingAction = true
                                                    local coords = Config.Warehouses[house].MoneyWash.Camera.xyz
                                                    TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                    SetTimeout(1100, function()
                                                        FreezeEntityPosition(cache.ped, true)
                                                    end)
                                                    dict = "anim@heists@prison_heiststation@cop_reactions"
                                                    clip = "cop_b_idle"
                                                    RequestAnimDict(dict)
                                                    while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                        false)
                                                    ProgressBar(2500, locale("accessingcamera"))
                                                    Camera(house)
                                                    FreezeEntityPosition(cache.ped, false)
                                                    doingAction = false
                                                end
                                            end, house)
                                        end
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-camera",
                                label = locale('accesscamera')
                            }
                        },
                        distance = 1.0
                    })
                else
                    lib.zones.sphere({
                        coords = Config.Warehouses[house].MoneyWash.Camera.xyz,
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if currentHouse == house then
                                if IsControlJustReleased(0, 38) then
                                    if (not doingAction) then
                                        if not cameraCanAccess then
                                            lib.callback('drc_moneywash:checkcamera', false, function(value)
                                                if value then
                                                    doingAction = true
                                                    local coords = Config.Warehouses[house].MoneyWash.Camera.xyz
                                                    TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                    SetTimeout(1100, function()
                                                        FreezeEntityPosition(cache.ped, true)
                                                    end)
                                                    dict = "anim@heists@prison_heiststation@cop_reactions"
                                                    clip = "cop_b_idle"
                                                    RequestAnimDict(dict)
                                                    while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                        false)
                                                    ProgressBar(2500, locale("accessingcamera"))
                                                    Camera(house)
                                                    FreezeEntityPosition(cache.ped, false)
                                                    doingAction = false
                                                end
                                            end, house)
                                        end
                                    end
                                end

                                if Config.InteractionType == "3dtext" then
                                    Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('accesscamera')))
                                end
                            end
                        end,
                        onEnter = function()
                            if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIShow('[E] - ' .. locale('accesscamera'))
                                end
                            end
                        end,
                        onExit = function()
                            if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIHide()
                                end
                            end
                        end
                    })
                end
            end
        end
        if not zonesmaked[house .. "manage" .. Config.Warehouses[house].MoneyWash.Manage.xyz] then
            zonesmaked[house .. "manage" .. Config.Warehouses[house].MoneyWash.Manage.xyz] = true
            if Config.InteractionType == 'target' then
                target:AddCircleZone("drc_manage" .. house, Config.Warehouses[house].MoneyWash.Manage.xyz, 1.0, {
                    name = "drc_manage" .. house,
                    useZ = true,
                    debugPoly = Config.Debug,
                }, {
                    options = {
                        {
                            -- Highcrest: shows this player's washing level and rate.
                            action = function()
                                local info = lib.callback.await('highcrest_moneywash:getLevel', false)
                                if not info then return end
                                local progress = info.nextXp
                                    and ('%d / %d XP to level %d'):format(info.xp, info.nextXp, info.level + 1)
                                    or 'Max level reached'
                                lib.alertDialog({
                                    header = ('Washing level %d'):format(info.level),
                                    content = ('You keep about %d%% of the dirty money you wash.  \n%s'):format(info.keep, progress),
                                    centered = true,
                                })
                            end,
                            icon = "fas fa-chart-line",
                            label = "Washing level",
                        },
                        {
                            action = function()
                                if (not doingAction) then
                                    if Config.Input == "qb-input" then
                                        local dialog = exports['qb-input']:ShowInput({
                                            header = locale("managesec"),
                                            submitText = "Submit",
                                            inputs = {
                                                {
                                                    text = locale('setwebhook'),
                                                    name = "input",
                                                    type = "text",
                                                    isRequired = true,
                                                }
                                            }
                                        })
                                        if dialog then
                                            input = dialog["input"]
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                    elseif Config.Input == "ox_lib" then
                                        local inputDialog = lib.inputDialog(locale("managesec"), {
                                            { type = 'input', label = locale('setwebhook') },
                                        })
                                        if not inputDialog or not inputDialog[1] then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                        input = inputDialog[1]
                                    end

                                    if not input then
                                        Notify('error', locale('error'), locale('InvalidAmount'))
                                        return
                                    end

                                    if verifyWebhookURL(input) then
                                        lib.callback('drc_moneywash:managewebhook', false, function(value)
                                            doingAction = true
                                            dict = "anim@heists@prison_heiststation@cop_reactions"
                                            clip = "cop_b_idle"
                                            local coords = Config.Warehouses[house].MoneyWash.Manage.xyz
                                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                            SetTimeout(1100, function()
                                                FreezeEntityPosition(cache.ped, true)
                                            end)
                                            RequestAnimDict(dict)
                                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                            ProgressBar(2500, locale("changingwebhook"))
                                            FreezeEntityPosition(cache.ped, false)
                                            ClearPedTasks(cache.ped)
                                            doingAction = false
                                        end, house, input)
                                    else
                                    end
                                end
                            end,
                            canInteract = function(entity, distance, data)
                                return (house == currentHouse) and CheckOwnership(house)
                            end,
                            icon = "fas fa-bell",
                            label = locale('setwebhook')
                        },
                        {
                            action = function()
                                if (not doingAction) then
                                    if Config.Input == "qb-input" then
                                        local dialog = exports['qb-input']:ShowInput({
                                            header = locale("giveaccess"),
                                            submitText = "Submit",
                                            inputs = {
                                                {
                                                    text = locale("nickname") .. '  \n ' .. locale("nicknamedesc"),
                                                    name = "input",
                                                    type = "text",
                                                    isRequired = true,
                                                }
                                            }
                                        })
                                        if dialog then
                                            input = dialog["input"]
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                    elseif Config.Input == "ox_lib" then
                                        local inputDialog = lib.inputDialog(locale("giveaccess"), {
                                            {
                                                type = 'input',
                                                label = locale("nickname"),
                                                description = locale("nicknamedesc")
                                            },
                                        })
                                        if not inputDialog or not inputDialog[1] then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                        input = inputDialog[1]
                                    end

                                    if not input then
                                        Notify('error', locale('error'), locale('InvalidAmount'))
                                        return
                                    end
                                    local TargetPlayer, dist = GetClosestEntity(GetPlayers(true, true), true,
                                        GetEntityCoords(cache.ped), nil)
                                    FillingInProgress = false
                                    if TargetPlayer ~= -1 then
                                        lib.callback('drc_moneywash:givekeys', false, function(value)
                                            doingAction = true
                                            dict = "anim@heists@prison_heiststation@cop_reactions"
                                            clip = "cop_b_idle"
                                            local coords = Config.Warehouses[house].MoneyWash.Manage.xyz
                                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                            SetTimeout(1100, function()
                                                FreezeEntityPosition(cache.ped, true)
                                            end)
                                            RequestAnimDict(dict)
                                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                            ProgressBar(2500, locale("givingaccess"))
                                            FreezeEntityPosition(cache.ped, false)
                                            ClearPedTasks(cache.ped)
                                            doingAction = false
                                        end, house, GetPlayerServerId(TargetPlayer), input)
                                    end
                                end
                            end,
                            canInteract = function(entity, distance, data)
                                return (house == currentHouse) and CheckOwnership(house)
                            end,
                            icon = "fas fa-key",
                            label = locale('givekeys')
                        },
                        {
                            action = function()
                                if (not doingAction) then
                                    lib.callback('drc_moneywash:getaccess', false, function(value)
                                        options = {}
                                        for k, v in pairs(value) do
                                            options["[" .. k .. "] - " .. v] = {}
                                            options["[" .. k .. "] - " .. v].arrow = false
                                            options["[" .. k .. "] - " .. v].description = locale("removeaccess")
                                            options["[" .. k .. "] - " .. v].event = 'drc_moneywash:removekeys'
                                            options["[" .. k .. "] - " .. v].args = { house = house, value = k, name = v }
                                        end
                                        lib.registerContext({
                                            id = 'Shop',
                                            title = locale("removeaccess"),
                                            options = options
                                        })
                                        lib.showContext('Shop')
                                    end, house)
                                end
                            end,
                            canInteract = function(entity, distance, data)
                                return CheckOwnership(house) and (house == currentHouse) 
                            end,
                            icon = "fas fa-ban",
                            label = locale('removekeys')
                        }
                    },
                    distance = 1.0
                })
            else
                lib.zones.sphere({
                    coords = Config.Warehouses[house].MoneyWash.Manage.xyz,
                    radius = 1,
                    debug = Config.Debug,
                    inside = function(self)
                        if currentHouse == house then
                        if IsControlJustReleased(0, 38) then
                            if CheckOwnership(house) then
                                if Config.Context == "ox_lib" then
                                    lib.registerContext({
                                        id = 'warehouse:interact:menu:02',
                                        title = locale('manageheader'),
                                        options = {
                                            {
                                                title = locale('setwebhook'),
                                                icon = "fas fa-bell",
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 4,
                                                    coords = Config.Warehouses[house].MoneyWash.Manage.xyz
                                                }
                                            },
                                            {
                                                title = locale('givekeys'),
                                                icon = "fas fa-key",
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 5,
                                                    coords = Config.Warehouses[house].MoneyWash.Manage.xyz
                                                }
                                            },
                                            {
                                                title = locale('removekeys'),
                                                icon = "fas fa-ban",
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 6,
                                                    coords = Config.Warehouses[house].MoneyWash.Manage.xyz
                                                }
                                            }
                                        }
                                    })
                                    lib.showContext('warehouse:interact:menu:02')
                                else
                                    exports['qb-menu']:openMenu({
                                        {
                                            isMenuHeader = true,
                                            header = locale("manageheader")
                                        },
                                        {
                                            header = locale('setwebhook'),
                                            arrow = false,
                                            txt = "",
                                            params = {
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 4,
                                                    coords = Config.Warehouses[house].MoneyWash.Manage.xyz
                                                }
                                            }
                                        },
                                        {
                                            header = locale('givekeys'),
                                            arrow = false,
                                            txt = "",
                                            params = {
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 5,
                                                    coords = Config.Warehouses[house].MoneyWash.Manage.xyz
                                                }
                                            }
                                        },
                                        {
                                            header = locale('removekeys'),
                                            arrow = false,
                                            txt = "",
                                            params = {
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 6,
                                                    coords = Config.Warehouses[house].MoneyWash.Manage.xyz
                                                }
                                            }
                                        }
                                    })
                                end
                            end
                        end

                        if Config.InteractionType == "3dtext" then
                            Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('manage')))
                        end
                    end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIShow('[E] - ' .. locale('manage'))
                        end
                    end
                    end,
                    onExit = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIHide()
                        end
                    end
                    end
                })
            end
        end
        SetTimeout(2000, function()
            for k, v in pairs(Config.Warehouses[house].MoneyWash.HackDevice) do
                if not zonesmaked[house .. k .. v.Coords] then
                    zonesmaked[house .. k .. v.Coords] = true
                    if Config.InteractionType == 'target' then
                        target:AddCircleZone("drc_moneywash_robberyplace" .. k, v.Coords.xyz, 1.0, {
                            name = "drc_moneywash_robberyplace" .. k,
                            useZ = true,
                            debugPoly = Config.Debug,
                        }, {
                            options = {
                                {
                                    action = function()
                                        local HaveLaptop = true
                                        if v.NeedItem then
                                            HaveLaptop = false
                                            lib.callback('drc_moneywash:getitem', false, function(value)
                                                if value then
                                                    HaveLaptop = true
                                                else
                                                    HaveLaptop = false
                                                    Notify('error', locale('error'), locale('NeedLaptop'))
                                                    return
                                                end
                                            end, v.Item)
                                        end
                                        SetTimeout(500, function()
                                            if not doingAction and HaveLaptop then
                                                if not HouseHacked[house] then
                                                    Hacking = true
                                                    doAnimation()
                                                    FreezeEntityPosition(cache.ped, true)
                                                    if HackingMinigame() then
                                                        Hacking = false
                                                        FreezeEntityPosition(cache.ped, false)
                                                        Notify('success', locale('success'), locale('hacked'))
                                                        TriggerServerEvent("drc_moneywash:AddHackedHouse", house)
                                                    else
                                                        if housesData and housesData[house] and housesData[house].alarm then
                                                            Dispatch(house)
                                                            AlarmSound()
                                                        end
                                                        Hacking = false
                                                        FreezeEntityPosition(cache.ped, false)
                                                        Notify('error', locale('error'), locale('failed'))
                                                    end
                                                elseif HouseHacked[house] and not HaveLaptop then
                                                    Notify('success', locale('success'), locale('AlreadyHacked'))
                                                end
                                            end
                                        end)
                                    end,
                                    canInteract = function(entity, distance, data)
                                        return (house == currentHouse) and not HouseHacked[house] and not (CheckOwnership(house) or CheckAcess(house))
                                    end,
                                    icon = "fas fa-server",
                                    label = v.Label
                                },
                                {
                                    icon = 'fas fa-bell',
                                    label = locale('ONalarm'),
                                    action = function(entity)
                                        if not doingAction then
                                            doingAction = true
                                            local coords = v.Coords.xyz
                                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                            SetTimeout(1100, function()
                                                FreezeEntityPosition(cache.ped, true)
                                            end)
                                            dict = "mp_arresting"
                                            clip = "a_uncuff"
                                            RequestAnimDict(dict)
                                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                            ProgressBar(2500, locale("ONalarmprog"))
                                            FreezeEntityPosition(cache.ped, false)
                                            TurnAlarm(house, true)
                                            ClearPedTasks(cache.ped)
                                            Notify('success', locale('success'), locale('ONalarmnot'))
                                            doingAction = false
                                        end
                                    end,
                                    canInteract = function(entity, distance, data)
                                        local isOwned = (CheckOwnership(house) or CheckAcess(house))
                                        local hasData = housesData[house] ~= nil
                                        local hasLights = hasData and housesData[house].lights
                                        local hasAlarm = hasData and housesData[house].alarm
                                        local isHacked = HouseHacked[house]
                                        return (house == currentHouse) and ((isOwned or isHacked) and not hasAlarm)
                                    end,
                                },
                                {
                                    icon = 'fas fa-bell',
                                    label = locale('OFFalarm'),
                                    action = function(entity)
                                        if not doingAction then
                                            doingAction = true
                                            local coords = v.Coords.xyz
                                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                            SetTimeout(1100, function()
                                                FreezeEntityPosition(cache.ped, true)
                                            end)
                                            dict = "mp_arresting"
                                            clip = "a_uncuff"
                                            RequestAnimDict(dict)
                                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                            ProgressBar(2500, locale("OFFalarmprog"))
                                            FreezeEntityPosition(cache.ped, false)
                                            TurnAlarm(house, false)
                                            ClearPedTasks(cache.ped)
                                            Notify('success', locale('success'), locale('OFFalarmnot'))
                                            doingAction = false
                                        end
                                    end,
                                    canInteract = function(entity, distance, data)
                                        local isOwned = (CheckOwnership(house) or CheckAcess(house))
                                        local hasData = housesData[house] ~= nil
                                        local hasLights = hasData and housesData[house].lights
                                        local hasAlarm = hasData and housesData[house].alarm
                                        local isHacked = HouseHacked[house]
                                        return (house == currentHouse) and ((isOwned or isHacked) and hasAlarm)
                                    end,
                                },
                                {
                                    icon = 'fas fa-lightbulb',
                                    label = locale('ONlights'),
                                    action = function(entity)
                                        if not doingAction then
                                            doingAction = true
                                            local coords = v.Coords.xyz
                                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                            SetTimeout(1100, function()
                                                FreezeEntityPosition(cache.ped, true)
                                            end)
                                            dict = "mp_arresting"
                                            clip = "a_uncuff"
                                            RequestAnimDict(dict)
                                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                            ProgressBar(2500, locale("ONlightsprog"))
                                            FreezeEntityPosition(cache.ped, false)
                                            TurnLights(house, true)
                                            ClearPedTasks(cache.ped)
                                            Notify('success', locale('success'), locale('ONlightsnot'))
                                            doingAction = false
                                        end
                                    end,
                                    canInteract = function(entity, distance, data)
                                        local isOwned = (CheckOwnership(house) or CheckAcess(house))
                                        local hasData = housesData[house] ~= nil
                                        local hasLights = hasData and housesData[house].lights
                                        local hasAlarm = hasData and housesData[house].alarm
                                        local isHacked = HouseHacked[house]
                                        return (house == currentHouse) and ((isOwned or isHacked) and not hasLights)
                                    end,
                                },
                                {
                                    icon = 'fas fa-lightbulb',
                                    label = locale('OFFlights'),
                                    action = function(entity)
                                        if not doingAction then
                                            doingAction = true
                                            local coords = v.Coords.xyz
                                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                            SetTimeout(1100, function()
                                                FreezeEntityPosition(cache.ped, true)
                                            end)
                                            dict = "mp_arresting"
                                            clip = "a_uncuff"
                                            RequestAnimDict(dict)
                                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                            ProgressBar(2500, locale("OFFlightsprog"))
                                            FreezeEntityPosition(cache.ped, false)
                                            TurnLights(house, false)
                                            ClearPedTasks(cache.ped)
                                            Notify('success', locale('success'), locale('OFFlightsnot'))
                                            doingAction = false
                                        end
                                    end,
                                    canInteract = function(entity, distance, data)
                                        local isOwned = (CheckOwnership(house) or CheckAcess(house))
                                        local hasData = housesData[house] ~= nil
                                        local hasLights = hasData and housesData[house].lights
                                        local hasAlarm = hasData and housesData[house].alarm
                                        local isHacked = HouseHacked[house]
                                        return (house == currentHouse) and ((isOwned or isHacked) and hasLights)
                                    end,
                                },
                            },
                            distance = 1.0
                        })
                    else
                        lib.zones.sphere({
                            coords = v.Coords.xyz,
                            radius = 1,
                            debug = Config.Debug,
                            inside = function(self)
                                if currentHouse == house then
                                if IsControlJustReleased(0, 38) then
                                    local isOwned = (CheckOwnership(house) or CheckAcess(house))
                                    local hasData = housesData[house] ~= nil
                                    local hasLights = hasData and housesData[house].lights
                                    local hasAlarm = hasData and housesData[house].alarm
                                    local isHacked = HouseHacked[house]
                                    if Config.Context == "ox_lib" then
                                        lib.registerContext({
                                            id = 'warehouse:interact:menu:03',
                                            title = locale('panel'),
                                            options = {
                                                {
                                                    title = locale('ONalarm'),
                                                    icon = "fas fa-bell",
                                                    disabled = not ((isOwned or isHacked) and not hasAlarm),
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, id = 21, coords = v.Coords.xyz }
                                                },
                                                {
                                                    title = locale('OFFalarm'),
                                                    icon = "fas fa-bell",
                                                    disabled = not ((isOwned or isHacked) and hasAlarm),
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, id = 22, coords = v.Coords.xyz }
                                                },
                                                {
                                                    title = locale('ONlights'),
                                                    icon = "fas fa-lightbulb",
                                                    disabled = not ((isOwned or isHacked) and not hasLights),
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, id = 23, coords = v.Coords.xyz }
                                                },
                                                {
                                                    title = locale('OFFlights'),
                                                    icon = "fas fa-lightbulb",
                                                    disabled = not ((isOwned or isHacked) and hasLights),
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, id = 24, coords = v.Coords.xyz }
                                                },
                                                {
                                                    title = v.Label,
                                                    icon = "fas fa-server",
                                                    disabled = HouseHacked[house] or
                                                        (CheckOwnership(house) or CheckAcess(house)),
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, NeedItem = v.NeedItem, Item = v.Item, id = 7 }
                                                },
                                            }
                                        })
                                        lib.showContext('warehouse:interact:menu:03')
                                    else
                                        exports['qb-menu']:openMenu({
                                            {
                                                isMenuHeader = true,
                                                header = locale("panel")
                                            },
                                            {
                                                header = locale('ONalarm'),
                                                arrow = false,
                                                disabled = not ((isOwned or isHacked) and not hasAlarm),
                                                txt = "",
                                                params = {
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, id = 21, coords = v.Coords.xyz }
                                                }
                                            },
                                            {
                                                header = locale('OFFalarm'),
                                                arrow = false,
                                                disabled = not ((isOwned or isHacked) and hasAlarm),
                                                txt = "",
                                                params = {
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, id = 22, coords = v.Coords.xyz }
                                                }
                                            },
                                            {
                                                header = locale('ONlights'),
                                                arrow = false,
                                                disabled = not ((isOwned or isHacked) and not hasLights),
                                                txt = "",
                                                params = {
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, id = 23, coords = v.Coords.xyz }
                                                }
                                            },
                                            {
                                                header = locale('OFFlights'),
                                                arrow = false,
                                                disabled = not ((isOwned or isHacked) and hasLights),
                                                txt = "",
                                                params = {
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, id = 24, coords = v.Coords.xyz }
                                                }
                                            },
                                            {
                                                header = v.Label,
                                                arrow = false,
                                                disabled = HouseHacked[house] or
                                                        (CheckOwnership(house) or CheckAcess(house)),
                                                txt = "",
                                                params = {
                                                    event = 'warehouse:interact:menu:buttons',
                                                    args = { house = house, NeedItem = v.NeedItem, Item = v.Item, id = 7 }
                                                }
                                            },

                                        })
                                    end
                                end

                                if Config.InteractionType == "3dtext" then
                                    Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('panel')))
                                end
                            end
                            end,
                            onEnter = function()
                                if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIShow('[E] - ' .. locale('panel'))
                                end
                            end
                            end,
                            onExit = function()
                                if currentHouse == house then
                                if Config.InteractionType == "textui" then
                                    TextUIHide()
                                end
                            end
                            end
                        })
                    end
                end
            end
        end)
        for place, v in pairs(Config.Warehouses[house].MoneyWash.InsidePositions) do
            if not zonesmaked[house .. place .. v.coords] then
                if Config.InteractionType == "target" then
                    zonesmaked[house .. place .. v.coords] = true
                    target:AddCircleZone("drc_moneywash_robberyplace" .. place .. house, v.coords.xyz, 1.0, {
                        name = "drc_moneywash_robberyplace" .. place .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        doingAction = true
                                        local coords = v.coords.xyz
                                        TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                        SetTimeout(1100, function()
                                            FreezeEntityPosition(cache.ped, true)
                                        end)
                                        leaveHouse(house)
                                        FreezeEntityPosition(cache.ped, false)
                                        doingAction = false
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse) and  (CheckOwnership(house) and (housesData[house] and not housesData[house].locked) or (house == currentHouse) and CheckAcess(house) and (housesData[house] and not housesData[house].locked)) or
                                        (house == currentHouse) and (housesData[house] and not housesData[house].locked)
                                end,
                                icon = "fas fa-door-open",
                                label = locale('exit_label')
                            },
                            {
                                icon = 'fas fa-door-open',
                                label = locale('unlock_label'),
                                action = function(entity)
                                    if not doingAction then
                                        doingAction = true
                                        local coords = v.coords.xyz
                                        TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                        SetTimeout(1100, function()
                                            FreezeEntityPosition(cache.ped, true)
                                        end)
                                        dict = "mp_arresting"
                                        clip = "a_uncuff"
                                        RequestAnimDict(dict)
                                        while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                        TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                        ProgressBar(2500, locale("unlocking"))
                                        UnlockHouse(house)
                                        ClearPedTasks(cache.ped)
                                        FreezeEntityPosition(cache.ped, false)
                                        doingAction = false
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse) and (CheckOwnership(house) or CheckAcess(house)) and
                                        (housesData[house] and housesData[house].locked) or housesData[house] == nil
                                end
                            },
                            {
                                icon = 'fas fa-lock',
                                label = locale('lock_label'),
                                action = function(entity)
                                    if not doingAction then
                                        doingAction = true
                                        local coords = v.coords.xyz
                                        TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                        SetTimeout(1100, function()
                                            FreezeEntityPosition(cache.ped, true)
                                        end)
                                        dict = "mp_arresting"
                                        clip = "a_uncuff"
                                        RequestAnimDict(dict)
                                        while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                        TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                        ProgressBar(2500, locale("locking"))
                                        LockHouse(house)
                                        ClearPedTasks(cache.ped)
                                        FreezeEntityPosition(cache.ped, false)
                                        doingAction = false
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse) and (CheckOwnership(house) or CheckAcess(house)) and housesData[house] and
                                        not housesData[house].locked
                                end
                            },
                        },
                        distance = 1.0
                    })
                else
                    lib.zones.sphere({
                        coords = v.coords.xyz,
                        radius = 1,
                        debug = Config.Debug,
                        inside = function(self)
                            if currentHouse == house then
                            if IsControlJustReleased(0, 38) then
                                if Config.Context == "ox_lib" then
                                    lib.registerContext({
                                        id = 'warehouse:interact:menu:04',
                                        title = locale('exit'),
                                        options = {
                                            {
                                                title = locale('exit_label'),
                                                icon = "fas fa-door-open",
                                                disabled = not ((housesData[house] and not housesData[house].locked) or housesData[house] == nil),
                                                event = 'warehouse:interact:menu:buttons',
                                                args = { house = house, id = 9, coords = v.coords.xyz }
                                            },
                                            {
                                                title = locale('unlock_label'),
                                                icon = "fas fa-door-closed",
                                                disabled = not (housesData[house] and housesData[house].locked) or
                                                    housesData[house] == nil,
                                                event = 'warehouse:interact:menu:buttons',
                                                args = { house = house, id = 10, coords = v.coords.xyz }
                                            },
                                            {
                                                title = locale('lock_label'),
                                                icon = "fas fa-lock",
                                                disabled = not ((CheckOwnership(house) or CheckAcess(house)) and housesData[house] and not housesData[house].locked),
                                                event = 'warehouse:interact:menu:buttons',
                                                args = { house = house, id = 11, coords = v.coords.xyz }
                                            }
                                        }
                                    })
                                    lib.showContext('warehouse:interact:menu:04')
                                else
                                    exports['qb-menu']:openMenu({
                                        {
                                            isMenuHeader = true,
                                            header = locale("exit")
                                        },
                                        {
                                            header = locale('exit_label'),
                                            arrow = false,
                                            txt = "",
                                            disabled = not ((housesData[house] and not housesData[house].locked) or housesData[house] == nil),
                                            params = {
                                                event = 'warehouse:interact:menu:buttons',
                                                args = { house = house, id = 9, coords = v.coords.xyz }
                                            }
                                        },
                                        {
                                            header = locale('unlock_label'),
                                            arrow = false,
                                            txt = "",
                                            disabled = not (housesData[house] and housesData[house].locked) or
                                                housesData[house] == nil,
                                            params = {
                                                event = 'warehouse:interact:menu:buttons',
                                                args = { house = house, id = 10, coords = v.coords.xyz }
                                            }
                                        },
                                        {
                                            header = locale('lock_label'),
                                            arrow = false,
                                            txt = "",
                                            disabled = not ((CheckOwnership(house) or CheckAcess(house)) and housesData[house] and not housesData[house].locked),
                                            params = {
                                                event = 'warehouse:interact:menu:buttons',
                                                args = { house = house, id = 11, coords = v.coords.xyz }
                                            }
                                        }
                                    })
                                end
                            end

                            if Config.InteractionType == "3dtext" then
                                Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('exit')))
                            end
                        end
                        end,
                        onEnter = function()
                            if currentHouse == house then
                            if Config.InteractionType == "textui" then
                                TextUIShow('[E] - ' .. locale('exit'))
                            end
                        end
                        end,
                        onExit = function()
                            if currentHouse == house then
                            if Config.InteractionType == "textui" then
                                TextUIHide()
                            end
                        end
                        end
                    })
                end
            end
        end
    end)
end

function Drying(house, upgrade)
    if upgrade then
        if not zonesmaked[house .. "Load" .. Config.Warehouses[house].MoneyWash.UpgradedDry.Load.pos.xyz] then
            zonesmaked[house .. "Load" .. Config.Warehouses[house].MoneyWash.UpgradedDry.Load.pos.xyz] = true
            if Config.InteractionType == "target" then
                target:AddCircleZone("drc_dry_load" .. house, Config.Warehouses[house].MoneyWash.UpgradedDry.Load.pos
                    .xyz, 1.0, {
                        name = "drc_dry_load" .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        if Config.Input == "qb-input" then
                                            local dialog = exports['qb-input']:ShowInput({
                                                header = locale("Amount"),
                                                submitText = "Submit",
                                                inputs = {
                                                    {
                                                        text = locale("requirementwet") ..
                                                            '  \n ' ..
                                                            locale("RangeLaundry",
                                                                Config.Warehouses[house].MoneyWash.DryItems
                                                                .RequiredItems
                                                                .minimum,
                                                                Config.Warehouses[house].MoneyWash.DryItems
                                                                .RequiredItems
                                                                .maximum),
                                                        name = "input",
                                                        type = "number",
                                                        isRequired = true,
                                                    }
                                                }
                                            })
                                            if dialog then
                                                input = tonumber(dialog["input"])
                                            else
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return -- Return if dialog is nil
                                            end
                                        elseif Config.Input == "ox_lib" then
                                            local inputDialog = lib.inputDialog(locale("Amount"), {
                                                {
                                                    type = 'number',
                                                    label = locale("requirementwet"),
                                                    description = locale("RangeLaundry",
                                                        Config.Warehouses[house].MoneyWash.DryItems.RequiredItems
                                                        .minimum,
                                                        Config.Warehouses[house].MoneyWash.DryItems.RequiredItems
                                                        .maximum)
                                                },
                                            })
                                            if not inputDialog or not inputDialog[1] then
                                                Notify('error', locale('error'), locale('InvalidAmount'))
                                                return
                                            end
                                            input = tonumber(inputDialog[1])
                                        end

                                        if not input then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                        if input >= Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.maximum then
                                            lib.callback('drc_moneywash:checkloaded', false, function(value)
                                                if value then
                                                    if value == "nomoney" then
                                                        Notify("error", locale("error"), locale("nomoney"))
                                                    else
                                                        doingAction = true
                                                        dict = "anim@amb@business@coc@coc_unpack_cut_left@"
                                                        clip = "coke_cut_v1_coccutter"
                                                        RequestAnimDict(dict)
                                                        while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                        TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false,
                                                            false,
                                                            false)
                                                        ProgressBar(2500, locale("loadingmoney"))
                                                        ClearPedTasks(cache.ped)
                                                        TriggerServerEvent("drc_moneywash:loadmoney", house, input)
                                                        Notify("success", locale("success"), locale("loadedmoney"))
                                                        doingAction = false
                                                    end
                                                else
                                                    Notify("error", locale("error"), locale("alreadyloaded"))
                                                end
                                            end, house, input)
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                        end
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-print",
                                label = locale('loadmoney')
                            }
                        },
                        distance = 1.0
                    })
            else
                lib.zones.sphere({
                    coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Load.pos.xyz,
                    radius = 1,
                    debug = Config.Debug,
                    inside = function(self)
                        if currentHouse == house then
                        if IsControlJustReleased(0, 38) then
                            if (not doingAction) then
                                if Config.Input == "qb-input" then
                                    local dialog = exports['qb-input']:ShowInput({
                                        header = locale("Amount"),
                                        submitText = "Submit",
                                        inputs = {
                                            {
                                                text = locale("requirementwet") ..
                                                    '  \n ' ..
                                                    locale("RangeLaundry",
                                                        Config.Warehouses[house].MoneyWash.DryItems.RequiredItems
                                                        .minimum,
                                                        Config.Warehouses[house].MoneyWash.DryItems.RequiredItems
                                                        .maximum),
                                                name = "input",
                                                type = "number",
                                                isRequired = true,
                                            }
                                        }
                                    })
                                    if dialog then
                                        input = tonumber(dialog["input"])
                                    else
                                        Notify('error', locale('error'), locale('InvalidAmount'))
                                        return -- Return if dialog is nil
                                    end
                                elseif Config.Input == "ox_lib" then
                                    local inputDialog = lib.inputDialog(locale("Amount"), {
                                        {
                                            type = 'number',
                                            label = locale("requirementwet"),
                                            description = locale("RangeLaundry",
                                                Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.minimum,
                                                Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.maximum)
                                        },
                                    })
                                    if not inputDialog or not inputDialog[1] then
                                        Notify('error', locale('error'), locale('InvalidAmount'))
                                        return
                                    end
                                    input = tonumber(inputDialog[1])
                                end

                                if not input then
                                    Notify('error', locale('error'), locale('InvalidAmount'))
                                    return
                                end
                                if input >= Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.maximum then
                                    lib.callback('drc_moneywash:checkloaded', false, function(value)
                                        if value then
                                            if value == "nomoney" then
                                                Notify("error", locale("error"), locale("nomoney"))
                                            else
                                                doingAction = true
                                                dict = "anim@amb@business@coc@coc_unpack_cut_left@"
                                                clip = "coke_cut_v1_coccutter"
                                                local coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Load.pos
                                                    .xyz
                                                TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                SetTimeout(1100, function()
                                                    FreezeEntityPosition(cache.ped, true)
                                                end)
                                                RequestAnimDict(dict)
                                                while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                    false)
                                                ProgressBar(2500, locale("loadingmoney"))
                                                FreezeEntityPosition(cache.ped, false)
                                                ClearPedTasks(cache.ped)
                                                TriggerServerEvent("drc_moneywash:loadmoney", house, input)
                                                Notify("success", locale("success"), locale("loadedmoney"))
                                                doingAction = false
                                            end
                                        else
                                            Notify("error", locale("error"), locale("alreadyloaded"))
                                        end
                                    end, house, input)
                                else
                                    Notify('error', locale('error'), locale('InvalidAmount'))
                                end
                            end
                        end

                        if Config.InteractionType == "3dtext" then
                            Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('loadmoney')))
                        end
                    end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIShow('[E] - ' .. locale('loadmoney'))
                        end
                    end
                    end,
                    onExit = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIHide()
                        end
                    end
                    end
                })
            end
        end


        if not zonesmaked[house .. "Start" .. Config.Warehouses[house].MoneyWash.UpgradedDry.Start.pos.xyz] then
            zonesmaked[house .. "Start" .. Config.Warehouses[house].MoneyWash.UpgradedDry.Start.pos.xyz] = true
            if Config.InteractionType == "target" then
                target:AddCircleZone("drc_dry_start" .. house,
                    Config.Warehouses[house].MoneyWash.UpgradedDry.Start.pos.xyz, 1.0, {
                        name = "drc_dry_start" .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        lib.callback('drc_moneywash:checkstarted', false, function(value)
                                            if value then
                                                if value == "occupied" then
                                                    Notify('error', locale('error'), locale('Stationoccupied'))
                                                else
                                                    doingAction = true
                                                    dict = "anim@gangops@facility@servers@"
                                                    clip = "hotwire"
                                                    local coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Start
                                                        .pos
                                                        .xyz
                                                    TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                    SetTimeout(1100, function()
                                                        FreezeEntityPosition(cache.ped, true)
                                                    end)
                                                    RequestAnimDict(dict)
                                                    while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                        false)
                                                    ProgressBar(2500, locale("startingdry"))
                                                    FreezeEntityPosition(cache.ped, false)
                                                    ClearPedTasks(cache.ped)
                                                    TriggerServerEvent("drc_moneywash:startdrying", house)
                                                    Notify("success", locale("success"), locale("starteddry"))
                                                    doingAction = false
                                                end
                                            else
                                                Notify("error", locale("error"), locale("alreadystarted"))
                                            end
                                        end, house)
                                    end
                                end,
                                icon = "fas fa-print",
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                label = locale('startdry')
                            }
                        },
                        distance = 1.0
                    })
            else
                lib.zones.sphere({
                    coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Start.pos.xyz,
                    radius = 1,
                    debug = Config.Debug,
                    inside = function(self)
                        if currentHouse == house then
                        if IsControlJustReleased(0, 38) then
                            if (not doingAction) then
                                lib.callback('drc_moneywash:checkstarted', false, function(value)
                                    if value then
                                        if value == "occupied" then
                                            Notify('error', locale('error'), locale('Stationoccupied'))
                                        else
                                            doingAction = true
                                            dict = "anim@gangops@facility@servers@"
                                            clip = "hotwire"
                                            local coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Start.pos.xyz
                                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                            SetTimeout(1100, function()
                                                FreezeEntityPosition(cache.ped, true)
                                            end)
                                            RequestAnimDict(dict)
                                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                            ProgressBar(2500, locale("startingdry"))
                                            FreezeEntityPosition(cache.ped, false)
                                            ClearPedTasks(cache.ped)
                                            TriggerServerEvent("drc_moneywash:startdrying", house)
                                            Notify("success", locale("success"), locale("starteddry"))
                                            doingAction = false
                                        end
                                    else
                                        Notify("error", locale("error"), locale("alreadystarted"))
                                    end
                                end, house)
                            end
                        end

                        if Config.InteractionType == "3dtext" then
                            Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('startdry')))
                        end
                    end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIShow('[E] - ' .. locale('startdry'))
                        end
                    end
                    end,
                    onExit = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIHide()
                        end
                    end
                    end
                })
            end
        end

        if not zonesmaked[house .. "Collect" .. Config.Warehouses[house].MoneyWash.UpgradedDry.Collect.pos.xyz] then
            zonesmaked[house .. "Collect" .. Config.Warehouses[house].MoneyWash.UpgradedDry.Collect.pos.xyz] = true
            if Config.InteractionType == "target" then
                target:AddCircleZone("drc_dry_collect" .. house,
                    Config.Warehouses[house].MoneyWash.UpgradedDry.Collect.pos.xyz, 1.0, {
                        name = "drc_dry_collect" .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        lib.callback('drc_moneywash:checkdry', false, function(value)
                                            if value then
                                                if value == "notstarted" then
                                                    Notify("error", locale("error"), locale("notstarted"))
                                                else
                                                    doingAction = true
                                                    dict = "mini@repair"
                                                    clip = "fixing_a_ped"
                                                    local coords = Config.Warehouses[house].MoneyWash.UpgradedDry
                                                        .Collect
                                                        .pos.xyz
                                                    TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                    SetTimeout(1100, function()
                                                        FreezeEntityPosition(cache.ped, true)
                                                    end)
                                                    RequestAnimDict(dict)
                                                    while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                        false)
                                                    ProgressBar(2500, locale("collectingmoney"))
                                                    FreezeEntityPosition(cache.ped, false)
                                                    ClearPedTasks(cache.ped)
                                                    TriggerServerEvent("drc_moneywash:collectdrymoney", house)
                                                    Notify("success", locale("success"), locale("collectedgmoney"))
                                                    doingAction = false
                                                end
                                            else
                                                Notify("error", locale("error"), locale("cantcollect"))
                                            end
                                        end, house)
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-print",
                                label = locale('collectmoney')
                            },
                            {
                                action = function()
                                    if (not doingAction) then
                                        lib.callback('drc_moneywash:checkdry', false, function(value)
                                        end, house, "check")
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-clock",
                                label = locale('Checkwash')
                            },
                        },
                        distance = 1.0
                    })
            else
                lib.zones.sphere({
                    coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Collect.pos.xyz,
                    radius = 1,
                    debug = Config.Debug,
                    inside = function(self)
                        if currentHouse == house then
                        if IsControlJustReleased(0, 38) then
                            if Config.Context == "ox_lib" then
                                lib.registerContext({
                                    id = 'warehouse:interact:menu:05',
                                    title = locale('collect'),
                                    options = {
                                        {
                                            title = locale('collectmoney'),
                                            icon = "fas fa-print",
                                            event = 'warehouse:interact:menu:buttons',
                                            args = {
                                                house = house,
                                                id = 12,
                                                coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Collect.pos.xyz
                                            }
                                        },
                                        {
                                            title = locale('Checkwash'),
                                            icon = "fas fa-clock",
                                            event = 'warehouse:interact:menu:buttons',
                                            args = {
                                                house = house,
                                                id = 13,
                                                coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Collect.pos.xyz
                                            }
                                        }
                                    }
                                })
                                lib.showContext('warehouse:interact:menu:05')
                            else
                                exports['qb-menu']:openMenu({
                                    {
                                        isMenuHeader = true,
                                        header = locale("collect")
                                    },
                                    {
                                        header = locale('collectmoney'),
                                        arrow = false,
                                        txt = "",
                                        params = {
                                            event = 'warehouse:interact:menu:buttons',
                                            args = {
                                                house = house,
                                                id = 12,
                                                coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Collect.pos.xyz
                                            }
                                        }
                                    },
                                    {
                                        header = locale('Checkwash'),
                                        arrow = false,
                                        txt = "",
                                        params = {
                                            event = 'warehouse:interact:menu:buttons',
                                            args = {
                                                house = house,
                                                id = 13,
                                                coords = Config.Warehouses[house].MoneyWash.UpgradedDry.Collect.pos.xyz
                                            }
                                        }
                                    }
                                })
                            end
                        end

                        if Config.InteractionType == "3dtext" then
                            Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('collect')))
                        end
                    end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIShow('[E] - ' .. locale('collect'))
                        end
                    end
                    end,
                    onExit = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIHide()
                        end
                    end
                    end
                })
            end
        end
    else
        if not zonesmaked[house .. "Load" .. Config.Warehouses[house].MoneyWash.Dry.Load.pos.xyz] then
            zonesmaked[house .. "Load" .. Config.Warehouses[house].MoneyWash.Dry.Load.pos.xyz] = true
            if Config.InteractionType == "target" then
                target:AddCircleZone("drc_dry_load" .. house, Config.Warehouses[house].MoneyWash.Dry.Load.pos.xyz, 1.0, {
                    name = "drc_dry_load" .. house,
                    useZ = true,
                    debugPoly = Config.Debug,
                }, {
                    options = {
                        {
                            action = function()
                                if (not doingAction) then
                                    if Config.Input == "qb-input" then
                                        local dialog = exports['qb-input']:ShowInput({
                                            header = locale("Amount"),
                                            submitText = "Submit",
                                            inputs = {
                                                {
                                                    text = locale("requirementwet") ..
                                                        '  \n ' ..
                                                        locale("RangeLaundry",
                                                            Config.Warehouses[house].MoneyWash.DryItems.RequiredItems
                                                            .minimum,
                                                            Config.Warehouses[house].MoneyWash.DryItems.RequiredItems
                                                            .maximum),
                                                    name = "input",
                                                    type = "number",
                                                    isRequired = true,
                                                }
                                            }
                                        })
                                        if dialog then
                                            input = tonumber(dialog["input"])
                                        else
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return -- Return if dialog is nil
                                        end
                                    elseif Config.Input == "ox_lib" then
                                        local inputDialog = lib.inputDialog(locale("Amount"), {
                                            {
                                                type = 'number',
                                                label = locale("requirementwet"),
                                                description = locale("RangeLaundry",
                                                    Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.minimum,
                                                    Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.maximum)
                                            },
                                        })
                                        if not inputDialog or not inputDialog[1] then
                                            Notify('error', locale('error'), locale('InvalidAmount'))
                                            return
                                        end
                                        input = tonumber(inputDialog[1])
                                    end

                                    if not input then
                                        Notify('error', locale('error'), locale('InvalidAmount'))
                                        return
                                    end
                                    if input >= Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.maximum then
                                        lib.callback('drc_moneywash:checkloaded', false, function(value)
                                            if value then
                                                if value == "nomoney" then
                                                    Notify("error", locale("error"), locale("nomoney"))
                                                else
                                                    doingAction = true
                                                    dict = "anim@amb@business@coc@coc_unpack_cut_left@"
                                                    clip = "coke_cut_v1_coccutter"
                                                    local coords = Config.Warehouses[house].MoneyWash.Dry.Load.pos.xyz
                                                    TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                    SetTimeout(1100, function()
                                                        FreezeEntityPosition(cache.ped, true)
                                                    end)
                                                    RequestAnimDict(dict)
                                                    while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                        false)
                                                    ProgressBar(2500, locale("loadingmoney"))
                                                    FreezeEntityPosition(cache.ped, false)
                                                    ClearPedTasks(cache.ped)
                                                    TriggerServerEvent("drc_moneywash:loadmoney", house, input)
                                                    Notify("success", locale("success"), locale("loadedmoney"))
                                                    doingAction = false
                                                end
                                            else
                                                Notify("error", locale("error"), locale("alreadyloaded"))
                                            end
                                        end, house, input)
                                    else
                                        Notify('error', locale('error'), locale('InvalidAmount'))
                                    end
                                end
                            end,
                            canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                            end,
                            icon = "fas fa-print",
                            label = locale('loadmoney')
                        }
                    },
                    distance = 1.0
                })
            else
                lib.zones.sphere({
                    coords = Config.Warehouses[house].MoneyWash.Dry.Load.pos.xyz,
                    radius = 1,
                    debug = Config.Debug,
                    inside = function(self)
                        if currentHouse == house then
                        if IsControlJustReleased(0, 38) then
                            if (not doingAction) then
                                if Config.Input == "qb-input" then
                                    local dialog = exports['qb-input']:ShowInput({
                                        header = locale("Amount"),
                                        submitText = "Submit",
                                        inputs = {
                                            {
                                                text = locale("requirementwet") ..
                                                    '  \n ' ..
                                                    locale("RangeLaundry",
                                                        Config.Warehouses[house].MoneyWash.DryItems.RequiredItems
                                                        .minimum,
                                                        Config.Warehouses[house].MoneyWash.DryItems.RequiredItems
                                                        .maximum),
                                                name = "input",
                                                type = "number",
                                                isRequired = true,
                                            }
                                        }
                                    })
                                    if dialog then
                                        input = tonumber(dialog["input"])
                                    else
                                        Notify('error', locale('error'), locale('InvalidAmount'))
                                        return -- Return if dialog is nil
                                    end
                                elseif Config.Input == "ox_lib" then
                                    local inputDialog = lib.inputDialog(locale("Amount"), {
                                        {
                                            type = 'number',
                                            label = locale("requirementwet"),
                                            description = locale("RangeLaundry",
                                                Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.minimum,
                                                Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.maximum)
                                        },
                                    })
                                    if not inputDialog or not inputDialog[1] then
                                        Notify('error', locale('error'), locale('InvalidAmount'))
                                        return
                                    end
                                    input = tonumber(inputDialog[1])
                                end

                                if not input then
                                    Notify('error', locale('error'), locale('InvalidAmount'))
                                    return
                                end
                                if input >= Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.DryItems.RequiredItems.maximum then
                                    lib.callback('drc_moneywash:checkloaded', false, function(value)
                                        if value then
                                            if value == "nomoney" then
                                                Notify("error", locale("error"), locale("nomoney"))
                                            else
                                                doingAction = true
                                                dict = "anim@amb@business@coc@coc_unpack_cut_left@"
                                                clip = "coke_cut_v1_coccutter"
                                                local coords = Config.Warehouses[house].MoneyWash.Dry.Load.pos.xyz
                                                TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                SetTimeout(1100, function()
                                                    FreezeEntityPosition(cache.ped, true)
                                                end)
                                                RequestAnimDict(dict)
                                                while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                    false)
                                                ProgressBar(2500, locale("loadingmoney"))
                                                FreezeEntityPosition(cache.ped, false)
                                                ClearPedTasks(cache.ped)
                                                TriggerServerEvent("drc_moneywash:loadmoney", house, input)
                                                Notify("success", locale("success"), locale("loadedmoney"))
                                                doingAction = false
                                            end
                                        else
                                            Notify("error", locale("error"), locale("alreadyloaded"))
                                        end
                                    end, house, input)
                                else
                                    Notify('error', locale('error'), locale('InvalidAmount'))
                                end
                            end
                        end

                        if Config.InteractionType == "3dtext" then
                            Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('loadmoney')))
                        end
                    end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIShow('[E] - ' .. locale('loadmoney'))
                        end
                    end
                    end,
                    onExit = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIHide()
                        end
                    end
                    end
                })
            end
        end

        if not zonesmaked[house .. "Start" .. Config.Warehouses[house].MoneyWash.Dry.Start.pos.xyz] then
            zonesmaked[house .. "Start" .. Config.Warehouses[house].MoneyWash.Dry.Start.pos.xyz] = true
            if Config.InteractionType == "target" then
                target:AddCircleZone("drc_dry_start" .. house, Config.Warehouses[house].MoneyWash.Dry.Start.pos.xyz, 1.0,
                    {
                        name = "drc_dry_start" .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        lib.callback('drc_moneywash:checkstarted', false, function(value)
                                            if value then
                                                if value == "occupied" then
                                                    Notify('error', locale('error'), locale('Stationoccupied'))
                                                else
                                                    doingAction = true
                                                    dict = "anim@gangops@facility@servers@"
                                                    clip = "hotwire"
                                                    local coords = Config.Warehouses[house].MoneyWash.Dry.Start.pos.xyz
                                                    TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                    SetTimeout(1100, function()
                                                        FreezeEntityPosition(cache.ped, true)
                                                    end)
                                                    RequestAnimDict(dict)
                                                    while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                        false)
                                                    ProgressBar(2500, locale("startingdry"))
                                                    FreezeEntityPosition(cache.ped, false)
                                                    ClearPedTasks(cache.ped)
                                                    TriggerServerEvent("drc_moneywash:startdrying", house)
                                                    Notify("success", locale("success"), locale("starteddry"))
                                                    doingAction = false
                                                end
                                            else
                                                Notify("error", locale("error"), locale("alreadystarted"))
                                            end
                                        end, house)
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-print",
                                label = locale('startdry')
                            }
                        },
                        distance = 1.0
                    })
            else
                lib.zones.sphere({
                    coords = Config.Warehouses[house].MoneyWash.Dry.Start.pos.xyz,
                    radius = 1,
                    debug = Config.Debug,
                    inside = function(self)
                        if currentHouse == house then
                        if IsControlJustReleased(0, 38) then
                            if (not doingAction) then
                                lib.callback('drc_moneywash:checkstarted', false, function(value)
                                    if value then
                                        if value == "occupied" then
                                            Notify('error', locale('error'), locale('Stationoccupied'))
                                        else
                                            doingAction = true
                                            dict = "anim@gangops@facility@servers@"
                                            clip = "hotwire"
                                            local coords = Config.Warehouses[house].MoneyWash.Dry.Start.pos.xyz
                                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                            SetTimeout(1100, function()
                                                FreezeEntityPosition(cache.ped, true)
                                            end)
                                            RequestAnimDict(dict)
                                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                                            ProgressBar(2500, locale("startingdry"))
                                            FreezeEntityPosition(cache.ped, false)
                                            ClearPedTasks(cache.ped)
                                            TriggerServerEvent("drc_moneywash:startdrying", house)
                                            Notify("success", locale("success"), locale("starteddry"))
                                            doingAction = false
                                        end
                                    else
                                        Notify("error", locale("error"), locale("alreadystarted"))
                                    end
                                end, house)
                            end
                        end

                        if Config.InteractionType == "3dtext" then
                            Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('startdry')))
                        end
                    end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIShow('[E] - ' .. locale('startdry'))
                        end
                    end
                    end,
                    onExit = function()
                        if currentHouse == house then
                        if Config.InteractionType == "textui" then
                            TextUIHide()
                        end
                    end
                    end
                })
            end
        end

        if not zonesmaked[house .. "Collect" .. Config.Warehouses[house].MoneyWash.Dry.Collect.pos.xyz] then
            zonesmaked[house .. "Collect" .. Config.Warehouses[house].MoneyWash.Dry.Collect.pos.xyz] = true
            if Config.InteractionType == "target" then
                target:AddCircleZone("drc_dry_collect" .. house, Config.Warehouses[house].MoneyWash.Dry.Collect.pos.xyz,
                    1.0, {
                        name = "drc_dry_collect" .. house,
                        useZ = true,
                        debugPoly = Config.Debug,
                    }, {
                        options = {
                            {
                                action = function()
                                    if (not doingAction) then
                                        lib.callback('drc_moneywash:checkdry', false, function(value)
                                            if value then
                                                if value == "notstarted" then
                                                    Notify("error", locale("error"), locale("notstarted"))
                                                else
                                                    doingAction = true
                                                    dict = "mini@repair"
                                                    clip = "fixing_a_ped"
                                                    local coords = Config.Warehouses[house].MoneyWash.Dry
                                                        .Collect
                                                        .pos.xyz
                                                    TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                                                    SetTimeout(1100, function()
                                                        FreezeEntityPosition(cache.ped, true)
                                                    end)
                                                    RequestAnimDict(dict)
                                                    while (not HasAnimDictLoaded(dict)) do Wait(0) end
                                                    TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false,
                                                        false)
                                                    ProgressBar(2500, locale("collectingmoney"))
                                                    FreezeEntityPosition(cache.ped, false)
                                                    ClearPedTasks(cache.ped)
                                                    TriggerServerEvent("drc_moneywash:collectdrymoney", house)
                                                    Notify("success", locale("success"), locale("collectedgmoney"))
                                                    doingAction = false
                                                end
                                            else
                                                Notify("error", locale("error"), locale("cantcollect"))
                                            end
                                        end, house)
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-print",
                                label = locale('collectmoney')
                            },
                            {
                                action = function()
                                    if (not doingAction) then
                                        lib.callback('drc_moneywash:checkdry', false, function(value)
                                        end, house, "check")
                                    end
                                end,
                                canInteract = function(entity, distance, data)
                                    return (house == currentHouse)
                                end,
                                icon = "fas fa-clock",
                                label = locale('Checkwash')
                            },
                        },
                        distance = 1.0
                    })
            else
                lib.zones.sphere({
                    coords = Config.Warehouses[house].MoneyWash.Dry.Collect.pos.xyz,
                    radius = 1,
                    debug = Config.Debug,
                    inside = function(self)
                        if currentHouse == house then
                            if IsControlJustReleased(0, 38) then
                                if Config.Context == "ox_lib" then
                                    lib.registerContext({
                                        id = 'warehouse:interact:menu:06',
                                        title = locale('collect'),
                                        options = {
                                            {
                                                title = locale('collectmoney'),
                                                icon = "fas fa-print",
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 12,
                                                    coords = Config.Warehouses[house].MoneyWash.Dry.Collect.pos.xyz
                                                }
                                            },
                                            {
                                                title = locale('Checkwash'),
                                                icon = "fas fa-clock",
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 13,
                                                    coords = Config.Warehouses[house].MoneyWash.Dry.Collect.pos.xyz
                                                }
                                            }
                                        }
                                    })
                                    lib.showContext('warehouse:interact:menu:06')
                                else
                                    exports['qb-menu']:openMenu({
                                        {
                                            isMenuHeader = true,
                                            header = locale("collect")
                                        },
                                        {
                                            header = locale('collectmoney'),
                                            arrow = false,
                                            txt = "",
                                            params = {
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    id = 12,
                                                    coords = Config.Warehouses[house].MoneyWash.Dry.Collect.pos.xyz
                                                }
                                            }
                                        },
                                        {
                                            header = locale('Checkwash'),
                                            arrow = false,
                                            txt = "",
                                            params = {
                                                event = 'warehouse:interact:menu:buttons',
                                                args = {
                                                    house = house,
                                                    place = place,
                                                    id = 13,
                                                    coords = Config.Warehouses[house].MoneyWash.Dry.Collect.pos.xyz
                                                }
                                            }
                                        }
                                    })
                                end
                            end

                            if Config.InteractionType == "3dtext" then
                                Draw3DText(self.coords, string.format("[~g~E~w~] - %s", locale('collect')))
                            end
                        end
                    end,
                    onEnter = function()
                        if currentHouse == house then
                            if Config.InteractionType == "textui" then
                                TextUIShow('[E] - ' .. locale('collect'))
                            end
                        end
                    end,
                    onExit = function()
                        if currentHouse == house then
                            if Config.InteractionType == "textui" then
                                TextUIHide()
                            end
                    end
                    end
                })
            end
        end
    end
end

RegisterNetEvent("drc_moneywash:lasercheck")
AddEventHandler("drc_moneywash:lasercheck", function(laser, house)
    Wait(1500)
    if currentHouse == house then
        if HouseHacked[house] then
            for b, g in pairs(Lasers) do
                g.setActive(false)
                g.setVisible(false)
            end
        else
            for k, v in pairs(Config.Warehouses[house].MoneyWash.Lasers) do
                if "Laser" .. k == laser.name and not v.spawned then
                    if not HouseHacked[house] then
                        hittedbylaser = false
                        v.spawned = true
                        local k = Laser.new(
                            v.FromCoords,
                            v.ToCoords,
                            {
                                travelTimeBetweenTargets = { 6.0, 6.0 },
                                waitTimeAtTargets = { 3.0, 3.00 },
                                randomTargetSelection = true,
                                name = "Laser" .. k
                            }
                        )
                        k.setVisible(true)
                        k.setActive(true)
                        k.setMoving(true)
                        if v.Visible then
                            k.setColor(255, 0, 0, 100)
                        else
                            k.setColor(255, 0, 0, 10)
                        end
                        k.onPlayerHit(function(playerBeingHit, hitPos)
                            if playerBeingHit and not hittedbylaser then
                                if housesData and housesData[house] and housesData[house].alarm then
                                    hittedbylaser = true
                                    AlarmSound()
                                    Dispatch(house)
                                end
                            end
                        end)
                        table.insert(Lasers, k)
                        TriggerServerEvent('drc_moneywash:lasercheck', k, house)
                        TriggerServerEvent("drc_moneywash:CheckHackedHouse", house)
                    end
                end
            end
            for b, g in pairs(Lasers) do
                if g.name == laser.name then
                    g.setVisible(true)
                    g.setActive(true)
                    g.setMoving(true)
                end
            end
        end
    end
end)

RegisterNetEvent("drc_moneywash:HackedSync")
AddEventHandler("drc_moneywash:HackedSync", function(house)
    if currentHouse == house then
        HouseHacked[house] = true
        for b, g in pairs(Lasers) do
            g.setActive(false)
            g.setVisible(false)
        end
    end
end)

function doLockpickAnimation(coords)
    if not Lockpicking then return end
    local Lockpickprop = `prop_tool_screwdvr01`
    RequestAnimDict("mp_arresting")
    while not HasAnimDictLoaded("mp_arresting") do Wait(100) end
    RequestModel(Lockpickprop)
    while not HasModelLoaded(Lockpickprop) do Wait(100) end
    local ped = PlayerPedId()
    lockpickobject = CreateObject(Lockpickprop, 0.0, 0.0, 0.0, true, true, false)
    local LockpickBoneIndex = GetPedBoneIndex(ped, 57005)
    AttachEntityToEntity(lockpickobject, ped, LockpickBoneIndex, 0.14, 0.06, 0.02, 51.0, -90.0, -40.0, true, true, false,
        false, 1, true)
    SetModelAsNoLongerNeeded(Lockpickprop)
    TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
    CreateThread(function()
        while Lockpicking do
            Wait(0)
            if not IsEntityPlayingAnim(ped, "mp_arresting", "a_uncuff", 3) then
                TaskPlayAnim(ped, "mp_arresting", "a_uncuff", 3.0, 1.0, -1, 49, 0, false, false, false)
            end
        end
        ClearPedSecondaryTask(ped)
        Wait(250)
        DetachEntity(lockpickobject, true, false)
        DeleteEntity(lockpickobject)
    end)
end

function doAnimation()
    if not Hacking then return end
    RequestAnimDict(tabletDict)
    while not HasAnimDictLoaded(tabletDict) do Wait(100) end
    RequestModel(tabletProp)
    while not HasModelLoaded(tabletProp) do Wait(100) end
    local ped = PlayerPedId()
    tabletObj = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)
    local tabletBoneIndex = GetPedBoneIndex(ped, tabletBone)
    AttachEntityToEntity(tabletObj, ped, tabletBoneIndex, tabletOffset.x, tabletOffset.y, tabletOffset.z, tabletRot.x,
        tabletRot.y, tabletRot.z, true, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(tabletProp)
    CreateThread(function()
        while Hacking do
            Wait(0)
            if not IsEntityPlayingAnim(ped, tabletDict, tabletAnim, 3) then
                TaskPlayAnim(ped, tabletDict, tabletAnim, 3.0, 1.0, -1, 49, 0, false, false, false)
            end
        end
        ClearPedSecondaryTask(ped)
        Wait(250)
        DetachEntity(tabletObj, true, false)
        DeleteEntity(tabletObj)
    end)
end

RegisterNetEvent("warehouse:interact:menu:buttons", function(data)
    if (not doingAction) then
        house = data.house
        if data.id == 1 then
            place = data.place
            house = data.house
            animation = data.animation
            action = data.action
            if Config.Input == "qb-input" then
                local dialog = exports['qb-input']:ShowInput({
                    header = locale("Amount"),
                    submitText = "Submit",
                    inputs = {
                        {
                            text = locale("requirementunmarked") ..
                                '  \n ' ..
                                locale("RangeLaundry", Config.Warehouses[house].MoneyWash.WashItems.RequiredItems
                                    .minimum,
                                    Config.Warehouses[house].MoneyWash.WashItems.RequiredItems.maximum),
                            name = "input",
                            type = "number",
                            isRequired = true,
                        }
                    }
                })
                if dialog then
                    input = tonumber(dialog["input"])
                else
                    Notify('error', locale('error'), locale('InvalidAmount'))
                    return
                end
            elseif Config.Input == "ox_lib" then
                local inputDialog = lib.inputDialog(locale("Amount"), {
                    {
                        type = 'number',
                        label = locale("requirementunmarked"),
                        description = locale("RangeLaundry",
                            Config.Warehouses[house].MoneyWash.WashItems.RequiredItems.minimum,
                            Config.Warehouses[house].MoneyWash.WashItems.RequiredItems.maximum)
                    },
                })
                if not inputDialog or not inputDialog[1] then
                    Notify('error', locale('error'), locale('InvalidAmount'))
                    return
                end
                input = tonumber(inputDialog[1])
            end

            if not input then
                Notify('error', locale('error'), locale('InvalidAmount'))
                return
            end

            if input >= Config.Warehouses[house].MoneyWash.WashItems.RequiredItems.minimum and input <= Config.Warehouses[house].MoneyWash.WashItems.RequiredItems.maximum then
                lib.callback('drc_moneywash:checkwash', false, function(value)
                    if value then
                        if value == "occupied" then
                            Notify('error', locale('error'), locale('Stationoccupied'))
                        elseif value == "started" then
                            Notify('error', locale('error'), locale('alreadywash'))
                        else
                            SceneHandler(action[3], animation.xyz, place, house, input)
                        end
                    else
                        Notify('error', locale('error'), locale('nounmarkedmoney'))
                    end
                end, house, place, "start", input)
            else
                Notify('error', locale('error'), locale('InvalidAmount'))
            end
        elseif data.id == 2 then
            place = data.place
            house = data.house
            if (not doingAction) then
                lib.callback('drc_moneywash:checkwash', false, function(value)
                end, house, place, "check")
            end
        elseif data.id == 3 then
            place = data.place
            house = data.house
            if (not doingAction) then
                lib.callback('drc_moneywash:checkwash', false, function(value)
                end, house, place, "collect")
            end
        elseif data.id == 4 then
            house = data.house
            if (not doingAction) then
                if Config.Input == "qb-input" then
                    local dialog = exports['qb-input']:ShowInput({
                        header = locale("managesec"),
                        submitText = "Submit",
                        inputs = {
                            {
                                text = locale('setwebhook'),
                                name = "input",
                                type = "text",
                                isRequired = true,
                            }
                        }
                    })
                    if dialog then
                        input = dialog["input"]
                    else
                        Notify('error', locale('error'), locale('InvalidAmount'))
                        return
                    end
                elseif Config.Input == "ox_lib" then
                    local inputDialog = lib.inputDialog(locale("managesec"), {
                        { type = 'input', label = locale('setwebhook') },
                    })

                    if not inputDialog or not inputDialog[1] then
                        Notify('error', locale('error'), locale('InvalidAmount'))
                        return
                    end

                    input = inputDialog[1]
                end

                if not input then
                    Notify('error', locale('error'), locale('InvalidAmount'))
                    return
                end

                if verifyWebhookURL(input) then
                    lib.callback('drc_moneywash:managewebhook', false, function(value)
                        doingAction = true
                        dict = "anim@heists@prison_heiststation@cop_reactions"
                        clip = "cop_b_idle"
                        local coords = data.coords
                        TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                        SetTimeout(1100, function()
                            FreezeEntityPosition(cache.ped, true)
                        end)
                        RequestAnimDict(dict)
                        while (not HasAnimDictLoaded(dict)) do Wait(0) end
                        TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                        ProgressBar(2500, locale("changingwebhook"))
                        FreezeEntityPosition(cache.ped, false)
                        ClearPedTasks(cache.ped)
                        doingAction = false
                    end, house, input)
                else
                end
            end
        elseif data.id == 5 then
            house = data.house
            if (not doingAction) then
                if Config.Input == "qb-input" then
                    local dialog = exports['qb-input']:ShowInput({
                        header = locale("giveaccess"),
                        submitText = "Submit",
                        inputs = {
                            {
                                text = locale("nickname") .. '  \n ' .. locale("nicknamedesc"),
                                name = "input",
                                type = "text",
                                isRequired = true,
                            }
                        }
                    })
                    if dialog then
                        input = dialog["input"]
                    else
                        Notify('error', locale('error'), locale('InvalidAmount'))
                        return
                    end
                elseif Config.Input == "ox_lib" then
                    local inputDialog = lib.inputDialog(locale("giveaccess"), {
                        { type = 'input', label = locale("nickname"), description = locale("nicknamedesc") },
                    })
                    if not inputDialog or not inputDialog[1] then
                        Notify('error', locale('error'), locale('InvalidAmount'))
                        return
                    end
                    input = inputDialog[1]
                end

                if not input then
                    Notify('error', locale('error'), locale('InvalidAmount'))
                    return
                end

                local TargetPlayer, dist = GetClosestEntity(GetPlayers(true, true), true,
                    GetEntityCoords(cache.ped), nil)
                FillingInProgress = false
                if TargetPlayer ~= -1 then
                    lib.callback('drc_moneywash:givekeys', false, function(value)
                        doingAction = true
                        dict = "anim@heists@prison_heiststation@cop_reactions"
                        clip = "cop_b_idle"
                        local coords = data.coords
                        TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                        SetTimeout(1100, function()
                            FreezeEntityPosition(cache.ped, true)
                        end)
                        RequestAnimDict(dict)
                        while (not HasAnimDictLoaded(dict)) do Wait(0) end
                        TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                        ProgressBar(2500, locale("givingaccess"))
                        FreezeEntityPosition(cache.ped, false)
                        ClearPedTasks(cache.ped)
                        doingAction = false
                    end, house, GetPlayerServerId(TargetPlayer), input)
                end
            end
        elseif data.id == 6 then
            house = data.house
            if (not doingAction) then
                lib.callback('drc_moneywash:getaccess', false, function(value)
                    options = {}
                    if value then
                        for k, v in pairs(value) do
                            options["[" .. k .. "] - " .. v] = {}
                            options["[" .. k .. "] - " .. v].arrow = false
                            options["[" .. k .. "] - " .. v].description = locale("removeaccess")
                            options["[" .. k .. "] - " .. v].event = 'drc_moneywash:removekeys'
                            options["[" .. k .. "] - " .. v].args = { house = house, value = k, name = v }
                        end
                        lib.registerContext({
                            id = 'Shop',
                            title = locale("removeaccess"),
                            options = options
                        })
                        lib.showContext('Shop')
                    end
                end, house)
            end
        elseif data.id == 7 then
            NeedItem = data.NeedItem
            Item = data.Item
            house = data.house
            local HaveLaptop = true
            if NeedItem then
                HaveLaptop = false
                lib.callback('drc_moneywash:getitem', false, function(value)
                    if value then
                        HaveLaptop = true
                    else
                        HaveLaptop = false
                        Notify('error', locale('error'), locale('NeedLaptop'))
                        return
                    end
                end, Item)
            end
            SetTimeout(500, function()
                if not doingAction and HaveLaptop then
                    if not HouseHacked[house] then
                        Hacking = true
                        doAnimation()
                        FreezeEntityPosition(cache.ped, true)
                        if HackingMinigame() then
                            Hacking = false
                            FreezeEntityPosition(cache.ped, false)
                            Notify('success', locale('success'), locale('hacked'))
                            TriggerServerEvent("drc_moneywash:AddHackedHouse", house)
                        else
                            if housesData and housesData[house] and housesData[house].alarm then
                                Dispatch(house)
                                AlarmSound()
                            end
                            Hacking = false
                            FreezeEntityPosition(cache.ped, false)
                            Notify('error', locale('error'), locale('failed'))
                        end
                    elseif HouseHacked[house] and not HaveLaptop then
                        Notify('success', locale('success'), locale('AlreadyHacked'))
                    end
                end
            end)
        elseif data.id == 9 then
            house = data.house
            if (not doingAction) then
                leaveHouse(house)
            end
        elseif data.id == 10 then
            doingAction = true
            house = data.house
            dict = "mp_arresting"
            clip = "a_uncuff"
            local coords = data.coords
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("unlocking"))
            FreezeEntityPosition(cache.ped, false)
            UnlockHouse(house)
            doingAction = false
            ClearPedTasks(cache.ped)
        elseif data.id == 11 then
            doingAction = true
            house = data.house
            dict = "mp_arresting"
            clip = "a_uncuff"
            local coords = data.coords
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("locking"))
            FreezeEntityPosition(cache.ped, false)
            LockHouse(house)
            ClearPedTasks(cache.ped)
            doingAction = false
        elseif data.id == 12 then
            house = data.house
            if (not doingAction) then
                lib.callback('drc_moneywash:checkdry', false, function(value)
                    if value then
                        if value == "notstarted" then
                            Notify("error", locale("error"), locale("notstarted"))
                        else
                            doingAction = true
                            dict = "mini@repair"
                            clip = "fixing_a_ped"
                            local coords = data.coords
                            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                            SetTimeout(1100, function()
                                FreezeEntityPosition(cache.ped, true)
                            end)
                            RequestAnimDict(dict)
                            while (not HasAnimDictLoaded(dict)) do Wait(0) end
                            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                            ProgressBar(2500, locale("collectingmoney"))
                            FreezeEntityPosition(cache.ped, false)
                            ClearPedTasks(cache.ped)
                            TriggerServerEvent("drc_moneywash:collectdrymoney", house)
                            Notify("success", locale("success"), locale("collectedgmoney"))
                            doingAction = false
                        end
                    else
                        Notify("error", locale("error"), locale("cantcollect"))
                    end
                end, house)
            end
        elseif data.id == 13 then
            house = data.house
            if (not doingAction) then
                lib.callback('drc_moneywash:checkdry', false, function(value)
                end, house, "check")
            end
        elseif data.id == 14 then
            house = data.house
            lib.callback('drc_moneywash:checkdry', false, function(value)
                if value then
                    if value == "notstarted" then
                        Notify("error", locale("error"), locale("notstarted"))
                    else
                        doingAction = true
                        dict = "mini@repair"
                        clip = "fixing_a_ped"
                        RequestAnimDict(dict)
                        local coords = data.coords
                        TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
                        SetTimeout(1100, function()
                            FreezeEntityPosition(cache.ped, true)
                        end)
                        while (not HasAnimDictLoaded(dict)) do Wait(0) end
                        TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
                        ProgressBar(2500, locale("collectingmoney"))
                        FreezeEntityPosition(cache.ped, false)
                        ClearPedTasks(cache.ped)
                        TriggerServerEvent("drc_moneywash:collectdrymoney", house)
                        Notify("success", locale("success"), locale("collectedgmoney"))
                        doingAction = false
                    end
                else
                    Notify("error", locale("error"), locale("cantcollect"))
                end
            end, house)
        elseif data.id == 15 then
            house = data.house
            place = data.place
            lib.callback('drc_moneywash:checkwash', false, function(value)
            end, house, place, "check")
        elseif data.id == 16 then
            house = data.house
            enterHouse(house, true)
        elseif data.id == 17 then
            doingAction = true
            house = data.house
            dict = "timetable@jimmy@doorknock@"
            clip = "knockdoor_idle"
            local coords = data.coords
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("knocking"))
            KnockOnDoors(house)
            ClearPedTasks(cache.ped)
            FreezeEntityPosition(cache.ped, false)
            doingAction = false
        elseif data.id == 18 then
            doingAction = true
            house = data.house
            dict = "mp_arresting"
            clip = "a_uncuff"
            local coords = data.coords
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("unlocking"))
            UnlockHouse(house)
            ClearPedTasks(cache.ped)
            FreezeEntityPosition(cache.ped, false)
            doingAction = false
        elseif data.id == 19 then
            doingAction = true
            house = data.house
            dict = "mp_arresting"
            clip = "a_uncuff"
            local coords = data.coords
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("locking"))
            LockHouse(house)
            ClearPedTasks(cache.ped)
            FreezeEntityPosition(cache.ped, false)
            doingAction = false
        elseif data.id == 20 then
            enterHouse(house, false)
        elseif data.id == 21 then
            doingAction = true
            local coords = data.coords
            house = data.house
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            dict = "mp_arresting"
            clip = "a_uncuff"
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("ONalarmprog"))
            FreezeEntityPosition(cache.ped, false)
            TurnAlarm(house)
            ClearPedTasks(cache.ped)
            Notify('success', locale('success'), locale('ONalarmnot'))
            doingAction = false
        elseif data.id == 22 then
            doingAction = true
            local coords = data.coords
            house = data.house
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            dict = "mp_arresting"
            clip = "a_uncuff"
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("OFFalarmprog"))
            FreezeEntityPosition(cache.ped, false)
            TurnAlarm(house, false)
            ClearPedTasks(cache.ped)
            Notify('success', locale('success'), locale('OFFalarmnot'))
            doingAction = false
        elseif data.id == 23 then
            house = data.house
            doingAction = true
            local coords = data.coords
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            dict = "mp_arresting"
            clip = "a_uncuff"
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("ONlightsprog"))
            FreezeEntityPosition(cache.ped, false)
            TurnLights(house, true)
            ClearPedTasks(cache.ped)
            Notify('success', locale('success'), locale('ONlightsnot'))
            doingAction = false
        elseif data.id == 24 then
            doingAction = true
            house = data.house
            local coords = data.coords
            TaskTurnPedToFaceCoord(cache.ped, coords, 1000)
            SetTimeout(1100, function()
                FreezeEntityPosition(cache.ped, true)
            end)
            dict = "mp_arresting"
            clip = "a_uncuff"
            RequestAnimDict(dict)
            while (not HasAnimDictLoaded(dict)) do Wait(0) end
            TaskPlayAnim(cache.ped, dict, clip, 3.0, 1.0, -1, 49, 0, false, false, false)
            ProgressBar(2500, locale("OFFlightsprog"))
            FreezeEntityPosition(cache.ped, false)
            TurnLights(house, false)
            ClearPedTasks(cache.ped)
            Notify('success', locale('success'), locale('OFFlightsnot'))
            doingAction = false
        end
    end
end)

local thread

function Lights(house, enabled)
    if enabled and not thread then
        thread = CreateThread(function()
            local timecycleEnabled = false
            while true do
                local sleep = 1500
                if Config.TimeChange then
                    if currentHouse and housesData[currentHouse] and not housesData[currentHouse].lights then
                        sleep = 0
                        if Config.TimeSync == 'cd_easytime' then
                            TriggerEvent('cd_easytime:PauseSync', true)
                        end
                        SetTimecycleModifier("Truck_Int_FIX_TRIP1_MCS2")
                        SetTimecycleModifierStrength(1.0)
                        timecycleEnabled = true
                        NetworkOverrideClockTime(2, 0, 0)
                    elseif timecycleEnabled or (currentHouse and housesData[currentHouse] and housesData[currentHouse].lights) then
                        if Config.TimeSync == 'cd_easytime' then
                            TriggerEvent('cd_easytime:PauseSync', false)
                        end
                        ClearTimecycleModifier()
                        timecycleEnabled = false
                    end
                end
                Wait(sleep)
            end
        end)
    elseif not enabled or (housesData[house] and housesData[house].lights) then
        if Config.TimeSync == 'cd_easytime' then
            TriggerEvent('cd_easytime:PauseSync', false)
        end
        ClearTimecycleModifier()
        timecycleEnabled = false

        if thread then
            TerminateThread(thread)
            thread = nil
        end
    end
end
