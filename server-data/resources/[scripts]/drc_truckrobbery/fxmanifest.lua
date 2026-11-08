
fx_version 'adamant'


game 'gta5'

ui_page 'html/index.html'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua'
}

files {
	'locales/*.json',
    'html/index.html',
    'html/script.js',
    'html/styles.css',
    'html/images/laptop.png',
	'html/images/truck.png',
	'html/images/stickybomb.png',
	'html/images/armedButton.png',
	'html/images/armed.png',
	'html/sound/beep.mp3',
	'html/sound/beepArmed.mp3',
}


client_script {
	'client/cl_utils.lua',
	'client/*.lua',
	'config.lua'
}

server_script {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
	'config.lua'
}


escrow_ignore {
    'config.lua',
	'client/cl_utils',
	'locales/*.json',
	'server/sv_utils'
  }

lua54 'yes'