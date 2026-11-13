Config = {}

-- How many seconds before a scheduled txAdmin restart the tsunami warning goes out.
-- txAdmin sends its restart warnings at 30, 15, 10, 5, 4, 3, 2 and 1 minutes, so this
-- must be one of those times in seconds (120 = 2 minutes).
Config.warnAt = 120

-- A light ground rumble starts this many seconds before the restart.
Config.shakeFrom = 30

-- City-wide blackout (street, building and traffic lights; car lights stay on), this many
-- seconds after the warning starts. Set through Renewed-Weathersync (GlobalState.blackOut).
Config.blackout = { enabled = true, after = 20 }

-- Only players carrying this item get the phone alert.
Config.phoneItem = 'phone'

Config.text = {
    headline = 'Tsunami Warning',
    body = 'A tsunami is approaching Los Santos. Move to high ground and get to safety now. '
        .. 'The city will be evacuated in two minutes.',
    ticker = 'EMERGENCY ALERT SYSTEM · NATIONAL WEATHER SERVICE · TSUNAMI WARNING IN EFFECT FOR ALL OF '
        .. 'LOS SANTOS AND BLAINE COUNTY · MOVE INLAND AND TO HIGH GROUND IMMEDIATELY · '
        .. 'THIS IS NOT A TEST · ',
    phone = 'Tsunami warning for Los Santos. Seek high ground. City evacuation in 2 minutes.',
    chat = 'EMERGENCY ALERT: A tsunami is approaching. The city will be evacuated (server restart) in 2 minutes.',
}

-- The flood: flood.xml (water tiles over the whole map at sea level) is loaded and rises by
-- `height` metres over the warning, so the coast and low ground are under water by the restart.
-- While it's loaded, GTA's lakes and rivers inland are replaced by it. The preview (/tsunamitest)
-- floods faster (previewSeconds), holds for previewHold seconds, then drains.
Config.flood = {
    enabled = true,
    height = 30.0,
    previewSeconds = 40,
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
