fx_version 'cerulean'
game 'gta5'

this_is_a_map 'yes'

author 'PEUREN DEVELOPMENT - peuren.tebex.io'
version '0.0.1'
lua54 'yes'

client_scripts { 'client/**/**' }
shared_scripts { 'shared/sh_main.lua', 'shared/sh_locations.lua'  }
server_scripts { 'server/**/**' }

files { 'locales/*.json', "web/build/**/*" }

dependency 'peuren_lib'

--ui_page "http://localhost:5173/"
ui_page "web/build/index.html"

--escrow_ignore { 'shared/**' }
escrow_ignore { '**/**' }
dependency '/assetpacks'
dependency '/assetpacks'