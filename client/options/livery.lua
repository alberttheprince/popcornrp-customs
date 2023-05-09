local originalLivery = {}

local function livery()
    local oldLiveryMethod = GetVehicleLivery(vehicle)
    local newLiveryMethod = GetVehicleMod(vehicle, 48)

    if oldLiveryMethod >= 0 then
        originalLivery = {
            index = oldLiveryMethod,
            old = true
        }
    else
        originalLivery = {
            index = newLiveryMethod,
            old = false
        }
    end

    local liveryLabels = {}
    if originalLivery.old then
        for i = 0, GetVehicleLiveryCount(vehicle) - 1 do
            liveryLabels[i + 1] = ('Livery %d'):format(i + 1)
        end
    else
        for i = 0, GetNumVehicleMods(vehicle, 48) - 1 do
            liveryLabels[i + 1] = ('%s'):format(GetLabelText(GetModTextLabel(vehicle, 48, i)))
        end
    end

    local option = {
        id = 'livery',
        label = 'Livery',
        description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
        close = true,
        values = liveryLabels,
        set = function(index)
            if originalLivery.old then
                SetVehicleLivery(vehicle, index - 1)
            else
                SetVehicleMod(vehicle, 48, index - 1, false)
            end
            return ('%s installed'):format(liveryLabels[index])
        end,
        restore = function()
            if originalLivery.old then
                SetVehicleLivery(vehicle, originalLivery.index)
            else
                SetVehicleMod(vehicle, 48, originalLivery.index, false)
            end
        end,
        defaultIndex = originalLivery.index + 1,
    }


    return option
end

return livery
