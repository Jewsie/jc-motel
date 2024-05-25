local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('rentedRooms', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local tableData = {}

    MySQL.query('SELECT `motel`, `room`, `uniqueid`, `renter`, `duration` FROM `jc_motels` WHERE `renter` = ?', {Player.PlayerData.citizenid}, function(response)
        if response and # response > 0 then
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
end)

RegisterNetEvent('jc-motels:server:rentRoom', function(motel, room, uniqueID, price, payInterval)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local fullName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    local insertQuery = MySQL.insert.await('INSERT INTO `jc_motels` (motel, room, uniqueid, renter, renterName, duration) VALUES (?, ?, ?, ?, ?, ?)', {motel, room, uniqueID, citizenid, fullName, payInterval})
    if insertQuery then
        local info = {
            room = room,
            uniqueID = uniqueID,
        }
        Player.Functions.RemoveMoney('cash', price)
        Player.Functions.AddItem(Config.MotelKey, 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.MotelKey], 'add')
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

RegisterNetEvent('jc-motels:server:endRent', function(uniqueID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local deleteQuery = MySQL.query.await('DELETE FROM `jc_motels` WHERE `uniqueid` = ?', {uniqueID})
    TriggerClientEvent('jc-motels:client:removeRenter', -1, uniqueID)
    if deleteQuery then
        QBCore.Functions.Notify(src, 'You successfully ended your renting periode!')
    else
        QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
    end
end)

RegisterNetEvent('jc-motels:server:kickoutRenter', function(uniqueID)
    local deleteQuery = MySQL.query.await('DELETE FROM `jc_motels` WHERE `uniqueid` = ?', {uniqueID})
    if deleteQuery then
        QBCore.Functions.Notify(src, 'Successfully kicked renter out!')
        TriggerClientEvent('jc-motels:client:removeRenter', -1, uniqueID)
    else
        QBCore.Functions.Notify(src, 'Something went wrong!', 'error', 3000)
    end
end)

RegisterNetEvent('jc-motels:server:changeMotelName', function(motel, newName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    print('Line 235')

    MySQL.query('SELECT `data` FROM `jc_ownedmotels` WHERE `owner` = ?', {citizenid}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local data = json.decode(row.data)
                print('Line 242', data.name)
                if data.name == motel or data.newName == motel then
                    print('Line 244')
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

RegisterNetEvent('jc-motels:server:buymotel', function(motel, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local money = Player.PlayerData.money['cash']

    if money >= data.price then
        local info = {
            name = data.label,
            roomprices = data.roomprices,
            autopay = data.autoPayment
        }
        local inserQuery = MySQL.insert.await('INSERT INTO `jc_ownedmotels` (owner, funds, data) VALUES (?, ?, ?)', {citizenid, 0, json.encode(info)})
        Player.Functions.RemoveMoney('cash', data.price)
        TriggerClientEvent('jc-motels:client:buyMotel', -1, motel, citizenid)
    else
        QBCore.Functions.Notify(src, 'You don\'t have enough to buy this motel!', 'error', 3000)
    end
end)