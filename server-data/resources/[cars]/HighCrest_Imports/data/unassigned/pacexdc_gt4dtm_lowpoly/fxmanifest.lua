fx_version 'cerulean'
games {'gta5'}

author 'PaceDesigns'
description 'https://discord.gg/rpZtva8AwC'
version '1.0.0'

data_file 'VEHICLE_LAYOUTS_FILE' 'vehiclelayouts.meta'
data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'
data_file "AUDIO_SYNTHDATA" "audioconfig/ta122s58_amp.dat"
data_file "AUDIO_GAMEDATA" "audioconfig/ta122s58_game.dat"
data_file "AUDIO_SOUNDDATA" "audioconfig/ta122s58_sounds.dat"
data_file "AUDIO_WAVEPACK" "sfx/dlc_ta122s58"


files {
    "audioconfig/*.dat151.rel",
  "audioconfig/*.dat54.rel",
  "audioconfig/*.dat10.rel",
  "sfx/**/*.awc",
  'vehiclelayouts.meta',
  'handling.meta',
  'vehicles.meta',
  'carcols.meta',
  'carvariations.meta',
}

client_script 'vehicle_names.lua'
lua54 'yes'


