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

---------------------------------------------------------------------------
-- The flood: raise every water area a little at a time.
---------------------------------------------------------------------------

local flooding = false
local baseLevels -- quad index -> original height

local function readBaseLevels()
    local levels = {}
    for i = 0, GetWaterQuadCount() - 1 do
        local ok, level = GetWaterQuadLevel(i)
        if ok then levels[i] = level end
    end
    return levels
end

local function setFlood(extra)
    for i, level in pairs(baseLevels) do SetWaterQuadLevel(i, level + extra) end
end

local function drain()
    if not baseLevels then return end
    setFlood(0.0)
    flooding = false
end

-- Rise from 0 to height over `seconds`. With hold set (the preview), drain afterwards.
local function flood(seconds, hold)
    if not Config.flood.enabled or flooding then return end
    flooding = true
    baseLevels = baseLevels or readBaseLevels()
    CreateThread(function()
        local started = GetGameTimer()
        local total = seconds * 1000
        while flooding do
            local t = math.min(1.0, (GetGameTimer() - started) / total)
            -- Slow at first, faster near the end, like a wave arriving.
            setFlood(Config.flood.height * (t * t))
            if t >= 1.0 then break end
            Wait(500)
        end
        if hold and flooding then
            Wait(hold * 1000)
            drain()
        end
    end)
end

RegisterNetEvent('highcrest_tsunami:client:flood', function(seconds, hold)
    flood(tonumber(seconds) or 120, hold and tonumber(hold) or nil)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then drain() end
end)

---------------------------------------------------------------------------
-- The storm: thunder, lightning, wind and waves that build up with the flood.
---------------------------------------------------------------------------

local storming = false

local function stopStorm()
    if not storming then return end
    storming = false
    ResetDeepOceanScaler()
    SetWind(0.0)
    SetWindSpeed(0.0)
    -- Hand the weather back to the server's weather.
    local current = GlobalState.weather
    if current and current.weather then SetWeatherTypeOvertimePersist(current.weather, 15.0) end
end

local function storm(seconds, hold)
    local s = Config.storm
    if not s.enabled or storming then return end
    storming = true
    SetWeatherTypeOvertimePersist(s.weather, 8.0)
    CreateThread(function()
        local started = GetGameTimer()
        local total = seconds * 1000
        local nextFlash = GetGameTimer() + 2000
        while storming do
            local t = math.min(1.0, (GetGameTimer() - started) / total)
            SetDeepOceanScaler(1.0 + (s.waves - 1.0) * t)
            SetWind(1.0)
            SetWindSpeed(s.wind * (0.4 + 0.6 * t))
            if GetGameTimer() >= nextFlash then
                ForceLightningFlash()
                nextFlash = GetGameTimer() + math.random(s.lightningEvery[1], s.lightningEvery[2]) * 1000
            end
            if hold and GetGameTimer() - started > total + hold * 1000 then break end
            Wait(250)
        end
        if hold then stopStorm() end
    end)
end

RegisterNetEvent('highcrest_tsunami:client:storm', function(seconds, hold)
    storm(tonumber(seconds) or 120, hold and tonumber(hold) or nil)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then stopStorm() end
end)
