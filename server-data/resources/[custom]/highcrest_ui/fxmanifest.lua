fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_ui'
description 'Highcrest HUD: pause menu colors, badge, compass bar and street name'
version '1.2.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client/main.lua',
    'client/compass.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/assets/icon.png',
    'html/assets/fonts/*.woff2',
}
