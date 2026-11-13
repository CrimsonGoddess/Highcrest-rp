fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_phone'
description 'Highcrest RP phone'
version '1.0.0'

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'ox_inventory',
    'qbx_garages',
    'screencapture',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/services.lua',
    'client/housing.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/contacts.lua',
    'server/messages.lua',
    'server/calls.lua',
    'server/feed.lua',
    'server/market.lua',
    'server/dating.lua',
    'server/darkweb.lua',
    'server/location.lua',
    'server/services.lua',
    'server/garage.lua',
    'server/mail.lua',
    'server/housing.lua',
}

-- The phone UI is the React + Mantine app in web/ (source in web/src, built with `npm run build`).
-- The old hand-written phone is still in html/. To roll back, restore this file from commit 2f59532 (git checkout 2f59532 -- fxmanifest.lua).
ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/assets/*',
}
