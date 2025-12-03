local M = {
    init = false,
    dbPath = "",
}

local function init()
    M.dbPath = BJSPluginPath:gsub("BeamJoyServer", "BeamJoyData/db")
    if not FS.Exists(M.dbPath) then FS.CreateDirectory(M.dbPath) end
    M.init = true
end

---@param filePath string
---@return any?
local function get(filePath)
    if not M.init then init() end
    local file, err = io.open(M.dbPath .. "/" .. filePath, "r")
    if file and not err then
        local data = file:read("*a")
        file:close()
        return utils_json.parse(data) or data
    end
end

---@param filePath string
---@param data any
local function save(filePath, data)
    if not M.init then init() end
    if data == nil or data == "" then
        if FS.Exists(M.dbPath .. "/" .. filePath) then
            FS.Remove(M.dbPath .. "/" .. filePath)
        end
        return
    end
    filePath = M.dbPath .. "/" .. filePath
    local tmpFilePath = filePath .. ".tmp"
    local file, err = io.open(tmpFilePath, "w")
    if file and not err then
        file:write(utils_json.stringify(data))
        file:close()

        if FS.Exists(filePath) then
            FS.Remove(filePath)
        end
        FS.Rename(tmpFilePath, filePath)
    end
end

M.get = get
M.save = save

return M
