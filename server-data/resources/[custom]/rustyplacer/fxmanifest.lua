fx_version 'cerulean'
game 'gta5'

name 'zoov_placeprops'
author 'zoov.dev'
description 'Placeable props with persistence (QBox + ox_lib + ox_inventory)'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/config.lua',
    'shared/utils.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory',
    'oxmysql',
    'ox_target'
}
