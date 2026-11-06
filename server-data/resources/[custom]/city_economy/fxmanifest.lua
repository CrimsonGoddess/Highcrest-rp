fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'city_economy'
description 'Income tax on paychecks, paid into the city treasury'
version '1.0.0'

dependencies {
    'ox_lib',
    'qbx_core',
    'Renewed-Banking',
}

shared_script '@ox_lib/init.lua'

server_scripts {
    'config.lua',
    'server/main.lua',
}
