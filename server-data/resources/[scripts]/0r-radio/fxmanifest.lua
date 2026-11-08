fx_version 'cerulean'
game {'gta5'}
lua54 'yes'

scriptname '0r-rccar'
version '1.1.1'

client_scripts {'client/*.lua'}
server_scripts {'server/*.lua'}
shared_scripts {'@ox_lib/init.lua', 'shared/*.lua'}
ui_page 'web/build/index.html'
files {'locales/**/*', 'web/**'}
escrow_ignore {
	'client/*.lua',
	'server/*.lua',
	'shared/*.lua',
	'locales/*.lua'
}
dependency '/assetpacks'
dependency '/assetpacks'