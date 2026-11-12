fx_version 'cerulean'

game 'gta5'


client_scripts {
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'server/main.lua',
	'config.lua',
}

lua54 'yes'

escrow_ignore {
    'config.lua',
    'union.lua',
	'client/main.lua',
    'server/main.lua',
}


dependency '/assetpacks'