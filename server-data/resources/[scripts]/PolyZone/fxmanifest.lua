games {'gta5'}

fx_version 'cerulean'

description 'Define zones of different shapes and test whether a point is inside or outside of the zone'
version '2.6.2'

-- Highcrest: the zone creation tool (creation/) is left out. Its save events let any player
-- write files on the server, and live servers only need the zone code below.
client_scripts {
  'client.lua',
  'BoxZone.lua',
  'EntityZone.lua',
  'CircleZone.lua',
  'ComboZone.lua',
}

server_scripts {
  'server.lua'
}
