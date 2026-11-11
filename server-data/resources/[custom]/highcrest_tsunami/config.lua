Config = {}

-- How many seconds before a scheduled txAdmin restart the tsunami warning goes out.
-- txAdmin sends its restart warnings at 30, 15, 10, 5, 4, 3, 2 and 1 minutes, so this
-- must be one of those times in seconds (120 = 2 minutes).
Config.warnAt = 120

-- How long the full-screen emergency broadcast stays up before shrinking to a countdown bar.
Config.broadcastSeconds = 18

-- The ground starts shaking this many seconds before the restart.
Config.shakeFrom = 30

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
