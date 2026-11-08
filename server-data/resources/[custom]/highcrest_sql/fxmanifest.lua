fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'highcrest_sql'
description 'Runs the database setup files for installed scripts, each one only once'
version '1.0.0'

dependency 'oxmysql'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}
