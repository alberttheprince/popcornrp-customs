local originalExtras = {}
local extrasLastIndex = 1
local config = require 'config.client'
local sharedConfig = require 'config.shared'

local function extras()
    local options = {}
    for i = 1, 14 do
        if not DoesExtraExist(vehicle, i) then
            goto continue
        end

        local extraTurnedOn = IsVehicleExtraTurnedOn(vehicle, i)

        options[#options + 1] = {
            label = ('Extra %d'):format(i),
            description = ('%s%s'):format(config.currency, sharedConfig.prices['cosmetic']),
            close = true,
            values = {locale('menus.general.enabled'), locale('menus.general.disabled')},
            set = function(selected, index)
                SetVehicleExtra(vehicle, i, index - 1)
                return originalExtras[i] == (index - 1 == 0), ('%s %s'):format(options[selected].label, index == 1 and string.lower(locale('menus.general.enabled')) or string.lower(locale('menus.general.disabled')))
            end,
            restore = function()
                SetVehicleExtra(vehicle, i, not originalExtras[i])
            end,
            defaultIndex = extraTurnedOn and 1 or 2,
        }
        originalExtras[i] = extraTurnedOn

        ::continue::
    end

    return options
end

local menu = {
    id = 'customs-extras',
    canClose = true,
    disableInput = false,
    title = locale('menus.main.extras'),
    position = 'top-left',
    options = {},
}

local function onSubmit(selected, scrollIndex)
    local option = menu.options[selected]

    for _, v in pairs(menu.options) do
        v.restore()
    end

    local duplicate, desc = option.set(selected, scrollIndex)

    local success = InstallMod(duplicate, 'cosmetic', {
        description = desc,
    })

    if not success then menu.options[selected].restore() end

    lib.setMenuOptions('customs-extras', extras())
    lib.showMenu('customs-extras', extrasLastIndex)
end

menu.onSideScroll = function(selected, scrollIndex)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    local option = menu.options[selected]
    option.set(selected, scrollIndex)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    extrasLastIndex = selected
end

menu.onClose = function()
    for _, v in pairs(menu.options) do
        v.restore()
    end
    lib.showMenu(mainMenuId, mainLastIndex)
end

return function()
    menu.options = extras()
    lib.registerMenu(menu, onSubmit)
    return menu.id
end