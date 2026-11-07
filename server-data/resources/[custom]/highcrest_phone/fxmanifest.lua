fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_phone'
description 'Highcrest RP phone'
version '0.3.0'

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'ox_inventory',
    'screencapture',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/contacts.lua',
    'server/messages.lua',
    'server/calls.lua',
    'server/feed.lua',
    'server/market.lua',
    'server/dating.lua',
    'server/darkweb.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/comms.js',
    'html/apps.js',
    'html/assets/fonts/*.woff2',
}
