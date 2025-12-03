local M = {
    ---@type tablelib<string, {key: string, handlerFn: fun(ctxt: BJSContext, ...: any)}>
    handlers = Table(),
    ---@type table<string, {senderID: integer, created: integer, key?: string, parts?: integer, data?: tablelib<integer, string>}>
    pending = Table(),
}

local function onInit()
    local constants = require("communications/constants")
    MP.RegisterEvent(constants.BASE_EVENT, "_BJSRxEvent")
    MP.RegisterEvent(constants.DATA_EVENT, "_BJSRxData")
end

---@param key string
---@param handlerFn fun(ctxt: BJSContext, ...: any)
local function addHandler(key, handlerFn)
    local id = UUID()
    M.handlers[id] = { key = key, handlerFn = handlerFn }
    return id
end

local function removeHandler(id)
    M.handlers[id] = nil
end

---@param key string
---@param ctxt BJSContext
local function dispatch(key, ctxt, ...)
    local data = { ... }
    M.handlers:filter(function(h)
        return h.key == key
    end):forEach(function(h)
        h.handlerFn(ctxt, table.unpack(data, 1, 20))
    end)
end

local function getTimeoutKey(id)
    return string.format("BJSRxEventTimeout-%s", id)
end

local function finalizeCommunication(id)
    local comm = M.pending[id]
    local strData = table.join(comm.data)
    ---@type table
    ---@diagnostic disable-next-line
    local parsedData = #strData > 0 and utils_json.parse(strData) or {}
    local ctxt = InitContext(comm.senderID)

    if IsDebug() then
        LogDebug(string.format("Event %s received from %s (ID %d, %d parts data)", comm.key,
            ctxt.sender.playerName, comm.senderID,
            comm.parts))
        dump(parsedData)
    end
    local ok, err = pcall(dispatch, comm.key, ctxt, table.unpack(parsedData, 1, 20))
    M.pending[id] = nil
    utils_async.removeTask(getTimeoutKey(id))
    if not ok then
        err = type(err) == "table" and err or { key = "error.generic" }
        -- TODO send error and toast
    end
end

---@param senderID integer
---@param dataStr string
function _BJSRxEvent(senderID, dataStr)
    local data = utils_json.parse(dataStr) or {}
    if #MP.GetPlayerName(senderID) == 0 then
        LogError(string.format("Invalid senderID %d", senderID))
        return
    end
    if not data.id or not data.key or not data.parts then
        LogError("Invalid event: ")
        return dump(data)
    end

    if M.pending[data.id] then
        table.assign(M.pending[data.id], {
            senderID = senderID,
            key = data.key,
            parts = data.parts,
        })
    else
        M.pending[data.id] = {
            senderID = senderID,
            created = GetCurrentTime(),
            key = data.key,
            parts = data.parts,
            data = Table(),
        }
    end

    if data.parts == 0 or
        M.pending[data.id].parts == table.length(M.pending[data.id].data) then
        finalizeCommunication(data.id)
    else
        utils_async.delayTask(function()
            LogWarn(string.format("Communication timed out : player %d ; event %s", senderID, data.key))
            M.pending[data.id] = nil
        end, 30, getTimeoutKey(data.id))
    end
end

---@param senderID integer
---@param dataStr string
function _BJSRxData(senderID, dataStr)
    local data = utils_json.parse(dataStr) or {}
    if #MP.GetPlayerName(senderID) == 0 then
        LogError(string.format("Invalid senderID %d", senderID))
        return
    end
    if not data.id or not data.part or not data.data then
        LogError("Invalid event: ")
        return dump(data)
    end

    if M.pending[data.id] then
        table.assign(M.pending[data.id].data, { [data.part] = data.data })
    else
        M.pending[data.id] = {
            senderID = senderID,
            created = GetCurrentTime(),
            data = Table({ [data.part] = data.data }),
        }
    end

    if M.pending[data.id].key and
        M.pending[data.id].parts == table.length(M.pending[data.id].data) then
        finalizeCommunication(data.id)
    else
        utils_async.delayTask(function()
            LogWarn(string.format("Communication timed out : player %d ; event %s", senderID, data.key))
            M.pending[data.id] = nil
        end, 30, getTimeoutKey(data.id))
    end
end

M.onInit = onInit

M.addHandler = addHandler
M.removeHandler = removeHandler
M.dispatch = dispatch

return M
