Config = Config or {}
Config.Locale = 'en' -- Currently supported languages, which you can make as many you want as long the files are set up properly use existing as reference! Current supported(en, dk)

-- General Config --
Config.Framework = 'qbx' -- Compatible for QB and QBX
Config.UseTarget = 'ox_target' -- Whether you wanna use target, ox_target, qb-target or false if false will use polyzone
Config.Polyzone = 'PolyZone' -- Currently only use PolyZone
Config.KeyItemUseable = false -- Whether you wanna make it useable, if it's useable then will check if you're within a certain distance for the door to use the key to unlock(By using inventory useable!)
Config.EnableRobbery = true -- Whether you wanna make motel rooms robbable
Config.AllowPoliceRaids = true -- Whether you want cops to be able to raid motel rooms or not!
Config.RestrictRooms = true -- Whether you want the player to only rent 1 motel room at a time!
Config.RestrictMotels = true -- Whether you want the player to only be able to own 1 motel at a time!
Config.WipeStash = true -- Removes items in stash if room is no longere rented!
Config.AllowOwnerAutoPay = true -- Toggles whether the player who owns a motel can set autopay or not for their renters!
Config.StashProtection = 'password' -- Whether you wanna make some sort of protection for your motel stash!(password, citizenid or false)
Config.LostkeyReplaceAll = false -- Whether it should remove all keys from players and storages from a specific room if key has been reported lost(Aka a lock change)
Config.ToggleDebug = false -- Whether you wanna have debug enabled or not(For developers!)
Config.Motelkey = 'motelkey' -- The item for the motel room key!

-- Criminal Config --
Config.LockpickItem = 'lockpick' -- The item to lockpick motel rooms if Config.EnableRobbery is true!
Config.DoorRam = 'police_stormram' -- The item cops uses as a doorram when breaching doors
Config.LoseLockpickOnFail = true -- Whether the player will lose the lockpick if they fail lockpicking or not!
Config.AlertOnFail = true -- Whether the cops should be alerted on failed lockpicking or not, if false will use Config.AlarmChance for both success and fail!
Config.CopCount = 0 -- How many cops required to rob a motel room if Config.EnableRobbery is true
Config.LoseLockpickChance = 0 -- How high a chance for losing lockpick when breaking into a room
Config.AlarmChance = 75 -- How high a chance police will be alerted on a breakin!
Config.PicklockCircles = math.random(3, 5) -- How many circles for picklocking motel door!
Config.CircleTime = 10 -- How fast the circle goes, the lower, the faster.

-- Script Integration Config --
Config.DoorlockScript = 'ox_doorlock' -- Can use qb-doorlock or ox_doorlock

function Config.Appearance() -- How you wanna use appearance script client-sided!
    local QBCore = exports['qb-core']:GetCoreObject()
    if GetResourceState('illenium-appearance') == 'started' then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
    elseif GetResourceState('qb-clothing') == 'started' then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
    end
end

function Config.PoliceAlert() -- How you wanna use police alerts client-sided!
    local QBCore = exports['qb-core']:GetCoreObject()
    exports['ps-dispatch']:HouseRobbery()
end

function Config.Stash(name, stash, roomData, masterCode, coords) -- How you wanna handle stashes!
    local QBCore = exports['qb-core']:GetCoreObject()
    if GetResourceState('qs-inventory') == 'started' then
        QBCore.Functions.TriggerCallback('motel:getRooms', function(data)
            if data then
                for _, room in pairs(data) do
                    if room.uniqueID == roomData.uniqueID then
                        if room.password then
                            local info = lib.inputDialog('Insert Password', {
                                {
                                    type = 'input',
                                    label = _L('password'),
                                    description = _L('passwordeesc'),
                                }
                            })

                            if info[1] == room.password or masterCode and info[1] == tostring(masterCode) then
                                exports['qs-inventory']:RegisterStash(name .. '_' .. roomData.uniqueID, stash.slots, stash.weight, coords)
                            else
                                QBCore.Functions.Notify(_L('wrongpassword'), 'error', 3000)
                            end
                        else
                            exports['qs-inventory']:RegisterStash(name .. '_' .. roomData.uniqueID, stash.slots, stash.weight, coords)
                        end
                    end
                end
            else
                QBCore.Functions.Notify(_L('nodata'), 'error', 3000)
                return
            end
        end, name)
    elseif GetResourceState('qb-inventory') == 'started' then
        QBCore.Functions.TriggerCallback('motel:getRooms', function(data)
            if data then
                for _, room in pairs(data) do
                    if room.uniqueID == roomData.uniqueID then
                        if room.password then
                            local info = lib.inputDialog('Insert Password', {
                                {
                                    type = 'input',
                                    label = _L('password'),
                                    description = _L('passwordeesc'),
                                }
                            })

                            if info[1] == room.password or masterCode and info[1] == tostring(masterCode) then
                                TriggerServerEvent('motel:server:openStash', name .. '_' .. roomData.uniqueID, stash.slots, stash.weight, coords)
                            else
                                QBCore.Functions.Notify(_L('wrongpassword'), 'error', 3000)
                            end
                        else
                            TriggerServerEvent('motel:server:openStash', name .. '_' .. roomData.uniqueID, stash.slots, stash.weight, coords)
                        end
                    end
                end
            else
                QBCore.Functions.Notify(_L('nodata'), 'error', 3000)
                return
            end
        end, name)
    elseif GetResourceState('ox_inventory') == 'started' then
        QBCore.Functions.TriggerCallback('motel:getRooms', function(data)
            if data then
                for _, room in pairs(data) do
                    if room.uniqueID == roomData.uniqueID then
                        if room.password then
                            local info = lib.inputDialog('Insert Password', {
                                {
                                    type = 'input',
                                    label = _L('password'),
                                    description = _L('passwordeesc'),
                                }
                            })

                            if info[1] == room.password or masterCode and info[1] == tostring(masterCode) then
                                TriggerServerEvent('motel:server:openStash', name .. '_' .. roomData.uniqueID, stash.slots, stash.weight, coords)
                            else
                                QBCore.Functions.Notify(_L('wrongpassword'), 'error', 3000)
                            end
                        else
                            TriggerServerEvent('motel:server:openStash', name .. '_' .. roomData.uniqueID, stash.slots, stash.weight, coords)
                        end
                    end
                end
            else
                QBCore.Functions.Notify(_L('nodata'), 'error', 3000)
                return
            end
        end, name)
    elseif GetResourceState('origen_inventory') == 'started' then
        QBCore.Functions.TriggerCallback('motel:getRooms', function(data)
            if data then
                for _, room in pairs(data) do
                    if room.uniqueID == roomData.uniqueID then
                        if room.password then
                            local info = lib.inputDialog('Insert Password', {
                                {
                                    type = 'input',
                                    label = _L('password'),
                                    description = _L('passwordeesc'),
                                }
                            })

                            if info[1] == room.password or masterCode and info[1] == tostring(masterCode) then
                                TriggerServerEvent('motel:server:openStash', name .. '_' .. roomData.uniqueID, stash.slots, stash.weight, coords)
                                exports['origen_inventory']:openInventory('stash', name .. '_' .. roomData.uniqueID)
                            else
                                QBCore.Functions.Notify(_L('wrongpassword'), 'error', 3000)
                            end
                        else
                            exports['origen_inventory']:openInventory('stash', name .. '_' .. roomData.uniqueID)
                        end
                    end
                end
            else
                QBCore.Functions.Notify(_L('nodata'), 'error', 3000)
                return
            end
        end, name)
    end
end



-- Motels --
Config.Motels = {
    ['bayviewlodge'] = { -- The unique name for the motels, MUST BE UNIQUE!
        autoPayment = true, -- Only works if Config.AllowOwnerAutoPay is true
        buyable = true, -- Whether the motel is buyable by a player!
        label = 'Bayview Lodge', -- The name of the motel, can be anything!
        coords = vector3(-695.49, 5802.34, 17.33), -- The coords where the blip and reception will be!
        price = 250000, -- The price of the motel if buyable!
        roomprices = 250, -- Prices for each room each pay interval!
        payInterval = 168, -- How often players has to pay in hours!
        keyPrice = 200 -- The price to get a new key if lost!
    }
}

-- Motel Rooms --
Config.Rooms = {
    ['bayviewlodge'] = {
        {
            room = 'Room #1', -- A simple room label/name, can be named anything!
            uniqueID = 10, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-709.93, 5768.64, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-710.9, 5767.1, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-708.28, 5766.35, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #2', -- A simple room label/name, can be named anything!
            uniqueID = 11, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-705.99, 5766.84, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-707.02, 5765.28, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-704.39, 5764.47, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #3', -- A simple room label/name, can be named anything!
            uniqueID = 12, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-702.05, 5764.89, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-703.13, 5763.57, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-700.49, 5762.6, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #4', -- A simple room label/name, can be named anything!
            uniqueID = 13, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-698.3, 5763.1, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-699.13, 5761.7, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-696.6, 5760.69, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #5', -- A simple room label/name, can be named anything!
            uniqueID = 14, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-694.27, 5761.33, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-695.21, 5759.83, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-692.63, 5758.99, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #6', -- A simple room label/name, can be named anything!
            uniqueID = 15, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-690.19, 5759.47, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-691.32, 5758.1, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-688.68, 5757.18, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #7', -- A simple room label/name, can be named anything!
            uniqueID = 16, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-687.28, 5759.05, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-686.01, 5758.0, 17.53), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-685.0, 5760.52, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #8', -- A simple room label/name, can be named anything!
            uniqueID = 17, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-685.6, 5762.86, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-684.0, 5761.85, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-683.28, 5764.48, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #9', -- A simple room label/name, can be named anything!
            uniqueID = 18, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-683.74, 5766.82, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-682.25, 5765.81, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-681.48, 5768.42, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
        {
            room = 'Room #10', -- A simple room label/name, can be named anything!
            uniqueID = 19, -- A uniqueID for the doorlock must match the doorid for the selected doorlock script!
            isLocked = true, -- Whether the motel room is locked by default or not!
            door = {
                pos = vector3(-681.79, 5770.84, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            stash = {
                pos = vector3(-680.58, 5769.72, 17.52), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
                weight = 100000, -- How much weight stash should have!
                slots = 50, -- How many slots stash should have!
            },
            wardrobe = {
                pos = vector3(-679.41, 5772.27, 17.51), -- The position to stand for door!
                radius = 0.8, -- Radius for target!
                polyRadius = 1.5, -- If using polyzones then how big the polyzone is!
            },
            renter = nil, -- Leave nil unless you want a default renter then add CitizenID
            renterName = '', -- Leave this blank! Unless you want a default renter!
        },
    }
}

function Config.DoorlockAction(doorId, setLocked)
    if Config.DoorlockScript == 'qb-doorlock' then
        TriggerServerEvent('qb-doorlock:server:updateState', doorId, setLocked, false, false, true, false, false)
    elseif Config.DoorlockScript == 'ox_doorlock' then
        TriggerServerEvent('jc-motel:server:setDoorStateOx', doorId, setLocked)
    end
end