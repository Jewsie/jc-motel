local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    local isLoggedIn = false
    while not isLoggedIn do
        Wait(1)
        if LocalPlayer.state.isLoggedIn then
            isLoggedIn = true
        end
    end
    Wait(500)

    for k, v in pairs(Config.Motels) do
        local PlayerData = QBCore.Functions.GetPlayerData()
        local globalData = {}

        globalData[#globalData + 1] = {
            title = 'Manage Motel',
            description = 'Manage the motel if you own it!',
            onSelect = function()
                local PlayerData = QBCore.Functions.GetPlayerData()
                if PlayerData.citizenid == v.owner then
                    lib.registerContext({
                        id = 'manage_motel',
                        title = v.label,
                        options = {
                            {
                                title = 'Manage Rooms',
                                description = 'Manage your rented rooms!',
                                onSelect = function()
                                    local roomData = {}
                                    for key, r in pairs(Config.Rooms[k]) do
                                        if r.renter then
                                            roomData[#roomData + 1] = {
                                                title = r.room,
                                                descrption = 'Click to kick out renter!\n' .. 'Renter: ' .. r.renterName,
                                                onSelect = function()
                                                    TriggerServerEvent('jc-motels:server:kickoutRenter', r.uniqueID)
                                                end
                                            }
                                        end
                                    end
                                    lib.registerContext({
                                        id = 'manage_renters',
                                        title = 'Manage Renters',
                                        options = roomData
                                    })
                                    lib.showContext('manage_renters')
                                end
                            },
                            {
                                title = 'Funds $' .. v.funds,
                                description = 'Deposit or withdraw funds!',
                                onSelect = function()
                                    local PlayerData = QBCore.Functions.GetPlayerData()
                                    local money = PlayerData.money['cash']
                                    local info = lib.inputDialog('Manage Funds', {
                                        {
                                            type = 'number',
                                            label = 'Amount',
                                            description = 'The amount to deposit or withdraw!',
                                            required = true,
                                            min = 0,
                                            default = 0,
                                        },
                                        {
                                            type = 'select',
                                            label = 'Option',
                                            description = 'Select to deposit or withdraw!',
                                            options = {
                                                {value = 'deposit', label = 'Deposit'},
                                                {value = 'withdraw', label = 'Withdraw'},
                                            }
                                        }
                                    })
                                    if info[2] == 'deposit' and money <= tonumber(info[1]) then
                                        QBCore.Functions.Notify('You don\'t have this much money to deposit!', 'error', 3000)
                                        return
                                    end
                                    if info[2] == 'withdraw' and v.funds < tonumber(info[1]) then
                                        QBCore.Functions.Notify('The motel does not have this amount of money in funds!', 'error', 3000)
                                        return
                                    end
                                    if tonumber(info[1]) <= 0 then
                                        QBCore.Functions.Notify('Can\'t deposit or withdraw a zero or minus value!', 'error', 3000)
                                        return
                                    end 
                                    TriggerServerEvent('jc-motels:server:changeFunds', v.label, info[1], info[2])
                                end
                            },
                            {
                                title = 'Change name',
                                description = 'Change the name of your motel!\n Current name: ' .. v.label,
                                onSelect = function()
                                    local info = lib.inputDialog('Motel name change', {
                                        {
                                            type = 'input',
                                            label = 'Name',
                                            description = 'Change the name of your motel',
                                            placeholder = v.label,
                                            required = true,
                                        }
                                    })
                                    TriggerServerEvent('jc-motels:server:changeMotelName', v.label, info[1])
                                end
                            },
                            {
                                title = 'Change Prices',
                                description = 'Change room prices!',
                                onSelect = function()
                                    local info = lib.inputDialog('Motel name change', {
                                        {
                                            type = 'number',
                                            label = 'New Price',
                                            description = 'Change the price of your motel rooms!',
                                            default = v.roomprices,
                                            min = 0,
                                            required = true,
                                        }
                                    })
                                    TriggerServerEvent('jc-motels:server:changePrices', v.label, info[1])
                                end
                            },
                            {
                                title = 'Automatic Payment',
                                description = 'Enable or disable automatic payment for your\n Autopay: ' .. tostring(v.autoPayment),
                                onSelect = function()
                                    local info = lib.inputDialog('Toggle Autopay', {
                                        {
                                            type = 'select',
                                            label = 'Toggle Autopay',
                                            options = {
                                                {value = 'true', label = 'Allow'},
                                                {value = 'false', label = 'Disallow'},
                                            },
                                            required = true,
                                        }
                                    })
                                    TriggerServerEvent('jc-motels:server:changeAutopay', v.label, info[1])
                                end
                            }
                        }
                    })
                    lib.showContext('manage_motel')
                end
            end
        }

        globalData[#globalData + 1] = {
            title = 'Rent Motel Room',
            description = 'Rent a motel room!',
            onSelect = function()
                local tableData = {}
                for key, h in pairs(Config.Rooms[k]) do
                    if not h.renter then
                        tableData[#tableData + 1] = {
                            title = h.room,
                            description = 'Rent room for $' .. v.roomprices,
                            onSelect = function()
                                local PlayerData = QBCore.Functions.GetPlayerData()
                                local money = PlayerData.money['cash']

                                if money >= v.roomprices then
                                    TriggerServerEvent('jc-motels:server:rentRoom', k, h.room, h.uniqueID, v.roomprices, v.payInterval)
                                else
                                    QBCore.Functions.Notify('You can\'t afford this room!', 'error', 3000)
                                end
                            end
                        }
                    end
                end

                lib.registerContext({
                    id = 'rent_room',
                    title = 'Rent Motel Room',
                    options = tableData
                })
                lib.showContext('rent_room')
            end
        }

        globalData[#globalData + 1] = {
            title = 'Rented Rooms',
            description = 'Check motel rooms you have rented!',
            onSelect = function()
                local tableData = {}
                local PlayerData = QBCore.Functions.GetPlayerData()
                QBCore.Functions.TriggerCallback('rentedRooms', function(data)
                    if data then
                        if Config.RestrictRooms then
                            lib.registerContext({
                                id = 'rented_rooms',
                                title = 'Manage your rented Room(s)',
                                options = {
                                    {
                                        title = data.room,
                                        description = 'Manage your motel room!\n Payment due ' .. string.format("%d days", math.floor(data.duration / 24)),
                                        onSelect = function()
                                            lib.registerContext({
                                                id = data.uniqueid,
                                                title = data.room,
                                                options = {
                                                    {
                                                        title = 'Extend Renting Periode',
                                                        description = 'Pay $' .. v.roomprices,
                                                        onSelect = function()
                                                            if data.duration <= 24 then
                                                                lib.registerContext({
                                                                    id = 'pay_rent',
                                                                    title = 'Pay Rent for ' .. data.room,
                                                                    options = {
                                                                        {
                                                                            title = 'Confirm',
                                                                            description = 'Confirm payment on room',
                                                                            onSelect = function()
                                                                                local PlayerData = QBCore.Functions.GetPlayerData()
                                                                                local money = PlayerData.money['cash']

                                                                                if money >= v.roomprices then
                                                                                    TriggerServerEvent('jc-motels:server:payRent', data.uniqueid, v.roomprices, v.payInterval)
                                                                                else
                                                                                    QBCore.Functions.Notify('You can\'t afford to extend your rent!', 'error', 3000)
                                                                                end
                                                                            end
                                                                        },
                                                                        {
                                                                            title = 'Cancel',
                                                                            description = 'Cancel payment of motel room',
                                                                            onSelect = function() end
                                                                        }
                                                                    }
                                                                })
                                                                lib.showContext('pay_rent')
                                                            else
                                                                QBCore.Functions.Notify('You can only pay when there\'s is 1 day or less left!', 'error', 3000)
                                                            end
                                                        end
                                                    },
                                                    {
                                                        title = 'End Rent',
                                                        description = 'End your renting periode with the motel immediately!',
                                                        onSelect = function()
                                                            TriggerServerEvent('jc-motels:server:endRent', data.uniqueid)
                                                        end
                                                    },
                                                    {
                                                        title = 'Lost Key',
                                                        description = 'If you have lost a key, you can get a new!',
                                                        onSelect = function()
                                                            local PlayerData = QBCore.Functions.GetPlayerData()
                                                            local money = PlayerData.money['cash']

                                                            if money >= v.keyPrice then
                                                                TriggerServerEvent('jc-motels:server:replaceKey', data.uniqueid)
                                                            else
                                                                QBCore.Functions.Notify('You can\'t afford to replace your key!', 'error', 3000)
                                                            end
                                                        end
                                                    }
                                                }
                                            })
                                            lib.showContext(data.uniqueid)
                                        end
                                    }
                                }
                            })
                            lib.showContext('rented_rooms')
                        end
                    end
                end)
            end
        }

        if v.owner == '' and v.price or v.owner == '' and v.price >= 0 then
            globalData[#globalData + 1] = {
                title = 'Buy Motel',
                description = 'Buy motel for $' .. v.price,
                onSelect = function()
                    if v.owner == '' then
                        TriggerServerEvent('jc-motels:server:buymotel', k, v)
                    else
                        QBCore.Functions.Notify('Motel is already owned by somebody!', 'error', 3000)
                    end
                end
            }
        end
        
        exports['qb-target']:AddCircleZone('motel_' .. k, v.coords, 1.5, {
            name = 'motel_' .. k,
            useZ = true,
            debugPoly = false,
        }, {
            options = {
                {
                    label = 'Open Reception',
                    icon = 'fas fa-desk',
                    action = function()
                        lib.registerContext({
                            id = 'open_motel',
                            title = 'Open Motel Reception',
                            options = globalData
                        })
                        lib.showContext('open_motel')
                    end
                }
            }
        })
    end

    for k, v in pairs(Config.Rooms) do
        for _, keydata in pairs(v) do
            local tableData = {}
        
            tableData[#tableData + 1] = {
                label = 'Unlock Door',
                icon = 'fas fa-key',
                action = function()
                    local PlayerData = QBCore.Functions.GetPlayerData()
                    local items = PlayerData.items
                    local hasFound = false
    
                    for _, item in pairs(items) do
                        if item.name ==  Config.MotelKey then
                            if item.info.uniqueID == keydata.uniqueID then
                                RequestAnimDict("anim@heists@keycard@")
                                while not HasAnimDictLoaded("anim@heists@keycard@") do
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 48, 0, 0, 0, 0)
                                Wait(300)
                                if v.doorLocked then
                                    Config.DoorlockAction(keydata.uniqueID, true)
                                    v.doorLocked = false
                                    ClearPedTasks(PlayerPedId())
                                else
                                    Config.DoorlockAction(keydata.uniqueID, false)
                                    v.doorLocked = true
                                    ClearPedTasks(PlayerPedId())
                                end
                                hasFound = true
                                break
                            end
                        end
                    end
    
                    if not hasFound then
                        QBCore.Functions.Notify('You don\'t have a key to this door!', 'error', 3000)
                    else
                        hasFound = false
                    end
                end
            }
    
            if Config.EnableRobbery then
                tableData[#tableData + 1] = {
                    label = 'Break into room',
                    icon = 'fas fa-doorlock',
                    action = function()
                        
                    end
                }
            end
            exports['qb-target']:AddCircleZone('room_' .. keydata.uniqueID, keydata.doorPos, 1.5, {
                name = 'room_' .. keydata.uniqueID,
                useZ = true,
                debugPoly = false,
            }, {
                options = tableData
            })

            exports['qb-target']:AddCircleZone('storage_' .. keydata.uniqueID, keydata.stashPos, 1.5, {
                name = 'storage_' .. keydata.uniqueID,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        label = 'Open Stash',
                        icon = 'fas fa-chest',
                        action = function()
                            TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'stash_' .. keydata.uniqueID, {
                                maxweight = keydata.stashData['weight'],
                                slots = keydata.stashData['slots'],
                            })
                            TriggerEvent('inventory:client:SetCurrentStash', 'stash_' .. keydata.uniqueID) 
                        end
                    }
                }
            })

            exports['qb-target']:AddCircleZone('wardrobe_' .. keydata.uniqueID, keydata.wardrobePos, 1.5, {
                name = 'wardrobe_' .. keydata.uniqueID,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        label = 'Open Wardrobe',
                        icon = 'fas fa-wardrobe',
                        action = function()
                            if Config.AppearanceScript == 'illenium-appearance' then
                                TriggerEvent('qb-clothing:client:openOutfitMenu')
                            elseif Config.AppearanceScript == 'qb-clothes' then
                                TriggerEvent('qb-clothing:client:openOutfitMenu')
                            end
                        end
                    }
                }
            })
        end
    end
end)