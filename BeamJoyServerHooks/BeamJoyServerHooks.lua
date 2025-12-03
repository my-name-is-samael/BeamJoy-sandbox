-- Chat/Command instability server crash workaround (https://github.com/BeamMP/BeamMP-Server/issues/435)

function BJSH_OnChatMessage(...)
    MP.TriggerGlobalEvent("onBJSChatMessage", ...)
    return 1
end

function BJSH_OnConsoleInput(...)
    MP.TriggerGlobalEvent("onBJSConsoleInput", ...)
    return ""
end

function _G.onInit() ---@diagnostic disable-line
    MP.RegisterEvent("onChatMessage", "BJSH_OnChatMessage")
    MP.RegisterEvent("onConsoleInput", "BJSH_OnConsoleInput")
end