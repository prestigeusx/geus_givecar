--[[
    geus_givecar (cliente) - FIXED sin ACE en comandos
    Autor / Créditos: PRESTIGEUS
       Comandos:
      - /owncar [PLACA]
      - /owncarid <ID> [PLACA]
      - /ownmenu   (menú dinámico con ox_lib)
    Requisitos: ESX Legacy + ox_lib
]]--

local ESX = exports['es_extended']:getSharedObject()

local function waitForESX()
    local timeout = GetGameTimer() + 10000 -- 10s
    while (not ESX) and GetGameTimer() < timeout do
        ESX = exports['es_extended']:getSharedObject()
        Wait(100)
    end
    while (not ESX or not ESX.Game or not ESX.Game.GetVehicleProperties) and GetGameTimer() < timeout do
        Wait(100)
    end
    return ESX ~= nil and ESX.Game ~= nil and ESX.Game.GetVehicleProperties ~= nil
end

local function notify(msg, type)
    type = type or 'inform'
    if lib and lib.notify then
        lib.notify({ title = 'geus_givecar', description = msg, type = type })
    elseif ESX and ESX.ShowNotification then
        ESX.ShowNotification(msg)
    else
        print(('[geus_givecar] %s'):format(msg))
    end
end

local function getVehAndProps(changePlate)
    if not waitForESX() then
        notify('~r~ESX no está listo aún. Reintenta en unos segundos.', 'error')
        return nil, nil
    end

    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        notify('~r~Súbete a un vehículo primero.', 'error')
        return nil, nil
    end
    local veh = GetVehiclePedIsIn(ped, false)

    if changePlate then
        if lib and lib.inputDialog then
            local input = lib.inputDialog('Cambiar placa', {
                { type = 'input', label = 'Nueva placa (1-8 chars)', placeholder = 'GZR123', required = true, min = 1, max = 8 }
            })
            if not input then return nil, nil end
            local plate = (input[1] or ''):upper():gsub('%s+', '')
            if #plate < 1 or #plate > 8 then
                notify('~r~Placa inválida.', 'error')
                return nil, nil
            end
            SetVehicleNumberPlateText(veh, plate)
            Wait(150)
        else
            notify('~y~ox_lib no está cargado: el cambio de placa interactivo no está disponible.', 'inform')
        end
    end

    local props = ESX.Game.GetVehicleProperties(veh)
    if not props or not props.plate then
        local plate = (GetVehicleNumberPlateText(veh) or ''):upper():gsub('%s+', '')
        if plate == '' then
            notify('~r~No pude leer la información del vehículo.', 'error')
            return nil, nil
        end
        props = { plate = plate }
    end
    return veh, props
end

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    print('^6[geus_givecar]^7 Cliente cargado — ^3PRESTIGEUS^7 (no-ACE client)')
    pcall(function()
        TriggerEvent('chat:addSuggestion', '/owncar', 'Asigna a ti el vehículo actual (opcional, define placa)', {
            { name = 'placa', help = 'Ej.: GZR123 (opcional)' }
        })
        TriggerEvent('chat:addSuggestion', '/owncarid', 'Asigna a otro jugador por ID (opcional, define placa)', {
            { name = 'id', help = 'ID de servidor del jugador' },
            { name = 'placa', help = 'Ej.: GZR123 (opcional)' }
        })
        TriggerEvent('chat:addSuggestion', '/ownmenu', 'Abrir menú administrativo de vehículos')
    end)
end)

-- /owncar [PLACA]  (sin ACE en cliente; el servidor valida admin)
RegisterCommand('owncar', function(_, args)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        notify('~r~Súbete a un vehículo primero.', 'error'); return
    end
    local veh = GetVehiclePedIsIn(ped, false)

    local plateArg = args[1]
    if plateArg and #plateArg > 0 then
        SetVehicleNumberPlateText(veh, plateArg)
        Wait(150)
    end

    local propsReady = waitForESX()
    if not propsReady then
        notify('~r~ESX no está listo aún.', 'error'); return
    end
    local props = ESX.Game.GetVehicleProperties(veh) or {}
    if not props.plate or props.plate == '' then
        props.plate = (GetVehicleNumberPlateText(veh) or ''):upper():gsub('%s+', '')
    end
    if not props.plate or props.plate == '' then
        notify('~r~No pude leer la información del vehículo.', 'error'); return
    end

    TriggerServerEvent('geus_givecar:registerOwnedSelf', props)
end, false)

-- /owncarid <ID> [PLACA]  (sin ACE en cliente; el servidor valida admin)
RegisterCommand('owncarid', function(_, args)
    local targetId = tonumber(args[1] or '')
    if not targetId then
        notify('~r~Uso: /owncarid <ID> [PLACA]', 'error'); return
    end

    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        notify('~r~Súbete a un vehículo primero.', 'error'); return
    end
    local veh = GetVehiclePedIsIn(ped, false)

    local plateArg = args[2]
    if plateArg and #plateArg > 0 then
        SetVehicleNumberPlateText(veh, plateArg)
        Wait(150)
    end

    if not waitForESX() then
        notify('~r~ESX no está listo aún.', 'error'); return
    end
    local props = ESX.Game.GetVehicleProperties(veh) or {}
    if not props.plate or props.plate == '' then
        props.plate = (GetVehicleNumberPlateText(veh) or ''):upper():gsub('%s+', '')
    end
    if not props.plate or props.plate == '' then
        notify('~r~No pude leer la información del vehículo.', 'error'); return
    end

    TriggerServerEvent('geus_givecar:registerOwnedForId', targetId, props)
end, false)

-- /ownmenu  (sin ACE en cliente; el servidor valida admin cuando se ejecuta la acción)
RegisterCommand('ownmenu', function()
    if not lib or not lib.registerContext then
        notify('~r~ox_lib no está cargado o está desactualizado. Revisa el fxmanifest y el ensure.', 'error')
        return
    end

    local options = {
        {
            title = 'Asignarme este vehículo',
            description = 'Registra este vehículo como tuyo.',
            icon = 'car',
            arrow = false,
            onSelect = function()
                local _, props = getVehAndProps(false)
                if not props then return end
                TriggerServerEvent('geus_givecar:registerOwnedSelf', props)
            end
        },
        {
            title = 'Asignar a jugador por ID',
            description = 'Pasa este vehículo a un jugador por ID de servidor.',
            icon = 'user',
            onSelect = function()
                local input = lib.inputDialog('Asignar a jugador', {
                    { type = 'number', label = 'ID de servidor', placeholder = '1', required = true, min = 1 },
                    { type = 'input', label = 'Placa (opcional)', placeholder = 'GZR123', required = false, min = 1, max = 8 }
                })
                if not input then return end
                local id = tonumber(input[1]); if not id or id <= 0 then notify('~r~ID inválido.', 'error'); return end

                local changePlate = (input[2] and #input[2] > 0)
                local veh, props = getVehAndProps(changePlate)
                if not props then return end
                if changePlate then
                    props.plate = input[2]:upper():gsub('%s+', '')
                end
                TriggerServerEvent('geus_givecar:registerOwnedForId', id, props)
            end
        },
        {
            title = 'Cambiar placa local',
            description = 'Cambia la placa del vehículo actual (no guarda propiedad).',
            icon = 'hashtag',
            onSelect = function()
                local veh, props = getVehAndProps(true)
                if not props then return end
                notify(('Placa establecida: ~y~%s~s~'):format(props.plate), 'success')
            end
        }
    }

    lib.registerContext({
        id = 'geus_givecar_menu',
        title = 'Menú de Vehículos (Admin)',
        options = options
    })
    lib.showContext('geus_givecar_menu')
end, false)
