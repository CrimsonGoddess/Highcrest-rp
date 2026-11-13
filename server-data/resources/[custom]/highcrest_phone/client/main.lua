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
local CAMERA_MAX_FOV = 90.0
local CAMERA_ZOOM_STEP = 4.0
local CAMERA_ZOOM_HOLD_STEP = 0.5
local CAMERA_LOOK_SPEED = 6.0
local CAMERA_MAX_PITCH = 70.0
local CAMERA_FORWARD_DISTANCE = 0.35
local SELFIE_DISTANCE = 0.75
-- Zooming out in selfie mode also backs the camera away, so hands fit without distorting faces.
local SELFIE_DISTANCE_PER_FOV = 0.03
local HEAD_BONE = 31086

-- Pause menu, chat and push to talk still work while using the camera.
local CAMERA_ALLOWED_CONTROLS = { 199, 200, 245, 249 }

local PHONE_MODEL = `prop_amb_phone`
local PHONE_ANIM_DICT = 'cellphone@'
local PHONE_ANIM = 'cellphone_text_read_base'
local HAND_BONE = 28422

local CONTROL_POSE_PREVIOUS = 174 -- left arrow
local CONTROL_POSE_NEXT = 175 -- right arrow
local SELFIE_MODEL = `prop_phone_ing`
local SELFIE_LOOK_INTERVAL_MS = 500
local RIGHT_HAND_BONE = 28422
local LEFT_HAND_BONE = 60309

-- These clips are gestures, so each one is frozen partway through to hold it as a pose.
-- hold is how far through the clip to freeze: 0.5 is halfway. Change it if a pose looks off.
local SELFIE_POSES = {
    { label = 'Peace', dict = 'cellphone@self@franklin@', anim = 'peace', bone = RIGHT_HAND_BONE, hold = 0.5 },
    { label = 'West Coast', dict = 'cellphone@self@franklin@', anim = 'west_coast', bone = RIGHT_HAND_BONE, hold = 0.5 },
    { label = 'Chest Bump', dict = 'cellphone@self@franklin@', anim = 'chest_bump', bone = RIGHT_HAND_BONE, hold = 0.5 },
    { label = 'Thumbs Up', dict = 'anim@mp_player_intselfiethumbs_up', anim = 'idle_a', bone = LEFT_HAND_BONE, hold = 0.5 },
    { label = 'OK', dict = 'anim@mp_player_intselfiedock', anim = 'idle_a', bone = LEFT_HAND_BONE, hold = 0.5 },
    { label = 'Middle Finger', dict = 'cellphone@self@trevor@', anim = 'proud_finger', bone = RIGHT_HAND_BONE, hold = 0.5 },
}

local isOpen = false
local inCamera = false
local phoneProp
local cameraHandle
local cameraCrop
local inSelfiePose = false
local selfiePoseIndex = 1
local activePose

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
    if activePose then
        StopAnimTask(ped, activePose.dict, activePose.anim, 2.0)
        activePose = nil
    end
    if inSelfiePose then
        TaskClearLookAt(ped)
        inSelfiePose = false
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

local function startSelfiePose()
    stopHolding()
    local ped = PlayerPedId()
    local pose = SELFIE_POSES[selfiePoseIndex]
    lib.requestAnimDict(pose.dict)
    lib.requestModel(SELFIE_MODEL)

    -- Flag 49: loop and upper body only.
    TaskPlayAnim(ped, pose.dict, pose.anim, 4.0, 4.0, -1, 49, 0, false, false, false)
    activePose = pose

    -- Wait for the clip to start before freezing it.
    local timeout = GetGameTimer() + 1000
    while not IsEntityPlayingAnim(ped, pose.dict, pose.anim, 3) and GetGameTimer() < timeout do
        Wait(0)
    end
    SetEntityAnimCurrentTime(ped, pose.dict, pose.anim, pose.hold)
    SetEntityAnimSpeed(ped, pose.dict, pose.anim, 0.0)

    local coords = GetEntityCoords(ped)
    phoneProp = CreateObject(SELFIE_MODEL, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(phoneProp, ped, GetPedBoneIndex(ped, pose.bone),
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(SELFIE_MODEL)
    inSelfiePose = true

    SendNUIMessage({ action = 'cameraPose', label = pose.label })
end

local function changeSelfiePose(step)
    selfiePoseIndex = (selfiePoseIndex - 1 + step) % #SELFIE_POSES + 1
    startSelfiePose()
end

local function openPhone()
    if isOpen or inCamera then return end

    local data = lib.callback.await('highcrest_phone:server:getPhone', false)
    if not data then
        lib.notify({ description = 'You need a phone.', type = 'error', position = 'top' })
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
    if inSelfiePose then
        stopHolding()
        startHolding()
    end
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
        local nextLook = 0

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
            local distance = selfie and (SELFIE_DISTANCE + math.max(0.0, fov - CAMERA_DEFAULT_FOV) * SELFIE_DISTANCE_PER_FOV) or CAMERA_FORWARD_DISTANCE
            local camX, camY, camZ = head.x + forwardX * distance, head.y + forwardY * distance, head.z + 0.03
            SetCamCoord(cameraHandle, camX, camY, camZ)
            if selfie then
                SetCamRot(cameraHandle, pitch, 0.0, yaw + 180.0, 2)
                if GetGameTimer() >= nextLook then
                    nextLook = GetGameTimer() + SELFIE_LOOK_INTERVAL_MS
                    TaskLookAtCoord(ped, camX, camY, camZ, SELFIE_LOOK_INTERVAL_MS + 200, 2048, 3)
                end
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
                if selfie then
                    startSelfiePose()
                else
                    stopHolding()
                    startHolding()
                    SendNUIMessage({ action = 'cameraPose' })
                end
            elseif selfie and IsDisabledControlJustPressed(0, CONTROL_POSE_NEXT) then
                changeSelfiePose(1)
            elseif selfie and IsDisabledControlJustPressed(0, CONTROL_POSE_PREVIOUS) then
                changeSelfiePose(-1)
            elseif IsDisabledControlJustPressed(0, CONTROL_ORIENTATION) then
                SendNUIMessage({ action = 'cameraRotate' })
            elseif IsDisabledControlJustPressed(0, CONTROL_BACKSPACE) then
                leaveCamera()
            end
        end
    end)
end

RegisterCommand('phone', openPhone, false)
RegisterKeyMapping('phone', 'Open phone', 'keyboard', 'M')
RegisterCommand('hcphone', openPhone, false)
exports('OpenPhone', openPhone)

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
    -- Shown even with the phone open, since another app may be on screen.
    lib.notify({
        title = 'Incoming call',
        description = ('%s is calling. Press M to answer.'):format(call.name or call.number),
        icon = 'phone',
        duration = 15000,
        position = 'top',
    })
end)

RegisterNetEvent('highcrest_phone:client:callConnected', function()
    ringing = false
    SendNUIMessage({ action = 'callConnected' })
end)

RegisterNetEvent('highcrest_phone:client:callEnded', function(reason)
    ringing = false
    SendNUIMessage({ action = 'callEnded', reason = reason })
end)

local function notifyMessage(name, body)
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
    lib.notify({ title = name, description = body, icon = 'message', duration = 7000, position = 'top' })
end

RegisterNetEvent('highcrest_phone:client:message', function(message)
    SendNUIMessage({ action = 'message', message = message })
    -- With the phone open, the screen asks for a notification unless that conversation is showing.
    if not isOpen then notifyMessage(message.name or message.from, message.body) end
end)

RegisterNUICallback('notifyMessage', function(data, cb)
    if type(data) == 'table' then notifyMessage(tostring(data.name or ''), tostring(data.body or '')) end
    cb(1)
end)

-- Share number: list the people standing right next to you, by character name.
local SHARE_DISTANCE = 2.0

RegisterNUICallback('shareNearby', function(_, cb)
    local mine = GetEntityCoords(cache.ped)
    local nearby = {}
    for _, player in ipairs(GetActivePlayers()) do
        if player ~= cache.playerId then
            local distance = #(GetEntityCoords(GetPlayerPed(player)) - mine)
            if distance <= SHARE_DISTANCE then
                nearby[#nearby + 1] = { id = GetPlayerServerId(player), distance = math.floor(distance * 10 + 0.5) / 10 }
            end
        end
    end
    table.sort(nearby, function(a, b) return a.distance < b.distance end)
    -- Names come from the server, which also checks each person is really that close.
    cb(#nearby > 0 and lib.callback.await("highcrest_phone:server:shareNearby", false, nearby) or {})
end)

RegisterNUICallback('shareNumber', function(target, cb)
    cb(lib.callback.await('highcrest_phone:server:shareNumber', false, target) or false)
end)

RegisterNetEvent('highcrest_phone:client:numberShared', function(card)
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
    SendNUIMessage({ action = 'numberShared', card = card })
    lib.notify({
        title = 'Contact received',
        description = ('%s shared their number. Open Contacts to save it.'):format(card.name),
        icon = 'address-card',
        duration = 8000,
        position = 'top',
    })
end)


RegisterNUICallback('close', function(_, cb)
    closePhone()
    cb(1)
end)

-- The React UI reports its own crashes here so they show in F8 and the client log.
RegisterNUICallback('uiError', function(data, cb)
    print(('^1[highcrest_phone UI] %s^7'):format(type(data) == 'table' and tostring(data.message) or '?'))
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

-- Emergency alerts (tsunami etc.): the phone slides up on its own with a red alert, no focus.
-- Only players carrying a phone get it (checked by the sender).
RegisterNetEvent('highcrest_phone:client:emergency', function(title, body, seconds)
    SendNUIMessage({ action = 'emergency', title = title, body = body, seconds = seconds or 15 })
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
    CreateThread(function()
        for _ = 1, 2 do
            Wait(900)
            PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
        end
    end)
end)
