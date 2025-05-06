local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('motel:getMotelData', function(source, cb, name)
    cb(motels[name])
end)

QBCore.Functions.CreateCallback('motel:getMasterKey', function(source, cb)
    cb(masterKey)
end)

QBCore.Functions.CreateCallback('motel:doorState', function(source, cb, name, uniqueID)
    for _, room in pairs(roomData[name]) do
        if room.uniqueID == uniqueID then
            return cb(room.isLocked)
        end
    end
    Wait(100)
    cb(nil)
end)

QBCore.Functions.CreateCallback('motel:motelData', function(source, cb, name)
    local response = MySQL.query.await('SELECT * FROM `jc_ownedmotels` WHERE `name` = ? LIMIT 1', {name})
    if response and #response > 0 then
        for i = 1, #response do
            local row = response[i]
            local tableData = {
                owner = row.owner,
                name = row.name,
                funds = row.funds,
                data = json.decode(row.data)
            }
            return cb(tableData)
        end
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('motel:getRooms', function(source, cb, name)
    cb(roomData[name])
end)