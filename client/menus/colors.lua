colorsLastIndex = 1

local function colors()
    local options = {}

    options[#options+1] = {
        label = 'Paint primary',
        close = true,
        args = {
            menu = 'client.menus.paint',
            menuArgs = {
                true,
            }
        }
    }

    options[#options+1] = {
        label = 'Paint secondary',
        close = true,
        args = {
            menu = 'client.menus.paint',
            menuArgs = {
                false,
            }
        }
    }

    options[#options+1] = {
        label = 'Neon',
        close = true,
        args = {
            menu = 'client.menus.neon',
        }
    }

    options[#options+1] = require('client.options.xenon')()
    options[#options+1] = require('client.options.pearlescent')()
    options[#options+1] = require('client.options.wheelcolor')()
    options[#options+1] = require('client.options.windowtint')()
    options[#options+1] = require('client.options.tyresmoke')()

    local liveryOption = require('client.options.livery')()
    if #liveryOption.values > 0 then
        options[#options+1] = liveryOption
    end

    table.sort(options, function(a, b)
        return a.label < b.label
    end)

    return options
end

local menu = {
    id = 'customs-colors',
    title = 'Cosmetics - Colors',
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

    local success = require('client.utils.installMod')(duplicate, 'colors', {
        description = desc,
        icon = 'fa-solid fa-spray-can',
    })

    if not success then menu.options[selected].restore() end

    lib.setMenuOptions(menu.id, colors())
    lib.showMenu(menu.id, colorsLastIndex)
end

menu.onSideScroll = function(selected, scrollIndex)
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    local option = menu.options[selected]
    option.set(scrollIndex)
end

menu.onClose = function()
    for _, v in pairs(menu.options) do
        if not v.args?.menu then v.restore() end -- v.args.menu means it's a submenu
    end
    lib.showMenu(mainMenuId, mainLastIndex)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    colorsLastIndex = selected
end

return function()
    menu.options = colors()
    lib.registerMenu(menu, onSubmit)
    return menu.id
end