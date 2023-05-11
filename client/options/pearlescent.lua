local originalPearlescent, originalWheelColor

local function pearlescent()
    originalPearlescent, originalWheelColor = GetVehicleExtraColours(vehicle)
    local defaultIndex = 1
    local ids = {}
    local labels = {}

    for i, colour in ipairs(Config.Paints.Classic) do
        ids[i] = colour.id
        labels[i] = colour.label
        if colour.id == originalPearlescent then
            defaultIndex = i
        end
    end

    local size = #ids
    for i, colour in ipairs(Config.Paints.Chameleon) do
        ids[size + i] = colour.id
        labels[size + i] = colour.label
        if colour.id == originalPearlescent then
            defaultIndex = size + i
        end
    end

    local option = {
        id = 'pearlescent',
        label = 'Pearlescent',
        description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
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

return pearlescent
