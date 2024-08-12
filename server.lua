local QBCore
local currentAdmins = {}
if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
    lib.addAce('group.admin', 'customs.admin')
else
    warn('qb-core is missing, modifications won\'t cost anything')
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
    if not QBCore then return true end
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
end

lib.callback.register('customs:server:checkPerms', function(source)
    if IsPlayerAceAllowed(source, 'customs.admin') then
        return true
    else
        return false
    end
end)

-- Won't charge money for mods if the player's job is in the list
lib.callback.register('customs:server:pay', function(source, mod, level)
    local zone = lib.callback.await('customs:client:zone', source)

    if currentAdmins[source] then
        if currentAdmins[source].admin then
            return true
        end
    end

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

    return removeMoney(source, getModPrice(mod, level))
end)

-- Won't charge money for repairs if the player's job is in the list
lib.callback.register('customs:server:repair', function(source, bodyHealth)
    local zone = lib.callback.await('customs:client:zone', source)

    if currentAdmins[source] then
        if currentAdmins[source].admin then
            return true
        end
    end

    for i, v in ipairs(Config.Zones) do
        if i == zone and v.freeRepair then
            local playerJob = QBCore.Functions.GetPlayer(source)?.PlayerData?.job?.name
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
    local vehicleProps = lib.callback.await('customs:client:vehicleProps', src)
    currentAdmins[src] = currentAdmins[src] or {}
    currentAdmins[src].admin = false
    if IsVehicleOwned(vehicleProps.plate) then
        MySQL.update.await('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
    end
end)

--Commands
lib.addCommand('admincustoms', {
    help = 'Toggle customs menu for admins',
    restricted = 'group.admin',
}, function(source, args, raw)
    currentAdmins[source] = currentAdmins[source] or {}
    currentAdmins[source].admin = true
    TriggerClientEvent('customs:client:adminMenu', source)
end)