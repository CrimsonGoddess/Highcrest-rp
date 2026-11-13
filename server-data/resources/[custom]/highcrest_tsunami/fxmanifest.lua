fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_tsunami'
description 'Tsunami before each scheduled txAdmin restart: phone and TV alerts, a ticker across the top, storm, blackout and a rising flood'
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
    'html/fonts/*.woff2',
    'flood.xml',
}
