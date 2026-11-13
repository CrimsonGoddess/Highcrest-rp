fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ef_shops_admin'
description 'In-game panel for making and editing ef_shops stores (/shopadmin)'
version '1.0.0'

dependencies {
	'ox_lib',
	'ox_inventory',
	'oxmysql',
	'ef_shops',
}

ui_page 'web/build/index.html'

files {
	'web/build/index.html',
	'web/build/**/*',
}

shared_script '@ox_lib/init.lua'

client_script 'client/main.lua'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/validate.lua',
	'server/main.lua',
}
