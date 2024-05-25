Config = Config or {}

Config.AppearanceScript = 'qb-clothes' -- qb-clothes or illenium-appearance

Config.UseTarget = true -- Whether to use QB or OX Target or not
Config.EnableRobbery = true -- Make it possible to break into motel rooms!
Config.RestrictRooms = true -- If set to true, people can only rent 1 room at a time!
Config.RestrictMotels = true -- If set to true, people cna only buy 1 motel at a time!
Config.Lockpick = 'lockpick' -- Item to lockpick doors if Config.EnableRobbery is set to true!
Config.MotelKey = 'motelkey' -- The item used for motel keys!
Config.CopCount = 2 -- How many cops required to break into a motel room if Config.EnableRobbery is set to true!

Config.Motels = {
    ['davismotel'] = { -- The unique id of the motel!
        autoPayment = false, -- Whether payment will be taken from renters automatically or not. Can be changed by motel owners if buying motels is enabled!
        label = 'Davis Motel', -- Simply the name of the motel!
        coords = vector3(378.6, -1786.47, 29.52), -- Where the blink and reception will be located
        owner = '', -- Unless you want a permanent owner, leave nil.
        funds = 0, -- Leave 0 unless you want the start capital to be more than 0!
        price = 250000, -- The price to buy the motel itself! Leave nil if not for sale!
        roomprices = 250, -- Prices for each room each interval
        payInterval = 168, -- Interval for every payment in hours.
        keyPrice = 200 -- The price to get a new key if lost
    }
}

Config.Rooms = {
    ['davismotel'] = {
        {
            room = 'Room #1', -- Just the name of the room
            uniqueID = 'DavisMotel-davmotel_room1', -- Has to match the name of the DoorID in qb-doorlock Config!
            doorPos = vector3(372.21, -1791.48, 29.1), -- The location where the door is!
            stashPos = vector3(374.38, -1793.4, 29.23), -- The location of the stash for the player!
            wardrobePos = vector3(373.27, -1796.84, 29.23), -- The location of the wardrobe!
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
            uniqueID = 'DavisMotel-davmotel_room2',
            doorPos = vector3(367.39, -1802.31, 29.07),
            stashPos = vector3(369.11, -1799.98, 29.23),
            wardrobePos = vector3(372.96, -1801.27, 29.23),
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
            uniqueID = 'DavisMotel-davmotel_room3',
            doorPos = vector3(379.13, -1812.12, 29.05),
            stashPos = vector3(380.83, -1809.82, 29.23),
            wardrobePos = vector3(380.45, -1807.54, 29.23),
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
            uniqueID = 'DavisMotel-davmotel_room4',
            doorPos = vector3(380.82, -1813.24, 29.05),
            stashPos = vector3(382.24, -1811.04, 29.23),
            wardrobePos = vector3(387.44, -1811.24, 29.23),
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
            uniqueID = 'DavisMotel-davmotel_room5',
            doorPos = vector3(405.41, -1795.62, 29.09),
            stashPos = vector3(403.62, -1797.68, 29.23),
            wardrobePos = vector3(401.0, -1796.92, 29.23),
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
            uniqueID = 'DavisMotel-davmotel_room6',
            doorPos = vector3(398.25, -1789.61, 29.17),
            stashPos = vector3(396.36, -1791.8, 29.23),
            wardrobePos = vector3(396.36, -1791.8, 29.23),
            doorLocked = true,
            stashData = {
                weight = 100000,
                slots = 50,
            },
            renter = nil,
            renterName = '',
        },
    }
}

function Config.DoorlockAction(doorId, setLocked)
    TriggerServerEvent('qb-doorlock:server:updateState', doorId, setLocked, false, false, true, false, false)
end