fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Samuel#0008 & ZF Labo'
description 'Advanced Beekeeping System for QBCore and ESX'
Version '1.3.0'

client_script 'client/*.lua'

server_scripts { '@oxmysql/lib/MySQL.lua', 'server/*.lua' }

dependency 'sd_lib' -- Highcrest: start sd_lib first (it runs on both server and client)
shared_scripts { '@sd_lib/init.lua', '@ox_lib/init.lua', 'config.lua' }

files { 'locales/*.json' }

data_file 'DLC_ITYP_REQUEST' 'stream/hp3d_beehive.ytyp'

escrow_ignore { '**/*.lua', 'stream/**', 'config.lua', }
dependency '/assetpacks'