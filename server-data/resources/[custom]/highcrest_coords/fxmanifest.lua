fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_coords'
description 'Highcrest /coords: admin coordinate tool (raycast picking, live preview, nudging, copy in any format)'
version '1.0.0'

shared_script '@ox_lib/init.lua'
client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'
files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/fonts/*.woff2',
}

dependency 'ox_lib'
