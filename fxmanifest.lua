fx_version 'cerulean'
game 'gta5'

author 'jackp'
description ''
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locale/en.lua',
    'locale/*.lua',
    'locale/locales.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/global_variables.lua',
    'server/functions.lua',
    'server/callbacks.lua',
    'server/events.lua',
    'server/main.lua',
}

client_scripts {
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
    'client/main.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/compat/qb/target.lua',
    'client/compat/qbx/target.lua',
    'client/compat/polyzone.lua',
}

lua54 'yes'