fx_version 'cerulean'
author 'Marttins | MT scripts'
description 'Simple printers script'
game 'gta5'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'functions.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'web/index.html'

files {
    'locales/*',
    'web/*.html',
    'web/*.js',
}