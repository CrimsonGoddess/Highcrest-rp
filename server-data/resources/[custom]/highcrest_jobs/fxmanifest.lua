fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_jobs'
description 'Highcrest jobs: create and edit jobs in-game, and place clock-in, stash and boss menu spots for any job'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

dependencies {
    'ox_lib',
    'qbx_core',
    'ox_target',
    'ox_inventory',
}
