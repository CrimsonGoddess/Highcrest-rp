Config = {}

-- Buttons on the pause menu. Leave a link empty to show the button as "Coming soon".
-- Keep these the same as LINKS in highcrest_ui/client/main.lua and highcrest_loadscreen/html/main.js.
Config.links = {
    discord = 'https://discord.gg/Se7Sx7nnkv',
    store = '',
}

-- Server rules shown on the pause menu. Edit freely; each line is one rule.
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
--   name:       what players see
--   role:       e.g. Owner, Admin, Moderator, Support
--   identifier: optional. With it, a green dot shows when that person is in the city.
--               Use their FiveM ID (fivem:1234567), license:... or discord:... identifier.
Config.staff = {
    { name = 'CleverGoose6564', role = 'Owner' },
    { name = 'ChillyMoth4656', role = 'Owner', identifier = 'fivem:8089178' },
    { name = 'SlowAnt8494', role = 'Owner', identifier = 'fivem:1670014' },
}

-- The message shown to a player who leaves with the Disconnect button.
Config.leaveMessage = 'You left Highcrest RP. See you soon.'
