local M = {}

local function onInit()
    communications_rx.addHandler("clientConnection", M.requestCaches)
    communications_rx.addHandler("requestCaches", M.requestCaches)
end

---@param ctxt BJSContext
local function requestCaches(ctxt)
    if ctxt.senderID then
        local res = {}
        extensions.hook("onBJRequestCache", res, ctxt.senderID)
        if table.length(res) > 0 then
            communications_tx.sendToPlayer(ctxt.senderID, "sendCache", res)
        end
    end
end

M.onInit = onInit

M.requestCaches = requestCaches

return M
