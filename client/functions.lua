if GetResourceState('qb-core') ~= 'started' and GetResourceState('qbx_core') ~= 'started' then return end
local QBCore = exports['qb-core']:GetCoreObject()

function LoadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

function OpenReception(name, motelData)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local citizenid = PlayerData.citizenid
    local lang = Config.Locale
    local tableData = {}

    QBCore.Functions.TriggerCallback('motel:getMotelData', function(data)
        if data then
            tableData[#tableData + 1] = {
                title = _L('rentroom'),
                description = _L('rentroomdesc'),
                onSelect = function()
                    RentRoomsHandler(name, motelData)
                end
            }
            tableData[#tableData + 1] = {
                title = _L('rentedrooms'),
                description = _L('rentedroomsdesc'),
                onSelect = function()
                    RentedRoomsHandler(name, motelData)
                end
            }
            
            if not data.owner or data.owner == '' then
                tableData[#tableData + 1] = {
                    title = _L('buymotel'),
                    description = _L('buymoteldesc') .. motelData.price,
                    onSelect = function()
                        BuyMotelHandler(name, motelData)
                    end
                }
            elseif data.owner and data.owner == citizenid then
                tableData[#tableData + 1] = {
                    title = _L('managemotel'),
                    description = _L('managemoteldesc'),
                    onSelect = function()
                        ManageMotelHandler(name, motelData)
                    end
                }
            end
        else
            tableData[#tableData + 1] = {
                title = _L('rentroom'),
                description = _L('rentroomdesc'),
                onSelect = function()
                    RentRoomsHandler(name, motelData)
                end
            }
            tableData[#tableData + 1] = {
                title = _L('rentedrooms'),
                description = _L('rentedroomsdesc'),
                onSelect = function()
                    RentedRoomsHandler(name, motelData)
                end
            }
            tableData[#tableData + 1] = {
                title = _L('buymotel'),
                description = _L('buymoteldesc') .. motelData.price,
                onSelect = function()
                    BuyMotelHandler(name, motelData)
                end
            }
        end

        lib.registerContext({
            id = 'open_motel',
            title = data.label or motelData.label,
            options = tableData
        })
        lib.showContext('open_motel')
    end, name)
end

function ManageMotelHandler(name, motelData)
    QBCore.Functions.TriggerCallback('motel:motelData', function(data)
        if data then
            lib.registerContext({
                id = 'manage_motel',
                title = _L('managemotel'),
                options = {
                    {
                        title = _L('managerooms'),
                        description = _L('manageroomsdesc'),
                        onSelect = function()
                            QBCore.Functions.TriggerCallback('motel:getRooms', function(roomData)
                                if roomData then
                                    local tableData = {}
                                    local hasFound = false

                                    for motelName, room in pairs(roomData) do
                                        if room.renter and room.renter ~= '' then
                                            if not hasFound then hasFound = true end
                                            tableData[#tableData + 1] = {
                                                title = room.room,
                                                description = 'Manage ' .. room.room,
                                                onSelect = function()
                                                    lib.registerContext({
                                                        id = 'manage_motel_rooms',
                                                        title = _L('managerooms'),
                                                        options = {
                                                            {
                                                                title = _L('renter') .. room.renterName,
                                                                readOnly = true,
                                                            },
                                                            {
                                                                title = _L('endrent'),
                                                                description = _L('endrentdesc2'),
                                                                onSelect = function()
                                                                    TriggerServerEvent('motel:server:endRent', name, room.uniqueID)
                                                                end
                                                            }
                                                        }
                                                    })
                                                    lib.showContext('manage_motel_rooms')
                                                end
                                            }
                                        end
                                    end
                                    Wait(100)

                                    if not hasFound then
                                        return QBCore.Functions.Notify(_L('noroomsrented'), 'error', 3000)
                                    else
                                        lib.registerContext({
                                            id = 'manage_rooms',
                                            title = _L('managerooms'),
                                            options = tableData
                                        })
                                        lib.showContext('manage_rooms')
                                    end
                                else
                                    QBCore.Functions.Notify(_L('noroomsrented'), 'error', 3000)
                                    return
                                end
                            end, name)
                        end
                    },
                    {
                        title = _L('funds') .. data.funds,
                        description = _L('fundsdesc'),
                        onSelect = function()
                            local PlayerData = QBCore.Functions.GetPlayerData()
                            local info = lib.inputDialog(_L('funds'), {
                                {
                                    type = 'number',
                                    label = _L('amount'),
                                    description = _L('amountdesc'),
                                    required = true,
                                    default = 0,
                                },
                                {
                                    type = 'select',
                                    label = _L('transactiontype'),
                                    description = _L('transactiontypedesc'),
                                    required = true,
                                    options = {
                                        {value = 'deposit', label = 'Deposit'},
                                        {value = 'withdraw', label = 'Withdraw'},
                                    }
                                },
                                {
                                    type = 'select',
                                    label = _L('paymethode'),
                                    description = _L('paymethodedesc'),
                                    required = true,
                                    options = {
                                        {value = 'bank', label = 'Bank'},
                                        {value = 'cash', label = 'Cash'},
                                    }
                                }
                            })

                            if info[2] == 'deposit' and PlayerData.money['cash'] >= info[1] then
                                TriggerServerEvent('motel:server:transactionMotelFunds', name, info)
                            else
                                QBCore.Functions.Notify(_L('nomoney'), 'error', 3000)
                            end

                            if info[2] == 'withdraw' and data.funds >= info[1] then
                                TriggerServerEvent('motel:server:transactionMotelFunds', name, info)
                            else
                                QBCore.Functions.Notify(_L('nofundsmoney'), 'error', 3000)
                            end
                        end
                    },
                    {
                        title = _L('changename'),
                        description = _L('changenamedesc'),
                        onSelect = function()
                            local info = lib.inputDialog(_L('changename'), {
                                {
                                    type = 'input',
                                    label = _L('newname'),
                                    description = _L('newnamedesc'),
                                    required = true,
                                }
                            })
                            TriggerServerEvent('motel:server:changeName', name, info[1])
                        end
                    },
                    {
                        title = _L('changeprice'),
                        description = _L('changepricedesc') .. (data.data['roomPrices'] or motelData.roomprices),
                        onSelect = function()
                            local info = lib.inputDialog(_L('changeprice'), {
                                {
                                    type = 'number',
                                    label = _L('amount'),
                                    description = _L('amountdesc2'),
                                    required = true,
                                }
                            })
                            TriggerServerEvent('motel:server:changeRoomPrice', name, info[1])
                        end
                    },
                    {
                        title = _L('autopay'),
                        description = _L('autopaydesc') .. tostring(Config.Motels[name].autoPayment),
                        onSelect = function()
                            TriggerServerEvent('motel:server:toggleAutoPay', name)
                        end
                    },
                    {
                        title = _L('sellmotel'),
                        description = _L('sellmoteldesc'),
                        onSelect = function()
                            TriggerServerEvent('motel:server:sellMotel', name)
                        end
                    },
                }
            })
            lib.showContext('manage_motel')
        else
            QBCore.Functions.Notify(_L('nodata'), 'error', 3000)
        end
    end, name)
end

function RentRoomsHandler(name, motelData)
    QBCore.Functions.TriggerCallback('motel:getRooms', function(data)
        if data then
            local tableData = {}
            for _, roomData in pairs(data) do
                if not roomData.renter or roomData.renter == '' then
                    tableData[#tableData + 1] = {
                        title = roomData.room,
                        description = _L('actionrentroom') .. roomData.room .. _L('actionrentroom2') .. Config.Motels[name].roomprices,
                        onSelect = function()
                            local PlayerData = QBCore.Functions.GetPlayerData()
                            local info = lib.inputDialog(_L('paymethode'), {
                                {
                                    type = 'select',
                                    label = _L('paymethode'),
                                    description = _L('paymethodedesc'),
                                    required = true,
                                    options = {
                                        {value = 'bank', label = 'Bank'},
                                        {value = 'cash', label = 'Cash'}
                                    }
                                }
                            })
                        
                            if PlayerData.money[info[1]] >= motelData.roomprices then
                                TriggerServerEvent('motel:server:rentRoom', name, roomData.uniqueID, roomData.room, motelData.payInterval, info[1], motelData.roomprices)
                                TriggerServerEvent('motel:server:giveKey', name, roomData)
                            else
                                QBCore.Functions.Notify(_L('nomoney'), 'error', 3000)
                            end
                        end
                    }
                end
            end
            Wait(100)

            lib.registerContext({
                id = 'rent_room',
                title = _L('rentroomstitle') .. motelData.label,
                options = tableData
            })
            lib.showContext('rent_room')
        else
            QBCore.Functions.Notify(_L('nodata'), 'error', 3000)
        end
    end, name)
end

function RentedRoomsHandler(name, motelData)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local citizenid = PlayerData.citizenid

    QBCore.Functions.TriggerCallback('motel:getRooms', function(data)
        local tableData = {}
        if data then
            print('Room data')
            for _, room in pairs(data) do
                print('Checking rooms', room.room, room.renter)
                if room.renter == citizenid then
                    tableData[#tableData + 1] = {
                        title = room.room,
                        description = 'Manage your room',
                        onSelect = function()
                            local tableData = {}
                            if Config.Motels[name].autoPayment then
                                tableData[#tableData + 1] = {
                                    title = _L('payauto'),
                                    description = _L('payautodesc'),
                                    onSelect = function()

                                    end
                                }
                                tableData[#tableData + 1] = {
                                    title = _L('ledger'),
                                    description = _L('ledgerdesc'),
                                    onSelect = function()
                                        lib.registerContext({
                                            id = 'manage_roomledger',
                                            title = _L('ledger'),
                                            options = {
                                                {
                                                    title = _L('ledgerfunds') .. room.ledger or 0,
                                                    description = _L('rentprice') .. motelData.roomprices,
                                                    icon = 'fas fa-dollar',
                                                    readOnly = true,
                                                },
                                                {
                                                    title = _L('depositledger'),
                                                    description = _L('depositledgerdesc'),
                                                    icon = 'fas fa-coins',
                                                    onSelect = function()
                                                        local PlayerData = QBCore.Functions.GetPlayerData()
                                                        local info = lib.inputDialog(_L('paymethode'), {
                                                            {
                                                                type = 'number',
                                                                label = _L('amount'),
                                                                description = _L('depositamountdesc'),
                                                                required = true,
                                                                default = 0,
                                                            },
                                                            {
                                                                type = 'select',
                                                                label = _L('paymethode'),
                                                                description = _L('paymethodedesc'),
                                                                required = true,
                                                                options = {
                                                                    {value = 'bank', label = 'Bank'},
                                                                    {value = 'cash', label = 'Cash'},
                                                                }
                                                            }
                                                        })

                                                        if PlayerData.money[info[2]] >= tonumber(info[1]) then 
                                                            TriggerServerEvent('motel:server:addToLedger', name, room.uniqueID, info[1], info[2])
                                                        else
                                                            QBCore.Functions.Notify(_L('nomoney'), 'error', 3000)
                                                        end
                                                    end
                                                },
                                                {
                                                    title = _L('withdrawledger'),
                                                    description = _L('withdrawledgerdesc'),
                                                    icon = 'fas fa-wallet',
                                                    onSelect = function()
                                                        local PlayerData = QBCore.Functions.GetPlayerData()
                                                        local info = lib.inputDialog(_L('paymethode'), {
                                                            {
                                                                type = 'number',
                                                                label = _L('amount'),
                                                                description = _L('depositamountdesc'),
                                                                required = true,
                                                                default = 0,
                                                            }
                                                        })

                                                        if room.ledger >= tonumber(info[1]) then 
                                                            TriggerServerEvent('motel:server:removeFromLedger', name, room.uniqueID, info[1])
                                                        else
                                                            QBCore.Functions.Notify(_L('noledgermoney'), 'error', 3000)
                                                        end
                                                    end
                                                }
                                            }
                                        })
                                        lib.showContext('manage_roomledger')
                                    end
                                }
                            end

                            if Config.StashProtection then
                                if Config.StashProtection == 'password' then
                                    tableData[#tableData + 1] = {
                                        title = _L('changestashpassword'),
                                        description = _L('changestashpassworddesc') .. '\n' .. _L('currentpassword') .. room.password,
                                        onSelect = function()
                                            local info = lib.inputDialog(_L('changestashpassword'), {
                                                {
                                                    type = 'input',
                                                    label = _L('password'),
                                                    description = _L('passworddesc'),
                                                    required = true,
                                                }
                                            })
                                            TriggerServerEvent('motel:server:changeStashPassword', name, room.uniqueID, info[1])
                                        end
                                    }
                                end
                            end

                            tableData[#tableData + 1] = {
                                title = _L('lostkey'),
                                description = _L('lostkeydesc') .. motelData.keyPrice,
                                onSelect = function()
                                    local PlayerData = QBCore.Functions.GetPlayerData()
                                    if PlayerData.money['cash'] >= motelData.keyPrice then
                                        TriggerServerEvent('motel:server:giveKey', name, room, motelData.keyPrice)
                                        if Config.LostkeyReplaceAll then
                                            TriggerServerEvent('motel:server:removeAllKeys', name, room)
                                        end
                                    else
                                        QBCore.Functions.Notify(_L('nomoney'), 'error', 3000)
                                    end
                                end
                            }

                            tableData[#tableData + 1] = {
                                title = _L('copykey'),
                                description = _L('copykeydesc'),
                                onSelect = function()
                                    local PlayerData = QBCore.Functions.GetPlayerData()
                                    local items = PlayerData.items
                                    local hasFound = false

                                    for _, item in pairs(items) do
                                        if item.name == Config.Motelkey then
                                            local motelInfo = item.info or item.metadata or {}
                                            if motelInfo.motel == name and motelInfo.room == room.room and motelInfo.uniqueID == room.uniqueID then
                                                hasFound = true
                                                break
                                            end
                                        end
                                    end
                                    Wait(100)

                                    if hasFound then
                                        if PlayerData.money['cash'] >= motelData.keyPrice then
                                            TriggerServerEvent('motel:server:giveKey', name, room, motelData.keyPrice)
                                        else
                                            QBCore.Functions.Notify(_L('nomoney'), 'error', 3000)
                                        end
                                    else
                                        QBCore.Functions.Notify(_L('nokey'), 'error', 3000)
                                    end
                                end
                            }

                            tableData[#tableData + 1] = {
                                title = _L('endrent'),
                                description = _L('endrentdesc'),
                                onSelect = function()
                                    TriggerServerEvent('motel:server:endRent', name, room.uniqueID)
                                end
                            }

                            lib.registerContext({
                                id = 'manage_rented_room',
                                title = room.room,
                                options = tableData
                            })
                            lib.showContext('manage_rented_room')
                        end
                    }
                end
            end
        else
            QBCore.Functions.Notify(_L('nodata'), 'error', 3000)
            return
        end

        lib.registerContext({
            id = 'player_rented_rooms',
            title = _L('rentedrooms'),
            options = tableData
        })
        lib.showContext('player_rented_rooms')
    end, name)
end

function StashHandler(name, roomData, coords)
    local stash = roomData.stash
    QBCore.Functions.TriggerCallback('motel:getMasterKey', function(code)
        Config.Stash(name, stash, roomData, code, coords)
    end)
end

function WardrobeHandler()
    Config.Appearance()
end

function BuyMotelHandler(name, motelData)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local info = lib.inputDialog(_L('paymethode'), {
        {
            type = 'select',
            label = _L('paymethode'),
            description = _L('paymethodedesc'),
            required = true,
            options = {
                {value = 'bank', label = 'Bank'},
                {value = 'cash', label = 'Cash'}
            }
        }
    })

    if PlayerData.money[info[1]] >= motelData.price then
        TriggerServerEvent('motel:server:buyMotel', name, motelData, info[1])
    else
        QBCore.Functions.Notify(_L('nomoney'), 'error', 3000)
    end
end

function ToggleDoorHandler(name, room)
    local items = QBCore.Functions.GetPlayerData().items
    for _, item in pairs(items) do
        if item.name == Config.Motelkey then
            local motelInfo = item.info or item.metadata or {}
            if motelInfo.motel == name and motelInfo.room == room.room and motelInfo.uniqueID == room.uniqueID then
                QBCore.Functions.TriggerCallback('motel:doorState', function(state)
                    RequestAnimDict('anim@mp_player_intmenu@key_fob@')
                    while not HasAnimDictLoaded('anim@mp_player_intmenu@key_fob@') do
                        Wait(10)
                    end
                    TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', -8.0, 8.0, 1000, 50, 0.0, false, false, false)
                    Config.DoorlockAction(room.uniqueID, not state)
                    TriggerServerEvent('motels:server:toggleDoorlock', name, room.uniqueID, not state)
                    hasKey = true
                    return
                end, name, room.uniqueID)
            end
        end
    end
    Wait(100)
    if not hasKey then
        return QBCore.Functions.Notify(_L('nokey'), 'error', 3000)
    end
end
RegisterNetEvent('motel:client:toggleDoorHander', ToggleDoorHandler)

function BreakinHandler(name, room)
    if not QBCore.Functions.HasItem(Config.LockpickItem) then return end
    LoadAnim('missheistfbisetup1')
    TaskPlayAnim(PlayerPedId(), 'missheistfbisetup1', 'hassle_intro_loop_f', -8.0, 8.0, -1, 47, 0.0, false, false, false)

    exports['ps-ui']:Circle(function(success)
        if success then
            if Config.AlarmChance > 0 then
                local chance = math.random(1, 100)
                if chance <= Config.AlarmChance then
                    Config.PoliceAlert()
                end
            end

            if lib.progressBar({
                label = 'Lockpicking motel room...',
                duration = math.random(7500, 15000),
                useWhileDead = false,
                canCancel = true,
            }) then
                ClearPedTasks(PlayerPedId())
                Config.DoorlockAction(room.uniqueID, false)
                TriggerServerEvent('motels:server:toggleDoorlock', name, room.uniqueID, false)
                if Config.LoseLockpickChance > 0 then
                    local chance = math.random(1, 100)
                    if chance <= Config.LoseLockpickChance then
                        TriggerServerEvent('motel:server:removeItem', Config.LockpickItem, 1)
                    end
                end
            end
        else
            ClearPedTasks(PlayerPedId())
            if Config.AlertOnFail then
                Config.PoliceAlert()
            end
            if Config.LoseLockpickOnFail then
                TriggerServerEvent('motel:server:removeItem', Config.LockpickItem, 1)
            else
                if Config.LoseLockpickChance > 0 then
                    local chance = math.random(1, 100)
                    if chance <= Config.LoseLockpickChance then
                        TriggerServerEvent('motel:server:removeItem', Config.LockpickItem, 1)
                    end
                end
            end
        end
    end, Config.PicklockCircles, Config.CircleTime)
end

function PoliceBreakInHandler(name, room)
    LoadAnim('missheistfbi3b_ig7')
    TaskPlayAnim(PlayerPedId(), 'missheistfbi3b_ig7', 'lift_fibagent_loop', -8.0, 8.0, -1, 47, 0.0, false, false, false)
    exports['ps-ui']:Circle(function(success)
        if success then
            ClearPedTasks(PlayerPedId())
            Config.DoorlockAction(room.uniqueID, false)
            TriggerServerEvent('motels:server:toggleDoorlock', name, room.uniqueID, false)
            QBCore.Functions.Notify(_L('policebrokendoor'))
            TriggerServerEvent('motel:server:createMasterKey')
            QBCore.Functions.TriggerCallback('motel:getMasterKey', function(code)
                if code then
                    QBCore.Functions.Notify(_L('masterkeytext') .. code, 'info', 10000)
                end
            end)
        else
            ClearPedTasks(PlayerPedId())
            QBCore.Functions.Notify(_L('policebrokendoorfail'), 'error', 3000)
        end
    end, Config.PicklockCircles, Config.CircleTime)
end

if GetResourceState('qb-core') == 'started' or GetResourceState('qbx-core') == 'started' then
    CreateThread(function()
        while not LocalPlayer.state.isLoggedIn do
            Wait(10)
        end
        TriggerServerEvent('motel:server:playerLoaded')
    end)
end