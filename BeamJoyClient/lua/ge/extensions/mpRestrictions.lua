--[[
This service is preventing all actions that should be disabled in MP:
- toggleTrackBuilder keybind
- toggleAITraffic keybind
- forceField keybind + radial menu
more to come...

simSpeed restrictions are moved to beamjoy_environment
]]

local M = {
    preloadedDependencies = { "core_input_actionFilter",  },
    dependencies = {},

    actionFilterName = "bj_base_restrictions",
    restrictions = { "toggleTrackBuilder", "toggleAITraffic",
        "forceField", "goto_checkpoint" },
}
AddPreloadedDependencies(M)

local function onInit()
    InitPreloadedDependencies(M)
    extensions.core_input_actionFilter.setGroup(M.actionFilterName, M.restrictions)
    extensions.core_input_actionFilter.addAction(0, M.actionFilterName, true)
end

local function onExtensionUnloaded()
    extensions.core_input_actionFilter.addAction(0, M.actionFilterName, false)
end

M.onInit = onInit
M.onBJClientReady = onInit
M.onExtensionUnloaded = onExtensionUnloaded

return M
