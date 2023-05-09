local originalNeon = {}
local lastIndex = 1
local originalLabelIndex = 1

local function neon()
    local options = {}

    for i = 1, 4 do
        local enabled = IsVehicleNeonLightEnabled(vehicle, i - 1)
        originalNeon[i] = enabled

        options[i] = {
            label = ('Neon %s'):format(Config.Neon[i].label),
            description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
            values = {
                'Disabled',
                'Enabled',
            },
            close = true,
            defaultIndex = enabled and 2 or 1,
            set = function(index)
                SetVehicleNeonLightEnabled(vehicle, i - 1, index == 2)
                return ("Neon %s %s"):format(Config.Neon[i].label, index == 2 and 'enabled' or 'disabled')
            end,
            restore = function()
                SetVehicleNeonLightEnabled(vehicle, i - 1, originalNeon[i])
            end
        }
    end

    local r, g, b = GetVehicleNeonLightsColour(vehicle)

    local rgbValues = {}
    local neonLabels = {}
    for i, v in ipairs(Config.NeonColors) do
        neonLabels[i] = v.label
        rgbValues[i] = {r = v.r, g = v.g, b = v.b}
        if v.r == r and v.g == g and v.b == b then
            originalLabelIndex = i
        end
    end

    options[5] = {
        label = 'Neon color',
        close = true,
        values = neonLabels,
        rgbValues = rgbValues,
        set = function(index)
            local rgb = Config.NeonColors[index]
            SetVehicleNeonLightsColour(vehicle, rgb.r, rgb.g, rgb.b)
            return Config.NeonColors[index].label
        end,
        restore = function()
            local rgb = Config.NeonColors[originalLabelIndex]
            SetVehicleNeonLightsColour(vehicle, rgb.r, rgb.g, rgb.b)
        end,
        defaultIndex = originalLabelIndex,
    }

    return options
end

local menu = {
    id = 'customs-neon',
    canClose = true,
    disableInput = false,
    title = 'Neon',
    position = 'top-left',
    options = {},
}

local function onSubmit(selected, scrollIndex, args)
    local option = menu.options[selected]

    for _, v in pairs(menu.options) do
        v.restore()
    end

    local desc = option.set(scrollIndex)

    local success = require('client.utils.installMod')({
        description = desc,
    }, 'colors')

    if not success then menu.options[selected].restore() end

    lib.setMenuOptions(menu.id, neon())
    lib.showMenu(menu.id, lastIndex)
end

menu.onSideScroll = function(selected, scrollIndex)
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    local option = menu.options[selected]
    option.set(scrollIndex)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    lastIndex = selected
end

menu.onClose = function()
    for _, v in pairs(menu.options) do
        v.restore()
    end
    lib.showMenu('customs-colors', colorsLastIndex)
end

return function()
    menu.options = neon()
    lib.registerMenu(menu, onSubmit)
    return menu.id
end