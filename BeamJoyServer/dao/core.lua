local M = {
    dependencies = { "dao_main" },
    path = "core.json",
}

---@return table?
local function get()
    return dao_main.get(M.path)
end

---@param data table
local function save(data)
    if type(data) == "table" then
        data = table.filter(data, function(_, k)
            return MP.Settings[k] ~= nil
        end)
    end
    dao_main.save(M.path, data)
    M.saveServerConfig(data)
end

---@return {General: table, Misc: table}?
local getServerConfig = function()
    local file, error = io.open("ServerConfig.toml", "r")
    if file and not error then
        local raw = file:read("*a")
        file:close()
        local data = utils_toml.parse(raw)
        if type(data) ~= "table" or not data.General then
            return
        end
        return data
    end
end

---@param generalFields table
local function saveServerConfig(generalFields)
    if type(generalFields) ~= "table" then return end
    local coreData = getServerConfig()
    if not coreData then return end
    table.assign(coreData.General, generalFields)

    local file, err = io.open("ServerConfig.temp", "w")
    if file and not err then
        file:write(utils_toml.encode(coreData))
        file:close()

        if FS.Exists("ServerConfig.toml") then
            FS.Remove("ServerConfig.toml")
        end
        FS.Rename("ServerConfig.temp", "ServerConfig.toml")
    end
end

M.get = get
M.getServerConfig = getServerConfig
M.save = save
M.saveServerConfig = saveServerConfig

return M
