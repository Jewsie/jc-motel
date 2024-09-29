local QBCore = exports['qb-core']:GetCoreObject()
local motels = {}
local rooms = {}
local zones = {}

if Config.PolyZone == 'ox' then
    RegisterNetEvent('jc-motel:client:AddMotel', function(k, v)
        zones[k] = lib.zones.box({
            name = k,
            coords = v.coords,
            size = vector3(1.5, 1.5, 1.5),
            rotation = 0,
            onEnter = function()
                AtMotelHandler(k, v)
            end,
            debug = false,
        })
    end)

    RegisterNetEvent('jc-motel:client:removezones', function(k, v)
        zones[k]:remove()
        for key, v in pairs(Config.Motels) do
            if key == k then
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

                    lib.zones.box({
                        name = k,
                        coords = keydata.doorPos,
                        size = vector3(1.5, 1.5, 1.5),
                        rotation = 0,
                        onEnter = function()
                            RoomHandler(k, keydata.doorPos, tableData)
                        end,
                        debug = false,
                    })
                    lib.zones.box({
                        name = k .. '_stash',
                        coords = keydata.stashPos,
                        size = vector3(0.5, 0.5, 0.5),
                        rotation = 0,
                        onEnter = function()
                            StashHandler(keydata.stashPos, keydata.uniqueID, keydata.stashData['weight'], keydata.stashData['slots'])
                        end,
                        debug = false,
                    })
                    lib.zones.box({
                        name = k .. '_wardrobe',
                        coords = keydata.wardrobePos,
                        size = vector3(1.5, 1.5, 1.5),
                        rotation = 0,
                        onEnter = function()
                            WardrobeHandler(keydata.wardrobePos)
                        end,
                        debug = false,
                    })
                end
            end
        end
    end)
end