Config = Config or {}

Config.Framework = 'qbx' -- qbcore or qbx
Config.Debug = true -- For developers and troubleshooting issues
Config.UseTarget = true -- Whether to use QB or OX Target or not
Config.EnableRobbery = true -- Make it possible to break into motel rooms!
Config.RestrictRooms = false -- If set to true, people can only rent 1 room at a time!
Config.RestrictMotels = true -- If set to true, people cna only buy 1 motel at a time!
Config.WipeStash = true -- Remove stash when room is no longere rented!
Config.AllowAutoPay = false -- Allow people to enable automatic payment for their motel or not!
Config.Lockpick = 'lockpick' -- Item to lockpick doors if Config.EnableRobbery is set to true!
Config.MotelKey = 'motelkey' -- The item used for motel keys!
Config.CopCount = 0 -- How many cops required to break into a motel room if Config.EnableRobbery is set to true!
Config.LockpickLoseChance = 0 -- How high chance to lose lockpick when breaking into house(Can be set to 100 and 0)
Config.SuccessAlarmChance = 75 -- How high a chance police alert will be reported if lockpicking a motel room is succeesfull.
Config.AppearanceScript = 'qb-clothes' -- qb-clothes or illenium-appearance
Config.PoliceAlert = 'qbdefault' -- The current modules are; 'qbdefault', 'ps-dispatch'
Config.DoorlockSystem = 'ox' -- Current options are; 'qb', 'ox'
Config.InventorySystem = 'ox' -- qb, qs, ox or ps
Config.TargetScript = 'ox' -- What targetting script you're currently using! 'qb', 'ox'
Config.PolyZone = 'ox' -- What polyzone script system to use 'PolyZone' or 'ox' Only if Config.UseTarget is set to false

Config.Motels = {
    ['bayviewlodge'] = { -- The unique id of the motel!
        autoPayment = false, -- Whether payment will be taken from renters automatically or not. Can be changed by motel owners if buying motels is enabled!
        label = 'Bayview Lodge', -- Simply the name of the motel!
        coords = vector3(-695.44, 5802.24, 17.33), -- Where the blink and reception will be located
        owner = nil, -- Unless you want a permanent owner, leave nil.
        funds = 0, -- Leave 0 unless you want the start capital to be more than 0!
        price = 250000, -- The price to buy the motel itself! Leave nil if not for sale!
        roomprices = 250, -- Prices for each room each interval
        payInterval = 168, -- Interval for every payment in hours.
        keyPrice = 200 -- The price to get a new key if lost
    },
    ['davis_motel'] = { -- The unique id of the motel!
        autoPayment = false, -- Whether payment will be taken from renters automatically or not. Can be changed by motel owners if buying motels is enabled!
        label = 'Bayview Lodge', -- Simply the name of the motel!
        coords = vector3(378.37, -1786.27, 29.52), -- Where the blink and reception will be located
        owner = nil, -- Unless you want a permanent owner, leave nil.
        funds = 0, -- Leave 0 unless you want the start capital to be more than 0!
        price = 250000, -- The price to buy the motel itself! Leave nil if not for sale!
        roomprices = 250, -- Prices for each room each interval
        payInterval = 168, -- Interval for every payment in hours.
        keyPrice = 200 -- The price to get a new key if lost
    },
}

Config.Rooms = {
    ['bayviewlodge'] = {
        {
            room = 'Room #1', -- Just the name of the room
            uniqueID = 1, -- Has to match the name of the DoorID in qb-doorlock or ox doorid Config!
            doorPos = vector3(-710.1, 5768.33, 17.83), -- The location where the door is!
            stashPos = vector3(-716.68, 5772.8, 17.65), -- The location of the stash for the player!
            wardrobePos = vector3(-711.36, 5780.36, 17.44), -- The location of the wardrobe!
            doorLocked = true, -- Whether the door starts locked or not, need to be set the same as in the qb-doorlock Config file!
            stashData = {
                weight = 100000, -- The amount of weight 100000 = 100 KG
                slots = 50, -- The amount of slots you wanna give your players!
            },
            renter = nil, -- Unless you want a permanent renter, leave nil.
            renterName = '', -- Leave this be blank!
        },
        {
            room = 'Room #2',
            uniqueID = 2,
            doorPos = vector3(-706.13, 5766.45, 17.9),
            stashPos = vector3(-710.92, 5767.11, 17.52),
            wardrobePos = vector3(-708.26, 5766.27, 17.51),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
        {
            room = 'Room #3',
            uniqueID = 3,
            doorPos = vector3(-701.97, 5764.45, 17.85),
            stashPos = vector3(-703.03, 5763.54, 17.52),
            wardrobePos = vector3(-700.47, 5762.65, 17.51),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
        {
            room = 'Room #4',
            uniqueID = 4,
            doorPos = vector3(-698.17, 5762.66, 17.57),
            stashPos = vector3(-699.14, 5761.63, 17.52),
            wardrobePos = vector3(-696.47, 5760.87, 17.51),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
        {
            room = 'Room #5',
            uniqueID = 5,
            doorPos = vector3(-694.21, 5760.81, 17.73),
            stashPos = vector3(-695.26, 5759.95, 17.52),
            wardrobePos = vector3(-692.68, 5758.77, 17.51),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
        {
            room = 'Room #6',
            uniqueID = 6,
            doorPos = vector3(-690.32, 5759.05, 17.72),
            stashPos = vector3(-691.24, 5758.05, 17.52),
            wardrobePos = vector3(-688.65, 5757.24, 17.51),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
        {
            room = 'Room #7',
            uniqueID = 7,
            doorPos = vector3(-686.83, 5759.16, 17.69),
            stashPos = vector3(-685.94, 5757.91, 17.53),
            wardrobePos = vector3(-684.95, 5760.49, 17.53),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
        {
            room = 'Room #8',
            uniqueID = 8,
            doorPos = vector3(-685.47, 5762.31, 17.86),
            stashPos = vector3(-684.03, 5761.77, 17.52),
            wardrobePos = vector3(-683.14, 5764.42, 17.52),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
        {
            room = 'Room #9',
            uniqueID = 9,
            doorPos = vector3(-683.56, 5766.36, 17.94),
            stashPos = vector3(-682.31, 5765.86, 17.52),
            wardrobePos = vector3(-681.38, 5768.38, 17.52),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
        {
            room = 'Room #10',
            uniqueID = 10,
            doorPos = vector3(-681.44, 5770.66, 17.81),
            stashPos = vector3(-680.64, 5769.72, 17.52),
            wardrobePos = vector3(-679.62, 5772.33, 17.51),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
    },
    ['davis_motel'] = {
        {
            room = 'Room #1', -- Just the name of the room
            uniqueID = 8, -- Has to match the name of the DoorID in qb-doorlock or ox doorid Config!
            doorPos = vector3(398.41, -1790.32, 29.38), -- The location where the door is!
            stashPos = vector3(390.34, -1787.94, 29.23), -- The location of the stash for the player!
            wardrobePos = vector3(393.69, -1790.97, 29.23), -- The location of the wardrobe!
            doorLocked = true, -- Whether the door starts locked or not, need to be set the same as in the qb-doorlock Config file!
            stashData = {
                weight = 100000, -- The amount of weight 100000 = 100 KG
                slots = 50, -- The amount of slots you wanna give your players!
            },
            renter = nil, -- Unless you want a permanent renter, leave nil.
            renterName = '', -- Leave this be blank!
        },
    },
}

function Config.DoorlockAction(doorId, setLocked)
    if Config.DoorlockSystem == 'qb' then
        TriggerServerEvent('qb-doorlock:server:updateState', doorId, setLocked, false, false, true, false, false)
    elseif Config.DoorlockSystem == 'ox' then
        TriggerServerEvent('jc-motels:server:setDoorStateOx', doorId, setLocked)
    end
end