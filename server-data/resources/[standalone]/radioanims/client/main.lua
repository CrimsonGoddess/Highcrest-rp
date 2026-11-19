local resourceName = GetCurrentResourceName()

local currentId = Config.Default
local propEntity = nil
local radioTalking = false
local radioPropModels = {}

CreateThread(function()
    for i = 1, #Config.Animations do
        local prop = Config.Animations[i].prop
        if prop and prop.model then
            radioPropModels[joaat(prop.model)] = true
        end
    end
end)

local function disableBaseRadioAnim()
    if GetResourceState('pma-voice') == 'started' then
        exports['pma-voice']:setDisableRadioAnim(true)
    end
end

local function findAnim(id)
    for i = 1, #Config.Animations do
        local a = Config.Animations[i]
        if a.id == id then
            return a
        end
    end
end

local function cleanupProp()
    if propEntity and DoesEntityExist(propEntity) then
        DetachEntity(propEntity, true, true)
        SetEntityAsMissionEntity(propEntity, true, true)
        DeleteObject(propEntity)
        DeleteEntity(propEntity)
    end
    propEntity = nil
end

local function cleanupAttachedRadioProps(ped)
    if not ped or ped == 0 then return end

    local objects = GetGamePool('CObject')
    for i = 1, #objects do
        local object = objects[i]
        if DoesEntityExist(object)
            and radioPropModels[GetEntityModel(object)]
            and IsEntityAttachedToEntity(object, ped)
        then
            DetachEntity(object, true, true)
            SetEntityAsMissionEntity(object, true, true)
            DeleteObject(object)
            DeleteEntity(object)
        end
    end
end

local function ensureAnimDict(dict)
    if not dict or dict == '' then return false end
    if HasAnimDictLoaded(dict) then return true end

    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
        if GetGameTimer() > timeout then
            return false
        end
    end

    return true
end

local function ensureModel(model)
    if not model or model == '' then return false end
    local hash = joaat(model)
    if HasModelLoaded(hash) then return hash end

    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
        if GetGameTimer() > timeout then
            return false
        end
    end

    return hash
end

local function attachProp(ped, prop)
    cleanupProp()
    if not prop then return end

    local hash = ensureModel(prop.model)
    if not hash then
        lib.notify({ title = 'Radio Animations', description = 'Failed to load prop model: ' .. tostring(prop.model), type = 'error' })
        return
    end

    local coords = GetEntityCoords(ped)
    local obj = CreateObject(hash, coords.x, coords.y, coords.z + 0.2, false, false, false)
    if not DoesEntityExist(obj) then
        lib.notify({ title = 'Radio Animations', description = 'Failed to create prop.', type = 'error' })
        return
    end

    SetModelAsNoLongerNeeded(hash)

    local boneIndex = GetPedBoneIndex(ped, prop.bone or 57005)
    local pos = prop.pos or vec3(0.0, 0.0, 0.0)
    local rot = prop.rot or vec3(0.0, 0.0, 0.0)

    AttachEntityToEntity(
        obj,
        ped,
        boneIndex,
        pos.x,
        pos.y,
        pos.z,
        rot.x,
        rot.y,
        rot.z,
        true,
        true,
        false,
        true,
        2,
        true
    )

    propEntity = obj
end

local function stopRadioAnim()
    local ped = PlayerPedId()
    ClearPedSecondaryTask(ped)
    cleanupProp()
    cleanupAttachedRadioProps(ped)
end

local function playRadioAnim()
    local ped = PlayerPedId()
    if IsEntityDead(ped) or IsPedRagdoll(ped) or IsPedInAnyVehicle(ped, false) then
        return
    end

    local anim = findAnim(currentId)
    if not anim then return end

    if not ensureAnimDict(anim.dict) then
        lib.notify({ title = 'Radio Animations', description = 'Failed to load anim dict: ' .. tostring(anim.dict), type = 'error' })
        return
    end

    -- Clear any existing upper-body radio task first so the selected anim wins.
    ClearPedSecondaryTask(ped)
    attachProp(ped, anim.prop)

    TaskPlayAnim(
        ped,
        anim.dict,
        anim.clip,
        8.0,
        -8.0,
        -1,
        anim.flag or 49,
        0.0,
        false,
        false,
        false
    )
end

local function toggleRadioAnim(state)
    radioTalking = state

    if state then
        if currentId ~= 'none' then
            playRadioAnim()
        end
        return
    end

    stopRadioAnim()
end

local function registerMenu()
    local options = {
        {
            title = 'Disable',
            description = 'No radio animation',
            icon = 'ban',
            onSelect = function()
                currentId = 'none'
                stopRadioAnim()
                lib.notify({ title = 'Radio Animations', description = 'Radio animation disabled.', type = 'inform' })
            end
        }
    }

    for i = 1, #Config.Animations do
        local a = Config.Animations[i]
        options[#options + 1] = {
            title = a.label,
            description = a.id,
            icon = (a.id == currentId) and 'check' or 'walkie-talkie',
            onSelect = function()
                currentId = a.id
                lib.notify({ title = 'Radio Animations', description = 'Selected: ' .. a.label, type = 'success' })
            end
        }
    end

    lib.registerContext({
        id = Config.Menu.id,
        title = Config.Menu.title,
        options = options
    })
end

local function openMenu()
    registerMenu()
    lib.showContext(Config.Menu.id)
end

RegisterCommand(Config.Command, function()
    openMenu()
end, false)

AddEventHandler('onResourceStop', function(res)
    if res ~= resourceName then return end
    stopRadioAnim()
end)

AddEventHandler('onClientResourceStart', function(res)
    if res == resourceName or res == 'pma-voice' then
        disableBaseRadioAnim()
    end
end)

CreateThread(function()
    disableBaseRadioAnim()
end)

-- pma-voice events
AddEventHandler('pma-voice:radioActive', function(radioTalking)
    toggleRadioAnim(radioTalking)
end)

-- Keep the selected radio animation active while the player is talking.
CreateThread(function()
    while true do
        Wait(150)

        if not radioTalking or currentId == 'none' then
            goto continue
        end

        local ped = PlayerPedId()
        if IsEntityDead(ped) or IsPedRagdoll(ped) or IsPedInAnyVehicle(ped, false) then
            stopRadioAnim()
            goto continue
        end

        local anim = findAnim(currentId)
        if anim and not IsEntityPlayingAnim(ped, anim.dict, anim.clip, 3) then
            playRadioAnim()
        end

        ::continue::
    end
end)

-- Safety: if player dies or gets ragdolled while talking, clear tasks/props.
CreateThread(function()
    while true do
        Wait(500)
        if currentId ~= 'none' then
            local ped = PlayerPedId()
            if IsEntityDead(ped) or IsPedRagdoll(ped) or IsPedInAnyVehicle(ped, false) then
                stopRadioAnim()
            elseif not radioTalking then
                cleanupProp()
                cleanupAttachedRadioProps(ped)
            end
        end
    end
end)

exports('PlayRadioAnimation', playRadioAnim)
exports('StopRadioAnimation', stopRadioAnim)
exports('ToggleRadioAnimation', toggleRadioAnim)
exports('GetCurrentRadioAnimation', function()
    return currentId, findAnim(currentId)
end)
