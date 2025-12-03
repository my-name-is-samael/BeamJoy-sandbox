local M = {
    actionFilterName = "bj_restrictions",
    ---@type tablelib<integer, string>
    restrictions = Table(),
}

local function onInit()
    extensions.core_input_actionFilter.setGroup(M.actionFilterName, M.restrictions)
    extensions.core_input_actionFilter.addAction(0, M.actionFilterName, true)
end

local function onExtensionUnloaded()
    extensions.core_input_actionFilter.addAction(0, M.actionFilterName, false)
end

local function update()
    local restrictions = Table()
    extensions.hook("onBJRequestRestrictions", restrictions)
    restrictions:sort()

    if not restrictions:compare(M.restrictions) then
        extensions.core_input_actionFilter.addAction(0, M.actionFilterName, false)
        M.restrictions = restrictions
        extensions.core_input_actionFilter.setGroup(M.actionFilterName, M.restrictions)
        extensions.core_input_actionFilter.addAction(0, M.actionFilterName, true)
    end
end

M.onInit = onInit
M.onExtensionUnloaded = onExtensionUnloaded
M.onVehicleInstantiated = update
M.onVehicleSwitched = update
M.onBJScenarioChanged = update
M.onBJUpdateSelf = update

M.update = update

return M
