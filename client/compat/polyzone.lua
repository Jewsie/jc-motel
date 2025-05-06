local QBCore = exports['qb-core']:GetCoreObject()

if not Config.UseTarget then
    CreateThread(function()
        for name, motel in pairs(Config.Motels) do
            if Config.Polyzone == 'PolyZone' then
                print('Running polyzone 1?')
                local motelZone = CircleZone:Create(motel.coords, 1.5, {
                    name = name,
                    useZ = true,
                    debugPoly = Config.ToggleDebug,
                })

                motelZone:onPlayerInOut(function(onInsideOut)
                    if onInsideOut then
                        local pos = GetEntityCoords(PlayerPedId())
                        while #(pos - motel.coords) <= 1.5 do
                            Wait(0)
                            pos = GetEntityCoords(PlayerPedId())
                            lib.showTextUI('[E] ' .. _L('openreception'))

                            if IsControlJustPressed(0, 38) then
                                OpenReception(name, motel)
                            end
                        end
                        local isOpen, text = lib.isTextUIOpen()
                        if isOpen and text == '[E] ' .. _L('openreception') then
                            lib.hideTextUI()
                        end
                    end
                end)
            end
        end

        for name, roomData in pairs(Config.Rooms) do
            for _, room in pairs(roomData) do
                local door = room.door
                local stash = room.stash
                local wardrobe = room.wardrobe

                if Config.Polyzone == 'PolyZone' then
                    local doorZone = CircleZone:Create(door.pos, door.radius, {
                        name = name .. '_door',
                        useZ = true,
                        debugPoly = Config.ToggleDebug,
                    })
                    local stashZone = CircleZone:Create(stash.pos, stash.radius, {
                        name = name .. '_stash',
                        useZ = true,
                        debugPoly = Config.ToggleDebug,
                    })
                    local wardrobeZone = CircleZone:Create(wardrobe.pos, wardrobe.radius, {
                        name = name .. '_wardrobe',
                        useZ = true,
                        debugPoly = Config.ToggleDebug,
                    })

                    doorZone:onPlayerInOut(function(onInsideOut)
                        if onInsideOut then
                            local pos = GetEntityCoords(PlayerPedId())
                            local uiText = ''
                            if Config.EnableRobbery and not Config.KeyItemUseable then
                                uiText = _L('pressbtn') .. ' [E] ' .. _L('unlockdoor') .. ' ' .. _L('pressbtn') .. ' [G] ' .. _L('lockpickdoor')
                            elseif Config.EnableRobbery and Config.KeyItemUseable then
                                uiText = _L('pressbtn') .. ' [G] ' .. _L('lockpickdoor')
                            else
                                uiText = _L('pressbtn') .. ' [E] ' .. _L('unlockdoor')
                            end
                            while #(pos - door.pos) <= door.radius do
                                Wait(0)
                                pos = GetEntityCoords(PlayerPedId())
                                lib.showTextUI(uiText)
                                if not Config.KeyItemUseable then
                                    if IsControlJustPressed(0, 38) then
                                        ToggleDoorHandler(name, room)
                                    end
                                end

                                if Config.EnableRobbery then
                                    if IsControlJustPressed(0, 47) then
                                        BreakinHandler(name, room)
                                    end
                                end
                            end
                            lib.hideTextUI()
                        end
                    end)

                    stashZone:onPlayerInOut(function(onInsideOut)
                        if onInsideOut then
                            local pos = GetEntityCoords(PlayerPedId())
                            if Config.StashProtection == 'citizenid' then
                                local PlayerData = QBCore.Functions.GetPlayerData()
                                local citizenid = PlayerData.citizenid

                                if citizenid == room.renter or PlayerData.job.type == 'leo' and PlayerData.job.onduty then
                                    while #(pos - stash.pos) <= stash.radius do
                                        Wait(0)
                                        pos = GetEntityCoords(PlayerPedId())
                                        lib.showTextUI(_L('pressbtn') .. ' [E] ' .. _L('openstash2'))
            
                                        if IsControlJustPressed(0, 38) then
                                            StashHandler(name, room)
                                        end
                                    end
                                    lib.hideTextUI()
                                end
                            else
                                while #(pos - stash.pos) <= stash.radius do
                                    Wait(0)
                                    pos = GetEntityCoords(PlayerPedId())
                                    lib.showTextUI(_L('pressbtn') .. ' [E] ' .. _L('openstash2'))
        
                                    if IsControlJustPressed(0, 38) then
                                        StashHandler(name, room)
                                    end
                                end
                                lib.hideTextUI()
                            end
                        end
                    end)

                    wardrobeZone:onPlayerInOut(function(onInsideOut)
                        if onInsideOut then
                            local pos = GetEntityCoords(PlayerPedId())
                            while #(pos - wardrobe.pos) <= wardrobe.radius do
                                Wait(0)
                                pos = GetEntityCoords(PlayerPedId())
                                lib.showTextUI(_L('pressbtn') .. ' [E] ' .. _L('openwardrobe2'))

                                if IsControlJustPressed(0, 38) then
                                    WardrobeHandler()
                                end
                            end
                            lib.hideTextUI()
                        end
                    end)
                end
            end
        end
    end)
end