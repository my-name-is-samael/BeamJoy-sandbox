local M = {
    dependencies = { "dao_main" },
    path = "maps.json",
    pathCache = "mods_cache.json"
}

local function get()
    return dao_main.get(M.path)
end

local function save(data)
    return dao_main.save(M.path, data)
end

local function getModsCache()
    return dao_main.get(M.pathCache)
end

local function saveModsCache(data)
    return dao_main.save(M.pathCache, data)
end

M.get = get
M.save = save

M.getModsCache = getModsCache
M.saveModsCache = saveModsCache

return M