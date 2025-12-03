local M = {
    ALL_PLAYERS = -1,

    LOG_EVENTS_BLACKLIST = { "tick", "trafficRubberbandTick" },
}

local function onSlowUpdate()
    ---@type BJServerTick
    local payload = { time = GetCurrentTime() }
    extensions.hook("onBJRequestServerTickPayload", payload)
    M.sendToPlayer(M.ALL_PLAYERS, "tick", payload)
end

---@param playerID integer
---@param key string
local function sendToPlayer(playerID, key, ...)
    if playerID == M.ALL_PLAYERS or #MP.GetPlayerName(playerID) > 0 then
        local id = UUID()
        local parts = {}
        local payload = #{ ... } > 0 and utils_json.stringifyRaw({ ... }) or ""
        local constants = require("communications/constants")
        while #payload > 0 do
            table.insert(parts, payload:sub(1, constants.PAYLOAD_SIZE_THRESHOLD))
            payload = payload:sub(constants.PAYLOAD_SIZE_THRESHOLD + 1)
        end

        MP.TriggerClientEvent(playerID, constants.BASE_EVENT, utils_json.stringifyRaw({
            id = id,
            key = key,
            parts = #parts,
        }))
        for i, p in ipairs(parts) do
            MP.TriggerClientEvent(playerID, constants.DATA_EVENT, utils_json.stringifyRaw({
                id = id,
                part = i,
                data = p,
            }))
        end
        if not table.includes(M.LOG_EVENTS_BLACKLIST, key) then
            LogDebug(string.format("Event %s sent to %s (ID %d, %d parts data)",
                key, playerID == -1 and services_lang.get("common.all") or
                MP.GetPlayerName(playerID), playerID, #parts))
        end
    end
end

---@param permissions string[]
---@param key string
local function sendByPermissions(permissions, key, ...)
    local data = { ... }
    services_players.players:filter(function(p)
        return services_permissions.hasAllPermissions(p.playerID, table.unpack(permissions, 1, 20))
    end):forEach(function(p)
        M.sendToPlayer(p.playerID, key, table.unpack(data, 1, 20))
    end)
end

M.onSlowUpdate = onSlowUpdate

M.sendToPlayer = sendToPlayer
M.sendByPermissions = sendByPermissions

return M
