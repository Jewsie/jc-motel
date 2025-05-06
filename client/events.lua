local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('motel:client:createBlips', function()
    for name, motel in pairs(Config.Motels) do
        local coords = motel.coords
        blips[name] = AddBlipForCoord(coords)
        SetBlipSprite(blips[name], 78)
        SetBlipDisplay(blips[name], 4)
        SetBlipScale(blips[name], 0.6)
        SetBlipColour(blips[name], 0)
        SetBlipAsShortRange(blips[name], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(motel.label)
        EndTextCommandSetBlipName(blips[name])
    end
end)

RegisterNetEvent('motel:client:changeBlip', function(name, newName)
    local coords = GetBlipCoords(blips[name])
    RemoveBlip(blips[name])

    blips[name] = AddBlipForCoord(coords)
    SetBlipSprite(blips[name], 78)
    SetBlipDisplay(blips[name], 4)
    SetBlipScale(blips[name], 0.6)
    SetBlipColour(blips[name], 0)
    SetBlipAsShortRange(blips[name], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(newName)
    EndTextCommandSetBlipName(blips[name])
end)

RegisterNetEvent('motels:client:toggleDoorlock', function(name, uniqueID, state)
    for _, room in pairs(Config.Rooms[name]) do
        if room.uniqueID == uniqueID then
            room.isLocked = state
        end
    end
end)

RegisterNetEvent('motel:client:checkKeyZone', function(name, roomData)
    local pos = GetEntityCoords(PlayerPedId())
    for _, room in pairs(Config.Rooms[name]) do
        if room.uniqueID == roomData.uniqueID then
            local door = room.door
            if #(pos - door.pos) <= door.radius then
                TriggerEvent('motel:client:toggleDoorHander', name, room)
                break
            else
                QBCore.Functions.Notify(_L('toofar'), 'error', 3000)
            end
        end
    end
end)

RegisterNetEvent('motel:client:toggleAutoPay', function(name)
    for motelName, motel in pairs(Config.Motels) do
        if motelName == name then
            motel.autoPayment = not motel.autoPayment
        end
    end
end)

RegisterNetEvent('motel:client:playerLoaded', function(name, data)
    Config.Motels[name] = data
end)