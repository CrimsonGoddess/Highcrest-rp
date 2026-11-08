fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_spawn'
description 'Highcrest RP spawn picker with a cinematic camera'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/fonts/*.woff2',
}
