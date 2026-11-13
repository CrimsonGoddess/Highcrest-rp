fx_version 'cerulean'
game 'gta5'

name "Rusty's Edits"
description 'Rustys Edits DO NOT RESTART EVER'
author 'akaRustyyy'
version '1.0.0'

client_script 'client/*.lua'
server_script 'server/*.lua'

this_is_a_map 'yes'


files {
    'stream/**/*.meta',
    'stream/**/*.ybn',
    'stream/**/*.ydr',
    'stream/**/*.ymap',
    'stream/**/*.ynd',
    'stream/**/*.ymf',
    'stream/**/*.ydd',
    'stream/**/*.ytd',
    'stream/**/*.ymt'
    
}


dependcy 'ox_lib'