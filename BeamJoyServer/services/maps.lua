---@class BJMap
---@field label string
---@field base boolean
---@field enabled boolean
---@field archive string?
---@field ignore true? if a modded map is removed, ignore will prevent serving

local M = {
    clientFolder = "",
    mapsFolder = "",

    modsCache = {
        Client = { "BJ.zip" },
        Maps = {},
    },

    ---@type table<string, BJMap>
    data = {
        smallgrid = {
            label = "Small Grid",
            base = true,
            enabled = true,
        },
        gridmap_v2 = {
            label = "Grid Map V2",
            base = true,
            enabled = true,
        },
        automation_test_track = {
            label = "Automation Test Track",
            base = true,
            enabled = true,
        },
        east_coast_usa = {
            label = "East Coast",
            base = true,
            enabled = true,
        },
        hirochi_raceway = {
            label = "Hirochi Raceway",
            base = true,
            enabled = true,
        },
        italy = {
            label = "Italy",
            base = true,
            enabled = true,
        },
        jungle_rock_island = {
            label = "Jungle Rock Island",
            base = true,
            enabled = true,
        },
        industrial = {
            label = "Industrial",
            base = true,
            enabled = true,
        },
        small_island = {
            label = "Small Island",
            base = true,
            enabled = true,
        },
        utah = {
            label = "Utah",
            base = true,
            enabled = true,
        },
        west_coast_usa = {
            label = "West Coast",
            base = true,
            enabled = true,
        },
        driver_training = {
            label = "Driver Training",
            base = true,
            enabled = true,
        },
        derby = {
            label = "Derby Arena",
            base = true,
            enabled = true,
        },
        johnson_valley = {
            label = "Johnson Valley",
            base = true,
            enabled = true,
        }
    }
}

---@return {Client: string[], Maps: string[]}
local function generateCache()
    local res = { Client = {}, Maps = {} }
    for _, mod in ipairs(FS.ListFiles(M.clientFolder)) do
        if mod:find("%.zip$") then
            table.insert(res.Client, mod)
        end
    end
    for _, mod in ipairs(FS.ListFiles(M.mapsFolder)) do
        if mod:find("%.zip$") then
            table.insert(res.Maps, mod)
        end
    end
    table.sort(res.Client)
    table.sort(res.Maps)
    return res
end

---@param archivePath string
---@return {name: string, archive: string, label: string}[]
local function extractLevelData(archivePath)
    ---@type any
    local archiveName = archivePath:split2("/")
    archiveName = archiveName[#archiveName]

    local dstPath = BJSPluginPath:gsub("Server/BeamJoyServer", "tmp")
    if FS.Exists(dstPath) then FS.RemoveDirectory(dstPath) end
    LogInfo("Analyzing " .. archivePath .. " ...")
    FS.ExtractTo(archivePath, dstPath)

    local res = {}

    if table.includes(FS.ListDirectories(dstPath), "levels") then
        for _, name in ipairs(FS.ListDirectories(dstPath .. "/levels")) do
            ---@type string?
            local label
            if FS.Exists(dstPath .. "/levels/" .. name .. "/info.json") then
                local file = io.open(dstPath .. "/levels/" .. name .. "/info.json", "r")
                if file then
                    local ok = pcall(function()
                        local content = utils_json.parse(file:read("*a")) or {}
                        label = content.title
                    end)
                    if not ok then
                        LogError(string.format("Error while reading %s/levels/%s/info.json : Maformed JSON file", dstPath,
                            name))
                    end
                    file:close()
                end
            end
            table.insert(res, { name = name, archive = archiveName, label = label or name })
        end
    end
    FS.RemoveDirectory(dstPath)
    return res
end

--- mapsData index is mapName
---@return table<string, {archive: string, label: string}> mapsData, boolean rebootNeeded
local function sanitizeAndRetrieveModdedMaps()
    local currentMap = services_core.getCurrentMap()
    local rebootNeeded = false
    local skipped = {} -- already analyzed archives moved/copied to idle
    local res = {}
    for _, mod in ipairs(FS.ListFiles(M.clientFolder)) do
        if mod:find("%.zip$") then
            local maps
            if table.includes(M.modsCache.Client, mod) or table.includes(M.modsCache.Maps, mod) then
                -- already cached maps
                maps = table.filter(M.data, function(map, name)
                    return map.archive == mod
                end):map(function(map, name)
                    return {
                        name = name,
                        archive = map.archive,
                        label = map.label,
                    }
                end):values()
            else
                maps = extractLevelData(M.clientFolder .. "/" .. mod)
            end
            if table.length(maps) > 0 then
                if not FS.Exists(M.mapsFolder .. "/" .. mod) then
                    -- copy to maps folder if not already there
                    FS.Copy(M.clientFolder .. "/" .. mod, M.mapsFolder .. "/" .. mod)
                    table.insert(skipped, mod)
                end
                if not table.any(maps, function(data)
                        return data.name == currentMap
                    end) then
                    -- modded map is active and not the current one
                    if FS.Exists(M.mapsFolder .. "/" .. mod) then
                        FS.Remove(M.clientFolder .. "/" .. mod)
                    end
                    rebootNeeded = true
                    table.insert(skipped, mod)
                end
                table.forEach(maps, function(data)
                    res[data.name] = {
                        archive = data.archive,
                        label = data.label,
                    }
                end)
            end
        end
    end
    for _, mod in ipairs(FS.ListFiles(M.mapsFolder)) do
        if mod:find("%.zip$") and not table.includes(skipped, mod) then
            local maps
            if table.includes(M.modsCache.Maps, mod) then
                -- already cached maps
                maps = table.filter(M.data, function(map, name)
                    return map.archive == mod
                end):map(function(map, name)
                    return {
                        name = name,
                        archive = map.archive,
                        label = map.label,
                    }
                end):values()
            else
                maps = extractLevelData(M.mapsFolder .. "/" .. mod)
            end
            if table.length(maps) > 0 then
                if table.any(maps, function(data)
                        return data.name == currentMap
                    end) and not FS.Exists(M.clientFolder .. "/" .. mod) then
                    -- modded map is the current one and is not active
                    FS.Copy(M.mapsFolder .. "/" .. mod, M.clientFolder .. "/" .. mod)
                    rebootNeeded = true
                end
                table.forEach(maps, function(data)
                    res[data.name] = {
                        archive = data.archive,
                        label = data.label,
                    }
                end)
            end
        end
    end
    return res, rebootNeeded
end

local function scanNewMods()
    LogWarn(services_lang.get("maps.scan.start"))
    local modded, rebootNeeded = sanitizeAndRetrieveModdedMaps()
    local changed = false
    table.forEach(modded, function(data, name)
        if not M.data[name] then
            -- new modded map
            M.data[name] = {
                label = data.label,
                enabled = true,
                base = false,
                archive = data.archive,
            }
            changed = true
        elseif M.data[name].ignore then
            -- re-enable modded map
            M.data[name].ignore = nil
            changed = true
        end
    end)
    table.forEach(M.data, function(map, name)
        if not map.base and not modded[name] then
            -- disable obsolete modded map
            M.data[name].ignore = true
            changed = true
        end
    end)

    if changed then
        dao_maps.save(M.data)
    end

    if rebootNeeded then
        LogWarn(services_lang.get("maps.scan.done.withReboot"))
        utils_async.delayTask(exit, 3)
    else
        LogInfo(services_lang.get("maps.scan.done"))
    end
end

local function onInit()
    M.clientFolder = BJSPluginPath:gsub("Server/BeamJoyServer", "Client")
    M.mapsFolder = BJSPluginPath:gsub("Server/BeamJoyServer", "Maps")
    if not FS.Exists(M.mapsFolder) then
        FS.CreateDirectory(M.mapsFolder)
    end

    table.assign(M.data, dao_maps.get() or {})

    table.assign(M.modsCache, dao_maps.getModsCache() or {})
    local cache = generateCache()
    if not table.compare(M.modsCache, cache, true) then
        -- set MaxPlayers to 0 to prevent connections during mods scan
        local maxPlayers = services_core.data.MaxPlayers
        MP.Set(MP.Settings.MaxPlayers, 0)
        scanNewMods()
        M.modsCache = generateCache()
        dao_maps.saveModsCache(M.modsCache)
        MP.Set(MP.Settings.MaxPlayers, maxPlayers)
    end

    if not M.data[services_core.getCurrentMap()] or
        M.data[services_core.getCurrentMap()].ignore then
        -- invalid current map
        LogWarn(services_lang.get("maps.start.fallback"):var({
            newMap = "gridmap_v2"
        }))
        services_core.setMap("gridmap_v2")
    end

    communications_rx.addHandler("setMaps", M.setMaps)
    communications_rx.addHandler("switchMap", M.switchMap)

    services_consoleCommands.register("map", "commands.map.args", "commands.map.desc", M.consoleMap)
end

---@param caches table<string, any>
---@param playerID integer
local function onBJRequestCache(caches, playerID)
    if services_permissions.hasAllPermissions(playerID, BJ_PERMISSIONS.SetMaps) then
        caches.maps = M.data
    elseif services_permissions.hasAllPermissions(playerID, BJ_PERMISSIONS.SwitchMap) then
        caches.maps = table.filter(M.data, function(map)
            return map.enabled
        end)
    end
end

---@param ctxt BJSContext
---@param mapsData table<string, BJMap>
local function setMaps(ctxt, mapsData)
    if ctxt.sender and not services_permissions.hasAllPermissions(ctxt.senderID, BJ_PERMISSIONS.SetMaps) then
        return
    end

    table.forEach(mapsData, function(map, name)
        if not M.data[name] then
            -- ensure only existing maps
            mapsData[name] = nil
        else
            -- force restricted fields values
            local current = M.data[name]
            map.base = current.base
            map.ignore = current.ignore
            map.archive = current.archive
            if current.ignore then
                map.enabled = current.enabled
            end
        end
    end)
    -- ensure base maps are present
    table.filter(M.data, function(m) return m.base end)
        :forEach(function(map, name)
            if not mapsData[name] then
                mapsData[name] = map
            end
        end)

    if not table.compare(M.data, mapsData, true) then
        M.data = mapsData
        dao_maps.save(M.data)

        services_players.players:forEach(function(p)
            local caches = {}
            M.onBJRequestCache(caches, p.playerID)
            communications_tx.sendToPlayer(p.playerID, "sendCache", caches)
        end)
    end
end

local function switchMap(ctxt, newMapName)
    local currentMapName = services_core.getCurrentMap()
    if ctxt.sender and not services_permissions.hasAllPermissions(ctxt.senderID, BJ_PERMISSIONS.SwitchMap) then
        return
    elseif not M.data[newMapName] or currentMapName == newMapName then
        return
    end

    local currentMap = M.data[currentMapName]
    local newMap = M.data[newMapName]
    if not currentMap.base then
        -- current is modded, remove archive
        FS.Remove(M.clientFolder .. "/" .. currentMap.archive)
        M.modsCache = generateCache()
        dao_maps.saveModsCache(M.modsCache)
    end
    if not newMap.base then
        -- new map is modded, copy archive
        FS.Copy(M.mapsFolder .. "/" .. newMap.archive,
            M.clientFolder .. "/" .. newMap.archive)
        M.modsCache = generateCache()
        dao_maps.saveModsCache(M.modsCache)
    end
    services_core.setMap(newMapName)

    local finishProcess = function()
        if not currentMap.base or not newMap.base then
            -- reboot required if previous or next map is modded
            LogWarn(services_lang.get("maps.switch.rebootWarn"))
            extensions.hook("onMapChangedWithReboot", currentMapName, newMapName)
            exit()
        else
            extensions.hook("onMapChanged", currentMapName, newMapName)
        end
    end
    -- warn and kick all players
    for i = 11, 1, -1 do
        utils_async.delayTask(function()
            if i == 11 then
                -- kick all
                services_players.players:forEach(function(p) ---@param p BJSPlayer
                    services_players.drop(p.playerID, "auth.kick.mapChanged")
                end)
                finishProcess()
            else
                if services_players.players:length() == 0 and
                    MP.GetPlayerCount() == 0 then
                    for j = 11, i + 1, -1 do
                        utils_async.removeTask(string.format("mapChangeKickCountdown-%d", j))
                    end
                    finishProcess()
                    return
                end
                services_players.players:forEach(function(p) ---@param p BJSPlayer
                    services_players.sendBroadcast(p.playerID, "beamjoy.broadcasts.mapChangeKick",
                        { time = 10 - i + 1 })
                    services_chat.sendServerChat(p.playerID, "beamjoy.broadcasts.mapChangeKick",
                        { time = 10 - i + 1 })
                end)
            end
        end, i, string.format("mapChangeKickCountdown-%d", i))
    end
end

---@param args string[]
local function consoleMap(args)
    if not args[1] then
        local current = services_core.getCurrentMap()
        local out = "\n" .. services_lang.get("commands.map.current")
            :var({ map = M.data[current] and M.data[current].label or current })
        print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_BLUE) ..
            out .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
        return
    end
    local matches
    if M.data[args[1]] then
        -- exact match
        matches = { args[1] }
    else
        -- fuzzy matches
        matches = table.keys(M.data):filter(function(name)
            return tostring(name):lower():find(args[1]:lower()) ~= nil
        end)
    end
    if #matches == 0 then
        local out = "\n" .. services_lang.get("commands.map.notFound")
        out = out .. "\n" .. table.keys(M.data):sort():join(" ")
        print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_RED) ..
            out .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
        return
    elseif #matches > 1 then
        local out = "\n" .. services_lang.get("commands.map.ambiguous")
        out = out .. "\n" .. matches:sort():join(" ")
        print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_RED) ..
            out .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
        return
    end

    M.switchMap(InitContext(), matches[1])
    local out = "\n" .. services_lang.get("commands.map.current")
        :var({ map = M.data[matches[1]] and M.data[matches[1]].label or matches[1] })
    print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_GREEN) ..
        out .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
end

M.onInit = onInit
M.onBJRequestCache = onBJRequestCache

M.setMaps = setMaps
M.switchMap = switchMap
M.consoleMap = consoleMap

return M
