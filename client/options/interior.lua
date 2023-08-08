local originalInterior

local function interior()
    originalInterior = GetVehicleInteriorColor(vehicle)

    local interiorLabels = {}
    local interiorIds = {}
    local defaultIndex = 0

    for i, v in ipairs(Config.Paints.Classic) do
        interiorLabels[i] = v.label
        interiorIds[i] = v.id
        if v.id == originalInterior then
            defaultIndex = i
        end
    end

    local option = {
        id = 'interior',
        label = 'Interior',
        description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
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

return interior
