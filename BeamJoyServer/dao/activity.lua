local M = {
    dependencies = { "dao_main" },
    path = "activities",
}

local function onInit()
    if not FS.Exists(dao_main.dbPath .. "/" .. M.path) then
        FS.CreateDirectory(dao_main.dbPath .. "/" .. M.path)
    end
end

---@param mapName string
---@param activityType string
---@return table?
local function get(mapName, activityType)
    local filePath = M.path .. "/" .. mapName .. "_" .. activityType .. ".json"
    return dao_main.get(filePath)
end

---@param mapName string
---@param activityType string
---@param data table?
local function save(mapName, activityType, data)
    local finalData = data and table.filter(data,
        function(v) return type(v) ~= "function" end) or nil
    local filePath = M.path .. "/" .. mapName .. "_" .. activityType .. ".json"
    return dao_main.save(filePath, finalData)
end

M.onInit = onInit

M.get = get
M.save = save

return M
