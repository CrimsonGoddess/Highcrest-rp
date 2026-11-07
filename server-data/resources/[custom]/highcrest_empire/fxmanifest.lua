fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_empire'
description 'Highcrest RP player-owned businesses'
version '1.0.0'

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/business.lua',
    'server/admin.lua',
}
