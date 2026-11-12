fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_handling'
description 'Highcrest car tuning: handling posted in the Discord #handling channel is saved into handling.meta'
version '1.1.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'realism.lua',
    'addons.lua',
    'client.lua',
}

server_scripts {
    'config.lua',
    'server.lua',
}

-- handling.meta and entries.json are written on the server (see server.lua) and are not in the repo.
files { 'handling.meta' }

data_file 'HANDLING_FILE' 'handling.meta'
