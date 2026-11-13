-- Highcrest tsunami, client side. Nothing here takes the mouse or covers the screen.
-- Timeline (Config.timeline, seconds before the restart):
--   3:00 alert (ticker across the top, phone, TV, chat) · 2:30 storm · 2:00 blackout and the sea
--   starts rising · 0:30 the city is under water · 0:00 restart.
-- /tsunamitest runs the same timeline for the admin only, then puts everything back.

local TICKER_HEIGHT = 3.6 -- vh, must match .ticker height in html/style.css
local run = 0             -- bumps on each start/stop so an old timeline stops itself
local preview = false

local function alive(id) return id == run end

-- Wait until `secondsLeft` before the end of this run (false if the run was replaced).
local function waitUntil(id, endsAt, secondsLeft)
    while GetGameTimer() < endsAt - secondsLeft * 1000 do
        if not alive(id) then return false end
        Wait(100)
    end
    return alive(id)
end

---------------------------------------------------------------------------
-- Ticker and ground shake
---------------------------------------------------------------------------

local shaking = false
local function stopShake()
    if shaking then StopGameplayCamShaking(true) shaking = false end
end

local function showTicker(seconds)
    SendNUIMessage({ action = 'warn', seconds = seconds, text = Config.text, preview = preview })
    TriggerEvent('highcrest_ui:setTopBanner', TICKER_HEIGHT)
end

local function hideTicker()
    SendNUIMessage({ action = 'stop' })
    TriggerEvent('highcrest_ui:setTopBanner', 0)
end

---------------------------------------------------------------------------
-- Flood: our own water layout over the whole map (GTA's water only covers the sea, so raising
-- it never reaches land), raised in small steps so GTA doesn't keep rebuilding the water.
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
    ResetWater()
    flooded = false
    level = 0.0
end

-- Move the water from its current level to `to` over `ms`, easing in, in Config.flood.step jumps.
local function moveWater(id, to, ms)
    local from, started = level, GetGameTimer()
    local step = Config.flood.step or 0.25
    while alive(id) do
        local t = math.min(1.0, (GetGameTimer() - started) / ms)
        local k = to > from and (t * t * (3 - 2 * t)) or t -- smooth start and finish
        local target = from + (to - from) * k
        if math.abs(target - level) >= step or t >= 1.0 then setLevel(target) end
        if t >= 1.0 then return true end
        Wait(250)
    end
    return false
end

---------------------------------------------------------------------------
-- Storm and blackout
---------------------------------------------------------------------------

local storming = false

local function startStorm(id, buildSeconds)
    local s = Config.storm
    if not s.enabled then return end
    storming = true
    ClearOverrideWeather()
    SetWeatherTypeOvertimePersist(s.weather, 10.0)
    CreateThread(function()
        local started = GetGameTimer()
        local nextFlash = GetGameTimer() + 1500
        while storming and alive(id) do
            local t = math.min(1.0, (GetGameTimer() - started) / (buildSeconds * 1000))
            SetRainLevel(0.4 + 0.6 * t)
            SetDeepOceanScaler(1.0 + (s.waves - 1.0) * t)
            SetWind(1.0)
            SetWindSpeed(s.wind * (0.3 + 0.7 * t))
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
-- The timeline
---------------------------------------------------------------------------

local function cleanUp()
    hideTicker()
    stopShake()
    stopStorm()
    restoreWater()
    if preview then
        LocalPlayer.state:set('syncWeather', true, true) -- Renewed-Weathersync takes over again
        setBlackout(GlobalState.blackOut == true)
        preview = false
    end
end

local function runTimeline(isPreview)
    run = run + 1
    local id = run
    preview = isPreview
    local tl = Config.timeline
    local endsAt = GetGameTimer() + tl.alertAt * 1000

    -- A preview stops Renewed-Weathersync from putting the weather back half way through.
    if preview then LocalPlayer.state:set('syncWeather', false, true) end

    CreateThread(function()
        showTicker(tl.alertAt)

        if not waitUntil(id, endsAt, tl.stormAt) then return end
        startStorm(id, tl.stormAt - tl.floodedAt)

        if not waitUntil(id, endsAt, tl.lightsAt) then return end
        if Config.blackout.enabled then setBlackout(true) end

        if not waitUntil(id, endsAt, tl.floodFrom) then return end
        if Config.flood.enabled and loadFloodWater() then
            CreateThread(function()
                moveWater(id, Config.flood.height, (tl.floodFrom - tl.floodedAt) * 1000)
            end)
        end

        if not waitUntil(id, endsAt, tl.shakeFrom) then return end
        ShakeGameplayCam('ROAD_VIBRATION_SHAKE', 0.3)
        shaking = true

        if not waitUntil(id, endsAt, 0) then return end
        stopShake()
        if not preview then return end -- the real one ends with the restart

        -- Preview: hold, drain, and put everything back.
        local holdUntil = GetGameTimer() + (Config.flood.previewHold or 15) * 1000
        while alive(id) and GetGameTimer() < holdUntil do Wait(200) end
        if not alive(id) then return end
        hideTicker()
        if flooded then moveWater(id, 0.0, 8000) end
        if alive(id) then cleanUp() end
    end)
end

RegisterNetEvent('highcrest_tsunami:client:start', function() runTimeline(false) end)
RegisterNetEvent('highcrest_tsunami:client:preview', function() runTimeline(true) end)

RegisterNetEvent('highcrest_tsunami:client:stopPreview', function()
    if not preview then return end
    run = run + 1
    cleanUp()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    run = run + 1
    cleanUp()
end)
