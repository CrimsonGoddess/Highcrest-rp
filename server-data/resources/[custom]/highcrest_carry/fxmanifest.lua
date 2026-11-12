fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_carry'
description 'Highcrest /carry: fireman carry another player (they accept; downed players are picked up straight away)'
version '1.0.0'

shared_script '@ox_lib/init.lua'
client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'ox_lib',
    'qbx_core',
}
