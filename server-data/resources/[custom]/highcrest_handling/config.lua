Config = {}

-- Discord channel staff paste exported handling into (from /handlingeditor → Export).
-- The bot token is the same one the pause menu uses: set highcrest_discord_token in secrets.cfg.
Config.channelId = '1570224751383675031'

-- How often the server checks the channel, in seconds.
Config.checkEvery = 120

-- Only these Discord accounts can change handling (same people as the pause menu staff list).
Config.allowed = {
    ['203335774895079425'] = 'Crimson',
    ['527137345619755018'] = 'Slug',
    ['246682979244441601'] = 'Gina',
    ['429060029342154772'] = 'Gracie',
    ['733120302489534474'] = 'Ash',
}
