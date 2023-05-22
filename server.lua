local Core, CoreName
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    CoreName = 'qb'
elseif
    Core = exports["es_extended"]:getSharedObject()
    CoreName = 'esx'
else
    print('Core is missing nothing will cost')
end
Functions = {}

Functions.qb = {}
Functions.qb.GetPlayer = function(src)
    return Core.Functions.GetPlayer(src)
end
Functions.qb.Getmoney = function(player, type)
    return player.Functions.GetMoney(type)
end
Functions.qb.RemoveMoney = function(player, type, amount)
    return player.Functions.RemoveMoney(type, amount, "Customs")
end
Functions.qb.GetJob = function(player)
    return player.PlayerData.job.name 
end
Functions.qb.Owned = function(vehicleplate)
    local result = MySQL.salar.await('SELECT 1 from player_vehicles WHERE plate = ?', {plate})
    return result
end
Functions.qb.Update = function(vehicleplate)
    MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
end
Functions.esx = {}
Functions.esx.GetPlayer = function(src)
   return Core.GetPlayerFromId(src) 
end
Functions.esx.Getmoney = function(player, type)
    return player.getAccount(type).money
end
Functions.esx.RemoveMoney = function(player, type, amount)
    return player.removeAccountMoney(type, amount)
end
Functions.esx.GetJob = function(player)
    return player.getJob().name
end
Functions.esx.Owned = function(vehicleplate)
    local result = MySQL.salar.await('SELECT 1 from owned_vehicles WHERE plate = ?', {plate})
    return result
end
Functions.esx.Update = function(vehicleplate)
    MySQL.update('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
end

---@return number
local function getModPrice(mod, level)
    if mod == 'cosmetic' or mod == 'colors' or mod == 18 then
        return Config.Prices[mod] --[[@as number]]
    else
        return Config.Prices[mod][level]
    end
end

---@param source number
---@param amount number
---@return boolean
local function removeMoney(source, amount)
    if not CoreName then return true end
    local player = Functions[CoreName].GetPlayer(source)
    local cashBalance = Functions[CoreName].GetMoney(player, 'cash')
    local bankBalance = Functions[CoreName].GetMoney(player, 'bank')

    if cashBalance >= amount then
        Functions[CoreName].RemoveMoney(player, 'cash', amount)
        return true
    elseif bankBalance >= amount then
        Functions[CoreName].RemoveMoney(player, 'bank', amount)
        lib.notify(source, {
            title = 'Customs',
            description = ('You paid $%s from your bank account'):format(amount),
            type = 'success',
        })
        return true
    end

    return false
end

-- Won't charge money for mods if the player's job is in the list
lib.callback.register('customs:server:pay', function(source, mod, level)
    local zone = lib.callback.await('customs:client:zone', source)

    for i, v in ipairs(Config.Zones) do
        if i == zone and v.freeMods then
            local player = Functions[CoreName].GetPlayer(source)
            local playerJob = Functions[CoreName].GetJob(player)
            for _, job in ipairs(v.freeMods) do
                if playerJob == job then
                    return true
                end
            end
        end
    end

    return removeMoney(source, getModPrice(mod, level))
end)

-- Won't charge money for repairs if the player's job is in the list
lib.callback.register('customs:server:repair', function(source, bodyHealth)
    local zone = lib.callback.await('customs:client:zone', source)

    for i, v in ipairs(Config.Zones) do
        if i == zone and v.freeRepair then
            local player = Functions[CoreName].GetPlayer(source)
            local playerJob = Functions[CoreName].GetJob(player)
            for _, job in ipairs(v.freeRepair) do
                if playerJob == job then
                    return true
                end
            end
        end
    end

    local price = math.ceil(1000 - bodyHealth)
    return removeMoney(source, price)
end)


--Copied from qb-mechanicjob
RegisterNetEvent('customs:server:saveVehicleProps', function()
    local src = source --[[@as number]]
    local vehicleProps = lib.callback.await('customs:client:vehicle', src)
    if Functions[CoreName].Owned(vehicleProps.plate) then
        Fuctions[CoreName].Update(vehicleprops)
    end
end)
