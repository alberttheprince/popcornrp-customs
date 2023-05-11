local originalPearlescent, originalWheelColor

local function wheelcolor()
    originalPearlescent, originalWheelColor = GetVehicleExtraColours(vehicle)
    local defaultIndex = 1
    local ids = {}
    local labels = {}

    for i, color in ipairs(Config.Paints.Classic) do
        ids[i] = color.id
        labels[i] = color.label
        if color.id == originalWheelColor then
            defaultIndex = i
        end
    end

    local option = {
        id = 'wheelcolor',
        label = 'Wheel color',
        description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
        ids = ids,
        values = labels,
        close = true,
        set = function(index)
            SetVehicleExtraColours(vehicle, originalPearlescent, ids[index])
            return originalWheelColor == ids[index], ('%s applied'):format(labels[index])
        end,
        restore = function()
            SetVehicleExtraColours(vehicle, originalPearlescent, originalWheelColor)
        end,
        defaultIndex = defaultIndex,
    }

    return option
end

return wheelcolor
