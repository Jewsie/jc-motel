local QBCore = exports['qb-core']:GetCoreObject()
local doorInfo = {}

QBCore.Functions.CreateCallback('motels:rentedRooms', function(source, cb, motel)
    local tableData = {}
    MySQL.query('SELECT `motel`, `room`, `uniqueid`, `renter`, `renterName`, `duration` FROM `jc_motels` WHERE `motel` = ?', {tostring(motel)}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                tableData[#tableData + 1] = {
                    motel = row.motel,
                    room = row.room,
                    uniqueid = row.uniqueid,
                    renter = row.renter,
                    renterName = row.renterName,
                    duration = row.duration
                }
            end
            cb(tableData)
        else
            cb(false)
        end
    end)
end)

QBCore.Functions.CreateCallback('rentedRooms', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local tableData = {}

    MySQL.query('SELECT `motel`, `room`, `uniqueid`, `renter`, `duration` FROM `jc_motels` WHERE `renter` = ?', {Player.PlayerData.citizenid}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                if Config.RestrictRooms then
                    tableData = {
                        motel = row.motel,
                        room = row.room,
                        uniqueid = row.uniqueid,
                        renter = row.renter,
                        duration = row.duration
                    }
                else
                    tableData[#tableData + 1] = {
                        motel = row.motel,
                        room = row.room,
                        uniqueid = row.uniqueid,
                        renter = row.renter,
                        duration = row.duration
                    }
                end
            end
            cb(tableData)
        else
            cb(false)
        end
    end)
end)

QBCore.Functions.CreateCallback('motels:GetCops', function(_, cb)
    local amount = 0
	local players = QBCore.Functions.GetQBPlayers()
	for _, v in pairs(players) do
		if v.PlayerData.job.name == 'leo' and v.PlayerData.job.onduty then
			amount = amount + 1
		end
	end
	cb(amount)
end)

QBCore.Functions.CreateCallback('motels:getDoorDate', function(_, cb, uniqueID)
    if doorInfo[uniqueID] then
        cb(doorInfo[uniqueID])
    else
        if Config.Debug then
            print('No match found for ' .. uniqueID .. '!')
        end
        cb(false)
    end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.Rooms) do
        for _, keyData in pairs(v) do
            if not doorInfo[keyData.uniqueID] then
                doorInfo[keyData.uniqueID] = {uniqueID = keyData.uniqueID, isLocked = keyData.doorLocked}
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        MySQL.query('SELECT `motel`, `uniqueid`, `renter`, `duration` FROM `jc_motels`', {}, function(response)
            if response and #response > 0 then
                for i = 1, #response do
                    local row = response[i]
                    local duration = row.duration
                    local uniqueID = row.uniqueid
                    duration = duration - 1

                    if duration <= 0 then
                        for k, v in pairs(Config.Motels) do
                            if k == row.motel then
                                if not v.autoPayment then
                                    MySQL.query('DELETE FROM `jc_motels` WHERE `uniqueid`', {uniqueID}, function(response) end)
                                else
                                    local Player = QBCore.Functions.GetPlayerByCitizenId(row.renter)
                                    if Player then
                                        if Player.PlayerData.money['cash'] >= v.roomprices then
                                            Player.Functions.RemoveMoney('cash', v.roomprices)
                                            MySQL.update.await('UPDATE jc_motels SET duration = ? WHERE uniqueid = ?', {v.payInterval, uniqueID})
                                            if v.owner ~= '' then
                                                MySQL.query('SELECT `data`, `funds` FROM `jc_ownedmotels`', {citizenid}, function(response)
                                                    if response and #response > 0 then
                                                        for i = 1, #response do
                                                            local row = response[i]
                                                            local data = json.decode(row.data)
                                                            if data.name == v.label or data.newName and data.newName == v.label then
                                                                funds = funds + v.roomprices
                                                                if data.name == v.label then
                                                                    local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `funds` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.name") = ?', {funds, v.owner, v.label})
                                                                else
                                                                    local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `funds` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.newName") = ?', {funds, v.owner, v.label})
                                                                end
                                                                break
                                                            end
                                                        end
                                                    end
                                                end)
                                            end
                                        else
                                            QBCore.Functions.Notify(Player.PlayerData.source, 'Can\'t afford to pay for motel room, you have been kicked out!')
                                            MySQL.query('DELETE FROM `jc_motels` WHERE `uniqueid`', {uniqueID}, function(response) end)
                                            TriggerClientEvent('jc-motels:client:removeRenter', -1, uniqueID)
                                        end
                                    else
                                        MySQL.query('SELECT `money` FROM `players` WHERE `citizenid` = ?', {row.renter}, function(response)
                                            if response then
                                                for i = 1, #response do
                                                    local row = response[i]
                                                    local money = json.decode(row.money)
                                                    if money.cash >= v.roomprices then
                                                        money.cash = money.cash - v.roomprices
                                                        MySQL.update.await('UPDATE jc_motels SET duration = ? WHERE uniqueid = ?', {v.payInterval, uniqueID})
                                                        if v.owner ~= '' then
                                                            MySQL.query('SELECT `data`, `funds` FROM `jc_ownedmotels`', {citizenid}, function(response)
                                                                if response and #response > 0 then
                                                                    for i = 1, #response do
                                                                        local row = response[i]
                                                                        local data = json.decode(row.data)
                                                                        if data.name == v.label or data.newName and data.newName == v.label then
                                                                            funds = funds + v.roomprices
                                                                            if data.name == v.label then
                                                                                local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `funds` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.name") = ?', {funds, v.owner, v.label})
                                                                            else
                                                                                local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `funds` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.newName") = ?', {funds, v.owner, v.label})
                                                                            end
                                                                            break
                                                                        end
                                                                    end
                                                                end
                                                            end)
                                                        end
                                                    elseif money.cash < v.roomprices and money.bank >= v.roomprices then
                                                        money.bank = money.bank - v.roomprices
                                                        MySQL.update.await('UPDATE jc_motels SET duration = ? WHERE uniqueid = ?', {v.payInterval, uniqueID})
                                                        if v.owner ~= '' then
                                                            MySQL.query('SELECT `data`, `funds` FROM `jc_ownedmotels`', {citizenid}, function(response)
                                                                if response and #response > 0 then
                                                                    for i = 1, #response do
                                                                        local row = response[i]
                                                                        local data = json.decode(row.data)
                                                                        if data.name == v.label or data.newName and data.newName == v.label then
                                                                            funds = funds + v.roomprices
                                                                            if data.name == v.label then
                                                                                local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `funds` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.name") = ?', {funds, v.owner, v.label})
                                                                            else
                                                                                local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `funds` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.newName") = ?', {funds, v.owner, v.label})
                                                                            end
                                                                            break
                                                                        end
                                                                    end
                                                                end
                                                            end)
                                                        end
                                                    elseif money.cash < v.roomprices and money.bank < v.roomprices then
                                                        MySQL.query('DELETE FROM `jc_motels` WHERE `uniqueid`', {uniqueID}, function(response) end)
                                                        TriggerClientEvent('jc-motels:client:removeRenter', -1, uniqueID)
                                                    end
                                                end
                                            end
                                        end)
                                    end
                                end
                                break
                            end
                        end
                    end
                    MySQL.update.await('UPDATE jc_motels SET duration = ? WHERE uniqueid = ?', {duration, uniqueID})
                end
            end
        end)
        Wait(60 * 60000)
    end
end)

RegisterNetEvent('jc-motels:server:checkRentedMotels', function()
    local src = source
    MySQL.query('SELECT `motel`, `uniqueid`, `renter`, `renterName` FROM `jc_motels`', {}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                TriggerClientEvent('jc-motels:client:rentedRoom', src, row.motel, row.uniqueid, row.renter, row.renterName)
            end
        end
    end)
end)

RegisterNetEvent('jc-motels:server:checkOwnedMotels', function()
    local src = source
    MySQL.query('SELECT `owner`, `funds`, `data` FROM `jc_ownedmotels`', {}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local owner = row.owner
                local funds = row.funds
                local data = json.decode(row.data)
                TriggerClientEvent('jc-motels:client:addMotel', src, owner, funds, data)
            end
        end
    end)
    TriggerClientEvent('jc-motels:client:intiateMotels', src)
end)

RegisterNetEvent('jc-motels:server:rentRoom', function(motel, room, uniqueID, price, payInterval, payMethode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local fullName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    if Config.RestrictRooms then
        local response = MySQL.query.await('SELECT `motel` FROM `jc_motels` WHERE `renter` = ?', {citizenid})
        if response and #response > 0 then
            QBCore.Functions.Notify(src, 'You\'re already renting a room here!', 'error', 3000)
            return
        end
    end

    local insertQuery = MySQL.insert.await('INSERT INTO `jc_motels` (motel, room, uniqueid, renter, renterName, duration) VALUES (?, ?, ?, ?, ?, ?)', {motel, room, uniqueID, citizenid, fullName, payInterval})
    if insertQuery then
        local info = {
            room = room,
            uniqueID = uniqueID,
        }
        Player.Functions.RemoveMoney(payMethode, price)
        if Config.InventorySystem == 'qs' then
            exports['qs-inventory']:AddItem(src, Config.MotelKey, 1, info, info)
            TriggerClientEvent('qs-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MotelKey], 'add')
        elseif Config.InventorySystem == 'ox' then
            local QBX = exports['qbx_core']:GetPlayer(src)
            QBX.Functions.AddItem(Config.MotelKey, 1, false, info)
        else
            exports['qb-inventory']:AddItem(src, Config.MotelKey, 1, info, info)
        end

        if Config.QBVersion == 'oldqb' then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MotelKey], 'add')
        else
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MotelKey], 'add')
        end

        local response = MySQL.query.await('SELECT `owner`, `data` FROM `jc_ownedmotels`', {})
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local owner = row.owner
                local data = json.decode(row.data)

                if data.motelID == motel then
                    if owner and owner ~= '' then
                        MySQL.update.await('UPDATE jc_ownedmotels SET funds = funds + ? WHERE owner = ? AND JSON_EXTRACT(data, "$.motelID") = ?', {
                            price, owner, motel
                        })
                        break
                    end
                end
            end
        end

        QBCore.Functions.Notify(src, 'You successfully rented room ' .. room .. '!')
        TriggerClientEvent('jc-motels:client:rentedRoom', -1, motel, uniqueID, citizenid, fullName)
    end
end)

RegisterNetEvent('jc-motels:server:payRent', function(uniqueID, price, payInterval)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.RemoveMoney('cash', price)
    MySQL.update.await('UPDATE jc_motels SET duration = ? WHERE uniqueid = ?', {payInterval, uniqueID})
end)

RegisterNetEvent('jc-motels:server:endRent', function(uniqueID, room)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Players = QBCore.Functions.GetQBPlayers()
    local info = {
        room = room,
        uniqueID = uniqueID,
    }

    local items = Player.PlayerData.items
    local tableToRemove = nil
    if Config.Framework == 'qbx' then
        for k, item in pairs(items) do
            if item.name == Config.MotelKey then
                if item.metadata.uniqueID == uniqueID and item.metadata.room == room then
                    tableToRemove = k
                    break
                end
            end
        end
    else
        for k, item in pairs(items) do
            if item.name == Config.MotelKey then
                if item.info.uniqueID == uniqueID and item.info.room == room then
                    tableToRemove = k
                    break
                end
            end
        end
    end
    if tableToRemove then
        table.remove(items, tableToRemove)
    end

    if Config.InventorySystem == 'qb' then
        exports['qb-inventory']:SetInventory(src, items)
    elseif Config.InventorySystem == 'qs' then
        exports['qs-inventory']:RemoveItem(src, Config.MotelKey, 1, info, info)
    elseif Config.InventorySystem == 'ox' then
        QBX = exports['qbx_core']:GetPlayer(src)
        QBX.Functions.RemoveItem(Config.Motelkey, 1, info, info)
    end
    Wait(10)
    for _, v in pairs(Players) do
        local items = v.PlayerData.items
        local tableToRemove = nil
        for k, item in pairs(items) do
            if item.name == Config.MotelKey then
                if item.metadata.uniqueID == uniqueID and item.metadata.room == room then
                    tableToRemove = k
                    break
                end
            end
        end
        if tableToRemove then
            table.remove(items, tableToRemove)
        end

        if Config.InventorySystem == 'qs' then
            local target = QBCore.Functions.GetPlayer(v.PlayerData.source)
            exports['qs-inventory']:RemoveItem(target, Config.MotelKey, 1, info, info)
        elseif Config.InventorySystem == 'qb' then
            local target = QBCore.Functions.GetPlayer(v.PlayerData.source)
            exports['qb-inventory']:SetInventory(target, items)
        elseif Config.InventorySystem == 'ox' then
            local target = exports['qbx_core']:GetPlayer(src)
            target.Functions.RemoveItem(Config.MotelKey, 1, info, info)
        end
    end
    Wait(1000)
    local deleteQuery = MySQL.query.await('DELETE FROM `jc_motels` WHERE `uniqueid` = ?', {uniqueID})
    TriggerClientEvent('jc-motels:client:removeRenter', -1, uniqueID)
    if deleteQuery then
        if Config.WipeStash then
            if Config.InventorySystem == 'qb' then
                MySQL.query.await('DELETE FROM `inventories` WHERE `identifier` = ?', {'stash_' .. uniqueID})
            elseif Config.InventorySystem == 'qs' then
                MySQL.query.await('DELETE FROM `inventory_stash` WHERE `stash` = ?', {'Stash_' .. uniqueID})
            end
        end
        QBCore.Functions.Notify(src, 'You successfully ended your renting periode!')
    else
        QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
    end
end)

RegisterNetEvent('jc-motels:server:kickoutRenter', function(motel, renter, room)
    local src = source
    local deleteQuery = MySQL.update.await('DELETE FROM `jc_motels` WHERE `motel` = ? AND `renter` = ? AND `room` = ?', {motel, renter, room})
    if deleteQuery and deleteQuery > 0 then
        QBCore.Functions.Notify(src, 'Successfully kicked renter out!')
        TriggerClientEvent('jc-motels:client:removeRenter', -1, renter)
    else
        QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
    end
end)

RegisterNetEvent('jc-motels:server:changeMotelName', function(motel, newName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT `data` FROM `jc_ownedmotels` WHERE `owner` = ?', {citizenid}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local data = json.decode(row.data)
                if data.name == motel or data.newName == motel then
                    data.newName = newName
                    local updatedData = json.encode(data)
                    if data.name == motel then
                        local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `data` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.name") = ?', {updatedData, citizenid, motel})
                        if updateQuery then
                            QBCore.Functions.Notify(src, 'Changed motel name to ' .. newName)
                            TriggerClientEvent('jc-motels:client:changeMotelData', -1, motel, 'namechange', newName)
                        else
                            QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
                        end
                    else
                        local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `data` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.newName") = ?', {updatedData, citizenid, motel})
                        if updateQuery then
                            QBCore.Functions.Notify(src, 'Changed motel name to ' .. newName)
                            TriggerClientEvent('jc-motels:client:changeMotelData', -1, motel, 'namechange', newName)
                        else
                            QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
                        end
                    end
                    break
                end
            end
        end
    end)    
end)

RegisterNetEvent('jc-motels:server:changePrices', function(motel, newPrice)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT `data` FROM `jc_ownedmotels` WHERE `owner` = ?', {citizenid}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local data = json.decode(row.data)
                if data.name == motel or data.newName and data.newName == motel then
                    data.roomprices = newPrice
                    local updatedData = json.encode(data)
                    if data.name == motel then
                        local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `data` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.name") = ?', {updatedData, citizenid, motel})
                        if updateQuery then
                            QBCore.Functions.Notify(src, 'Changed room prices to $' .. newPrice)
                            TriggerClientEvent('jc-motels:client:changeMotelData', -1, motel, 'roomprices', newPrice)
                        else
                            QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
                        end
                    else
                        local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `data` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.newName") = ?', {updatedData, citizenid, motel})
                        if updateQuery then
                            QBCore.Functions.Notify(src, 'Changed room prices to $' .. newPrice)
                            TriggerClientEvent('jc-motels:client:changeMotelData', -1, motel, 'roomprices', newPrice)
                        else
                            QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
                        end
                    end
                    break
                end
            end
        end
    end)    
end)

RegisterNetEvent('jc-motels:server:changeAutopay', function(motel, value)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT `data` FROM `jc_ownedmotels` WHERE `owner` = ?', {citizenid}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local data = json.decode(row.data)
                if data.name == motel or data.newName and data.newName == motel then
                    data.autopay = value
                    local updatedData = json.encode(data)
                    if data.name == motel then
                        local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `data` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.name") = ?', {updatedData, citizenid, motel})
                        if updateQuery then
                            QBCore.Functions.Notify(src, 'Changed autopay option!')
                            TriggerClientEvent('jc-motels:client:changeMotelData', -1, motel, 'autopay', value)
                        else
                            QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
                        end
                    else
                        local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `data` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.newName") = ?', {updatedData, citizenid, motel})
                        if updateQuery then
                            QBCore.Functions.Notify(src, 'Changed autopay option!')
                            TriggerClientEvent('jc-motels:client:changeMotelData', -1, motel, 'autopay', value)
                        else
                            QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
                        end
                    end
                    break
                end
            end
        end
    end)    
end)

RegisterNetEvent('jc-motels:server:changeFunds', function(motel, value, selected)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT `data`, `funds` FROM `jc_ownedmotels` WHERE `owner` = ?', {citizenid}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local data = json.decode(row.data)
                local funds = row.funds
                if data.name == motel or data.newName and data.newName == motel then
                    if selected == 'withdraw' then
                        funds = funds - value
                    else
                        funds = funds + value
                    end
                    local updatedData = json.encode(data)
                    if data.name == motel then
                        local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `funds` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.name") = ?', {funds, citizenid, motel})
                        if updateQuery then
                            QBCore.Functions.Notify(src, 'Changed the funds!')
                            if selected == 'withdraw' then
                                Player.Functions.AddMoney('cash', value)
                            else
                                Player.Functions.RemoveMoney('cash', value)
                            end
                            TriggerClientEvent('jc-motels:client:changeMotelData', -1, motel, 'funds', funds)
                        else
                            QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
                        end
                    else
                        local updateQuery = MySQL.update.await('UPDATE `jc_ownedmotels` SET `funds` = ? WHERE `owner` = ? AND JSON_EXTRACT(`data`, "$.newName") = ?', {funds, citizenid, motel})
                        if updateQuery then
                            QBCore.Functions.Notify(src, 'Changed the funds!')
                            if selected == 'withdraw' then
                                Player.Functions.AddMoney('cash', value)
                            else
                                Player.Functions.RemoveMoney('cash', value)
                            end
                            TriggerClientEvent('jc-motels:client:changeMotelData', -1, motel, 'funds', funds)
                        else
                            QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
                        end
                    end
                    break
                end
            end
        end
    end)    
end)

RegisterNetEvent('jc-motels:server:buymotel', function(motel, data, paymethode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local money = Player.PlayerData.money[paymethode]

    if money >= data.price then
        local info = {
            motelID = motel,
            name = data.label,
            roomprices = data.roomprices,
            autopay = data.autoPayment
        }
        local inserQuery = MySQL.insert.await('INSERT INTO `jc_ownedmotels` (owner, funds, data) VALUES (?, ?, ?)', {citizenid, 0, json.encode(info)})
        Player.Functions.RemoveMoney(paymethode, data.price)
        TriggerClientEvent('jc-motels:client:buyMotel', -1, motel, citizenid)
        TriggerClientEvent('jc-motels:client:removeTargetZone', -1, motel, data)
        TriggerClientEvent('jc-motel:client:removezones', -1, motel, data)
    else
        QBCore.Functions.Notify(src, 'You don\'t have enough to buy this motel!', 'error', 3000)
    end
end)

RegisterNetEvent('motel:server:setDoorState', function(uniqueID)
    local hasFound = false
    for key, value in pairs(doorInfo) do
        if value.uniqueID == uniqueID then
            value.isLocked = not value.isLocked
            hasFound = true
            if Config.DoorlockSystem == 'ox' then
                exports['ox_doorlock']:setDoorState(uniqueId, value.isLocked)
            end
            break
        end
    end

    if not hasFound then
        if Config.Debug then
            print('Could not find the door with UniqueID ' .. uniqueID)
        end
    end
end)

RegisterNetEvent('motel:server:loseLockpick', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.InventorySystem == 'qs' then
        exports['qs-inventory']:RemoveItem(src, Config.Lockpick, 1)
    elseif Config.InventorySystem == 'ox' then
        local target = exports['qbx_core']:GetPlayer(src)
        target.Functions.RemoveItem(Config.Lockpick, 1)
    else
        exports['qb-inventory']:RemoveItem(src, Config.Lockpick, 1)
    end
end)

RegisterNetEvent('jc-motel:server:openInventory', function(keyId, weight, slots, inventory, coords)
    if inventory == 'qb' then
        exports['qb-inventory']:OpenInventory(source, 'stash_' .. keyId, {
            maxweight = weight,
            slots = slots,
        })
    elseif inventory == 'qs' then
        exports['qs-inventory']:RegisterStash(source, keyId, slots, weight)
    elseif inventory == 'ox' then
        exports['ox_inventory']:RegisterStash('stash_' .. keyId, 'Stash', slots, weight, nil, nil, coords)
        TriggerClientEvent('ox_inventory:openInventory', source, 'stash', 'stash_' .. keyId)
    end
end)

RegisterNetEvent('jc-motels:server:replaceKey', function(room, uniqueID, keyPrice, payMethode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Players = QBCore.Functions.GetQBPlayers()

    local info = {
        room = room,
        uniqueID = uniqueID,
    }
    
    Player.Functions.RemoveMoney(payMethode, keyPrice)
    for _, v in pairs(Players) do
        local items = v.PlayerData.items
        local itemToRemove = nil
        local itemMeta = nil
        local tableToRemove = nil
        if Config.Framework == 'qbx' then
            for k, item in pairs(items) do
                if item.name == Config.MotelKey then
                    if item.metadata.uniqueID == uniqueID and item.metadata.room == room then
                        tableToRemove = k
                        itemToRemove = item.name
                        itemMeta = item.metadata
                        item = nil
                        break
                    end
                end
            end
        else
            for k, item in pairs(items) do
                if item.name == Config.MotelKey then
                    if item.info.uniqueID == uniqueID and item.info.room == room then
                        tableToRemove = k
                        itemToRemove = item.name
                        itemMeta = item.info
                        item = nil
                        break
                    end
                end
            end
        end
        if Config.InventorySystem == 'qs' then
            exports['qs-inventory']:RemoveItem(v.PlayerData.source, itemToRemove, 1, itemMeta, itemMeta)
        elseif Config.InventorySystem == 'ox' then
            local target = exports['qbx_core']:GetPlayer(v.PlayerData.source)
            target.Functions.RemoveItem(Config.MotelKey, 1, itemMeta, itemMeta)
        elseif Config.InventorySystem == 'qb' then
            if tableToRemove then
                table.remove(items, tableToRemove)
            end
            local target = QBCore.Functions.GetPlayer(v.PlayerData.source)
            exports['qb-inventory']:SetInventory(target, items)
        end
    end
    exports['qs-inventory']:AddItem(src, Config.MotelKey, 1, info, info)
    TriggerClientEvent('qs-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MotelKey], 'add')
end)

RegisterNetEvent('jc-motels:server:sellMotel', function(motel, paymethode, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddMoney(paymethode, price)
    MySQL.query.await('DELETE FROM `jc_ownedmotels` WHERE JSON_EXTRACT(`data`, "$.motelID") = ?', {motel})
    TriggerClientEvent('jc-motels:client:removeOwner', -1, motel)
    Wait(100)
    TriggerClientEvent('jc-motels:client:removeTargetZone', -1, motel)
end)

RegisterNetEvent('jc-motels:server:setDoorStateOx', function(doorId, state)
    exports['ox_doorlock']:setDoorState(doorId, state)
end)
