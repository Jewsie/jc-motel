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
    'client/target_main.lua',
    'client/main.lua',
    'client/functions.lua',
}

lua54 'yes'
