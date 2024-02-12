colorsLastIndex = 1
local originalXenon
local originalToggle
local originalPearlescent, originalWheelColor
local originalWindowTint
local originalLabelIndex = 1
local originalInterior
local originalLivery = {}
local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function xenon()
    originalToggle = IsToggleModOn(vehicle, 22)
    originalXenon = GetVehicleXenonLightsColor(vehicle)
    originalXenon = originalXenon == 255 and -1 or originalXenon

    local xenonLabels = {Lang:t('menus.general.disabled')}
    for i, v in ipairs(config.xenon) do
        xenonLabels[i + 1] = v.label
    end

    local option = {
        id = 'xenon',
        label = Lang:t('menus.options.xenon.title'),
        description = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        close = true,
        values = xenonLabels,
        set = function(index)
            if index == 1 then
                ToggleVehicleMod(vehicle, 22, false)
                return 'Disabled'
            end
            ToggleVehicleMod(vehicle, 22, true)
            SetVehicleXenonLightsColor(vehicle, index - 3)
            return originalXenon == index - 3,Lang:t('menus.options.xenon.installed', {color = xenonLabels[index]})
        end,
        restore = function()
            ToggleVehicleMod(vehicle, 22, originalToggle)
            SetVehicleXenonLightsColor(vehicle, originalXenon)
        end,
        defaultIndex = not originalToggle and 1 or originalXenon + 3,
    }

    return option
end

local function pearlescent()
    originalPearlescent, originalWheelColor = GetVehicleExtraColours(vehicle)
    local defaultIndex = 1
    local ids = {}
    local labels = {}

    for i, colour in ipairs(config.paints.Classic) do
        ids[i] = colour.id
        labels[i] = colour.label
        if colour.id == originalPearlescent then
            defaultIndex = i
        end
    end

    local size = #ids
    for i, colour in ipairs(config.paints.Chameleon) do
        ids[size + i] = colour.id
        labels[size + i] = colour.label
        if colour.id == originalPearlescent then
            defaultIndex = size + i
        end
    end

    local option = {
        id = 'pearlescent',
        label = Lang:t('menus.options.pearlescent'),
        description = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        ids = ids,
        values = labels,
        close = true,
        set = function(index)
            SetVehicleExtraColours(vehicle, ids[index], originalWheelColor)
            return originalPearlescent == ids[index], ('%s applied'):format(labels[index])
        end,
        restore = function()
            SetVehicleExtraColours(vehicle, originalPearlescent, originalWheelColor)
        end,
        defaultIndex = defaultIndex,
    }

    return option
end

local function wheelcolor()
    originalPearlescent, originalWheelColor = GetVehicleExtraColours(vehicle)
    local defaultIndex = 1
    local ids = {}
    local labels = {}

    for i, color in ipairs(config.paints.Classic) do
        ids[i] = color.id
        labels[i] = color.label
        if color.id == originalWheelColor then
            defaultIndex = i
        end
    end

    local option = {
        id = 'wheelcolor',
        label = Lang:t('menus.options.wheelColor'),
        description = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        ids = ids,
        values = labels,
        close = true,
        set = function(index)
            SetVehicleExtraColours(vehicle, originalPearlescent, ids[index])
            return originalWheelColor == ids[index], Lang:t('menus.general.applied', {element = labels[index]})
        end,
        restore = function()
            SetVehicleExtraColours(vehicle, originalPearlescent, originalWheelColor)
        end,
        defaultIndex = defaultIndex,
    }

    return option
end

local function windowTint()
    originalWindowTint = GetVehicleWindowTint(vehicle)

    local windowTintLabels = {}
    for i, v in ipairs(config.windowTints) do
        windowTintLabels[i] = v.label
    end

    local option = {
        id = 'window_tint',
        label = Lang:t('menus.options.windowTint.title'),
        description = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        close = true,
        values = windowTintLabels,
        set = function(index)
            SetVehicleWindowTint(vehicle, index - 1)
            return originalWindowTint == index - 1, Lang:t('menus.options.windowTint.installed', {window = windowTintLabels[index]})
        end,
        restore = function()
            SetVehicleWindowTint(vehicle, originalWindowTint)
        end,
        defaultIndex = originalWindowTint + 1,
    }

    return option
end

local function tyresmoke()
    ToggleVehicleMod(vehicle, 20, true)
    local r, g, b = GetVehicleTyreSmokeColor(vehicle)

    local rgbValues = {}
    local smokeLabels = {}
    for i, v in ipairs(config.tyreSmoke) do
        smokeLabels[i] = v.label
        rgbValues[i] = {r = v.r, g = v.g, b = v.b}
        if v.r == r and v.g == g and v.b == b then
            originalLabelIndex = i
        end
    end

    local option = {
        id = 'tyre_smoke',
        label = Lang:t('menus.options.tyreSmoke'),
        description = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        close = true,
        values = smokeLabels,
        rgbValues = rgbValues,
        set = function(index)
            local rgb = config.tyreSmoke[index]
            SetVehicleTyreSmokeColor(vehicle, rgb.r, rgb.g, rgb.b)
            return originalLabelIndex == index, Lang:t('menus.general.installed', {element = config.tyreSmoke[index].label})
        end,
        restore = function()
            local rgb = config.tyreSmoke[originalLabelIndex]
            SetVehicleTyreSmokeColor(vehicle, rgb.r, rgb.g, rgb.b)
        end,
        defaultIndex = originalLabelIndex,
    }

    return option
end

local function interior()
    originalInterior = GetVehicleInteriorColor(vehicle)

    local interiorLabels = {}
    local interiorIds = {}
    local defaultIndex = 0

    for i, v in ipairs(config.paints.Classic) do
        interiorLabels[i] = v.label
        interiorIds[i] = v.id
        if v.id == originalInterior then
            defaultIndex = i
        end
    end

    local option = {
        id = 'interior',
        label = Lang:t('menus.options.interior'),
        description = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        close = true,
        values = interiorLabels,
        set = function(index)
            SetVehicleInteriorColor(vehicle, interiorIds[index])
        end,
        restore = function()
            SetVehicleInteriorColor(vehicle, originalInterior)
        end,
        defaultIndex = defaultIndex,
    }


    return option
end

local function livery()
    local oldLiveryMethod = GetVehicleLivery(vehicle)
    local newLiveryMethod = GetVehicleMod(vehicle, 48)

    if newLiveryMethod >= 0 or oldLiveryMethod == -1 then
        originalLivery = {
            index = newLiveryMethod,
            old = false
        }
    else
        originalLivery = {
            index = oldLiveryMethod,
            old = true
        }
    end

    local liveryLabels = {}
    if originalLivery.old then
        local liveryCount = GetVehicleLiveryCount(vehicle) - 1
        for i = 0, liveryCount do
            liveryLabels[i + 1] = ('%s %d'):format(Lang:t('menus.options.livery'), i + 1)
        end
    else
        liveryLabels[1] = Lang:t('menus.general.stock')
        local liveryCount = GetNumVehicleMods(vehicle, 48) - 1
        for i = 0, liveryCount do
            liveryLabels[i + 2] = ('%s'):format(GetLabelText(GetModTextLabel(vehicle, 48, i)))
        end
    end

    local option = {
        id = 'livery',
        label = Lang:t('menus.options.livery'),
        description = ('%s%s'):format(config.currency, sharedConfig.prices['colors']),
        close = true,
        values = liveryLabels,
        set = function(index)
            if originalLivery.old then
                SetVehicleLivery(vehicle, index - 1)
                return originalLivery.index == index - 1, Lang:t('menus.general.installed', {element = liveryLabels[index]})
            else
                SetVehicleMod(vehicle, 48, index - 2, false)
                return originalLivery.index == index - 2, Lang:t('menus.general.installed', {element = liveryLabels[index]})
            end
        end,
        restore = function()
            if originalLivery.old then
                SetVehicleLivery(vehicle, originalLivery.index)
            else
                SetVehicleMod(vehicle, 48, originalLivery.index, false)
            end
        end,
        defaultIndex = originalLivery.old and originalLivery.index + 1 or originalLivery.index + 2,
    }


    return option
end

local function colors()
    local options = {}

    options[#options + 1] = {
        label = Lang:t('menus.colors.primary'),
        close = true,
        args = {
            menu = 'client.menus.paint',
            menuArgs = {
                true,
            }
        }
    }

    options[#options + 1] = {
        label = Lang:t('menus.colors.secondary'),
        close = true,
        args = {
            menu = 'client.menus.paint',
            menuArgs = {
                false,
            }
        }
    }

    options[#options + 1] = {
        label = Lang:t('menus.colors.neon'),
        close = true,
        args = {
            menu = 'client.menus.neon',
        }
    }

    options[#options + 1] = xenon()
    options[#options + 1] = pearlescent()
    options[#options + 1] = wheelcolor()
    options[#options + 1] = windowTint()
    options[#options + 1] = tyresmoke()
    options[#options + 1] = interior()

    local liveryOption = livery()
    if #liveryOption.values > 0 then
        options[#options + 1] = liveryOption
    end

    table.sort(options, function(a, b)
        return a.label < b.label
    end)

    return options
end

local menu = {
    id = 'customs-colors',
    title = Lang:t('menus.colors.cosmetics_colors'),
    canClose = true,
    disableInput = false,
    options = {},
    position = 'top-left',
}

local function onSubmit(selected, scrollIndex, args)
    for _, v in pairs(menu.options) do
        if not v.args?.menu then v.restore() end
    end

    local subMenuName = args?.menu
    if subMenuName then
        local menuId = require(subMenuName)(args?.menuArgs and table.unpack(args.menuArgs))
        lib.showMenu(menuId, 1)
        return
    end


    local duplicate, desc = menu.options[selected].set(scrollIndex)

    local success = InstallMod(duplicate, 'colors', {
        description = desc,
        icon = 'fa-solid fa-spray-can',
    })

    if not success then menu.options[selected].restore() end

    lib.setMenuOptions(menu.id, colors())
    lib.showMenu(menu.id, colorsLastIndex)
end

menu.onSideScroll = function(selected, scrollIndex)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    local option = menu.options[selected]
    option.set(scrollIndex)
end

menu.onClose = function()
    for _, v in pairs(menu.options) do
        if not v.args?.menu then v.restore() end -- v.args.menu means it's a submenu
    end
    lib.showMenu(mainMenuId, mainLastIndex)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    colorsLastIndex = selected
end

return function()
    menu.options = colors()
    lib.registerMenu(menu, onSubmit)
    return menu.id
end