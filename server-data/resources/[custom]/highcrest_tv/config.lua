Config = {}

-- TV models players can use. They all draw to the "tvscreen" render target.
-- To add a TV from a house shell or MLO, add its model name here.
Config.models = {
    'des_tvsmash_start', 'prop_flatscreen_overlay', 'prop_laptop_lester2', 'prop_monitor_02',
    'prop_trev_tv_01', 'prop_tv_02', 'prop_tv_03', 'prop_tv_03_overlay', 'prop_tv_06',
    'prop_tv_flat_01', 'prop_tv_flat_01_screen', 'prop_tv_flat_02', 'prop_tv_flat_02b',
    'prop_tv_flat_03', 'prop_tv_flat_03b', 'prop_tv_flat_michael', 'prop_monitor_w_large',
}

-- The picture shows within this many metres of a playing TV.
Config.drawRange = 25.0

-- Sound fades out over this many metres.
Config.audioRange = 15.0

-- Seconds a player must wait between changing a TV.
Config.cooldown = 3

-- Screen resolution of the video page.
Config.resolution = { width = 1280, height = 720 }
