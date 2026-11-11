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
}

-- The message shown to a player who leaves with the Disconnect button.
Config.leaveMessage = 'You left Highcrest RP. See you soon.'
