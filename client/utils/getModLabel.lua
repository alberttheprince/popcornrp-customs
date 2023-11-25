---@param vehicle number
---@param modType number
---@param modValue number
---@return string
return function (vehicle, modType, modValue)
    if Config.ModLabels[modType] then
        for _, mod in ipairs(Config.ModLabels[modType]) do
            if mod.id == modValue then return mod.label end
        end
    end

    if modValue == -1 then return Lang:t('menus.general.stock') end

    local label = GetModTextLabel(vehicle, modType, modValue)
    return (not label or label == '') and tostring(modValue) or GetLabelText(label)
end