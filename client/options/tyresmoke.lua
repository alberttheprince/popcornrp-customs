local originalLabelIndex = 1

local function tyresmoke()
    ToggleVehicleMod(vehicle, 20, true)
    local r, g, b = GetVehicleTyreSmokeColor(vehicle)

    local rgbValues = {}
    local smokeLabels = {}
    for i, v in ipairs(Config.TyreSmoke) do
        smokeLabels[i] = v.label
        rgbValues[i] = {r = v.r, g = v.g, b = v.b}
        if v.r == r and v.g == g and v.b == b then
            originalLabelIndex = i
        end
    end

    local option = {
        id = 'tyre_smoke',
        label = 'Tyre smoke',
        description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
        close = true,
        values = smokeLabels,
        rgbValues = rgbValues,
        set = function(index)
            local rgb = Config.TyreSmoke[index]
            SetVehicleTyreSmokeColor(vehicle, rgb.r, rgb.g, rgb.b)
            return originalLabelIndex == index, ('%s installed'):format(Config.TyreSmoke[index].label)
        end,
        restore = function()
            local rgb = Config.TyreSmoke[originalLabelIndex]
            SetVehicleTyreSmokeColor(vehicle, rgb.r, rgb.g, rgb.b)
        end,
        defaultIndex = originalLabelIndex,
    }

    return option
end

return tyresmoke
