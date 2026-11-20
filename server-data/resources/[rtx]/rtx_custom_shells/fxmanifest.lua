-- Made by Kanikuly (Nina) for RTX Development
-- https://discord.gg/rtxdev
-- https://rtx.tebex.io/

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'RTX Development'
description 'rtx_custom_shells - 1 made with RTX Shell Creator'
version '1.0.0'

shared_script 'config.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'
ui_page 'html/sound.html'

files {
	'items.json',
	'items/rtx_shell_my_shell/shell.json',
	'html/sound.html'
}

data_file 'DLC_ITYP_REQUEST' 'stream/rtx_shell_my_shell/rtx_shell_my_shell.ytyp'
