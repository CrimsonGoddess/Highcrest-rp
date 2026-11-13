local placing = false
local ghostEntity = nil
local currentItem = nil
local currentDef = nil
local currentHeading = 0.0

local streamed = {}
local streamedEntities = {}

local function notify(msg, ntype)
    lib.notify({ description = msg, type = ntype or 'inform' })
end

local function cleanupGhost()
    if ghostEntity and DoesEntityExist(ghostEntity) then
        DeleteEntity(ghostEntity)
    end
    ghostEntity = nil
end

local function setPlacementUi(state)
    placing = state
    if not state then
        SetNuiFocus(false, false)
    end
end

local function raycastFromCamera(maxDist)
    local camCoord = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)

    local rotZ = math.rad(camRot.z)
    local rotX = math.rad(camRot.x)

    local dir = vec3(
        -math.sin(rotZ) * math.abs(math.cos(rotX)),
        math.cos(rotZ) * math.abs(math.cos(rotX)),
        math.sin(rotX)
    )

    local dest = camCoord + (dir * maxDist)

    local ray = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, dest.x, dest.y, dest.z, 1 + 16, PlayerPedId(), 0)
    local _, hit, endCoords, _, _ = GetShapeTestResult(ray)

    if hit == 1 then
        return true, endCoords
    end

    return false, dest
end

local function ensureGhost(model)
    local modelHash = type(model) == 'number' and model or joaat(model)
    if ghostEntity and DoesEntityExist(ghostEntity) then
        local curModel = GetEntityModel(ghostEntity)
        if curModel == modelHash then return end
    end

    cleanupGhost()

    lib.requestModel(modelHash)

    local coords = GetEntityCoords(PlayerPedId())
    ghostEntity = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityAlpha(ghostEntity, 170, false)
    SetEntityCollision(ghostEntity, false, false)
    FreezeEntityPosition(ghostEntity, true)
    SetEntityInvincible(ghostEntity, true)
    SetEntityAsMissionEntity(ghostEntity, true, true)
end

local function startPlacement(itemName)
    local def = Config.PlaceableItems[itemName]
    if not def then
        notify('This item cannot be placed.', 'error')
        return
    end

    currentItem = itemName
    currentDef = def
    currentHeading = GetEntityHeading(PlayerPedId())

    ensureGhost(def.model)

    setPlacementUi(true)
    notify(('Placing %s\n%s/%s rotate | %s place | %s cancel'):format(
        def.label or itemName,
        Config.Keybinds.rotateLeft.defaultKey,
        Config.Keybinds.rotateRight.defaultKey,
        Config.Keybinds.place.defaultKey,
        Config.Keybinds.cancel.defaultKey
    ), 'inform')

    CreateThread(function()
        while placing do
            local ok, hitCoords = raycastFromCamera(Config.PlaceMaxDistance)
            if ok then
                SetEntityCoordsNoOffset(ghostEntity, hitCoords.x, hitCoords.y, hitCoords.z, false, false, false)
                SetEntityHeading(ghostEntity, currentHeading)
                PlaceObjectOnGroundProperly(ghostEntity)
            else
                SetEntityCoordsNoOffset(ghostEntity, hitCoords.x, hitCoords.y, hitCoords.z, false, false, false)
                SetEntityHeading(ghostEntity, currentHeading)
            end

            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)

            Wait(0)
        end
    end)
end

local function confirmPlacement()
    if not placing or not ghostEntity or not DoesEntityExist(ghostEntity) then return end

    local coords = GetEntityCoords(ghostEntity)
    local heading = GetEntityHeading(ghostEntity)

    setPlacementUi(false)
    cleanupGhost()

    TriggerServerEvent('zoov_placeprops:server:place', currentItem, { x = coords.x + 0.0, y = coords.y + 0.0, z = coords.z + 0.0 }, heading + 0.0)

    currentItem = nil
    currentDef = nil
end

local function cancelPlacement()
    if not placing then return end
    setPlacementUi(false)
    cleanupGhost()
    currentItem = nil
    currentDef = nil
    notify('Cancelled.', 'inform')
end

lib.addKeybind({
    name = Config.Keybinds.rotateLeft.name,
    description = Config.Keybinds.rotateLeft.description,
    defaultKey = Config.Keybinds.rotateLeft.defaultKey,
    onPressed = function()
        if not placing then return end
        currentHeading = (currentHeading - Config.RotationStep) % 360.0
    end
})

lib.addKeybind({
    name = Config.Keybinds.rotateRight.name,
    description = Config.Keybinds.rotateRight.description,
    defaultKey = Config.Keybinds.rotateRight.defaultKey,
    onPressed = function()
        if not placing then return end
        currentHeading = (currentHeading + Config.RotationStep) % 360.0
    end
})

lib.addKeybind({
    name = Config.Keybinds.place.name,
    description = Config.Keybinds.place.description,
    defaultKey = Config.Keybinds.place.defaultKey,
    onPressed = function()
        if not placing then return end
        confirmPlacement()
    end
})

lib.addKeybind({
    name = Config.Keybinds.cancel.name,
    description = Config.Keybinds.cancel.description,
    defaultKey = Config.Keybinds.cancel.defaultKey,
    onPressed = function()
        if not placing then return end
        cancelPlacement()
    end
})

AddEventHandler('ox_inventory:usedItem', function(itemName, slotId, metadata)
    if placing then return end
    if not Config.PlaceableItems[itemName] then return end
    startPlacement(itemName)
end)

RegisterNetEvent('zoov_placeprops:client:notify')
AddEventHandler('zoov_placeprops:client:notify', function(data)
    if type(data) ~= 'table' then return end
    lib.notify(data)
end)

local function spawnStreamed(prop)
    local id = prop.id
    if streamedEntities[id] and DoesEntityExist(streamedEntities[id]) then return end

    local model = prop.model
    lib.requestModel(model)

    local c = prop.coords
    local ent = CreateObject(model, c.x + 0.0, c.y + 0.0, c.z + 0.0, false, false, false)
    SetEntityHeading(ent, (prop.heading or 0.0) + 0.0)
    FreezeEntityPosition(ent, true)
    SetEntityAsMissionEntity(ent, true, true)
    PlaceObjectOnGroundProperly(ent)

    streamedEntities[id] = ent

    if Config.Target.enabled and exports.ox_target then
        exports.ox_target:addLocalEntity(ent, {
            {
                name = 'zoov_placeprops_remove_' .. id,
                icon = Config.Target.icon,
                label = Config.Target.removeLabel,
                distance = Config.Target.removeDistance,
                onSelect = function()
                    TriggerServerEvent('zoov_placeprops:server:remove', id)
                end,
                canInteract = function()
                    return not placing
                end
            }
        })
    end
end

local function despawnStreamed(id)
    local ent = streamedEntities[id]
    if ent and DoesEntityExist(ent) then
        if Config.Target.enabled and exports.ox_target then
            exports.ox_target:removeLocalEntity(ent)
        end
        DeleteEntity(ent)
    end
    streamedEntities[id] = nil
end

RegisterNetEvent('zoov_placeprops:client:placed')
AddEventHandler('zoov_placeprops:client:placed', function(prop)
    if type(prop) ~= 'table' or type(prop.id) ~= 'string' then return end
    streamed[prop.id] = prop
end)

RegisterNetEvent('zoov_placeprops:client:removed')
AddEventHandler('zoov_placeprops:client:removed', function(propId)
    if type(propId) ~= 'string' then return end
    streamed[propId] = nil
    despawnStreamed(propId)
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)

        local nearby = lib.callback.await('zoov_placeprops:server:getNearby', false, { x = pcoords.x + 0.0, y = pcoords.y + 0.0, z = pcoords.z + 0.0 })
        if type(nearby) == 'table' then
            local keep = {}
            for i = 1, #nearby do
                local prop = nearby[i]
                if prop and prop.id then
                    streamed[prop.id] = prop
                    keep[prop.id] = true
                end
            end

            for id in pairs(streamed) do
                if not keep[id] then
                    streamed[id] = nil
                    despawnStreamed(id)
                end
            end
        end

        for id, prop in pairs(streamed) do
            local c = prop.coords
            local dist = #(vec3(c.x + 0.0, c.y + 0.0, c.z + 0.0) - pcoords)
            if dist <= Config.StreamDistance then
                spawnStreamed(prop)
            else
                despawnStreamed(id)
            end
        end

        Wait(1500)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    cancelPlacement()
    for id in pairs(streamedEntities) do
        despawnStreamed(id)
    end
end)
