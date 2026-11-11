fx_version 'cerulean'
game 'gta5'

-- this_is_a_map 'yes' -- Highcrest: no map files in this resource

author 'PEUREN DEVELOPMENT - peuren.tebex.io'
version '0.0.1'
lua54 'yes'

client_scripts { 'client/**/**' }
shared_scripts { 'shared/sh_main.lua', 'shared/sh_locations.lua'  }
server_scripts { 'server/**/**' }

files { 'locales/*.json', "web/dist/**/*" }

dependency 'peuren_lib'

--ui_page "http://localhost:5173/"
ui_page "web/dist/index.html"

escrow_ignore { '**/**' }
dependency '/assetpacks'