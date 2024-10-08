fx_version 'cerulean'
game 'gta5'

author 'jackp'
description ''
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/target_main.lua',
    'server/functions.lua',
}

client_scripts {
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
    'client/functions.lua',
    'client/target_main.lua',
    'client/target_ox.lua',
    'client/main.lua',
    'client/ox_polyzone.lua',
}

lua54 'yes'
