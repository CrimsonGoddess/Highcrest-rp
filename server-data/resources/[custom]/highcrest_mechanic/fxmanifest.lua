fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_mechanic'
description 'Highcrest mechanic orders: customers design builds at the shop, mechanics quote and fit them from a tablet'
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
    'html/style.css',
    'html/app.js',
    'html/fonts/*.woff2',
}
