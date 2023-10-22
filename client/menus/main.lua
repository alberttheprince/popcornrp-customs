mainLastIndex = 1
vehicle = 0
mainMenuId = 'customs-main'
local QBCore
local inMenu = false
local dragcam = require('client.dragcam')
local startDragCam = dragcam.startDragCam
local stopDragCam = dragcam.stopDragCam

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local menu = {
    id = mainMenuId,
    canClose = true,
    disableInput = false,
    title = 'Popcorn Customs',
    position = 'top-left',
    options = {},
}

local function main()
    if GetVehicleBodyHealth(vehicle) < 1000.0 then
        return {{
            label = 'Repair',
            description = ('%s%d'):format(Config.Currency, math.ceil(1000 - GetVehicleBodyHealth(vehicle))),
            close = true,
        }}
    end

    local options = {
        {
            label = 'Performance',
            close = true,
            args = {
                menu = 'client.menus.performance',
            }
        },
        {
            label = 'Cosmetics - Parts',
            close = true,
            args = {
                menu = 'client.menus.parts',
            }
        },
        {
            label = 'Cosmetics - Colors',
            close = true,
            args = {
                menu = 'client.menus.colors',
            }
        },
    }

    if DoesExtraExist(vehicle, 1) then
        options[#options + 1] = {
            label = 'Extras',
            close = true,
            args = {
                menu = 'client.menus.extras',
            }
        }
    end

    return options
end

local function disableControls()
    inMenu = true
    CreateThread(function()
        while inMenu do
            Wait(0)
            DisableControlAction(0, 71, true) -- accelerating
            DisableControlAction(0, 72, true) -- decelerating
            for i = 81, 85 do -- radio stuff
                DisableControlAction(0, i, true)
            end
            DisableControlAction(0, 106, true) -- turning vehicle wheels
        end
    end)
end

local function repair()
    local success = lib.callback.await('customs:server:repair', false, GetVehicleBodyHealth(vehicle))
    if success then
        lib.notify({
            title = 'Customs',
            description = 'Vehicle repaired!',
            position = 'top',
            type = 'success'
        })
        SendNUIMessage({sound = true})
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehicleEngineHealth(vehicle, 1000.0)
        local fuelLevel = GetVehicleFuelLevel(vehicle)
        SetVehicleFixed(vehicle)
        SetVehicleFuelLevel(vehicle, fuelLevel)
    else
        lib.notify({
            title = 'Customs',
            description = 'You don\'t have enough money!',
            position = 'top',
            type = 'error'
        })
    end

    menu.options = main()
    lib.setMenuOptions(menu.id, menu.options)
    lib.showMenu(menu.id, 1)
end

local function onSubmit(selected, scrollIndex, args)
    if menu.options[selected].label == 'Repair' then
        lib.hideMenu(false)
        repair()
        return
    end
    local menuId = require(args.menu)()
    lib.showMenu(menuId, 1)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    mainLastIndex = selected
end

menu.onClose = function()
    inMenu = false
    stopDragCam()
    lib.showTextUI('Press [E] to tune your car', {
        icon = 'fa-solid fa-car',
        position = 'left-center',
    })
    if QBCore then
        TriggerServerEvent("customs:server:saveVehicleProps")
    end
end

lib.callback.register('customs:client:vehicleProps', function()
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    return vehicleProps
end)

return function()
    if not cache.vehicle or inMenu then return end
    vehicle = cache.vehicle
    SetVehicleModKit(vehicle, 0)
    menu.options = main()
    lib.registerMenu(menu, onSubmit)
    lib.showMenu(menu.id, 1)
    disableControls()
    startDragCam(vehicle)
end
