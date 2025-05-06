if Config.Framework ~= 'qb' then return end
local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    for name, motel in pairs(Config.Motels) do
        if Config.UseTarget then
            if Config.UseTarget == 'qb-target' then
                exports['qb-target']:AddCircleZone(name .. '_reception', motel.coords, 1.5, {
                    name = name .. '_reception',
                    debugPoly = Config.ToggleDebug,
                    useZ = true,
                }, {
                    options = {
                        {
                            label = _L('openreception'),
                            icon = 'fas fa-file-invoice',
                            action = function()
                                OpenReception(name, motel)
                            end
                        }
                    }
                })
            end
        end
    end

    if Config.UseTarget then
        for name, roomData in pairs(Config.Rooms) do
            for _, room in pairs(roomData) do
                local door = room.door
                local stash = room.stash
                local wardrobe = room.wardrobe

                if Config.UseTarget then
                    if Config.UseTarget == 'qb-target' then
                        local targetData = {}
                        if not Config.KeyItemUseable then
                            local hasKey = false
                            targetData[#targetData + 1] = {
                                label = 'Toggle Doorlock',
                                icon = 'fas fa-key',
                                action = function()
                                    ToggleDoorHandler(name, room)
                                end
                            }
                        end
                        if Config.EnableRobbery then
                            targetData[#targetData + 1] = {
                                label = 'Break in',
                                icon = 'fas fa-lock',
                                action = function()
                                    BreakinHandler(name, room)
                                end
                            }
                        end
                        if Config.AllowPoliceRaids then
                            targetData[#targetData + 1] = {
                                label = 'Break Down',
                                icon = 'fas fa-lock',
                                item = Config.DoorRam,
                                canInteract = function()
                                    local PlayerData = QBCore.Functions.GetPlayerData()
                                    if PlayerData.job.type == 'leo' then return true else return false end
                                end,
                                action = function()
                                    PoliceBreakInHandler(name, room)
                                end
                            }
                        end
                        
                        exports['qb-target']:AddCircleZone(tostring(room.uniqueID) .. '_door', door.pos, door.radius, {
                            name = tostring(room.uniqueID) .. '_door',
                            debugPoly = Config.ToggleDebug,
                            useZ = true,
                        }, {
                            options = targetData,
                            distance = door.radius,
                        })

                        exports['qb-target']:AddCircleZone(tostring(room.uniqueID) .. '_stash', stash.pos, stash.radius, {
                            name = tostring(room.uniqueID) .. '_stash',
                            debugPoly = Config.ToggleDebug,
                            useZ = true,
                        }, {
                            options = {
                                {
                                    label = _L('openstash'),
                                    icon = 'fas fa-box',
                                    canInteract = function()
                                        local PlayerData = QBCore.Functions.GetPlayerData()
                                        local citizenid = PlayerData.citizenid
                                        if Config.StashProtection and Config.StashProtection == 'citizenid' then
                                            QBCore.Functions.TriggerCallback('motel:getMasterKey', function(code)
                                                if code then
                                                    if PlayerData.job.type == 'leo' then return true end
                                                end
                                            end)
                                            Wait(250)
                                            QBCore.Functions.TriggerCallback('motel:getRooms', function(data)
                                                if data then
                                                    for _, v in pairs(data) do
                                                        if v.uniqueID == room.uniqueID then
                                                            if v.renter == citizenid then return true end
                                                            return false
                                                        end
                                                    end
                                                else
                                                    if Config.ToggleDebug then
                                                        QBCore.Functions.Notify(_L('nodata'), 'error', 3000)
                                                        return false
                                                    end
                                                end
                                            end)
                                        end
                                        return true
                                    end,
                                    action = function()
                                        StashHandler(name, room)
                                    end
                                }
                            },
                            distance = stash.radius,
                        })

                        exports['qb-target']:AddCircleZone(tostring(room.uniqueID) .. '_wardrobe', wardrobe.pos, wardrobe.radius, {
                            name = tostring(room.uniqueID) .. '_wardrobe',
                            debugPoly = Config.ToggleDebug,
                            useZ = true,
                        }, {
                            options = {
                                {
                                    label = _L('openwardrobe'),
                                    icon = 'fas fa-wardrobe',
                                    action = function()
                                        WardrobeHandler()
                                    end
                                }
                            },
                            distance = wardrobe.radius,
                        })
                    end
                end
            end
        end
    end
end)