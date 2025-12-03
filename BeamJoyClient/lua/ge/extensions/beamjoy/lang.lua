local M = {
    ---@type string[]
    langs = {},

    lang = nil,
}

local function onExtensionLoaded()
    -- load beamjoy langs
    local bjLocales = FS:findFiles('/beamjoy_locales/', '*.json', 0) or {}
    for i, loc in ipairs(bjLocales) do
        bjLocales[i] = loc:gsub('/beamjoy_locales/', '')
    end

    for _, filePath in ipairs(FS:directoryList("/locales/")) do
        local loc = filePath:gsub("^/locales/", "")
        if table.includes(bjLocales, loc) then
            local merged = table.assign(
                jsonReadFile(filePath),
                jsonReadFile("/beamjoy_locales/" .. loc)
            )
            jsonWriteFile(filePath, merged, true)
            FS:mount(filePath)
        end
    end
end

local function onInit()
    beamjoy_communications.addHandler("sendCache", M.retrieveCache)
end

local function onSlowUpdate()
    local lang = Lua:getSelectedLanguage()
    if M.lang ~= lang then
        beamjoy_communications.send("changeLang", lang)
        M.lang = lang
    end
end

local function initLang()
    M.lang = Lua:getSelectedLanguage()
end

local function retrieveCache(caches)
    if caches.langs then
        M.langs = caches.langs
    end
end

---@param key string
---@param default string?
---@return string
local function translate(key, default)
    local res = MPTranslate(key)
    return res ~= key and res or default or key
end

M.onExtensionLoaded = onExtensionLoaded
M.onInit = onInit
M.onSlowUpdate = onSlowUpdate

M.initLang = initLang
M.retrieveCache = retrieveCache
M.translate = translate

return M
