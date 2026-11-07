local CONTROL_ENTER = 191
local CONTROL_BACKSPACE = 194
local CONTROL_SELFIE = 27 -- up arrow
local CONTROL_ATTACK = 24
local CONTROL_AIM = 25

local PHONE_MODEL = `prop_npc_phone_01`
local PHONE_ANIM_DICT = 'cellphone@'
local PHONE_ANIM = 'cellphone_text_read_base'
local HAND_BONE = 28422

local isOpen = false
local inCamera = false
local phoneProp

local function sendClock()
    SendNUIMessage({ action = 'clock', hours = GetClockHours(), minutes = GetClockMinutes() })
end

local function stopHolding()
    if phoneProp then
        DeleteEntity(phoneProp)
        phoneProp = nil
    end
    local ped = PlayerPedId()
    if IsEntityPlayingAnim(ped, PHONE_ANIM_DICT, PHONE_ANIM, 3) then
        StopAnimTask(ped, PHONE_ANIM_DICT, PHONE_ANIM, 2.0)
    end
end

local function startHolding()
    local ped = PlayerPedId()
    lib.requestAnimDict(PHONE_ANIM_DICT)
    lib.requestModel(PHONE_MODEL)

    -- Flag 50: loop, upper body only, so the player can still walk.
    TaskPlayAnim(ped, PHONE_ANIM_DICT, PHONE_ANIM, 3.0, 3.0, -1, 50, 0, false, false, false)

    if not phoneProp then
        local coords = GetEntityCoords(ped)
        phoneProp = CreateObject(PHONE_MODEL, coords.x, coords.y, coords.z, true, true, false)
        AttachEntityToEntity(phoneProp, ped, GetPedBoneIndex(ped, HAND_BONE),
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    end
    SetModelAsNoLongerNeeded(PHONE_MODEL)
end

local function openPhone()
    if isOpen or inCamera then return end

    local data = lib.callback.await('highcrest_phone:server:getPhone', false)
    if not data then
        lib.notify({ description = 'You need a phone.', type = 'error', position = 'top-left' })
        return
    end

    isOpen = true
    sendClock()
    SendNUIMessage({ action = 'open', data = data })
    SetNuiFocus(true, true)
    startHolding()

    CreateThread(function()
        while isOpen or inCamera do
            Wait(2000)
            sendClock()
        end
    end)
end

local function closePhone()
    isOpen = false
    SetNuiFocus(false, false)
    stopHolding()
end

local function leaveCamera()
    inCamera = false
    CellCamActivate(false, false)
    DestroyMobilePhone()
    TriggerEvent('highcrest_ui:setHidden', false)
    isOpen = true
    SendNUIMessage({ action = 'cameraClosed' })
    SetNuiFocus(true, true)
    startHolding()
end

-- Uses GTA's own phone camera, so the view comes from the character's hand.
-- `crop` is the phone screen's position, used to crop the photo to what the player framed.
local function runCamera(crop)
    inCamera = true
    isOpen = false
    SetNuiFocus(false, false)
    stopHolding()
    TriggerEvent('highcrest_ui:setHidden', true)

    CreateMobilePhone(1)
    CellCamActivate(true, true)

    CreateThread(function()
        local busy = false
        local selfie = false

        while inCamera do
            Wait(0)
            HideHudAndRadarThisFrame()
            DisableControlAction(0, CONTROL_ATTACK, true)
            DisableControlAction(0, CONTROL_AIM, true)

            if not busy and IsControlJustPressed(0, CONTROL_ENTER) then
                busy = true
                CreateThread(function()
                    local result = lib.callback.await('highcrest_phone:server:takePhoto', false, crop)
                    SendNUIMessage({ action = 'captured', result = result })
                    busy = false
                end)
            elseif IsControlJustPressed(0, CONTROL_SELFIE) then
                selfie = not selfie
                -- CELL_FRONT_CAM_ACTIVATE
                Citizen.InvokeNative(0x2491A93618B7D838, selfie)
            elseif IsControlJustPressed(0, CONTROL_BACKSPACE) then
                leaveCamera()
            end
        end
    end)
end

RegisterCommand('hcphone', openPhone, false)
RegisterKeyMapping('hcphone', 'Open Highcrest phone', 'keyboard', 'F3')

-- These just pass a request to the server, which validates everything.
for _, name in ipairs({
    'saveContact', 'deleteContact', 'listConversations', 'getConversation',
    'sendMessage', 'startCall', 'answerCall', 'hangUp',
    'feedGet', 'feedProfile', 'feedSaveProfile', 'feedPost', 'feedLike', 'feedFollow', 'feedDelete',
    'feedComments', 'feedComment', 'feedDeleteComment',
    'marketGet', 'marketCreate', 'marketDelete',
    'datingGet', 'datingSave', 'datingDelete', 'datingSwipe',
    'darkwebGet', 'darkwebPost', 'darkwebDelete',
}) do
    RegisterNUICallback(name, function(data, cb)
        cb(lib.callback.await('highcrest_phone:server:' .. name, false, data) or false)
    end)
end

local ringing = false

local function startRinging()
    if ringing then return end
    ringing = true

    CreateThread(function()
        while ringing do
            PlaySoundFrontend(-1, 'Remote_Ring', 'Phone_SoundSet_Michael', true)
            Wait(3000)
        end
    end)
end

RegisterNetEvent('highcrest_phone:client:incomingCall', function(call)
    startRinging()
    SendNUIMessage({ action = 'incomingCall', call = call })
    if not isOpen then
        lib.notify({ title = 'Incoming call', description = ('%s is calling. Press F3 to answer.'):format(call.name or call.number), position = 'top-left' })
    end
end)

RegisterNetEvent('highcrest_phone:client:callConnected', function()
    ringing = false
    SendNUIMessage({ action = 'callConnected' })
end)

RegisterNetEvent('highcrest_phone:client:callEnded', function(reason)
    ringing = false
    SendNUIMessage({ action = 'callEnded', reason = reason })
end)

RegisterNetEvent('highcrest_phone:client:message', function(message)
    SendNUIMessage({ action = 'message', message = message })
    if not isOpen then
        lib.notify({ title = message.name or message.from, description = message.body, position = 'top-left' })
    end
end)

RegisterNUICallback('close', function(_, cb)
    closePhone()
    cb(1)
end)

RegisterNUICallback('startCamera', function(data, cb)
    runCamera(data.crop)
    cb(1)
end)

RegisterNUICallback('saveSettings', function(data, cb)
    cb(lib.callback.await('highcrest_phone:server:saveSettings', false, data) or false)
end)

RegisterNUICallback('deletePhoto', function(data, cb)
    cb(lib.callback.await('highcrest_phone:server:deletePhoto', false, data.id) or false)
end)

RegisterNUICallback('getPhoto', function(data, cb)
    TriggerServerEvent('highcrest_phone:server:requestPhoto', data.id)
    cb(1)
end)

RegisterNetEvent('highcrest_phone:client:photo', function(id, src, crop)
    SendNUIMessage({ action = 'photo', id = id, src = src, crop = crop })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if isOpen or inCamera then SetNuiFocus(false, false) end
    if inCamera then
        CellCamActivate(false, false)
        DestroyMobilePhone()
        TriggerEvent('highcrest_ui:setHidden', false)
    end
    stopHolding()
end)
