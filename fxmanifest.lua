fx_version 'cerulean'
game 'gta5'

author 'Draxy'
description 'Járműbérlési rendszer'
version '1.0.0'

-- Követelmények
dependencies {
    'ox_target',
    'ox_lib',
    'es_extended' -- ESX szükséges a pénzkezeléshez
}

-- Script fájlok
client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'server.lua'
}

lua54 'yes'
