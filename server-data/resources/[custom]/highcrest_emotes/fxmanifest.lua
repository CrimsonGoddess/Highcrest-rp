fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_emotes'
description 'Highcrest emote menu (F4): search, categories, favourites and a live preview on your character. Emotes come from scully_emotemenu.'
version '1.0.0'

shared_script '@ox_lib/init.lua'
client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/fonts/*.woff2',
}

dependency 'scully_emotemenu'
