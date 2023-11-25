local originalLivery = {}

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
        description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
        close = true,
        values = liveryLabels,
        set = function(index)
            if originalLivery.old then
                SetVehicleLivery(vehicle, index - 1)
                return originalLivery.index == index - 1, Lang:t('menus.options.general.installed', {element = liveryLabels[index]})
            else
                SetVehicleMod(vehicle, 48, index - 2, false)
                return originalLivery.index == index - 2, Lang:t('menus.options.general.installed', {element = liveryLabels[index]})
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

return livery
