if GetResourceState('qbx_core') ~= 'started' then return end
local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    for name, motel in pairs(Config.Motels) do
        if Config.UseTarget then
            if Config.UseTarget == 'ox_target' then
                exports['ox_target']:addSphereZone({
                    name = name .. '_reception',
                    coords = motel.coords,
                    radius = 1.5,
                    debug = Config.ToggleDebug,
                    options = {
                        {
                            label = _L('openreception'),
                            icon = 'fas fa-file-invoice',
                            onSelect = function()
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
                    if Config.UseTarget == 'ox_target' then
                        local targetData = {}
                        if not Config.KeyItemUseable then
                            local hasKey = false
                            targetData[#targetData + 1] = {
                                label = 'Toggle Doorlock',
                                icon = 'fas fa-key',
                                onSelect = function()
                                    ToggleDoorHandler(name, room)
                                end
                            }
                        end
                        if Config.EnableRobbery then
                            targetData[#targetData + 1] = {
                                label = 'Break in',
                                icon = 'fas fa-lock',
                                onSelect = function()
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
                                onSelect = function()
                                    PoliceBreakInHandler(name, room)
                                end
                            }
                        end
                        
                        exports['ox_target']:addSphereZone({
                            name = tostring(room.uniqueID) .. '_door',
                            coords = door.pos,
                            radius = door.radius,
                            debug = Config.ToggleDebug,
                            options = targetData
                        })

                        exports['ox_target']:addSphereZone({
                            name = tostring(room.uniqueID) .. '_stash',
                            coords = stash.pos,
                            radius = stash.radius,
                            debug = Config.ToggleDebug,
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
                                    onSelect = function()
                                        StashHandler(name, room, stash.pos)
                                    end
                                }
                            }
                        })

                        exports['ox_target']:addSphereZone({
                            name = tostring(room.uniqueID) .. '_wardrobe',
                            coords = wardrobe.pos,
                            radius = wardrobe.radius,
                            debug = Config.ToggleDebug,
                            options = {
                                {
                                    label = _L('openwardrobe'),
                                    icon = 'fas fa-wardrobe',
                                    onSelect = function()
                                        WardrobeHandler()
                                    end
                                }
                            }
                        })
                    end
                end
            end
        end
    end
end)