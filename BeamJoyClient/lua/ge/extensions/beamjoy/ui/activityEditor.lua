---@class BJActivityEditorCommon
local M = {
    ---@type BJActivityEditor?
    activeEditor = nil,

}

---@type tablelib<integer, BJActivityEditor>
local editors = Table({
    require("ge/extensions/beamjoy/ui/activityEditorSafeZone"),
})

local function onInit()
    editors:forEach(function(editor) editor.onInit(M) end)
    beamjoy_communications_ui.addHandler("BJCloseWindow", function(windowName)
        if windowName == "config" then
            M.onClose()
        end
    end)
end

local function onUpdate()
    if M.activeEditor and M.activeEditor.onUpdate then
        M.activeEditor.onUpdate()
    end
end

local function onClose()
    if M.activeEditor and M.activeEditor.onClose then
        M.activeEditor.onClose()
    end
    M.activeEditor = nil
end

M.onInit = onInit
M.onUpdate = onUpdate
M.onClose = onClose

return M
