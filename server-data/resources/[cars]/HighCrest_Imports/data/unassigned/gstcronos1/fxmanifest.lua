fx_version 'cerulean'
games {'gta5'}

author 'HexR'
description 'Template'
version '3.0.0'

data_file 'VEHICLE_LAYOUTS_FILE' 'vehiclelayouts.meta'
data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'
data_file "AUDIO_SYNTHDATA" "audioconfig/lg62chironpursport_amp.dat"
data_file "AUDIO_GAMEDATA" "audioconfig/lg62chironpursport_game.dat"
data_file "AUDIO_SOUNDDATA" "audioconfig/lg62chironpursport_sounds.dat"
data_file "AUDIO_WAVEPACK" "sfx/dlc_lg62chironpursport"

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

lua54 'yes'