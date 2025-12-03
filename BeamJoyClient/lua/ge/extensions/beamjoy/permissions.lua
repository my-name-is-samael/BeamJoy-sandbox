BJ_PERMISSIONS = {
    SendPrivateMessage = "SendPrivateMessage",
    TeleportTo = "TeleportTo",
    SpawnTrailers = "SpawnTrailers",
    BypassModelBlacklist = "BypassModelBlacklist",
    SpawnProps = "SpawnProps",
    TeleportFrom = "TeleportFrom",
    DeleteVehicle = "DeleteVehicle",
    Kick = "Kick",
    Mute = "Mute",
    Whitelist = "Whitelist",
    SetGroup = "SetGroup",
    TempBan = "TempBan",
    FreezePlayers = "FreezePlayers",
    EnginePlayers = "EnginePlayers",
    SetConfig = "SetConfig",
    Ban = "Ban",
    DatabasePlayers = "DatabasePlayers",
    SetEnvironment = "SetEnvironment",
    SwitchMap = "SwitchMap",
    SetMaps = "SetMaps",
    SetPermissions = "SetPermissions",
    SetCore = "SetCore",
    SetCEN = "SetCEN",
}

local M = {
    data = {},
    permissionsDefault = {},
}

local function onInit()
    beamjoy_communications.addHandler("sendCache", M.retrieveCache)
    beamjoy_communications_ui.addHandler("BJReady", M.onUIReady)
    beamjoy_communications_ui.addHandler("BJSavePermissions", M.savePermissions)
end

local function onUIReady()
    beamjoy_communications_ui.send("BJPermissionsNames", BJ_PERMISSIONS)
    core_jobsystem.create(function(job)
        while table.length(M.data) == 0 do
            job.sleep(.01)
        end
        beamjoy_communications_ui.send("BJUpdatePermissions", M.data)
    end)
end

---@param caches table
local function retrieveCache(caches)
    if caches.permissions then
        M.data = caches.permissions
        beamjoy_communications_ui.send("BJUpdatePermissions", M.data)
        extensions.hook("onBJPermissionsUpdate")
    end
    if caches.permissionsDefault then
        M.permissionsDefault = caches.permissionsDefault
    end
end

---@param playerID integer?
---@return boolean
local function isStaff(playerID)
    playerID = playerID or MPConfig.getPlayerServerID()
    local player = beamjoy_players.players:find(function(p) return p.playerID == playerID end)
    if not player then return false end
    local group = beamjoy_groups.getGroup(player.group)
    return group ~= nil and group.staff
end

---@param playerName string?
---@param ... string permissions
---@return boolean
local function hasAllPermissions(playerName, ...)
    playerName = playerName or MPConfig.getNickname()
    ---@type BJCPlayer?
    local target = beamjoy_players.players[playerName]
    if not target then return false end
    ---@type BJGroup?
    local targetGroup, targetGroupIndex = beamjoy_groups.getGroup(target.group)
    if not targetGroup then return false end

    return Table({ ... }):every(function(permName)
        local _, permGroupIndex = beamjoy_groups.getGroup(M.data[permName])
        return permGroupIndex ~= nil and
            (table.includes(targetGroup.permissions, permName) or
                targetGroupIndex >= permGroupIndex)
    end)
end

---@param playerName string?
---@param ... string permissions
---@return boolean
local function hasAnyPermission(playerName, ...)
    playerName = playerName or MPConfig.getNickname()
    ---@type BJCPlayer?
    local target = beamjoy_players.players[playerName]
    if not target then return false end
    ---@type BJGroup?
    local targetGroup, targetGroupIndex = beamjoy_groups.getGroup(target.group)
    if not targetGroup then return false end

    return Table({ ... }):any(function(permName)
        local _, permGroupIndex = beamjoy_groups.getGroup(M.data[permName])
        return permGroupIndex ~= nil and
            (table.includes(targetGroup.permissions, permName) or
                targetGroupIndex >= permGroupIndex)
    end)
end

---@param perms BJPermissions
local function savePermissions(perms)
    beamjoy_communications.send("savePermissions", perms)
end

M.onInit = onInit
M.onUIReady = onUIReady

M.retrieveCache = retrieveCache
M.isStaff = isStaff
M.hasAllPermissions = hasAllPermissions
M.hasAnyPermission = hasAnyPermission
M.savePermissions = savePermissions

return M
