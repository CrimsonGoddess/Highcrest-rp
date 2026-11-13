-- Highcrest tsunami, client side. Nothing here takes the mouse or covers the screen:
--   * an emergency ticker scrolls across the top (the compass moves below it)
--   * the alert goes to the phone and the nearest TV (sent by the server)
--   * the sea rises over the city (our own water layout, flood.xml), with a storm and a blackout
-- A preview (/tsunamitest) runs faster, only for the admin, and puts everything back afterwards.

local TICKER_HEIGHT = 3.6 -- vh, must match .ticker height in html/style.css
local active = false      -- the ticker / event is running
local previewRun = 0      -- bumps on each preview so an old one can't undo a newer one

---------------------------------------------------------------------------
-- Ticker and ground shake
---------------------------------------------------------------------------

local shaking = false
local function stopShake()
    if shaking then StopGameplayCamShaking(true) shaking = false end
end

local function hideTicker()
    SendNUIMessage({ action = 'stop' })
    TriggerEvent('highcrest_ui:setTopBanner', 0)
    stopShake()
    active = false
end

local function showTicker(seconds, preview)
    active = true
    SendNUIMessage({ action = 'warn', seconds = seconds, text = Config.text, preview = preview == true })
    TriggerEvent('highcrest_ui:setTopBanner', TICKER_HEIGHT)

    -- A light rumble near the end, growing as the water arrives.
    CreateThread(function()
        local endsAt = GetGameTimer() + seconds * 1000
        local shakeFor = math.min(Config.shakeFrom, seconds) * 1000
        while active and GetGameTimer() < endsAt do
            local left = endsAt - GetGameTimer()
            if left <= shakeFor then
                if not shaking then ShakeGameplayCam('ROAD_VIBRATION_SHAKE', 0.3) shaking = true end
                SetGameplayCamShakeAmplitude(0.3 + (1 - left / shakeFor) * 0.9)
            end
            Wait(250)
        end
        stopShake()
    end)
end

---------------------------------------------------------------------------
-- Flood: load a water layout that covers the whole map at sea level, then raise it.
-- GTA's own water only covers the sea, so raising it never reaches the land.
---------------------------------------------------------------------------

local flooded = false
local level = 0.0

local function setLevel(value)
    level = value
    for i = 0, GetWaterQuadCount() - 1 do SetWaterQuadLevel(i, value) end
end

local function loadFloodWater()
    if flooded then return true end
    if not LoadWaterFromPath(GetCurrentResourceName(), 'flood.xml') then
        print('^1[highcrest_tsunami] Could not load flood.xml^7')
        return false
    end
    flooded = true
    setLevel(0.0)
    return true
end

local function restoreWater()
    if not flooded then return end
    ResetWater() -- back to GTA's normal water
    flooded = false
    level = 0.0
end

-- Ease the water from `from` to `to` over `ms`. Stops early if the run was replaced.
local function easeLevel(from, to, ms, run)
    local started = GetGameTimer()
    while true do
        if run and run ~= previewRun then return false end
        local t = math.min(1.0, (GetGameTimer() - started) / ms)
        -- Slow at first and faster at the end on the way up; smooth on the way down.
        local k = to > from and (t * t) or (1 - (1 - t) * (1 - t))
        setLevel(from + (to - from) * k)
        if t >= 1.0 then return true end
        Wait(100)
    end
end

---------------------------------------------------------------------------
-- Storm and blackout
---------------------------------------------------------------------------

local storming = false

local function startStorm(seconds)
    local s = Config.storm
    if not s.enabled then return end
    storming = true
    ClearOverrideWeather()
    SetWeatherTypeOvertimePersist(s.weather, 6.0)
    SetRainLevel(1.0)
    CreateThread(function()
        local started = GetGameTimer()
        local nextFlash = GetGameTimer() + 1500
        while storming do
            local t = math.min(1.0, (GetGameTimer() - started) / (seconds * 1000))
            SetDeepOceanScaler(1.0 + (s.waves - 1.0) * t)
            SetWind(1.0)
            SetWindSpeed(s.wind * (0.4 + 0.6 * t))
            if GetGameTimer() >= nextFlash then
                ForceLightningFlash()
                nextFlash = GetGameTimer() + math.random(s.lightningEvery[1], s.lightningEvery[2]) * 1000
            end
            Wait(250)
        end
    end)
end

local function stopStorm()
    if not storming then return end
    storming = false
    ResetDeepOceanScaler()
    SetRainLevel(-1.0)
    SetWind(0.0)
    SetWindSpeed(0.0)
    local current = GlobalState.weather
    if current and current.weather then SetWeatherTypeOvertimePersist(current.weather, 15.0) end
end

local function setBlackout(on)
    SetArtificialLightsState(on)
    SetArtificialLightsStateAffectsVehicles(false) -- car lights keep working
end

---------------------------------------------------------------------------
-- The real event (before a scheduled restart). Storm weather and the blackout are set
-- server-wide through Renewed-Weathersync (GlobalState); the rest runs here.
---------------------------------------------------------------------------

RegisterNetEvent('highcrest_tsunami:client:start', function(seconds)
    seconds = tonumber(seconds) or 120
    showTicker(seconds, false)
    startStorm(seconds)
    if Config.flood.enabled and loadFloodWater() then
        CreateThread(function() easeLevel(0.0, Config.flood.height, seconds * 1000) end)
    end
end)

---------------------------------------------------------------------------
-- Preview: only this player, faster, then everything goes back.
---------------------------------------------------------------------------

local function endPreview()
    previewRun = previewRun + 1
    hideTicker()
    stopStorm()
    LocalPlayer.state:set('syncWeather', true, true) -- Renewed-Weathersync takes over again
    setBlackout(GlobalState.blackOut == true)
    restoreWater()
end

RegisterNetEvent('highcrest_tsunami:client:preview', function()
    local f = Config.flood
    previewRun = previewRun + 1
    local run = previewRun
    local seconds = f.previewSeconds

    -- Stop Renewed-Weathersync from putting the weather back mid-preview.
    LocalPlayer.state:set('syncWeather', false, true)
    showTicker(seconds + f.previewHold, true)
    startStorm(seconds)
    -- Lights go out a few seconds in, like the power failing.
    SetTimeout(4000, function() if run == previewRun then setBlackout(true) end end)

    CreateThread(function()
        if f.enabled and loadFloodWater() then
            if not easeLevel(0.0, f.height, seconds * 1000, run) then return end
        else
            Wait(seconds * 1000)
        end
        Wait(f.previewHold * 1000)
        if run ~= previewRun then return end
        if flooded then easeLevel(level, 0.0, 8000, run) end
        if run == previewRun then endPreview() end
    end)
end)

RegisterNetEvent('highcrest_tsunami:client:stopPreview', endPreview)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    hideTicker()
    stopStorm()
    restoreWater()
end)
