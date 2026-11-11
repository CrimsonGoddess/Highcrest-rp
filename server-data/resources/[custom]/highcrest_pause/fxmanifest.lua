fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_pause'
description 'Highcrest pause menu (Esc): map, settings, character card, server info, rules and links'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/assets/icon.png',
    'html/assets/fonts/*.woff2',
}
