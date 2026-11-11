local endsAt = 0
local shaking = false

local function stopShake()
    if shaking then
        StopGameplayCamShaking(true)
        shaking = false
    end
end

RegisterNetEvent('highcrest_tsunami:client:warn', function(seconds, preview)
    endsAt = GetGameTimer() + seconds * 1000
    SendNUIMessage({
        action = 'warn',
        seconds = seconds,
        broadcastSeconds = Config.broadcastSeconds,
        text = Config.text,
        preview = preview == true,
    })

    -- The ground shakes harder as the wave gets closer. A preview only shakes briefly.
    CreateThread(function()
        local shakeUntil = preview and (GetGameTimer() + 6000) or endsAt
        local shakeStart = preview and GetGameTimer() or (endsAt - Config.shakeFrom * 1000)
        while GetGameTimer() < shakeUntil do
            if GetGameTimer() >= shakeStart and not shaking then
                ShakeGameplayCam('ROAD_VIBRATION_SHAKE', 0.6)
                shaking = true
            end
            if shaking then
                local left = (shakeUntil - GetGameTimer()) / 1000
                local total = preview and 6 or Config.shakeFrom
                SetGameplayCamShakeAmplitude(0.6 + (1 - left / total) * 1.4)
            end
            Wait(250)
        end
        stopShake()
    end)
end)

RegisterNetEvent('highcrest_tsunami:client:phone', function()
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
    lib.notify({
        title = 'Emergency Alert',
        description = Config.text.phone,
        icon = 'triangle-exclamation',
        iconColor = '#ff4d66',
        type = 'error',
        position = 'top',
        duration = 15000,
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then stopShake() end
end)
