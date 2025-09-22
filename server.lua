--[[
    geus_givecar (servidor)
    Autor / Créditos: PRESTIGEUS
    Lógica de /owncar, /owncarid y llamadas desde el menú.
    Seguridad: Solo admin (ACE 'geus.givecar' o 'group.admin') + comandos restringidos.
]]

local ESX = exports['es_extended']:getSharedObject()

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    print('^6[geus_givecar]^7 Iniciado — ^3PRESTIGEUS^7')
    print('^6[geus_givecar]^7 Comandos: ^2/owncar [PLA]^7, ^2/owncarid <ID> [PLA]^7, ^2/ownmenu^7 (Admin only)')
end)

local function isAdmin(src)
    return IsPlayerAceAllowed(src, 'geus.givecar') or IsPlayerAceAllowed(src, 'group.admin')
end

-- Self ownership
RegisterNetEvent('geus_givecar:registerOwnedSelf', function(props)
    local src = source
    if not isAdmin(src) then
        print(('[geus_givecar] %d intentó usar /owncar sin permisos'):format(src))
        return
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local plate = props and props.plate or nil
    if not plate then
        TriggerClientEvent('esx:showNotification', src, '~r~Placa inválida.'); return
    end

    local identifier = xPlayer.getIdentifier()
    local vehicleJson = json.encode(props)

    MySQL.insert(
        'INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?) ' ..
        'ON DUPLICATE KEY UPDATE owner = VALUES(owner), vehicle = VALUES(vehicle), type = VALUES(type), stored = VALUES(stored)',
        { identifier, plate, vehicleJson, 'car', 1 },
        function(_)
            TriggerClientEvent('esx:showNotification', src, ('~g~Ahora eres dueño del vehículo ~w~[%s]'):format(plate))
            print(('[geus_givecar] SELF: %s -> %s'):format(identifier, plate))
        end
    )
end)

-- Assign to target by server ID
RegisterNetEvent('geus_givecar:registerOwnedForId', function(targetId, props)
    local src = source
    if not isAdmin(src) then
        print(('[geus_givecar] %d intentó usar /owncarid sin permisos'):format(src))
        return
    end

    targetId = tonumber(targetId or 0) or 0
    if targetId <= 0 then
        TriggerClientEvent('esx:showNotification', src, '~r~ID inválido.'); return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        TriggerClientEvent('esx:showNotification', src, '~r~Jugador no conectado.'); return
    end

    local plate = props and props.plate or nil
    if not plate then
        TriggerClientEvent('esx:showNotification', src, '~r~Placa inválida.'); return
    end

    local identifier = xTarget.getIdentifier()
    local vehicleJson = json.encode(props)

    MySQL.insert(
        'INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?) ' ..
        'ON DUPLICATE KEY UPDATE owner = VALUES(owner), vehicle = VALUES(vehicle), type = VALUES(type), stored = VALUES(stored)',
        { identifier, plate, vehicleJson, 'car', 1 },
        function(_)
            TriggerClientEvent('esx:showNotification', src, ('~g~Asignado a ID %d el vehículo ~w~[%s]'):format(targetId, plate))
            TriggerClientEvent('esx:showNotification', targetId, ('~g~Te asignaron un vehículo ~w~[%s]'):format(plate))
            print(('[geus_givecar] GIVE: %s -> %s (ID %d)'):format(plate, identifier, targetId))
        end
    )
end)
