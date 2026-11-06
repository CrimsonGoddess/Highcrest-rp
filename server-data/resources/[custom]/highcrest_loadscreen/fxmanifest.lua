fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_loadscreen'
description 'Highcrest RP loading screen'
version '1.0.0'

server_script 'server/handover.lua'

files {
    'html/**',
}

loadscreen 'html/index.html'

-- qbx_core closes the loading screen when character selection is ready.
loadscreen_manual_shutdown 'yes'
