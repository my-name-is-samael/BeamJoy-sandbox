local M = {
    preloadedDependencies = { "ui_imgui" },
    dependencies = {},
    GUI = { setupEditorGuiTheme = nop },
}
AddPreloadedDependencies(M)

local function onInit()
    InitPreloadedDependencies(M)
end

local function onBJClientReady()
    require("ge/extensions/editor/api/gui").initialize(M.GUI)

    Table(FS:directoryList("/lua/ge/extensions/beamjoy/imgui")):filter(function(path)
        return path:endswith(".lua")
    end):map(function(el)
        return el:gsub("^/lua/ge/extensions/beamjoy/imgui/", ""):gsub(".lua$", "")
    end):filter(function(fileName)
        return fileName ~= "manager" and not fileName:find("/")
    end):forEach(function(windowName)
        LogInfo("Loading ui module " .. windowName)
        extensions.load("beamjoy_imgui_" .. windowName)
    end)
end

M.onInit = onInit
M.onBJClientReady = onBJClientReady

return M
