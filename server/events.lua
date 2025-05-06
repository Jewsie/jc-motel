local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('motels:server:toggleDoorlock', function(name, uniqueID, state)
    for _, room in pairs(roomData[name]) do
        if room.uniqueID == uniqueID then
            room.isLocked = state
            break
        end
    end
    TriggerClientEvent('motels:client:toggleDoorlock', -1, name, uniqueID, state)
end)

RegisterNetEvent('motel:server:buyMotel', function(name, motelData, paymethode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT * FROM `jc_ownedmotels` WHERE `name` = ?', {name}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                MySQL.update.await('UPDATE jc_ownedmotels SET owner = ? WHERE name = ?', {citizenid, name})
                Player.Functions.RemoveMoney(paymethode, motelData.price)
                motels[name] = motelData
                motels[name].owner = citizenid
            end
        else
            MySQL.insert.await('INSERT INTO `jc_ownedmotels` (name, owner) VALUES (?, ?)', {name, citizenid})
            Player.Functions.RemoveMoney(paymethode, motelData.price)
            motels[name] = motelData
            motels[name].owner = citizenid
        end
    end)
end)

RegisterNetEvent('motel:server:rentRoom', function(motel, roomUniqueID, room, payInterval, paymethode, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    if MySQL.insert.await('INSERT INTO `jc_motels` (motel, room, uniqueid, renter, renterName, duration) VALUES (?, ?, ?, ?, ?, ?)', {
        motel, room, roomUniqueID, citizenid, name, payInterval
    }) then
        Player.Functions.RemoveMoney(paymethode, motels[motel].roomprices or price)
    end
    for _, room in pairs(roomData[motel]) do
        if room.uniqueID == roomUniqueID then
            room.renter = citizenid
            room.renterName = citizenid
            room.duration = payInterval
            if Config.StashProtection then
                if Config.StashProtection == 'password' then
                    room.password = ''
                end
            end
            break
        end
    end
end)

RegisterNetEvent('motel:server:changeStashPassword', function(name, uniqueID, password)
    MySQL.update('UPDATE jc_motels SET stashpassword = ? WHERE motel = ? AND uniqueid = ?', {password, name, uniqueID}, function(affectedRows)
        for _, room in pairs(roomData[name]) do
            if room.uniqueID == uniqueID then
                room.password = password
            end
        end
    end)
end)

RegisterNetEvent('motel:server:addToLedger', function(name, uniqueID, amount, paymethode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    MySQL.update('UPDATE jc_motels SET ledger = ledger + ? WHERE motel = ? AND uniqueid = ?', {amount, name, uniqueID}, function(affectedRows)
        Player.Functions.RemoveMoney(paymethode, amount)
        for _, room in pairs(roomData[name]) do
            if room.uniqueID == uniqueID then
                if not room.ledger then room.ledger = 0 end
                room.ledger = room.ledger + amount
                break
            end
        end
    end)
end)

RegisterNetEvent('motel:server:removeFromLedger', function(name, uniqueID, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    MySQL.update('UPDATE jc_motels SET ledger = ledger - ? WHERE motel = ? AND uniqueid = ?', {amount, name, uniqueID}, function(affectedRows)
        Player.Functions.AddMoney('cash', amount)
        for _, room in pairs(roomData[name]) do
            if room.uniqueID == uniqueID then
                room.ledger = room.ledger - amount
                break
            end
        end
    end)
end)

RegisterNetEvent('motel:server:endRent', function(name, uniqueID)
    local src = source
    MySQL.query('DELETE FROM `jc_motels` WHERE motel = ? AND uniqueid = ?', {name, uniqueID}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
            end
        end
    end)
    for _, room in pairs(roomData[name]) do
        if room.uniqueID == uniqueID then
            room.ledger = 0
            room.renter = ''
            room.renterName = ''
            QBCore.Functions.Notify(src, _L('endedrent'), 'error', 3000)
            break
        end
    end
end)

RegisterNetEvent('motel:server:giveKey', function(motel, roomData, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local info = {
        motel = motel,
        room = roomData.room,
        uniqueID = roomData.uniqueID,
    }
    
    if GetResourceState('qs-inventory') == 'started' then
        exports['qs-inventory']:AddItem(src, Config.Motelkey, 1, nil, info)
        TriggerClientEvent('qs-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Motelkey], 'add')
        if price then Player.Functions.RemoveMoney('cash', price) end
    elseif GetResourceState('qb-inventory') == 'started' then
        Player.Functions.AddItem(Config.Motelkey, 1, nil, info)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Motelkey], 'add')
        if price then Player.Functions.RemoveMoney('cash', price) end
    elseif GetResourceState('ox_inventory') == 'started' then
        exports['ox_inventory']:AddItem(src, Config.Motelkey, 1, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Motelkey], 'add')
        if price then Player.Functions.RemoveMoney('cash', price) end
    elseif GetResourceState('origen_inventory') == 'started' then
        Player.Functions.AddItem(Config.MotelKey, 1, info)
    end
end)

RegisterNetEvent('motel:server:removeAllKeys', function(motel, roomData)
    local src = source
    local Players = QBCore.Functions.GetQBPlayers()
    local info = {
        motel = motel,
        room = roomData.room,
        uniqueID = roomData.uniqueID,
    }

    for _, v in pairs(Players) do
        local Player = QBCore.Functions.GetPlayer(v.PlayerData.source)
        local items = v.PlayerData.items
        for _, item in pairs(items) do
            if item.name == Config.Motelkey then
                if item.info == info then
                    if GetResourceState('qs-inventory') == 'started' then
                        exports['qs-inventory']:AddItem(v.PlayerData.source, Config.Motelkey, 1, nil, info)
                        TriggerClientEvent('qs-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Motelkey], 'add')
                    elseif GetResourceState('qb-inventory') == 'started' then
                        Player.Functions.AddItem(Config.Motelkey, 1, nil, info)
                        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Motelkey], 'add')
                    elseif GetResourceState('ox_inventory') then
                        exports['ox_inventory']:AddItem(v.PlayerData.source, Config.Motelkey, 1, nil, info)
                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Motelkey], 'add')
                    elseif GetResourceState('origen_inventory') == 'started' then
                        Player.Functions.AddItem(Config.MotelKey, 1, info)
                    end
                end
            end
        end
    end

    MySQL.query('SELECT * FROM `inventory_stash`', {}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local stash = row.stash
                local items = json.decode(row.items)

                for k, item in pairs(items) do
                    if item.name == Config.Motelkey then
                        if item.info == info then
                            table.remove(items, k)
                        end
                    end
                end
                Wait(100)
                MySQL.update.await('UPDATE inventory_stash SET items = ? WHERE stash = ?', {json.encode(items), stash})
            end
        end
    end)
end)

RegisterNetEvent('motel:server:transactionMotelFunds', function(name, info)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = info[1]
    local transaction = info[2]
    local paymethode = info[3]

    if transaction == 'deposit' then
        MySQL.update.await('UPDATE jc_ownedmotels SET funds = funds + ? WHERE name = ?', {amount, name})
        Player.Functions.RemoveMoney(paymethode, amount)
    else
        MySQL.update.await('UPDATE jc_ownedmotels SET funds = funds - ? WHERE name = ?', {amount, name})
        Player.Functions.AddMoney(paymethode, amount)
    end
end)

RegisterNetEvent('motel:server:changeName', function(name, newName)
    MySQL.query('SELECT `data` FROM `jc_ownedmotels` WHERE `name` = ?', {name}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local data = json.decode(row.data)
                data.changedName = newName
                motels[name].label = newName
                MySQL.update.await('UPDATE jc_ownedmotels SET data = ? WHERE name = ?', {json.encode(data), name})
                TriggerClientEvent('motel:client:changeBlip', -1, name, newName)
            end
        end
    end)
end)

RegisterNetEvent('motel:server:changeRoomPrice', function(name, amount)
    MySQL.query('SELECT `data` FROM `jc_ownedmotels` WHERE `name` = ?', {name}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local data = json.decode(row.data)
                data.roomPrices = amount
                motels[name].roomPrices = amount
                MySQL.update.await('UPDATE jc_ownedmotels SET data = ? WHERE name = ?', {json.encode(data), name})
            end
        end
    end)
end)

RegisterNetEvent('motel:server:toggleAutoPay', function(name, amount)
    local src = source
    MySQL.query('SELECT `data` FROM `jc_ownedmotels` WHERE `name` = ?', {name}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local data = json.decode(row.data)
                data.toggleautopay = not Config.Motels[name].autoPayment
                motels[name].autoPayment = not Config.Motels[name].autoPayment
                QBCore.Functions.Notify(src, _L('toggleautopay'))
                MySQL.update.await('UPDATE jc_ownedmotels SET data = ? WHERE name = ?', {json.encode(data), name})
                TriggerClientEvent('motel:client:toggleAutoPay', -1, name)
            end
        end
    end)
end)

RegisterNetEvent('motel:server:sellMotel', function(name)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    MySQL.query('DELETE FROM `jc_ownedmotels` WHERE name = ?', {name}, function(response)
        if response then
            Player.Functions.AddMoney('cash', Config.Motels[name].price / 50)
            motels[name].owner = nil
        end
    end)
end)

RegisterNetEvent('motel:server:playerLoaded', function()
    local src = source
    MySQL.query('SELECT * FROM `jc_ownedmotels`', {}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local name = row.name
                local data = json.decode(row.data)
                if data.toggleautopay or data.toggleautopay == false then motels[name].autoPayment = data.toggleautopay end
                if data.roomPrices then motels[name].roomprices = data.roomPrices end
                if data.changedName then motels[name].label = data.changedName end
                TriggerClientEvent('motel:client:playerLoaded', src, name, motels[name])
                TriggerClientEvent('motel:client:createBlips', src)
            end
        else
            TriggerClientEvent('motel:client:createBlips', src)
        end
    end)
    Wait(250)
    motels = Config.Motels
end)

RegisterNetEvent('motel:server:removeItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if GetResourceState('qs-inventory') == 'started' then
        exports['qs-inventory']:RemoveItem(src, item, amount)
    elseif GetResourceState('qs-inventory') == 'started' then
        exports['qb-inventory']:RemoveItem(src, item, amount)
    elseif GetResourceState('qs-inventory') == 'started' then
        exports['ox_inventory']:RemoveItem(src, item, amount)
    elseif GetResourceState('origen_inventory') == 'started' then
        Player.Functions.RemoveItem(Config.MotelKey, 1, info)
    end
end)

RegisterNetEvent('motel:server:createMasterKey', function()
    masterKey = math.random(1000, 9999)
end)

RegisterNetEvent('motel:server:openStash', function(key, slots, weight, coords)
    
    if GetResourceState('qb-inventory') == 'started' then
        exports['qb-inventory']:OpenInventory(source, key, {
            maxweight = weight,
            slots = slots,
        })
    elseif GetResourceState('ox_inventory') == 'started' then
        exports['ox_inventory']:RegisterStash(key, 'Stash', slots, weight, nil, nil, coords)
        TriggerClientEvent('ox_inventory:openInventory', source, 'stash', key)
    end
end)

RegisterNetEvent('jc-motel:server:setDoorStateOx', function(doorId, state)
    exports['ox_doorlock']:setDoorState(doorId, state)
end)