fx_version 'cerulean'
game 'gta5'

author 'zoov.dev'
description 'Radio animation selector (pma-voice)'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua',
}

dependencies {
    'ox_lib',
    'pma-voice'
}

files {
    'stream/*.ycd'  
}

data_file 'ANIM_DICT' 'stream/anim@cop_radio_pose.ycd'

lua54 'yes'
