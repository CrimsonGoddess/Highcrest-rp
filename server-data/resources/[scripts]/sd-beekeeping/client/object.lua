local locale = SD.Locale.T
local ObjectList = {} -- Object, Model, Coords, IsRendered, SpawnRange
local PlacingObject, LoadedObjects, PlacingItemObject, CurrentHiveType = false, false, nil, nil
local CurrentModel, CurrentObject, CurrentObjectType, CurrentObjectName, CurrentSpawnRange, CurrentCoords = nil, nil, nil, nil, nil, nil
local honeyZones = {} -- Table to store honey zones
local hasSpawnThreadStarted = false -- Variable to track if spawn thread started
local FacilityBlips = {}


local model_bee_house, model_bee_hive = nil, nil
model_bee_hive = Beekeeping.Props.bee_hive
model_bee_house = Beekeeping.Props.bee_house

local ObjectParams = {
    ['house'] = {
        object = model_bee_house,
        event = 'sd-beekeeping:openBeeHouse',
        icon = 'fa-solid fa-bug',
        label = locale('target.open_bee_house'),
        SpawnRange = Beekeeping.SpawnRange,
        defaultData = {
            workers = 0,
            queens = 0,
            time = 0,
        }
    },
    ['hive'] = {
        object = model_bee_hive,
        event = 'sd-beekeeping:openBeeHive',
        icon = 'fa-solid fa-bug',
        label = locale('target.open_bee_hive'),
        SpawnRange = Beekeeping.SpawnRange,
        defaultData = {
            haveQueen = false,
            haveWorker = false,
            honey = 0,
            wax = 0,
            time = 0,
        }
    },
}

--- Function to create honey zones from configuration
--- @param zonesConfig table The zones configuration from cconfig.lua
local CreateHoneyZones = function(zonesConfig)
    for _, zoneData in ipairs(zonesConfig) do
        local zone = lib.zones.poly({
            points = zoneData.points,
            thickness = zoneData.thickness or 10,
            debug = Beekeeping.DebugZones or false,
            honeyType = zoneData.honeyType,
            name = zoneData.name,
        })
        table.insert(honeyZones, zone)
    end
end

if Beekeeping.HoneyZones.Enable then 
    CreateHoneyZones(Beekeeping.HoneyZones)
end

local CancelPlacement = function()
    DeleteObject(CurrentObject)
    PlacingObject = false
    CurrentObject = nil
    CurrentObjectType = nil
    CurrentObjectName = nil
    CurrentSpawnRange = nil
    CurrentCoords = nil
end

local RequestObjects = function()
    lib.callback('sd-beekeeping:objects:server:RequestObjects', false, function(incObjectList)
        ObjectList = incObjectList
        if ObjectList then
            TriggerEvent('sd-beekeeping:client:ObjectListReady')
        else
            print("[sd-beekeeping] Received empty ObjectList, skipping spawn loop.")
        end
    end)
end

if Beekeeping.LoadOnStart then
    RequestObjects()
else
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        RequestObjects()
    end)

    RegisterNetEvent('esx:playerLoaded', function()
        RequestObjects()
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, v in pairs(ObjectList) do
            if v["IsRendered"] then
                DeleteObject(v["object"])
            end
        end
    end
end)

local ButtonMessage = function(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local Button = function(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

local setupScaleform = function(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    -- draw it once to set up layout
    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()


    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 177, true))
    ButtonMessage(locale('scaleforms.cancel_button'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 176, true))
    ButtonMessage(locale('scaleforms.place_button'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 16, true))
    Button(GetControlInstructionalButton(2, 15, true))
    ButtonMessage(locale('scaleforms.rotate_button'))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

local RotationToDirection = function(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local RayCastGamePlayCamera = function(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
    local handle, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(StartShapeTestSweptSphere(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, 0.2, 339, PlayerPedId(), 4))
	return hit, endCoords, entityHit, materialHash
end

local isInExclusionZone = function(playerCoords)
    for _, zone in pairs(Beekeeping.ExclusionZones) do
        if #(playerCoords - zone.coords) < zone.radius then
            return true
        end
    end
    return false
end

--- Function to get honey type based on coordinates
--- @param coords vector3 The coordinates to check
--- @return string The honey type ('wildflower', 'clover', etc.)
local GetHoneyType = function(coords)
    for _, zone in ipairs(honeyZones) do
        if zone:contains(coords) then
            return zone.honeyType
        end
    end
    return 'basic' -- Default honey type if not in any zone
end

--- Function to place the spawned object
--- @param heading number The heading of the object
--- @param honeyType string The honey type determined by the client
local PlaceSpawnedObject = function(heading)
    if isInExclusionZone(GetEntityCoords(PlayerPedId())) then
        SD.ShowNotification(locale('notifications.in_exclusion_zone'), 'error')
        return
    end

    local ObjectType = 'prop'
    local Options = { SpawnRange = tonumber(CurrentSpawnRange) }

    if ObjectParams[CurrentHiveType] ~= nil then
        Options = {
            event = ObjectParams[CurrentHiveType].event,
            icon = ObjectParams[CurrentHiveType].icon,
            label = ObjectParams[CurrentHiveType].label,
            SpawnRange = ObjectParams[CurrentHiveType].SpawnRange
        }
    end

    local finalCoords = {
        x = CurrentCoords.x,
        y = CurrentCoords.y,
        z = CurrentCoords.z,
        w = heading
    }

    if PlacingItemObject then
        TriggerServerEvent("sd-beekeeping:server:removeItem", PlacingItemObject, 1)
    end

    -- Determine honeyType based on the current coordinates
    local honeyType = 'basic'
    if CurrentHiveType == 'hive' then
        honeyType = GetHoneyType(CurrentCoords)
    end

    -- Clone the defaultData and include honeyType
    local defaultData = {}
    for key, value in pairs(ObjectParams[CurrentHiveType].defaultData) do
        defaultData[key] = value
    end
    defaultData.honeyType = honeyType

    -- Trigger the server event without passing honeyType separately
    TriggerServerEvent("sd-beekeeping:objects:server:CreateNewObject", CurrentHiveType, finalCoords, Options, defaultData, CurrentOwner)

    -- Cleanup
    DeleteObject(CurrentObject)
    PlacingObject = false
    CurrentObject = nil
    CurrentObjectType = nil
    CurrentObjectName = nil
    CurrentSpawnRange = nil
    CurrentCoords = nil
    CurrentModel = nil
    PlacingItemObject = nil
    CurrentOwner = nil
end

--- Function to create the spawned object for placement
--- @param data table The data containing object information (e.g., hive type, citizen ID)
local CreateSpawnedObject = function(data)
    -- Prepare object parameters
    local objectModel = ObjectParams[data.hive_type].object
    CurrentObjectType = objectModel
    CurrentHiveType = data.hive_type
    CurrentSpawnRange = ObjectParams[data.hive_type].SpawnRange or data.distance or 15
    CurrentOwner = data.citizenid

    SD.LoadModel(objectModel)
    CurrentModel = objectModel
    CurrentObject = CreateObject(objectModel, 1.0, 1.0, 1.0, true, true, false)
    local heading = 0.0
    SetEntityHeading(CurrentObject, heading)

    SetEntityAlpha(CurrentObject, 200)
    SetEntityDrawOutline(CurrentObject, true)
    SetEntityCollision(CurrentObject, false, false)
    FreezeEntityPosition(CurrentObject, true)
    PlacingObject = true

    CreateThread(function()
        local form = setupScaleform("instructional_buttons")
        while PlacingObject do
            local hit, coords, entity, material = RayCastGamePlayCamera(Beekeeping.RaycastingDistance)
            CurrentCoords = coords
            DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)

            if hit then
                local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 10.0, false)
                if success then
                    local modelHash = GetEntityModel(CurrentObject)
                    local minDim, maxDim = GetModelDimensions(modelHash)
                    local zOffset = -minDim.z

                    SetEntityCoords(CurrentObject, coords.x, coords.y, groundZ + zOffset, false, false, false, true)
                end
            end

            if IsControlJustPressed(0, 15) then
                heading = (heading + 5) % 360
                SetEntityHeading(CurrentObject, heading)
            end
            if IsControlJustPressed(0, 14) then
                heading = (heading - 5) % 360
                if heading < 0 then heading = heading + 360 end
                SetEntityHeading(CurrentObject, heading)
            end

            if IsControlJustPressed(0, 177) then
                CancelPlacement()
                return
            end

            if IsControlJustPressed(0, 176) then
                if lib.table.contains(Beekeeping.Grounds, material) then
                    local honeyType = 'basic'
                    if data.hive_type == 'hive' then
                        honeyType = GetHoneyType(coords)
                    end
                    data.honeyType = honeyType
                    PlaceSpawnedObject(heading)
                    return
                else
                    SD.ShowNotification(locale('notifications.incorrect_ground'), 'error')
                end
            end

            Wait(1)
        end
    end)
end

RegisterNetEvent("sd-beekeeping:objects:client:UpdateObjectList", function(NewObjectList)
    ObjectList = NewObjectList
end)

local SpawnObject = function(v, objectCoords)
    local objectModel = ObjectParams[v['hive_type']].object
    local object = CreateObject(objectModel, objectCoords["x"], objectCoords["y"], objectCoords["z"], false, false, false)
    SetEntityHeading(object, objectCoords["w"])
    SetEntityAlpha(object, 0)
    PlaceObjectOnGroundProperly(object)
    FreezeEntityPosition(object, true)
    v["IsRendered"] = true
    v["object"] = object

    CreateThread(function()
        for i = 0, 255, 51 do
            Wait(50)
            SetEntityAlpha(v["object"], i, false)
        end
    end)
end

local ApplyParticleEffects = function(objectCoords)
    SD.LoadPtfxAsset('core')
    UseParticleFxAssetNextCall('core')
    StartParticleFxLoopedAtCoord('ent_amb_fly_swarm', objectCoords["x"], objectCoords["y"], objectCoords["z"], 0.0, 0.0, 0.0, 1.5, 0.0, 0.0, 0.0, 0)
end

local AssignTargetToObject = function(v, object)
    local startTime = GetGameTimer()
    local timeout   = 3000
    while not DoesEntityExist(object) and (GetGameTimer() - startTime) < timeout do
        Wait(100)
    end

    if DoesEntityExist(object) then
        if ObjectParams[v.hive_type] and ObjectParams[v.hive_type].event then
            SD.Interaction.AddTargetEntity(Beekeeping.Interaction, object, {
                options = {{
                    name  = "object_spawner_" .. object,
                    event = ObjectParams[v.hive_type].event,
                    icon  = ObjectParams[v.hive_type].icon,
                    label = ObjectParams[v.hive_type].label,
                    id    = v.id,
                }},
                distance = Beekeeping.InteractionDistance
            })
        end
    else
        print(('[sd-beekeeping] Failed to assign target to object (id=%s, hive_type=%s) — entity did not exist after %dms'):format(v.id, v.hive_type, GetGameTimer() - startTime))
    end
end

local CreateFacilityBlips = function()
    if not Beekeeping.FacilityBlip or not Beekeeping.FacilityBlip.Enable then return end
    local playerId = SD.GetIdentifier()
    for id, facility in pairs(ObjectList) do
        if facility.coords and facility.blipData and facility.blipData[playerId] then
            local blipConf = Beekeeping.FacilityBlip[facility.hive_type] or {}
            local blip = AddBlipForCoord(facility.coords.x, facility.coords.y, facility.coords.z)
            SetBlipSprite(blip, blipConf.sprite or 1)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, blipConf.scale or 1.0)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, blipConf.color or 0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(blipConf.label or "Facility")
            EndTextCommandSetBlipName(blip)
            FacilityBlips[id] = blip
        end
    end
end

RegisterNetEvent('sd-beekeeping:client:UpdateBlip', function(hiveId, newState, coords, hive_type)
    if newState then
        local blipConf = Beekeeping.FacilityBlip[hive_type] or {}
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, blipConf.sprite or 1)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, blipConf.scale or 1.0)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, blipConf.color or 0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(blipConf.label or "Facility")
        EndTextCommandSetBlipName(blip)
        FacilityBlips[hiveId] = blip
    else
        if FacilityBlips[hiveId] then
            RemoveBlip(FacilityBlips[hiveId])
            FacilityBlips[hiveId] = nil
        end
    end
end)

RegisterNetEvent('sd-beekeeping:client:ObjectListReady', function()
    if not hasSpawnThreadStarted then
        hasSpawnThreadStarted = true

        CreateFacilityBlips()

        CreateThread(function()
            while true do
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local inRange = false

                for k, v in pairs(ObjectList) do
                    local data = v.options
                    local objectCoords = v.coords
                    local dist = #(playerCoords - vec3(objectCoords.x, objectCoords.y, objectCoords.z))

                    if dist < data.SpawnRange and not v.IsRendered then
                        inRange = true
                        SpawnObject(v, objectCoords)
                        ApplyParticleEffects(objectCoords)
                        AssignTargetToObject(v, v.object)

                    elseif dist >= data.SpawnRange and v.IsRendered then
                        if DoesEntityExist(v.object) then
                            CreateThread(function()
                                for i = 255, 0, -51 do
                                    Wait(50)
                                    SetEntityAlpha(v.object, i, false)
                                end
                                DeleteObject(v.object)
                                v.object = nil
                                v.IsRendered = false
                            end)
                        end
                    end
                end
                
                Wait(inRange and 500 or 2000)
            end
        end)
    end
end)

RegisterNetEvent("sd-beekeeping:objects:client:AddObject", function(object)
    ObjectList[object.id] = object

    local playerCoords = GetEntityCoords(PlayerPedId())
    local oc = object.coords
    local spawnRange = object.options and object.options.SpawnRange or Beekeeping.SpawnRange
    local dist = #(playerCoords - vec3(oc.x, oc.y, oc.z))

    if dist < spawnRange and not object.IsRendered then
        SpawnObject(object, oc)
        ApplyParticleEffects(oc)
        AssignTargetToObject(object, object.object)
        object.IsRendered = true
    end
end)

RegisterNetEvent('sd-beekeeping:objects:client:receiveObjectDelete', function(id)
    if ObjectList[id]["IsRendered"] then
        if DoesEntityExist(ObjectList[id]["object"]) then 
            for i = 255, 0, -51 do
                Wait(50)
                SetEntityAlpha(ObjectList[id]["object"], i, false)
            end
            DeleteObject(ObjectList[id]["object"])
        end
    end
    ObjectList[id] = nil
end)

RegisterNetEvent('sd-beekeeping:objects:client:SpawnObject', function(data)
    if not PlacingObject then
        
        -- Check if the player is in an exclusion zone
        if isInExclusionZone(GetEntityCoords(PlayerPedId())) then SD.ShowNotification(locale('notifications.in_exclusion_zone'), 'error') return end

        lib.callback('sd-beekeeping:server:CheckHiveCount', false, function(hasReachedMax)
            if hasReachedMax then SD.ShowNotification(locale('notifications.max_limit_reached'), 'error') return end

            PlacingObject = true
            PlacingItemObject = data.item
            CreateSpawnedObject(data)
        end, data)
    else
        SD.ShowNotification(locale('notifications.already_placing'), 'error')
    end
end)
