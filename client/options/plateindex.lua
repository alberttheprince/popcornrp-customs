local originalPlateIndex
local function plateIndex()
    originalPlateIndex = GetVehicleNumberPlateTextIndex(vehicle)

    local plateIndexLabels = {}
    for i, v in ipairs(Config.PlateIndexes) do
        plateIndexLabels[i] = v.label
    end

    local option = {
        id = 'plate_index',
        label = Lang:t('menus.options.plateIndex.title'),
        description = ('%s%s'):format(Config.Currency, Config.Prices['cosmetic']),
        close = true,
        values = plateIndexLabels,
        set = function(index)
            SetVehicleNumberPlateTextIndex(vehicle, index - 1)
            return originalPlateIndex == index - 1, Lang:t('menus.options.plateIndex.installed', {plate = plateIndexLabels[index]})
        end,
        restore = function()
            SetVehicleNumberPlateTextIndex(vehicle, originalPlateIndex)
        end,
        defaultIndex = originalPlateIndex + 1,
    }

    return option
end

return plateIndex