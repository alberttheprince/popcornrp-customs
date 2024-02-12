local config = require 'config.client'

---@param vehicle number
---@param modType number
---@param modValue number
---@return string
function GetModLabel (vehicle, modType, modValue)
    if config.modLabels[modType] then
        for _, mod in ipairs(config.modLabels[modType]) do
            if mod.id == modValue then return mod.label end
        end
    end

    if modValue == -1 then return locale('menus.general.stock') end

    local label = GetModTextLabel(vehicle, modType, modValue)
    return (not label or label == '') and tostring(modValue) or GetLabelText(label)
end

---@param duplicate boolean
---@param mod 'repair' | 'cosmetic' | 'colors' | 11 | 12 | 13 | 15 | 18
---@param props NotifyProps?
---@param level number?
function InstallMod(duplicate, mod, props, level)
    if duplicate then
        exports.qbx_core:Notify(locale('notifications.error.alreadyInstalled'), 'error')
        return false
    end

    local success = lib.callback.await('qbx_customs:server:pay', false, mod, level)
    if success then
        exports.qbx_core:Notify(
            props?.title or locale('notifications.props.installTitle'),
            props?.position or 'top',
            props?.duration,
            props?.description,
            props?.position or 'top',
            props?.style,
            props?.icon or 'fa-solid fa-wrench',
            props?.iconColor
        )
        qbx.playAudio({
            audioName = 'PICK_UP',
            audioRef = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
        })
        return true
    end

    exports.qbx_core:Notify(locale('notifications.error.money'), 'error')
    return false
end