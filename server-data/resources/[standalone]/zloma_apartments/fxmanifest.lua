fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'zloma_apartments'
author 'Zloma'
description 'Apartments for ESX, QBCore and QBox: rent, buy, roommate, personal safe, native door locks, in-game building creator and furniture editor'
version '0.2.1-beta.1'
license 'GPL-3.0-or-later'

dependencies {
    'oxmysql',
    'ox_lib',
    'zloma_core',
    'sleepless_interact',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'config_minigame.lua',
    'locales/*.lua',
    'shared/locale.lua',
    'shared/version.lua',
    'shared/security.lua',
    'shared/alarm_panel.lua',
    'shared/alarm_panel_model.lua',
    'shared/alarm_device.lua',
    'shared/safe_model.lua',
    'shared/safe_motion.lua',
    'shared/alarm_cable.lua',
    'shared/doorpick/math.lua',
    'shared/doorpick/rig.lua',
    'shared/hotels.lua',
    'shared/transform.lua',
    'presets/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/version.lua',
    'server/customization.lua',
    'server/bridge.lua',
    'server/db.lua',
    'server/state.lua',
    'server/guard.lua',
    'server/doors.lua',
    'server/booking.lua',
    'server/roommates.lua',
    'server/payments.lua',
    'server/safe.lua',
    'server/safe_lifecycle.lua',
    'server/security.lua',
    'server/doorpick.lua',
    'server/furniture.lua',
    'server/admin.lua',
    'server/main.lua',
}

client_scripts {
    'client/bridge.lua',
    'client/prop_stream.lua',
    'client/doors.lua',
    'client/main.lua',
    'client/safe_scene.lua',
    'client/safecrack.lua',
    'client/safe.lua',
    'client/minigame_lock.lua',
    'client/doorpick/scene.lua',
    'client/doorpick/ui.lua',
    'client/doorpick/door.lua',
    'client/doorpick/game.lua',
    'client/doorpick/main.lua',
    'client/lockpick.lua',
    'client/alarm_panel.lua',
    'client/alarm_connect.lua',
    'client/furniture.lua',
    'client/admin.lua',
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/**',
    'stream/doorpick/*.ytyp',
    'stream/alarm/*.ytyp',
    'stream/safe/*.ytyp',
}

data_file 'DLC_ITYP_REQUEST' 'stream/doorpick/tr_lockpick.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/alarm/zloma_alarm.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/safe/zloma_safe.ytyp'

