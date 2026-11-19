fx_version 'cerulean'
game 'gta5'

author ''
description 'Yoga stress-relief script using ox_target and ox_lib for QBCore'
version '1.0.0'

-- Dependencies
lua54 'yes'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    '@qb-core/server/main.lua',
    'server.lua'
}