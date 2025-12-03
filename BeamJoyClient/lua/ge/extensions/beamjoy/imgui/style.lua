local M = {
    TEXT_COLORS = {
        DEFAULT = ImVec4(1, 1, 1, 1),
        HIGHLIGHT = ImVec4(1, 1, 0, 1),
        ERROR = ImVec4(9, .09, .04, 1),
        SUCCESS = ImVec4(.6, .8, 0, 1),
        DISABLED = ImVec4(0.5, 0.5, 0.5, 1),
    },
    BTN_PRESETS = {
        -- bg, bg hovered, bg active
        INFO = { ImVec4(.44, .5, .72, .6), ImVec4(.44, .5, .72, .8), ImVec4(.44, .5, .72, .4) },
        SUCCESS = { ImVec4(.6, .8, 0, .8), ImVec4(.6, .8, 0, 1), ImVec4(.6, .8, 0, .6) },
        ERROR = { ImVec4(.9, .09, .04, .6), ImVec4(.9, .09, .04, .8), ImVec4(.9, .09, .04, .4) },
        WARNING = { ImVec4(.8, .47, .23, .6), ImVec4(.8, .47, .23, .8), ImVec4(.8, .47, .23, .4) },
        DISABLED = { ImVec4(0, 0, 0, .6), ImVec4(0, 0, 0, .6), ImVec4(0, 0, 0, .6), ImVec4(.65, .65, .65, 1) },
        TRANSPARENT = { ImVec4(0, 0, 0, 0), ImVec4(0, 0, 0, 0), ImVec4(0, 0, 0, 0) },
    },
    INPUT_PRESETS = {
        -- frame bg, override text color?, frame bg hovered, frame bg active, slider grab, slider grab active
        DEFAULT = { ImVec4(.44, .5, .72, .5), nil, ImVec4(.44, .5, .72, .8), ImVec4(.44, .5, .72, .4), ImVec4(.3, 0, .65, .3), ImVec4(.3, 0, .75, .6) },
        ERROR = { ImVec4(.9, .09, .04, .6), nil, ImVec4(.9, .09, .04, .8), ImVec4(.9, .09, .04, .4), ImVec4(1, 1, 0, .5), ImVec4(1, 1, 0, 1) },
        DISABLED = { ImVec4(0, 0, 0, .6), ImVec4(1, 1, 1, .4), ImVec4(0, 0, 0, .6), ImVec4(0, 0, 0, .6), ImVec4(0, 0, 0, 0), ImVec4(0, 0, 0, 0) },
        TRANSPARENT = { ImVec4(0, 0, 0, 0), nil, ImVec4(0, 0, 0, 0), ImVec4(0, 0, 0, 0), ImVec4(1, 1, 1, .3), ImVec4(1, 1, 1, .55) },
    },
}

local function getComboWidthByContent(content)
    return CalcTextSize(content and tostring(content) or "").x + 30
end

---@param big boolean?
---@return integer
local function getIconSize(big)
    return big and 32 or 20
end

---@param big boolean?
---@return integer
local function getBtnIconSize(big)
    return getIconSize(big) + 10
end

M.getComboWidthByContent = getComboWidthByContent
M.getIconSize = getIconSize
M.getBtnIconSize = getBtnIconSize

return M
