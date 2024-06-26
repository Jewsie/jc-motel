local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    TriggerServerEvent('jc-motels:server:checkRentedMotels')
    TriggerServerEvent('jc-motels:server:checkOwnedMotels')
end)

RegisterNetEvent('jc-motels:client:rentedRoom', function(motel, uniqueID, citizenid, fullName)
    for k, v in pairs(Config.Rooms[motel]) do
        if v.uniqueID == uniqueID then
            v.renter = citizenid
            v.renterName = fullName
            break
        end
    end
end)

RegisterNetEvent('jc-motels:client:removeRenter', function(uniqueID)
    for k, v in pairs(Config.Rooms) do
        for key, room in pairs(v) do
            if room.uniqueID == uniqueID then
                room.renter = nil
                room.renterName = ''
                break
            end
        end
    end
end)

RegisterNetEvent('jc-motels:client:buyMotel', function(motel, citizenid)
    for k, v in pairs(Config.Motels) do
        v.owner = citizenid
    end
end)

RegisterNetEvent('jc-motels:client:addMotel', function(owner, funds, data)
    for k, v in pairs(Config.Motels) do
        if v.label == data.name or v.label == data.newName then
            if data.newName then
                v.label = data.newName
            end
            v.owner = owner
            v.funds = funds
            v.roomprices = data.roomprices
            v.autoPayment = data.autopay
            break
        end
    end
end)

RegisterNetEvent('jc-motels:client:changeMotelData', function(motel, dataType, value)
    for k, v in pairs(Config.Motels) do
        if v.label == motel then
            if dataType == 'roomprices' then
                v.roomprices = value
            elseif dataType == 'autopay' then
                v.autoPayment = value
            elseif dataType == 'namechange' then
                v.label = value
            elseif dataType == 'funds' then
                v.funds = value
            end
            break
        end
    end
end)

RegisterNetEvent('motel:client:setDoorState', function(uniqueID)
    for key, value in pairs(Config.Rooms) do
        for _, v in pairs(value) do
            v.doorLocked = not v.doorLocked
        end
    end
end)

Citizen.CreateThread(function()
    Wait(500)
    for key, value in pairs(Config.Rooms) do
        for _, v in pairs(value) do
            QBCore.Functions.TriggerCallback('motels:getDoorDate', function(data)
                if data then
                    if data.uniqueID == v.uniqueID then
                        v.doorLocked = data.isLocked
                        Config.DoorlockAction(v.uniqueID, v.doorLocked)
                    end
                else
                    if Config.Debug then
                        print('No data received for uniqueID: ' .. v.uniqueID)
                    end
                end
            end, v.uniqueID)
            Wait(200)
        end
    end
end)