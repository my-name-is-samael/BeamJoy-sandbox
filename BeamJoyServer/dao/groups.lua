local M = {
    dependencies = { "dao_main" },
    path = "groups.json",
}

---@return BJGroup[]?
local function get()
    return dao_main.get(M.path)
end

---@param data BJGroup[]
local function save(data)
    dao_main.save(M.path, data)
end

M.get = get
M.save = save

return M