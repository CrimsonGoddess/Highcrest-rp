fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_tv'
description 'Highcrest TVs: play YouTube or video links on in-world TVs, synced for everyone nearby'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'

files {
    'html/screen.html',
}

dependencies {
    'ox_lib',
    'ox_target',
}
