local CONTROL_ENTER = 191
local CONTROL_BACKSPACE = 194

local isOpen = false
local inCamera = false

local function sendClock()
    SendNUIMessage({ action = 'clock', hours = GetClockHours(), minutes = GetClockMinutes() })
end

local function openPhone()
    if isOpen or inCamera then return end

    local data = lib.callback.await('highcrest_phone:server:getPhone', false)
    if not data then
        lib.notify({ description = 'You need a phone.', type = 'error' })
        return
    end

    isOpen = true
    sendClock()
    SendNUIMessage({ action = 'open', data = data })
    SetNuiFocus(true, true)

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
end

-- Camera mode hands control back to the player so they can walk and frame the shot.
local function runCamera()
    inCamera = true
    isOpen = false
    SetNuiFocus(false, false)

    CreateThread(function()
        local busy = false

        while inCamera do
            Wait(0)
            if not busy and IsControlJustPressed(0, CONTROL_ENTER) then
                busy = true
                CreateThread(function()
                    local result = lib.callback.await('highcrest_phone:server:takePhoto', false)
                    SendNUIMessage({ action = 'captured', result = result })
                    busy = false
                end)
            elseif IsControlJustPressed(0, CONTROL_BACKSPACE) then
                inCamera = false
                isOpen = true
                SendNUIMessage({ action = 'cameraClosed' })
                SetNuiFocus(true, true)
            end
        end
    end)
end

RegisterCommand('hcphone', openPhone, false)

RegisterNUICallback('close', function(_, cb)
    closePhone()
    cb(1)
end)

RegisterNUICallback('startCamera', function(_, cb)
    runCamera()
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

RegisterNetEvent('highcrest_phone:client:photo', function(id, src)
    SendNUIMessage({ action = 'photo', id = id, src = src })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and (isOpen or inCamera) then
        SetNuiFocus(false, false)
    end
end)
