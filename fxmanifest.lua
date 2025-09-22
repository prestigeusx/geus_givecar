fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'geus_givecar'
author 'PRESTIGEUS'
description 'Registrar vehículos OWNED en ESX (self, por ID) + menú dinámico con ox_lib.'
version '1.3.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts { 'client.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server.lua' }
