local getModLabel = require('client.utils.getModLabel')
local originalMods = {}
partsLastIndex = 1
local VehicleClass = require('client.utils.enums.VehicleClass')

local function parts()
    local options = {}

    for _, mod in ipairs(Config.Mods) do
        local modCount = GetNumVehicleMods(vehicle, mod.id)

        if mod.category ~= 'parts'
            or mod.enabled == false
            or modCount == 0
            or mod.id == 23
        then
            goto continue
        end

        local modLabels = {}
        modLabels[1] = 'Stock'
        for i = -1, modCount - 1 do
            modLabels[i + 2] = getModLabel(vehicle, mod.id, i)
        end

        local currentMod = GetVehicleMod(vehicle, mod.id)
        originalMods[mod.id] = currentMod

        options[#options + 1] = {
            id = mod.id,
            label = mod.label,
            description = ('%s%s'):format(Config.Currency, Config.Prices['cosmetic']),
            values = modLabels,
            close = true,
            defaultIndex = currentMod + 2,
            set = function(index)
                SetVehicleMod(vehicle, mod.id, index - 2, false)
                return originalMods[mod.id] == index - 2, ('%s installed'):format(modLabels[index])
            end,
            restore = function()
                SetVehicleMod(vehicle, mod.id, originalMods[mod.id], false)
            end,
        }

        ::continue::
    end

    if GetVehicleClass(vehicle) ~= VehicleClass.Cycles then
        options[#options + 1] = {
            label = 'Wheels',
            close = true,
            args = {
                menu = 'client.menus.wheels',
            }
        }
    end

    options[#options + 1] = require('client.options.plateindex')()

    table.sort(options, function(a, b)
        return a.label < b.label
    end)

    return options
end

local menu = {
    id = 'customs-parts',
    title = 'Cosmetics - Parts',
    canClose = true,
    disableInput = false,
    options = {},
    position = 'top-left',
}

local function onSubmit(selected, scrollIndex, args)
    for _, v in pairs(menu.options) do
        if not v.args?.menu then v.restore() end
    end

    local subMenuName = args?.menu
    if subMenuName then
        local menuId = require(subMenuName)(args?.menuArgs and table.unpack(args.menuArgs))
        lib.showMenu(menuId, 1)
        return
    end


    local duplicate, desc = menu.options[selected].set(scrollIndex)

    local success = require('client.utils.installMod')(duplicate, 'cosmetic', {
        description = desc,
    })

    if not success then menu.options[selected].restore() end

    lib.setMenuOptions(menu.id, parts())
    lib.showMenu(menu.id, partsLastIndex)
end

menu.onSideScroll = function(selected, scrollIndex)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    local option = menu.options[selected]
    option.set(scrollIndex)
end

menu.onClose = function()
    for _, v in pairs(menu.options) do
        if not v.args?.menu then v.restore() end
    end
    lib.showMenu(mainMenuId, mainLastIndex)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    partsLastIndex = selected
end

return function()
    menu.options = parts()
    lib.registerMenu(menu, onSubmit)
    return menu.id
end
