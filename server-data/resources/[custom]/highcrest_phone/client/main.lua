local CONTROL_ENTER = 191
local CONTROL_BACKSPACE = 194
local CONTROL_SELFIE = 27 -- up arrow
local CONTROL_ORIENTATION = 182 -- L
local CONTROL_LOOK_X = 1
local CONTROL_LOOK_Y = 2
local CONTROL_SCROLL_UP = 241
local CONTROL_SCROLL_DOWN = 242
local CONTROL_ZOOM_IN = 38 -- E
local CONTROL_ZOOM_OUT = 44 -- Q

-- Field of view: a smaller number is more zoomed in.
local CAMERA_DEFAULT_FOV = 50.0
local CAMERA_MIN_FOV = 12.0
local CAMERA_MAX_FOV = 75.0
local CAMERA_ZOOM_STEP = 4.0
local CAMERA_ZOOM_HOLD_STEP = 0.5
local CAMERA_LOOK_SPEED = 6.0
local CAMERA_MAX_PITCH = 70.0
local CAMERA_FORWARD_DISTANCE = 0.35
local SELFIE_DISTANCE = 0.75
local HEAD_BONE = 31086

-- Pause menu, chat and push to talk still work while using the camera.
local CAMERA_ALLOWED_CONTROLS = { 199, 200, 245, 249 }

local PHONE_MODEL = `prop_npc_phone_01`
local PHONE_ANIM_DICT = 'cellphone@'
local PHONE_ANIM = 'cellphone_text_read_base'
local HAND_BONE = 28422

local isOpen = false
local inCamera = false
local phoneProp
local cameraHandle
local cameraCrop

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
    RenderScriptCams(false, false, 0, true, true)
    if cameraHandle then
        DestroyCam(cameraHandle, false)
        cameraHandle = nil
    end
    TriggerEvent('highcrest_ui:setHidden', false)
    isOpen = true
    SendNUIMessage({ action = 'cameraClosed' })
    SetNuiFocus(true, true)
end

-- A custom camera, because it allows zoom. The character holds still while framing the shot.
-- cameraCrop is the phone screen's position, used to crop the photo to what the player framed.
local function runCamera()
    inCamera = true
    isOpen = false
    SetNuiFocus(false, false)
    TriggerEvent('highcrest_ui:setHidden', true)

    local ped = PlayerPedId()
    cameraHandle = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(cameraHandle, true)
    RenderScriptCams(true, false, 0, true, true)

    CreateThread(function()
        local busy = false
        local selfie = false
        local fov = CAMERA_DEFAULT_FOV
        local yaw = GetEntityHeading(ped)
        local pitch = 0.0

        while inCamera do
            Wait(0)
            HideHudAndRadarThisFrame()
            DisableAllControlActions(0)
            for _, control in ipairs(CAMERA_ALLOWED_CONTROLS) do
                EnableControlAction(0, control, true)
            end

            -- Looking feels the same at any zoom because it scales with the field of view.
            local sensitivity = CAMERA_LOOK_SPEED * (fov / CAMERA_DEFAULT_FOV)
            yaw = yaw - GetDisabledControlNormal(0, CONTROL_LOOK_X) * sensitivity
            pitch = math.max(-CAMERA_MAX_PITCH, math.min(CAMERA_MAX_PITCH, pitch - GetDisabledControlNormal(0, CONTROL_LOOK_Y) * sensitivity))

            if IsDisabledControlJustPressed(0, CONTROL_SCROLL_UP) then fov = fov - CAMERA_ZOOM_STEP end
            if IsDisabledControlJustPressed(0, CONTROL_SCROLL_DOWN) then fov = fov + CAMERA_ZOOM_STEP end
            if IsDisabledControlPressed(0, CONTROL_ZOOM_IN) then fov = fov - CAMERA_ZOOM_HOLD_STEP end
            if IsDisabledControlPressed(0, CONTROL_ZOOM_OUT) then fov = fov + CAMERA_ZOOM_HOLD_STEP end
            fov = math.max(CAMERA_MIN_FOV, math.min(CAMERA_MAX_FOV, fov))

            SetEntityHeading(ped, yaw)
            local head = GetPedBoneCoords(ped, HEAD_BONE, 0.0, 0.0, 0.0)
            local radians = math.rad(yaw)
            local forwardX, forwardY = -math.sin(radians), math.cos(radians)
            local distance = selfie and SELFIE_DISTANCE or CAMERA_FORWARD_DISTANCE
            SetCamCoord(cameraHandle, head.x + forwardX * distance, head.y + forwardY * distance, head.z + 0.03)
            if selfie then
                SetCamRot(cameraHandle, pitch, 0.0, yaw + 180.0, 2)
            else
                SetCamRot(cameraHandle, pitch, 0.0, yaw, 2)
            end
            SetCamFov(cameraHandle, fov)

            if not busy and IsDisabledControlJustPressed(0, CONTROL_ENTER) then
                busy = true
                CreateThread(function()
                    local result = lib.callback.await('highcrest_phone:server:takePhoto', false, cameraCrop)
                    SendNUIMessage({ action = 'captured', result = result })
                    busy = false
                end)
            elseif IsDisabledControlJustPressed(0, CONTROL_SELFIE) then
                selfie = not selfie
            elseif IsDisabledControlJustPressed(0, CONTROL_ORIENTATION) then
                SendNUIMessage({ action = 'cameraRotate' })
            elseif IsDisabledControlJustPressed(0, CONTROL_BACKSPACE) then
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
    cameraCrop = data.crop
    runCamera()
    cb(1)
end)

-- Sent again whenever the viewfinder rotates, so the crop always matches what's on screen.
RegisterNUICallback('cameraCrop', function(data, cb)
    cameraCrop = data.crop
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
        RenderScriptCams(false, false, 0, true, true)
        if cameraHandle then DestroyCam(cameraHandle, false) end
        TriggerEvent('highcrest_ui:setHidden', false)
    end
    stopHolding()
end)
