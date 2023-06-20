local zoneId
local Core, CoreName
local allowAccess = false

if GetResourceState('qb-core') == 'started' then
    Core = exports['qb-core']:GetCoreObject()
    CoreName = 'qb'
elseif GetResourceState('es_extended') == 'starter' then
    Core = exports['es_extended']:getSharedObject()
    CoreName = 'esx'
else
    print('You arent using esx or qb, if you want payment to work use one of them.')
end

Functions = {}

Functions.qb = {}
Functions.qb.GetPlayer = function(src)
    return Core.Functions.GetPlayer(src)
end
Functions.qb.GetJob = function(player)
    return player.PlayerData.job.name 
end
Functions.esx = {}
Functions.esx.GetPlayer = function(src)
   return Core.GetPlayerFromId(src) 
end
Functions.esx.GetJob = function(player)
    return Core.PlayerData.job.name
end


---@param vertices vector3[]
---@return vector3
local function calculatePolyzoneCenter(vertices)
    local xSum = 0
    local ySum = 0
    local zSum = 0

    for i = 1, #vertices do
        xSum = xSum + vertices[i].x
        ySum = ySum + vertices[i].y
        zSum = zSum + vertices[i].z
    end

    local center = vec3(xSum / #vertices, ySum / #vertices, zSum / #vertices)

    return center
end

CreateThread(function()
    for _, v in ipairs(Config.Zones) do
        lib.zones.poly({
            points = v.points,
            onEnter = function(s)
                zoneId = s.id
                if not cache.vehicle then return end
                local hasJob = true
                if v.job and CoreName then
                    hasJob = false
                    local player = Functions[CoreName].player()
                    local playerJob = Functions[CoreName].GetJob(player)
                    for _, job in ipairs(v.job) do
                        if playerJob == job then
                            hasJob = true
                            break
                        end
                    end
                end

                allowAccess = hasJob
                if not hasJob then
                    return
                end

                lib.showTextUI('Press [E] to tune your car', {
                    icon = 'fa-solid fa-car',
                    position = 'left-center',
                })
            end,
            onExit = function()
                zoneId = nil
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustPressed(0, 38) and cache.vehicle and allowAccess then
                    SetEntityVelocity(cache.vehicle, 0.0, 0.0, 0.0)
                    lib.hideTextUI()
                    require('client.menus.main')()
                end
            end,
        })

        if not v.hideBlip then
            local center = calculatePolyzoneCenter(v.points)
            local blip = AddBlipForCoord(center.x, center.y, center.z)
            SetBlipSprite(blip, 72)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName('Customs')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

lib.callback.register('customs:client:zone', function()
    return zoneId
end)
