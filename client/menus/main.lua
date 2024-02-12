mainLastIndex = 1
vehicle = 0
mainMenuId = 'customs-main'
local inMenu = false
local dragcam = require('client.dragcam')
local startDragCam = dragcam.startDragCam
local stopDragCam = dragcam.stopDragCam
local config = require 'config.client'

local menu = {
    id = mainMenuId,
    canClose = true,
    disableInput = false,
    title = Lang:t("menus.main.title"),
    position = 'top-left',
    options = {},
}

local function main()
    if GetVehicleBodyHealth(vehicle) < 1000.0 then
        return {{
            label = Lang:t('menus.main.repair'),
            description = ('%s%d'):format(config.currency, math.ceil(1000 - GetVehicleBodyHealth(vehicle))),
            close = true,
        }}
    end

    local options = {
        {
            label = Lang:t('menus.main.performance'),
            close = true,
            args = {
                menu = 'client.menus.performance',
            }
        },
        {
            label = Lang:t('menus.main.parts'),
            close = true,
            args = {
                menu = 'client.menus.parts',
            }
        },
        {
            label = Lang:t('menus.main.colors'),
            close = true,
            args = {
                menu = 'client.menus.colors',
            }
        },
    }

    if DoesExtraExist(vehicle, 1) then
        options[#options + 1] = {
            label = Lang:t('menus.main.extras'),
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
    local success = lib.callback.await('qbx_customs:server:repair', false, GetVehicleBodyHealth(vehicle))
    if success then
        exports.qbx_core:Notify(Lang:t('notifications.success.repaired'), 'success')
        SendNUIMessage({sound = true})
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehicleEngineHealth(vehicle, 1000.0)
        local fuelLevel = GetVehicleFuelLevel(vehicle)
        SetVehicleFixed(vehicle)
        SetVehicleFuelLevel(vehicle, fuelLevel)
    else
        exports.qbx_core:Notify(Lang:t('notifications.error.money'), 'error')
    end

    menu.options = main()
    lib.setMenuOptions(menu.id, menu.options)
    lib.showMenu(menu.id, 1)
end

local function onSubmit(selected, scrollIndex, args)
    if menu.options[selected].label == Lang:t('menus.main.repair') then
        lib.hideMenu(false)
        repair()
        return
    end
    local menuId = require(args.menu)()
    lib.showMenu(menuId, 1)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    mainLastIndex = selected
end

menu.onClose = function()
    inMenu = false
    stopDragCam()
    lib.showTextUI(Lang:t('textUI.tune'), {
        icon = 'fa-solid fa-car',
        position = 'left-center',
    })
    TriggerServerEvent('qbx_customs:server:saveVehicleProps')
end

lib.callback.register('qbx_customs:client:vehicleProps', function()
    return lib.getVehicleProperties(vehicle)
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
