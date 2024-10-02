local QBCore = exports['qb-core']:GetCoreObject()

if Config.TargetScript == 'qb' then
    RegisterNetEvent('jc-motel:client:AddTargetMotel', function(k, v)
        local PlayerData = QBCore.Functions.GetPlayerData()
        local globalData = {}

        if v.owner and v.owner == PlayerData.citizenid then
            globalData[#globalData + 1] = {
                title = 'Manage Motel',
                description = 'Manage the motel if you own it!',
                onSelect = function()
                    ManageMotelHandler(k, v)
                end
            }
        end
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
            },
            distance = 1.5,
        })
    end)

    RegisterNetEvent('jc-motels:client:removeTargetZone', function(k, data)
        exports['qb-target']:RemoveZone(k)
        for key, v in pairs(Config.Motels) do
            if key == k then
                TriggerEvent('jc-motel:client:AddTargetMotel', key, v)
            end
        end
    end)

    RegisterNetEvent('jc-motels:client:intiateMotels', function()
        if Config.UseTarget then
            local isLoggedIn = false
            while not isLoggedIn do
                Wait(1)
                if LocalPlayer.state.isLoggedIn then
                    isLoggedIn = true
                end
            end
            Wait(500)

            for k, v in pairs(Config.Motels) do
                TriggerEvent('jc-motel:client:AddTargetMotel', k, v)
            end

            for k, v in pairs(Config.Rooms) do
                for _, keydata in pairs(v) do
                    local tableData = {}
                
                    tableData[#tableData + 1] = {
                        label = 'Lock/Unlock Door',
                        icon = 'fas fa-key',
                        action = function()
                            local PlayerData = QBCore.Functions.GetPlayerData()
                            local items = PlayerData.items
                            local hasFound = false
            
                            if Config.Framework == 'qbx' then 
                                for _, item in pairs(items) do
                                    if item.name == Config.MotelKey then
                                        if item.metadata.uniqueID == keydata.uniqueID then
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
                            else
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
                        }
                    end
                    exports['qb-target']:AddCircleZone('room_' .. keydata.uniqueID, keydata.doorPos, 1.5, {
                        name = 'room_' .. keydata.uniqueID,
                        useZ = true,
                        debugPoly = false,
                    }, {
                        options = tableData,
                        distance = 1.5,
                    })

                    exports['qb-target']:AddCircleZone('storage_' .. keydata.uniqueID, keydata.stashPos, 0.5, {
                        name = 'storage_' .. keydata.uniqueID,
                        useZ = true,
                        debugPoly = false,
                    }, {
                        options = {
                            {
                                label = 'Open Stash',
                                icon = 'fas fa-chest',
                                action = function()
                                    StashHandler(keydata.stashPos, keydata.uniqueID, keydata.stashData['weight'], keydata.stashData['slots'])
                                end
                            }
                        },
                        distance = 0.5,
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
                                    WardrobeHandler(keydata.wardrobePos)
                                end
                            }
                        },
                        distance = 1.5,
                    })
                end
            end
        end
    end)
end