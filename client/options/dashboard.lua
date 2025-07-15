local originalDashboard

local function dashboard()
    originalDashboard = GetVehicleDashboardColor(vehicle)

    local dashboardLabels = {}
    local dashboardIds = {}
    local defaultIndex = 0

    for i, v in ipairs(Config.Paints.Classic) do
        dashboardLabels[i] = v.label
        dashboardIds[i] = v.id
        if v.id == originalDashboard then
            defaultIndex = i
        end
    end

    local option = {
        id = 'dashboard',
        label = 'Dashboard',
        description = ('%s%s'):format(Config.Currency, Config.Prices['colors']),
        close = true,
        values = dashboardLabels,
        set = function(index)
            SetVehicleDashboardColor(vehicle, dashboardIds[index])
        end,
        restore = function()
            SetVehicleDashboardColor(vehicle, originalDashboard)
        end,
        defaultIndex = defaultIndex,
        firstPerson = true
    }


    return option
end

return dashboard
