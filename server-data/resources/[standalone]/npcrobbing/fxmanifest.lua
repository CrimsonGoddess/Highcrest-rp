fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'et_npcrobbery'
description 'Rob street NPCs with chance to run/fight + ps-dispatch alert'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}
