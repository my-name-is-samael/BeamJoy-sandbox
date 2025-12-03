local DEFAULT_GRAVITY = -9.81
local M = {
    ---@class BJEnvironment
    data = {
        simSpeed = 1,
        simPause = false,
        timeSync = false,
        ToD = 0, -- noon
        dayNightCycle = false,
        ---@type integer
        dayLength = 1800, -- seconds
        dayScale = 1,
        nightScale = 2,
        nightBrightnessMultiplier = 1,
        gravitySync = false,
        gravity = DEFAULT_GRAVITY,
    },
    default = {},
}

local function onInit()
    M.default = table.clone(M.data)
    table.assign(M.data, dao_environment.get() or {})

    communications_rx.addHandler("simSpeed", M.changeSimSpeed)
    communications_rx.addHandler("simPause", M.changeSimPause)
    communications_rx.addHandler("setEnv", M.changeEnv)

    services_consoleCommands.register("env", "commands.bjenv.args", "commands.bjenv.desc", M.consoleEnv)
end

local function onBJRequestCache(caches, targetID)
    caches.environment = table.clone(M.data)
end

---@param playerID integer
local function onPlayerDisconnect(playerID)
    if not services_players.players:filter(function(p) return p.playerID ~= playerID end):any(function(p)
            return
                services_permissions.isStaff(p.playerName)
        end) then
        -- no staff member left
        if M.data.simSpeed ~= 1 or M.data.simPause then
            M.changeSimPause(InitContext(), false)
            M.changeSimSpeed(InitContext(), 1)
        end
        if M.data.gravity ~= DEFAULT_GRAVITY then
            M.changeEnv(InitContext(), { gravity = DEFAULT_GRAVITY })
        end
    end
end

local function onSlowUpdate()
    -- cycle ToD
    if MP.GetPlayerCount() > 0 and
        M.data.timeSync and M.data.dayNightCycle and not M.data.simPause then
        local scale
        if M.data.ToD >= .25 and M.data.ToD < .75 then
            -- night
            scale = M.data.nightScale
        else
            -- day
            scale = M.data.dayScale
        end
        local step = 0.5 / (M.data.dayLength / 2 / scale)
        if M.data.simSpeed ~= 1 then
            step = step * M.data.simSpeed
        end
        M.data.ToD = math.round((M.data.ToD + step) % 1, 10)
        dao_environment.save(M.data)
    end
end

---@param payload BJServerTick
local function onBJRequestServerTickPayload(payload)
    if M.data.timeSync and M.data.dayNightCycle then
        payload.ToD = M.data.ToD
    end
end

---@param ctxt BJSContext
---@param newSpeed integer
local function changeSimSpeed(ctxt, newSpeed)
    if not tonumber(newSpeed) then return end
    if ctxt.sender and not services_permissions.hasAnyPermission(ctxt.senderID,
            BJ_PERMISSIONS.SetEnvironment) then
        return
    end

    if M.data.simSpeed ~= newSpeed then
        M.data.simSpeed = newSpeed
        dao_environment.save(M.data)
        communications_tx.sendToPlayer(communications_tx.ALL_PLAYERS, "sendCache",
            { environment = { simSpeed = M.data.simSpeed, simPause = M.data.simPause } })
    end
end

---@param ctxt BJSContext
---@param pauseState boolean
local function changeSimPause(ctxt, pauseState)
    if ctxt.sender and not services_permissions.hasAnyPermission(ctxt.senderID,
            BJ_PERMISSIONS.SetEnvironment) then
        return
    end

    if M.data.simPause ~= pauseState then
        M.data.simPause = pauseState
        dao_environment.save(M.data)
        communications_tx.sendToPlayer(communications_tx.ALL_PLAYERS, "sendCache",
            { environment = { simSpeed = M.data.simSpeed, simPause = M.data.simPause } })
    end
end

---@param ctxt BJSContext
---@param payload {timeSync: boolean, ToD: number, dayNightCycle: boolean, dayLength: integer, dayScale: number, nightScale: number, gravitySync: boolean, gravity: number}
local function changeEnv(ctxt, payload)
    if ctxt.sender and not services_permissions.hasAnyPermission(ctxt.senderID,
            BJ_PERMISSIONS.SetEnvironment) then
        return
    end

    local newData = table.assign(table.clone(M.data), payload)
    if not table.compare(M.data, newData) then
        table.assign(M.data, newData)
        if not M.data.gravitySync and M.data.gravity ~= DEFAULT_GRAVITY then
            M.data.gravity = DEFAULT_GRAVITY
        end
        dao_environment.save(M.data)
        communications_tx.sendToPlayer(communications_tx.ALL_PLAYERS, "sendCache",
            { environment = payload })
    end
end

local function consoleEnvHelp()
    local lang = services_config.data.Console.Lang
    local args = {}
    local commandMaxLength = 0
    local descs = {}
    local commands = Table({ "timesync", "time", "timeplay", "daylength" })
    commands:forEach(function(v)
        args[v] = services_lang.get("commands.bjenv." .. v .. ".args", lang)
        local length = #args[v] + 1
        if commandMaxLength < length then
            commandMaxLength = length
        end
        descs[v] = services_lang.get("commands.bjenv." .. v .. ".desc", lang)
    end)
    print("\n" .. services_lang.get("commands.usage", lang) .. " :\n" ..
        commands:map(function(cmd)
            return string.format("%s env %s - %s",
                services_consoleCommands.baseCommand,
                string.normalize(args[cmd], commandMaxLength),
                descs[cmd])
        end):join("\n"))
end

local function consoleEnvTimesync(args)
    local lang = services_config.data.Console.Lang
    local printUsage = function()
        print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_RED) ..
            string.format("\n%s : %s env %s - %s",
                services_lang.get("commands.usage", lang),
                services_consoleCommands.baseCommand,
                services_lang.get("commands.bjenv.timesync.args", lang),
                services_lang.get("commands.bjenv.timesync.desc", lang)
            ) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
    end
    local showStatus = function()
        print("\n" .. GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_BLUE) ..
            services_lang.get("commands.bjenv.timesync.status", lang)
            :var({
                state = services_lang.get(M.data.timeSync and
                    "common.enabled" or "common.disabled", lang)
            }) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET)
        )
    end
    if not args[1] then
        return showStatus()
    end
    if args[1] and not table.includes({ "true", "false" }, args[1]:lower()) then
        return printUsage()
    end
    local newState = args[1]:lower() == "true"
    changeEnv(InitContext(), { timeSync = newState })
    return showStatus()
end

local function consoleEnvTime(args)
    local lang = services_config.data.Console.Lang
    local printUsage = function()
        print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_RED) ..
            string.format("\n%s : %s env %s - %s",
                services_lang.get("commands.usage", lang),
                services_consoleCommands.baseCommand,
                services_lang.get("commands.bjenv.time.args", lang),
                services_lang.get("commands.bjenv.time.desc", lang)
            ) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
    end
    local showStatus = function()
        local formattedTime = ""
        if M.data.ToD == 0 then
            formattedTime = services_lang.get("time.noon", lang)
        elseif M.data.ToD == .25 then
            formattedTime = services_lang.get("time.dusk", lang)
        elseif M.data.ToD == .5 then
            formattedTime = services_lang.get("time.night", lang)
        elseif M.data.ToD == .75 then
            formattedTime = services_lang.get("time.dawn", lang)
        else
            local time = (M.data.ToD + .5) % 1
            local hour = math.floor(time * 24)
            local minute = math.round(time % 24 * 60)
            formattedTime = string.format("%s:%s",
                hour < 10 and "0" .. hour or hour,
                minute < 10 and "0" .. minute or minute
            )
        end
        print("\n" .. GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_BLUE) ..
            services_lang.get("commands.bjenv.time.status", lang)
            :var({
                time = formattedTime
            }) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET)
        )
    end
    if not args[1] then
        return showStatus()
    end
    if args[1] and not table.includes({ "dawn", "noon", "dusk", "night" }, args[1]:lower()) then
        return printUsage()
    end
    local newToD
    if args[1]:lower() == "dawn" then
        newToD = .75
    elseif args[1]:lower() == "noon" then
        newToD = 0
    elseif args[1]:lower() == "dusk" then
        newToD = .25
    elseif args[1]:lower() == "night" then
        newToD = .5
    end
    changeEnv(InitContext(), { ToD = newToD })
    return showStatus()
end

local function consoleEnvTimeplay(args)
    local lang = services_config.data.Console.Lang
    local printUsage = function()
        print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_RED) ..
            string.format("\n%s : %s env %s - %s",
                services_lang.get("commands.usage", lang),
                services_consoleCommands.baseCommand,
                services_lang.get("commands.bjenv.timeplay.args", lang),
                services_lang.get("commands.bjenv.timeplay.desc", lang)
            ) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
    end
    local showStatus = function()
        print("\n" .. GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_BLUE) ..
            services_lang.get("commands.bjenv.timeplay.status", lang)
            :var({
                state = services_lang.get(M.data.dayNightCycle and
                    "common.enabled" or "common.disabled", lang)
            }) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET)
        )
    end
    if not args[1] then
        return showStatus()
    end
    if args[1] and not table.includes({ "true", "false" }, args[1]:lower()) then
        return printUsage()
    end
    local newState = args[1]:lower() == "true"
    changeEnv(InitContext(), { dayNightCycle = newState })
    return showStatus()
end

local function consoleEnvDaylength(args)
    local lang = services_config.data.Console.Lang
    local printUsage = function()
        print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_RED) ..
            string.format("\n%s : %s env %s - %s",
                services_lang.get("commands.usage", lang),
                services_consoleCommands.baseCommand,
                services_lang.get("commands.bjenv.daylength.args", lang),
                services_lang.get("commands.bjenv.daylength.desc", lang)
            ) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
    end
    local showStatus = function()
        local minutes = math.floor(M.data.dayLength / 60)
        local seconds = math.round(M.data.dayLength % 60)
        local formattedDuration = string.format("%d %s", minutes,
            services_lang.get("time.minutes", lang))
        if seconds > 0 then
            formattedDuration = string.format("%s %s %d %s",
                formattedDuration,
                services_lang.get("common.and", lang),
                seconds,
                services_lang.get("time.second" .. (seconds > 1 and "s" or ""), lang)
            )
        end
        print("\n" .. GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_BLUE) ..
            services_lang.get("commands.bjenv.daylength.status", lang)
            :var({
                duration = formattedDuration
            }) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET)
        )
    end
    if not args[1] then
        return showStatus()
    end
    local min, max = 240, 18000 -- 4 minutes to 5 hours
    local value = tonumber(args[1])
    if not value then
        return printUsage()
    elseif value < min or value > max then
        return print("\n" .. GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.LIGHT_RED) ..
            services_lang.get("commands.bjenv.daylength.limits", lang):var({
                min = min, max = max
            }) .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
    end
    changeEnv(InitContext(), { dayLength = value })
    return showStatus()
end

---@param args string[]
local function consoleEnv(args)
    local fns = {
        timesync = consoleEnvTimesync,
        time = consoleEnvTime,
        timeplay = consoleEnvTimeplay,
        daylength = consoleEnvDaylength,
    }
    if not args[1] or not fns[args[1]:lower()] then
        return consoleEnvHelp()
    end

    fns[args[1]:lower()](table.filter(args, function(_, i) return i > 1 end))
end

M.onInit = onInit
M.onBJRequestCache = onBJRequestCache
M.onPlayerDisconnect = onPlayerDisconnect
M.onSlowUpdate = onSlowUpdate
M.onBJRequestServerTickPayload = onBJRequestServerTickPayload

M.changeSimSpeed = changeSimSpeed
M.changeSimPause = changeSimPause
M.changeEnv = changeEnv
M.consoleEnv = consoleEnv

return M
