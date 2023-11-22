local Qbox
if GetResourceState('qbx_core') == 'started' then
    Qbox = true
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
    if not Qbox then return true end
    local player = exports.qbx_core:GetPlayer(source)
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

-- Won't charge money for mods if the player's job is in the list
lib.callback.register('customs:server:pay', function(source, mod, level)
    local zone = lib.callback.await('customs:client:zone', source)

    for i, v in ipairs(Config.Zones) do
        if i == zone and v.freeMods then
            local playerJob = exports.qbx_core:GetPlayer(source)?.PlayerData?.job?.name
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
            local playerJob = exports.qbx_core:GetPlayer(source)?.PlayerData?.job?.name
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
    local result = exports.oxmysql.scalar_async('SELECT 1 from player_vehicles WHERE plate = ?', {plate})
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
    if IsVehicleOwned(vehicleProps.plate) then
        exports.oxmysql.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
    end
end)