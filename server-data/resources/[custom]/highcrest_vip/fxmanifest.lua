fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_vip'
description 'Highcrest VIP tiers: account-wide tier and expiry, perks (early access, VIP Collection, custom plates, free valet and transfers), admin and Tebex commands'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}
