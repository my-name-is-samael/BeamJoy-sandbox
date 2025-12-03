local M = {
    defaultLang = "en-US",
    langs = Table(),
}

local function onPreInit()
    for _, fileName in pairs(FS.ListFiles(BJSPluginPath .. "/locales/")) do
        if fileName:endswith(".json") then
            local file, err = io.open(BJSPluginPath .. "/locales/" .. fileName, "r")
            if file and not err then
                local lang = fileName:gsub(".json$", "")
                M.langs[lang] = utils_json.parse(file:read("*a"))
                file:close()
                LogDebug(string.format("Lang %s loaded", lang))
            else
                LogError(string.format("Error while opening locale file %s : %s", fileName, err))
            end
        end
    end
    if not M.langs[M.defaultLang] then
        M.langs:find(TrueFn, function(_, lang) M.defaultLang = tostring(lang) end)
    end
end

---@param caches table<string, any>
local function onBJRequestCache(caches)
    caches.langs = M.langs:keys()
end

---@param key string
---@param lang string?
---@param default string?
---@return string
local function get(key, lang, default)
    lang = lang or services_config.data.Console.Lang
    local baseLang = table.clone(M.langs[M.defaultLang])
    if M.langs[lang] and lang ~= M.defaultLang then
        table.assign(baseLang, M.langs[lang])
    end
    return baseLang[key] or default or key
end

M.onPreInit = onPreInit
M.onBJRequestCache = onBJRequestCache

M.get = get

return M
