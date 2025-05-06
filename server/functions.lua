local QBCore = exports['qb-core']:GetCoreObject()

if Config.KeyItemUseable then
    QBCore.Functions.CreateUseableItem(Config.Motelkey, function(source, item)
        local src = source
        local info = item.info
        TriggerClientEvent('motel:client:checkKeyZone', src, info.motel, info)
    end)
end