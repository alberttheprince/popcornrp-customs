---@param duplicate boolean
---@param mod 'repair' | 'cosmetic' | 'colors' | 11 | 12 | 13 | 15 | 18
---@param props NotifyProps?
---@param level number?
return function(duplicate, mod, props, level)
    if duplicate then
        exports.qbx_core:Notify(Lang:t('notifications.error.alreadyInstalled'), 'error')
        return false
    end

    local success = lib.callback.await('customs:server:pay', false, mod, level)
    if success then
        exports.qbx_core:Notify(
            props?.title or Lang:t('notifications.props.installTitle'),
            props?.position or 'top',
            props?.duration,
            props?.description,
            props?.position or 'top',
            props?.style,
            props?.icon or 'fa-solid fa-wrench',
            props?.iconColor
        )
        SendNUIMessage({sound = true})
        return true
    end

    exports.qbx_core:Notify(Lang:t('notifications.error.money'), 'error')
    return false
end