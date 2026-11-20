fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'RTX Development'
description 'RTX Shell Creator - build house interiors in game and turn them into shells and MLOs. Made by Kanikuly (Nina) for RTX Development'
version '1.0.5'

ui_page 'html/ui.html'

shared_scripts {
	'config.lua',
	'language/*.lua',
	'shared/main.lua'
}

client_scripts {
	'client/other.lua',
	'client/main.lua'
}

server_scripts {
	'server/engine.js',
	'html/shellgeo.js',
	'server/files.js',
	'server/shell.js',
	'server/other.lua',
	'server/main.lua'
}

files {
	'html/ui.html',
	'html/*.js',
	'html/*.css',
	'html/*.ttf',
	'html/data/*.json',
	'html/img/*.webp',
	'html/img/doors/*.webp',
	'html/img/home/*.webp',
	'html/img/kit/*.webp',
	'html/img/props.bin',
	'html/img/props.json',
	'data/kit.json',
	'custom/*.png'
}

escrow_ignore {
	'config.lua',
	'language/*.lua',
	'client/other.lua',
	'server/other.lua'
}

dependency '/assetpacks'

dependency '/assetpacks'