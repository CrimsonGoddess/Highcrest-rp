Config = {}

-- The timeline, in seconds BEFORE the scheduled txAdmin restart.
-- txAdmin announces restarts at 30, 15, 10, 5, 4, 3, 2 and 1 minutes, so alertAt must be one of
-- those (180 = 3 minutes). The rest are timed from it.
Config.timeline = {
    alertAt = 180,   -- phones, TVs, the ticker and chat
    stormAt = 150,   -- thunderstorm, wind and big waves
    lightsAt = 120,  -- city-wide blackout (street, building and traffic lights; car lights stay on)
    floodFrom = 120, -- the sea starts rising
    floodedAt = 30,  -- the whole city is under water
    shakeFrom = 30,  -- a light ground rumble until the restart
}
Config.warnAt = Config.timeline.alertAt

-- Blackout is set server-wide through Renewed-Weathersync (GlobalState.blackOut).
Config.blackout = { enabled = true }

-- Only players carrying this item get the phone alert.
Config.phoneItem = 'phone'

Config.text = {
    headline = 'Tsunami Warning',
    body = 'A tsunami is approaching Los Santos. Move to high ground and get to safety now. '
        .. 'The city will be evacuated in three minutes.',
    ticker = 'EMERGENCY ALERT SYSTEM · NATIONAL WEATHER SERVICE · TSUNAMI WARNING IN EFFECT FOR ALL OF '
        .. 'LOS SANTOS AND BLAINE COUNTY · MOVE INLAND AND TO HIGH GROUND IMMEDIATELY · '
        .. 'THIS IS NOT A TEST · ',
    phone = 'Tsunami warning for Los Santos. Seek high ground. City evacuation in 3 minutes.',
    chat = 'EMERGENCY ALERT: A tsunami is approaching. The city will be evacuated (server restart) in 3 minutes.',
}

-- The flood: flood.xml (large water tiles over the whole map at sea level) is loaded and rises
-- by `height` metres between floodFrom and floodedAt. While it is loaded, inland lakes and rivers
-- are covered by it. /tsunamitest runs the same timeline for you only, holds for previewHold
-- seconds at the end, then drains and puts everything back.
Config.flood = {
    enabled = true,
    height = 50.0,     -- metres above sea level: enough to cover downtown; the hills stay dry
    step = 0.25,       -- only move the water when it has risen this much (fewer redraws, no flicker)
    previewHold = 15,
}

-- The storm during the flood: thunder, lightning, wind and huge waves that build up.
Config.storm = {
    enabled = true,
    weather = 'THUNDER',
    wind = 12.0,          -- wind speed (GTA's normal storm is about 5)
    waves = 3.0,          -- deep ocean wave scale at the peak (1.0 = normal)
    lightningEvery = { 3, 9 }, -- seconds between lightning flashes (random)
}
