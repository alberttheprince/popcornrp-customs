local originalPearlescent, originalWheelColor

local function wheelcolor()
    originalPearlescent, originalWheelColor = GetVehicleExtraColours(vehicle)
    local defaultIndex = 1
    local ids = {}
    local labels = {}

    local categories = { 'Classic', 'Matte', 'Metal', 'Chameleon' }

    local index = 0
    for _, category in ipairs(categories) do
        if Config.Paints[category] then
            for _, color in ipairs(Config.Paints[category]) do
                index += 1
                ids[index] = color.id
                labels[index] = ('%s - %s'):format(category, color.label)
                if color.id == originalWheelColor then
                    defaultIndex = index
                end
            end
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