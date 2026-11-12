Config = {}

-- Buttons on the pause menu. Leave a link empty to show the button as "Coming soon".
-- Keep these the same as LINKS in highcrest_ui/client/main.lua and highcrest_loadscreen/html/main.js.
Config.links = {
    discord = 'https://discord.gg/Se7Sx7nnkv',
    store = '',
}

-- Store page in the pause menu. Players browse here and press Buy, which copies the package's
-- Tebex checkout link (FiveM can't open a browser). Until Tebex is set up, Buy copies
-- Config.links.store, or says the store isn't open yet if that's empty too.
--   url:   the package's Tebex link (from your Tebex dashboard: Packages → the package → copy link)
-- FiveM/Rockstar rules: never sell in-game money or anything that turns into it.
Config.store = {
    currency = '$',
    -- Tiers match highcrest_vip/config.lua (that's where the perks actually live).
    tiers = {
        {
            tier = 'supporter', name = 'Supporter', price = '4.99', period = 'month', colour = '#c0c0c0',
            perks = { 'Supporter role in Discord', 'Supporter badge on your pause menu', 'Keeps Highcrest running' },
            url = '',
        },
        {
            tier = 'vip', name = 'VIP', price = '9.99', period = 'month', colour = '#d4af37', featured = true,
            perks = { 'Everything in Supporter', 'VIP role in Discord', '1 custom licence plate (/vipplate)', 'Free "Bring to me" valet' },
            url = '',
        },
        {
            tier = 'elite', name = 'Elite', price = '19.99', period = 'month', colour = '#c8102e',
            perks = { 'Everything in VIP', '3 custom licence plates', 'Free garage transfers', 'Elite role in Discord' },
            url = '',
        },
    },
    note = 'All imports stay available to everyone for in-game money. VIP never includes in-game money.',
}

Config.rules = {
    'Stay in character. Out-of-character talk goes in /ooc or Discord.',
    'No random deathmatch. Violence needs a roleplay reason.',
    'Value your life. Act like you have one to lose.',
    'No metagaming: use only what your character knows.',
    'No powergaming or forcing actions on others.',
    'Crime needs a story. Robberies and heists follow the police count.',
    'Respect everyone. No hate speech or harassment, in or out of character.',
    'Bugs and exploits get reported in Discord, never abused.',
}

-- Staff shown on the pause menu, in this order.
--   name:    what players see
--   role:    e.g. Owner, Management, Admin, Moderator, Support
--   discord: their Discord user ID (Discord → Settings → Advanced → Developer Mode on,
--            then right-click them → Copy User ID). It gives:
--              - their Discord profile picture (needs the bot token, see below)
--              - a green dot when they're in the city (FiveM must be linked to their Discord)
--   identifier: optional, another way to get the green dot (fivem:1234567 or license:...).
--
-- Profile pictures need a Discord bot token. Put this line in secrets.cfg (never in this file):
--   set highcrest_discord_token "YOUR_BOT_TOKEN"
-- Create the bot at discord.com/developers/applications → New Application → Bot → Reset Token.
-- The bot doesn't need to join the Discord server or have any permissions.
Config.staff = {
    { name = 'Crimson', role = 'Owner', discord = '203335774895079425' },
    { name = 'Slug', role = 'Management', discord = '527137345619755018' },
    { name = 'Gina', role = 'Management', discord = '246682979244441601' },
    { name = 'Lead Dev', role = 'Lead Dev', discord = '199508907444404224' },
    { name = 'Gracie', role = 'Admin', discord = '429060029342154772' },
    { name = 'Ash', role = 'Admin', discord = '733120302489534474' },
    { name = 'Tanor', role = 'Admin', discord = '249696922334396416' },
}

-- The message shown to a player who leaves with the Disconnect button.
Config.leaveMessage = 'You left Highcrest RP. See you soon.'
