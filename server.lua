local QBCore
local ESX
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif GetResourceState('es_extended') == 'started' then 
    ESX = exports["es_extended"]:getSharedObject()
else 
    warn('Framework is missing, modifications won\'t cost anything')
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
    if QBCore then 
        local player = QBCore.Functions.GetPlayer(source)
        local cashBalance = player.Functions.GetMoney('cash')
        local bankBalance = player.Functions.GetMoney('bank')

        if cashBalance >= amount then
            player.Functions.RemoveMoney('cash', amount, "Customs")
            return true
        elseif bankBalance >= amount then
            player.Functions.RemoveMoney('bank', amount, "Customs")
            lib.notify(source, {
                title = 'Customs',
                description = ('You paid $%s from your bank account'):format(amount),
                type = 'success',
            })
            return true
        end

        return false
    elseif ESX then 
        local xPlayer = ESX.GetPlayerFromId(source)
        local cashBalance = xPlayer.getMoney()
        local bankBalance = xPlayer.getAccount("bank").money 
        if cashBalance >= amount then 
            xPlayer.removeMoney(amount)
            return true 
        elseif bankBalance >= amount then 
            xPlayer.removeAccountMoney("bank", amount, "Custom")
            lib.notify(source, {
                title = 'Customs',
                description = ('You paid $%s from your bank account'):format(amount),
                type = 'success',
            })
            return true
        end 
        return false 
    else 
        return true
    end
end

-- Won't charge money for mods if the player's job is in the list
lib.callback.register('customs:server:pay', function(source, mod, level)
    local zone = lib.callback.await('customs:client:zone', source)
    if QBCore then 
        for i, v in ipairs(Config.Zones) do
            if i == zone and v.freeMods then
                local playerJob = QBCore.Functions.GetPlayer(source)?.PlayerData?.job?.name
                for _, job in ipairs(v.freeMods) do
                    if playerJob == job then
                        return true
                    end
                end
            end
        end
    elseif ESX then 
        for i, v in ipairs(Config.Zones) do
            if i == zone and v.freeMods then
                local xPlayers = ESX.GetExtendedPlayers() -- Returns all xPlayers
                for _, job in ipairs(v.freeMods) do
                    for _, xPlayer in pairs(xPlayers) do
                        if xPlayer.job.name == job then
                            return true
                        end
                    end 
                end
            end
        end
    end 

    return removeMoney(source, getModPrice(mod, level))
end)

-- Won't charge money for repairs if the player's job is in the list
lib.callback.register('customs:server:repair', function(source, bodyHealth)
    local zone = lib.callback.await('customs:client:zone', source)

    if QBCore then 
        for i, v in ipairs(Config.Zones) do
            if i == zone and v.freeMods then
                local playerJob = QBCore.Functions.GetPlayer(source)?.PlayerData?.job?.name
                for _, job in ipairs(v.freeMods) do
                    if playerJob == job then
                        return true
                    end
                end
            end
        end
    elseif ESX then 
        for i, v in ipairs(Config.Zones) do
            if i == zone and v.freeMods then
                local xPlayers = ESX.GetExtendedPlayers() -- Returns all xPlayers
                for _, job in ipairs(v.freeMods) do
                    for _, xPlayer in pairs(xPlayers) do
                        if xPlayer.job.name == job then
                            return true
                        end
                    end 
                end
            end
        end
    end 

    local price = math.ceil(1000 - bodyHealth)
    return removeMoney(source, price)
end)

local function IsVehicleOwned(plate)
    local result = MySQL.scalar.await('SELECT 1 from player_vehicles WHERE plate = ?', {plate})
    if result then
        return true
    else
        return false
    end
end

--Copied from qb-mechanicjob
RegisterNetEvent('customs:server:saveVehicleProps', function()
    local src = source --[[@as number]]
    local vehicleProps = lib.callback.await('customs:client:vehicle', src)
    if IsVehicleOwned(vehicleProps.plate) then
        MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
    end
end)
