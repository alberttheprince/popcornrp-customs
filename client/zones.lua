local zoneId
local allowAccess = false
local sharedConfig = require 'config.shared'

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
    for _, v in ipairs(sharedConfig.zones) do
        lib.zones.poly({
            points = v.points,
            onEnter = function(s)
                zoneId = s.id
                if not cache.vehicle then return end
                local hasJob = true
                if v.job and QBX?.PlayerData then
                    hasJob = false
                    local playerJob = QBX.PlayerData.job.name
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

                lib.showTextUI(locale('textUI.tune'), {
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
            SetBlipSprite(blip, v.blip.sprite or 72)
            SetBlipColour(blip, v.blip.color or 4)
            SetBlipScale(blip, v.blip.scale or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.blip.label or 'Customs')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

lib.callback.register('qbx_customs:client:zone', function()
    return zoneId
end)
