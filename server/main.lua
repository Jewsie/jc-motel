local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    roomData = Config.Rooms
    motels = Config.Motels
    MySQL.query('SELECT * FROM `jc_ownedmotels`', {}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local name = row.name
                local owner = row.owner
                if motels[name] then motels[name].owner = owner end
            end
        end
    end)

    MySQL.query('SELECT * FROM `jc_motels`', {}, function(response)
        if response and #response > 0 then
            for i = 1, #response do
                local row = response[i]
                local name = row.motel
                local uniqueid = row.uniqueid
                
                for _, room in pairs(roomData[name]) do
                    if GetResourceState('qb-doorlock') == 'started' then
                        if room.uniqueID == uniqueid then
                            if Config.StashProtection and Config.StashProtection == 'password' then
                                room.password = row.stashpassword
                            end
                            room.ledger = row.ledger
                            room.renter = row.renter
                            room.renterName = row.renterName
                            room.duration = row.duration
                        end
                    elseif GetResourceState('ox_doorlock') then
                        if tonumber(room.uniqueID) == tonumber(uniqueid) then
                            if Config.StashProtection and Config.StashProtection == 'password' then
                                room.password = row.stashpassword
                            end
                            room.ledger = row.ledger
                            room.renter = row.renter
                            room.renterName = row.renterName
                            room.duration = row.duration
                        end
                    end
                end
            end
        end
    end)

    if GetResourceState('origen_inventory') == 'started' then
        for name, roomData in pairs(Config.Rooms) do
            for _, room in pairs(roomData) do
                local stash = room.stash
                exports['origen_inventory']:registerStash(name .. '_' .. room.uniqueID, {
                    label = room.label,
                    slots = stash.slots,
                    weight = stash.weight,
                })
            end
        end
    end
end)

CreateThread(function()
    while true do
        MySQL.query('SELECT * FROM `jc_motels`', {}, function(response)
            if response and #response > 0 then
                for i = 1, #response do
                    local row = response[i]
                    local duration = row.duration
                    local ledger = row.ledger
                    local motel = row.motel
                    local uniqueid = row.uniqueid
                    
                    if duration > 0 then 
                        duration = duration - 1
                        if duration <= 0 then
                            if Config.Motels[motel].autoPayment then
                                if ledger >= Config.Motels[motel].roomprices then
                                    MySQL.update.await('UPDATE jc_motels SET ledger = ledger - ?, duration = ? WHERE `motel` = ? AND uniqueid = ?', {Config.Motels[motel].roomprices, Config.Motels[motel].payInterval, motel, uniqueid})
                                    motels[motel].duration = Config.Motels[motel].payInterval
                                end
                            else
                                MySQL.query('DELETE FROM `jc_motels` WHERE `motel` = ? AND uniqueid = ?', {motel, uniqueid}, function() end)
                                motels[motel].owner = nil
                                motels[motel].duration = 0
                            end
                        else
                            MySQL.update.await('UPDATE jc_motels SET duration = duration - ? WHERE `motel` = ? AND uniqueid = ?', {1, motel, uniqueid})
                        end
                    end
                end
            end
        end)
        Wait(60 * 60000)
    end
end)
