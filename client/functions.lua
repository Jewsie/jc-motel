local QBCore = exports['qb-core']:GetCoreObject()

function RoomHandler(k, doorPos, tableData)
    local pos = GetEntityCoords(PlayerPedId())
    while #(pos - doorPos) <= 2.0 do
        Wait(0)
        pos = GetEntityCoords(PlayerPedId())
        lib.showTextUI('[E] To Interact')

        if IsControlJustPressed(0, 38) then
            lib.registerContext({
                id = k .. '_door',
                title = 'Motel Room',
                options = tableData
            })
            lib.showContext(k .. '_door')
        end
    end
    lib.hideTextUI()
end

function WardrobeHandler(wardrobePos)
    local pos = GetEntityCoords(PlayerPedId())
    while (#pos - wardrobePos) <= 2.0 do
        Wait(0)
        pos = GetEntityCoords(PlayerPedId())
        lib.showTextUI('[E] To open wardrobe')
        
        if Config.AppearanceScript == 'illenium-appearance' then
            TriggerEvent('qb-clothing:client:openOutfitMenu')
        elseif Config.AppearanceScript == 'qb-clothes' then
            TriggerEvent('qb-clothing:client:openOutfitMenu')
        end
    end
    lib.hideTextUI()
end

function StashHandler(stashPos, uniqueID, weight, slots)
    local pos = GetEntityCoords(PlayerPedId())
    while #(pos - stashPos) <= 2.0 do
        Wait(0)
        pos = GetEntityCoords(PlayerPedId())
        lib.showTextUI('[E] To open stash')

        if IsControlJustPressed(0, 38) then
            if Config.InventorySystem == 'qs' then
                TriggerServerEvent('jc-motel:server:openInventory', uniqueID, weight, slots, 'qs')
            elseif Config.InventorySystem == 'qb' then
                TriggerServerEvent('jc-motel:server:openInventory', uniqueID, weight, slots, 'qb')
            elseif Config.InventorySystem == 'ps' then
                TriggerServerEvent('ps-inventory:server:OpenInventory', 'stash', uniqueID, {
                    maxweight = weight,
                    slots = slots,
                })
                TriggerEvent('ps-inventory:client:SetCurrentStash', uniqueID)
            end
        end
    end
    lib.hideTextUI()
end

function ManageMotelHandler(k, v)
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
                        if Config.AllowAutoPay then
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
                        else
                            QBCore.Functions.Notify('This function is not allowed!', 'error', 3000)
                        end
                    end
                },
                {
                    title = 'Sell Motel',
                    description = 'Sell the motel again for $' .. v.price * 0.85,
                    onSelect = function()
                        local input = lib.inputDialog('Transfer Account', {
                            {
                                type = 'select',
                                label = 'Account',
                                description = 'Account to transfer the money to',
                                options = {
                                    {value = 'bank', label = 'Bank'},
                                    {value = 'cash', label = 'Cash'},
                                },
                                required = true,
                            }
                        })
                        TriggerServerEvent('jc-motels:server:sellMotel', k, input[1], v.price * 0.85)
                    end
                }
            }
        })
        lib.showContext('manage_motel')
    end
end

function RentMotelHandler(k, v)
    local tableData = {}
    for key, h in pairs(Config.Rooms[k]) do
        if not h.renter then
            tableData[#tableData + 1] = {
                title = h.room,
                description = 'Rent room for $' .. v.roomprices,
                onSelect = function()
                    local PlayerData = QBCore.Functions.GetPlayerData()
                    local money = PlayerData.money['cash']
                    local bank = PlayerData.money['bank']

                    local input = lib.inputDialog('Replace Key', {
                        {
                            type = 'select',
                            label = 'Payment Methode',
                            description = 'Pay through bank or card',
                            options = {
                                {value = 'bank', label = 'Bank'},
                                {value = 'cash', label = 'Cash'}
                            },
                            required = true
                        }
                    })

                    if money >= v.roomprices and input[1] == 'cash' then
                        TriggerServerEvent('jc-motels:server:rentRoom', k, h.room, h.uniqueID, v.roomprices, v.payInterval, input[1])
                    elseif bank >= v.roomprices and input[1] == 'bank' then
                        TriggerServerEvent('jc-motels:server:rentRoom', k, h.room, h.uniqueID, v.roomprices, v.payInterval, input[1])
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

function RentedRoomsHandler(k, v)
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
                                                TriggerServerEvent('jc-motels:server:endRent', data.uniqueid, data.room)
                                            end
                                        },
                                        {
                                            title = 'Lost Key',
                                            description = 'If you have lost a key, you can get a new!',
                                            onSelect = function()
                                                local PlayerData = QBCore.Functions.GetPlayerData()
                                                local money = PlayerData.money['cash']
                                                local bank = PlayerData.money['bank']

                                                local input = lib.inputDialog('Replace Key', {
                                                    {
                                                        type = 'select',
                                                        label = 'Payment Methode',
                                                        description = 'Pay through bank or card',
                                                        options = {
                                                            {value = 'bank', label = 'Bank'},
                                                            {value = 'cash', label = 'Cash'}
                                                        },
                                                        required = true
                                                    }
                                                })

                                                if money >= v.keyPrice and input[1] == 'cash' then
                                                    TriggerServerEvent('jc-motels:server:replaceKey', data.room, data.uniqueid, v.keyPrice, input[1])
                                                elseif bank >= v.keyPrice and input[1] == 'bank' then
                                                    TriggerServerEvent('jc-motels:server:replaceKey', data.room, data.uniqueid, v.keyPrice, input[1])
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

function BuyMotelHandler(k, v)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local input = lib.inputDialog('Buy Motel', {
        {
            type = 'select',
            label = 'Payment Methode',
            description = 'Buy the motel using cash or card',
            options = {
                {value = 'cash', label = 'Cash'},
                {value = 'bank', label = 'Bank'},
            },
            required = true
        }
    })
    print('Owner:', tostring(v.owner))
    if not v.owner or v.owner == '' and PlayerData.money[input[1]] >= v.price then
        TriggerServerEvent('jc-motels:server:buymotel', k, v, input[1])
    else
        QBCore.Functions.Notify('Motel is already owned by somebody!', 'error', 3000)
    end
end

function AtMotelHandler(k, v)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local globalData = {}

    globalData[#globalData + 1] = {
        title = 'Manage Motel',
        description = 'Manage the motel if you own it!',
        onSelect = function()
            ManageMotelHandler(k, v)
        end
    }
    globalData[#globalData + 1] = {
        title = 'Rent Motel Room',
        description = 'Rent a motel room!',
        onSelect = function()
            RentMotelHandler(k, v)
        end
    }
    globalData[#globalData + 1] = {
        title = 'Rented Rooms',
        description = 'Check motel rooms you have rented!',
        onSelect = function()
            RentedRoomsHandler(k, v)
        end
    }
    if not v.owner or v.owner == '' and v.price or v.owner == '' and v.price >= 0 then
        globalData[#globalData + 1] = {
            title = 'Buy Motel',
            description = 'Buy motel for $' .. v.price,
            onSelect = function()
                BuyMotelHandler(k, v)
            end
        }
    end
    
    local pos = GetEntityCoords(PlayerPedId())
    while #(pos - v.coords) <= 2.0 do
        Wait(0)
        pos = GetEntityCoords(PlayerPedId())
        lib.showTextUI('[E] To Interact')

        if IsControlJustPressed(0, 38) then
            lib.registerContext({
                id = k,
                title = v.label,
                options = globalData
            })
            lib.showContext(k)
        end
    end
    lib.hideTextUI()
end

function ToggleDoorHandler(k, keydata)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local items = PlayerData.items
    local hasFound = false

    for _, item in pairs(items) do
        if item.name == Config.MotelKey then
            if item.info.uniqueID == keydata.uniqueID then
                RequestAnimDict("anim@heists@keycard@")
                while not HasAnimDictLoaded("anim@heists@keycard@") do
                    Wait(0)
                end
                TaskPlayAnim(PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 48, 0, 0, 0, 0)
                Wait(300)
                QBCore.Functions.TriggerCallback('motels:getDoorDate', function(data)
                    if data then
                        Config.DoorlockAction(keydata.uniqueID, not data.isLocked)
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent('motel:server:setDoorState', keydata.uniqueID)
                    end
                end, keydata.uniqueID)
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

function BreakInHandler(k, keydata)
    QBCore.Functions.TriggerCallback('motels:GetCops', function(cops)
        if cops >= Config.CopCount then
            local hasItem = nil
            if Config.InventorySystem == 'qb' then
                hasItem = QBCore.Functions.HasItem(Config.Lockpick, 1)
            else
                hasItem = exports['ps-inventory']:HasItem(Config.Lockpick, 1)
            end
            
            if hasItem then
                TaskStartScenarioInPlace(PlayerPedId(), 'PROP_HUMAN_PARKING_METER', 0, false)
                exports['ps-ui']:Circle(function(success)
                    if success then
                        QBCore.Functions.TriggerCallback('motels:getDoorDate', function(data)
                            if data then
                                if data.isLocked then
                                    local chance = math.random(1, 100)
                                    if chance <= Config.SuccessAlarmChance then
                                        if Config.PoliceAlert == 'qbdefault' then
                                            TriggerEvent('police:client:policeAlert', GetEntityCoords(PlayerPedId()), 'Suspicious activity reported')
                                        elseif Config.PoliceAlert == 'ps-dispatch' then
                                            exports['ps-dispatch']:HouseRobbery()
                                        end
                                    end

                                    if Config.DoorlockSystem == 'qb' then
                                        Config.DoorlockAction(keydata.uniqueID, not data.isLocked)
                                    end
                                    ClearPedTasks(PlayerPedId())
                                    TriggerServerEvent('motel:server:setDoorState', keydata.uniqueID)
                                else
                                    QBCore.Functions.Notify('Can\'t break into an already unlocked door silly!', 'error', 3000)
                                end
                            end
                        end, keydata.uniqueID)
                    else
                        ClearPedTasks(PlayerPedId())
                        QBCore.Functions.Notify('Failed at lockpicking door!', 'error', 3000)

                        if Config.PoliceAlert == 'qbdefault' then
                            TriggerEvent('police:client:policeAlert', GetEntityCoords(PlayerPedId()), 'Suspicious activity reported')
                        elseif Config.PoliceAlert == 'ps-dispatch' then
                            exports['ps-dispatch']:HouseRobbery()
                        end
                    end
                end, math.random(3, 5), 15)

                local loseChance = math.random(1, 100)
                if loseChance <= Config.CopCount then
                    TriggerServerEvent('motel:server:loseLockpick')
                end
            else
                QBCore.Functions.Notify('You don\'t have a lockpick!', 'error', 3000)
            end
        else
            QBCore.Functions.Notify('Not enough cops on duty!', 'error', 3000)
        end
    end)
end

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

RegisterNetEvent('jc-motels:client:removeOwner', function(motel)
    for k, v in pairs(Config.Motels) do
        if k == motel then
            v.owner = nil
            break
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