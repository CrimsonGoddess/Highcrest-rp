fx_version 'cerulean'
game 'gta5'

description 'rcore spray'

version '2.12.1'

client_scripts {
    'object.lua',
	'config.lua',
	'client/secret_sauce.lua',
	'client/fonts.lua',
	'client/determinant.lua',
	'client/raycast.lua',
	'client/client.lua',
	'client/control.lua',
	'client/remove.lua',
	'client/cancellable_progress.lua',
	'client/framework/*.lua',
}

server_scripts {
	'config.lua',

	'@oxmysql/lib/MySQL.lua', -- Highcrest: oxmysql instead of mysql-async

	'server/framework/*.lua',
	'server/db/bridge.lua',

	'server/db.lua',
	'server/server.lua',
	'server/remove.lua',
	
    'object.lua',
}

lua54 "yes"

escrow_ignore {
	'config.lua',

	'server/framework/*.lua',
	'server/db/*.lua',

	'server/*.lua',

	'client/cancellable_progress.lua',
	'client/client.lua',
	'client/control.lua',
	'client/fonts.lua',
	'client/raycast.lua',
	'client/remove.lua',
	
	'client/framework/QBCore.lua',

	'stream/*',
}

ui_page 'ui/index.html'

files {
	'ui/index.html',
	'ui/css/app.css',
	'ui/scripts/app.js',
	'ui/graffiti/*',
	'ui/fonts/*',
	'ui/images/*'
}

dependencies {
	'rcore_spray_assets',
}

dependency '/assetpacks'