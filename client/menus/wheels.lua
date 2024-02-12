local originalWheelType
local originalMod
local originalRearWheel
local lastIndex = 1
local WheelType = require('client.enums.WheelType')
local VehicleClass = require('client.enums.VehicleClass')
local config = require 'config.client'
local sharedConfig = require 'config.shared'

---@param wheelType WheelType
local function isWheelTypeAllowed(wheelType)
    local class = GetVehicleClass(vehicle)
    if class == VehicleClass.Cycles then return false end

    if class == VehicleClass.Motorcycles then
        if wheelType == WheelType.Bike then
            return true
        end
        return false
    end

    if class == VehicleClass.OpenWheels then
        if wheelType == WheelType.OpenWheel then
            return true
        end
        return false
    end
    return true
end

local function wheels()
    local options = {}

    originalWheelType = GetVehicleWheelType(vehicle)
    originalMod = GetVehicleMod(vehicle, 23)

    for _, category in ipairs(config.wheels) do
        if not isWheelTypeAllowed(category.id) then goto continue end
        SetVehicleWheelType(vehicle, category.id)
        local modCount = GetNumVehicleMods(vehicle, 23)
        local labels = {}
        for j = 1, modCount do
            labels[j] = GetLabelText(GetModTextLabel(vehicle, 23, j - 1))
        end

        options[#options + 1] = {
            id = category.id,
            label = category.label,
            description = ('%s%s'):format(config.currency, sharedConfig.prices['cosmetic']),
            values = labels,
            close = true,
            set = function(wheelType, index)
                SetVehicleWheelType(vehicle, wheelType)
                SetVehicleMod(vehicle, 23, index - 1, false)
            end,
            defaultIndex = originalWheelType == category.id and originalMod + 1 or 1
        }

        if GetVehicleClass(vehicle) == VehicleClass.Motorcycles then
            originalRearWheel = GetVehicleMod(vehicle, 24)
            options[#options + 1] = {
                id = 'rear',
                label = locale('menus.wheels.bikeRear'),
                values = labels,
                close = true,
                set = function(_, index)
                    SetVehicleWheelType(vehicle, 6)
                    SetVehicleMod(vehicle, 24, index - 1, false)
                end,
                defaultIndex = originalWheelType == 6 and originalRearWheel + 1 or 1,
            }
        end

        ::continue::
    end

    SetVehicleWheelType(vehicle, originalWheelType)

    table.sort(options, function(a, b)
        if a.id == 'rear' then return false end
        return a.label < b.label
    end)

    return options
end

local menu = {
    id = 'customs-wheels',
    canClose = true,
    disableInput = false,
    title = locale('menus.wheels.title'),
    position = 'top-left',
    options = {}
}

local function onSubmit(selected, scrollIndex)
    local option = menu.options[selected]
    local label = option.values[scrollIndex]
    local duplicate = option.id == originalWheelType and scrollIndex - 1 == originalMod

    if option.id == 6 then
        SetVehicleMod(vehicle, 24, originalRearWheel, false)
    elseif option.id == 'rear' then
        SetVehicleMod(vehicle, 23, originalMod, false)
    end

    local success = InstallMod(duplicate, 'cosmetic', {
        description = locale('menus.wheels.installed', option.label, label),
    })

    if not success then
        SetVehicleWheelType(vehicle, originalWheelType)
        SetVehicleMod(vehicle, 23, originalMod, false)
        SetVehicleMod(vehicle, 24, originalRearWheel, false)
    end

    lib.setMenuOptions(menu.id, wheels())
    lib.showMenu(menu.id, lastIndex)
end

menu.onSideScroll = function(selected, scrollIndex)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    local option = menu.options[selected]
    option.set(option.id, scrollIndex)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    lastIndex = selected
end

menu.onClose = function()
    SetVehicleWheelType(vehicle, originalWheelType)
    SetVehicleMod(vehicle, 23, originalMod, false)
    SetVehicleMod(vehicle, 24, originalRearWheel, false)
    lib.showMenu('customs-parts', partsLastIndex)
end

return function()
    menu.options = wheels()
    lib.registerMenu(menu, onSubmit)
    return menu.id
end