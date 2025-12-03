--- Checks if the server version is greater than or equal to the given version
---@param major integer
---@param minor integer?
---@param patch integer?
---@return boolean
function CheckServerVersion(major, minor, patch)
    minor = minor or 0
    patch = patch or 0
    local srvMajor, srvMinor, srvPatch = MP.GetServerVersion()
    if srvMajor ~= major then
        return major < srvMajor
    end
    if srvMinor ~= minor then
        return minor < srvMinor
    end
    return patch <= srvPatch
end

function IsDebug()
    return not MP.Get or MP.Get(MP.Settings.Debug)
end

---@class BJSContext
---@field time number
---@field origin "cmd"|"player"|"vote"
---@field senderID number?
---@field sender BJSPlayer?
---@field groupIndex integer?
---@field group BJGroup?

---@param senderID integer?
---@return BJSContext
function InitContext(senderID)
    local sender = senderID and
        services_players.players[MP.GetPlayerName(senderID)] or nil
    local groupIndex = sender and services_groups.getGroupIndex(sender.group) or nil
    return {
        time = GetCurrentTime(),
        origin = senderID and "player" or "cmd",
        senderID = senderID,
        sender = sender,
        groupIndex = groupIndex,
        group = groupIndex and services_groups.data[groupIndex] or nil
    }
end
