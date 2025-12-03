local M = {
    ---@type BJGroup[]
    data = {},
    ---@type string[]
    defaultGroups = {},
}

local function onInit()
    beamjoy_communications.addHandler("sendCache", M.retrieveCache)
    beamjoy_communications_ui.addHandler("BJReady", M.onUIReady)
    beamjoy_communications_ui.addHandler("BJSaveGroups", M.saveGroups)
end

local function onUIReady()
    core_jobsystem.create(function(job)
        while table.length(M.data) == 0 do
            job.sleep(.01)
        end
        beamjoy_communications_ui.send("BJUpdateGroups",
            { groups = M.data, defaultGroups = M.defaultGroups })
    end)
end

---@param caches table
local function retrieveCache(caches)
    if caches.defaultGroups then
        M.defaultGroups = caches.defaultGroups
    end
    if caches.groups then
        M.data = caches.groups
        beamjoy_communications_ui.send("BJUpdateGroups",
            { groups = M.data, defaultGroups = M.defaultGroups })
    end
end

---@param groups BJGroup[]
local function saveGroups(groups)
    beamjoy_communications.send("groupsSave", groups)
end

---@param groupName string
---@return BJGroup? group, integer? index
local function getGroup(groupName)
    for i, group in pairs(M.data) do
        if group.name == groupName then
            return group, i
        end
    end
end

M.onInit = onInit
M.onUIReady = onUIReady

M.retrieveCache = retrieveCache
M.saveGroups = saveGroups
M.getGroup = getGroup

return M
