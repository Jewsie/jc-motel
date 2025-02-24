local QBCore = exports['qb-core']:GetCoreObject()
local motels = {}
local rooms = {}

if Config.PolyZone == 'PolyZone' and not Config.UseTarget then
    RegisterNetEvent('jc-motel:client:AddMotel', function(k, v)
        motels[k]:onPlayerInOut(function(onInsideOut)
            if onInsideOut then
                AtMotelHandler(k, v)
            end
        end)
    end)

    RegisterNetEvent('jc-motel:client:removezones', function(k, v)
        motels[k]:remove()
        motels[k]:destroy()
        for key, v in pairs(Config.Motels) do
            if key == k then
                motels[key] = BoxZone:Create(v.coords, 1.0, 1.0, {
                    name = key,
                    debugPoly = Config.Debug
                })
                TriggerEvent('jc-motel:client:AddMotel', key, v)
            end
        end
    end)
    
    RegisterNetEvent('jc-motels:client:intiateMotels', function()
        if not Config.UseTarget then
            local isLoggedIn = false
            while not isLoggedIn do
                Wait(1)
                if LocalPlayer.state.isLoggedIn then
                    isLoggedIn = true
                end
            end
            Wait(500)

            for k, v in pairs(Config.Motels) do
                motels[k] = BoxZone:Create(v.coords, 1.0, 1.0, {
                    name = k,
                    debugPoly = Config.Debug
                })
                TriggerEvent('jc-motel:client:AddMotel', k, v)
            end

            for k, v in pairs(Config.Rooms) do
                rooms[k] = {door = '', stash = '', wardrobe = ''}
                for _, keydata in pairs(v) do
                    local tableData = {}

                    tableData[#tableData + 1] = {
                        title = 'Toggle Doorlock',
                        description = 'Toggle the doorlock for door!',
                        onSelect = function()
                            ToggleDoorHandler(k, keydata)
                        end
                    }
                    if Config.EnableRobbery then
                        tableData[#tableData + 1] = {
                            title = 'Break into room',
                            description = 'Break into the motel room!',
                            onSelect = function()
                                BreakInHandler(k, keydata)
                            end
                        }
                    end

                    rooms[k] = BoxZone:Create(keydata.doorPos, 1.0, 1.0, {
                        name = k,
                        debugPoly = Config.Debug
                    })
                    rooms[k .. '_stash'] = BoxZone:Create(keydata.stashPos, 1.0, 1.0, {
                        name = k,
                        debugPoly = Config.Debug
                    })
                    rooms[k .. '_wardrobe'] = BoxZone:Create(keydata.wardrobePos, 1.0, 1.0, {
                        name = k,
                        debugPoly = Config.Debug
                    })

                    rooms[k]:onPlayerInOut(function(onInsideOut)
                        if onInsideOut then
                            RoomHandler(k, keydata.doorPos, tableData)
                        end
                    end)
                    rooms[k .. '_stash']:onPlayerInOut(function(onInsideOut)
                        if onInsideOut then
                            StashHandler(keydata.stashPos, keydata.uniqueID, keydata.stashData['weight'], keydata.stashData['slots'])
                        end
                    end)
                    rooms[k .. '_wardrobe']:onPlayerInOut(function(onInsideOut)
                        if onInsideOut then
                            WardrobeHandler(keydata.wardrobePos)
                        end
                    end)
                end
            end
        end
    end)
end
