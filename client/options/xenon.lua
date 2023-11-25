local originalXenon
local originalToggle

local function xenon()
    originalToggle = IsToggleModOn(vehicle, 22)
    originalXenon = GetVehicleXenonLightsColor(vehicle)
    originalXenon = originalXenon == 255 and -1 or originalXenon

    local xenonLabels = {Lang:t('menus.general.disabled')}
    for i, v in ipairs(Config.Xenon) do
        xenonLabels[i + 1] = v.label
    end

    local option = {
        id = 'xenon',
        label = Lang:t('menus.options.xenon.title'),
        description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
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

return xenon