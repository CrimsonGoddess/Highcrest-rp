resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'
 
files {
    'vehicles.meta',
    'carvariations.meta',
    'carcols.meta',
    'handling.meta',
    'data/**/weapon_pickup.meta',
    'data/**/weapons_mortar.meta',
    'data/**/weapons_arena.meta',
    'vehiclelayouts.meta',    -- Not Required
}

data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'vehiclelayouts.meta'   -- Not Required
data_file 'WEAPONINFO_FILE' 'data/**/weapon_pickup.meta'
data_file 'WEAPONINFO_FILE' 'data/**/weapons_mortar_pickup.meta'
data_file 'WEAPONINFO_FILE' 'data/**/weapons_arena_pickup.meta'