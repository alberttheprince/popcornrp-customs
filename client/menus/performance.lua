local originalMods = {}
local originalTurbo
local lastIndex
local VehicleClass = require('client.enums.VehicleClass')

local function priceLabel(price)
    if type(price) ~= 'table' then
        return ('%s%s'):format(Config.Currency, price)
    end

    local copy = table.clone(price)
    table.remove(copy, 1)

    for i = 1, #copy do
        copy[i] = ('%d: %s%s'):format(i, Config.Currency, copy[i])
    end

    return table.concat(copy, ' | ')
end

local function performance()
    local options = {}

    for _, mod in ipairs(Config.Mods) do
        local modCount = GetNumVehicleMods(vehicle, mod.id)

        if mod.category ~= 'performance'
        or mod.enabled == false
        or modCount == 0
        then goto continue end

        local modLabels = {}
        modLabels[1] = Lang:t('menus.general.stock')
        for i = -1, modCount - 1 do
            modLabels[i + 2] = GetModLabel(vehicle, mod.id, i)
        end

        local currentMod = GetVehicleMod(vehicle, mod.id)
        originalMods[mod.id] = currentMod

        options[#options + 1] = {
            id = mod.id,
            label = mod.label,
            description = priceLabel(Config.Prices[mod.id]),
            values = modLabels,
            close = true,
            defaultIndex = currentMod + 2,
            set = function(index)
                SetVehicleMod(vehicle, mod.id, index - 2, false)
                return currentMod == index - 2, ('%s installed'):format(modLabels[index])
            end,
            restore = function()
                SetVehicleMod(vehicle, mod.id, originalMods[mod.id], false)
            end
        }

        ::continue::
    end

    originalTurbo = IsToggleModOn(vehicle, 18)
    if GetVehicleClass(vehicle) ~= VehicleClass.Cycles then
        options[#options + 1] = {
            id = 18,
            label = Lang:t('menus.performance.turbo'),
            description = ('%s%s'):format(Config.Currency, Config.Prices[18]),
            values = {Lang:t('menus.general.disabled'), Lang:t('menus.general.enabled')},
            close = true,
            defaultIndex = originalTurbo and 2 or 1,
            set = function(index)
                ToggleVehicleMod(vehicle, 18, index == 2)
                return originalTurbo == (index == 2), ('%s %s'):format(Lang:t('menus.performance.turbo'), index == 2 and string.lower(Lang:t('menus.general.enabled')) or string.lower(Lang:t('menus.general.disabled')))
            end,
            restore = function()
                ToggleVehicleMod(vehicle, 18, originalTurbo)
            end
        }
    end

    table.sort(options, function(a, b)
        return a.label < b.label
    end)

    return options
end

local menu = {
    id = 'customs-performance',
    title = Lang:t('menus.performance.title'),
    canClose = true,
    disableInput = false,
    options = {},
    position = 'top-left',
}

local function onSubmit(selected, scrollIndex)
    for _, v in pairs(menu.options) do
        v.restore()
    end

    local duplicate, desc = menu.options[selected].set(scrollIndex)

    local success = InstallMod(duplicate, menu.options[selected].id, {
        description = desc,
    }, scrollIndex)

    if not success then menu.options[selected].restore() end

    lib.setMenuOptions(menu.id, performance())
    lib.showMenu(menu.id, lastIndex)
end

menu.onSideScroll = function(selected, scrollIndex)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    local option = menu.options[selected]
    option.set(scrollIndex)
end

menu.onClose = function()
    for _, v in pairs(menu.options) do
        v.restore()
    end
    lib.showMenu(mainMenuId, mainLastIndex)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    lastIndex = selected
end

return function()
    menu.options = performance()
    lib.registerMenu(menu, onSubmit)
    return menu.id
end