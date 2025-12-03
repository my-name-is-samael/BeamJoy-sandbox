local M = {}

local function onInit()
    beamjoy_communications.addHandler("chatBroadcast", M.chatBroadcast)
end

---@param entry {lang: string, message: string}[]
---@param color number[]
local function broadcast(entry, color)
    local found = table.find(entry, function(el)
        return el.lang == beamjoy_lang.lang
    end) or entry[1]
    if found then
        beamjoy_chat.directChat(found.message, color)
    end
end

M.onInit = onInit

M.chatBroadcast = broadcast

return M
