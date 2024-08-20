local zoneId
local QBCore
local allowAccess = false
MENUOPEN = false
PROMPTOPEN = false

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
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
                if v.job and QBCore then
                    hasJob = false
                    local playerJob = QBCore.Functions.GetPlayerData().job.name
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
                PROMPTOPEN = true
            end,
            onExit = function()
                zoneId = nil
                lib.hideTextUI()
                MENUOPEN = false
                PROMPTOPEN = false
            end,
            inside = function()
                --[[if IsControlJustPressed(0, 38) and cache.vehicle and allowAccess then
                    SetEntityVelocity(cache.vehicle, 0.0, 0.0, 0.0)
                    lib.hideTextUI()
                    MENUOPEN = true
                    require('client.menus.main')()
                end]]--
                
                    if not PROMPTOPEN and IsPedInAnyVehicle(PlayerPedId(), false) then
                        lib.showTextUI('Press [E] to tune your car', {
                            icon = 'fa-solid fa-car',
                            position = 'left-center',
                        })
                        PROMPTOPEN = true
                    end
                    if  PROMPTOPEN and not IsPedInAnyVehicle(PlayerPedId(), false) then
                        lib.hideTextUI()
                        PROMPTOPEN = false
                    end
                    if IsControlJustPressed(0, 38) and IsPedInAnyVehicle(PlayerPedId(), false) and allowAccess then
                        SetEntityVelocity(cache.vehicle, 0.0, 0.0, 0.0)
                        lib.hideTextUI()
                        MENUOPEN = true
                        require('client.menus.main')()
                    end
                    Wait(10)
            end,
        })

        if not v.hideBlip then
            local center = calculatePolyzoneCenter(v.points)
            local blip = AddBlipForCoord(center.x, center.y, center.z)
            SetBlipSprite(blip, 72)
            SetBlipColour(blip, v.blipColor or 0)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.blipLabel or 'Customs')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

lib.callback.register('customs:client:zone', function()
    return zoneId
end)

RegisterNetEvent('customs:client:adminMenu', function()
    local perm = lib.callback.await('customs:server:checkPerms')
    if perm then
        SetEntityVelocity(cache.vehicle, 0.0, 0.0, 0.0)
        require('client.menus.main')()
    else
        lib.notify({
            title = 'Customs',
            description = 'Cound not access menu or no vehicle present',
            position = 'top',
            type = 'error'
        })
    end
end)