fx_version 'cerulean'
games {'gta5'}

author 'Eternium Roleplay'
description ''

lua54 'yes'

data_file 'VEHICLE_LAYOUTS_FILE' 	'data/**/**/vehiclelayouts.meta'
data_file 'HANDLING_FILE' 			'data/**/**/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 	'data/**/**/vehicles.meta'
data_file 'CARCOLS_FILE' 			'data/**/**/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE'  'data/**/**/carvariations.meta'


files {
  'data/**/**/*.meta',
  'data/**/**/*.xml',
  'data/**/**/*.dat',
  'data/**/**/*.ytyp',
}

client_script 'data/**/**/vehicle_names.lua'
lua54 'yes'