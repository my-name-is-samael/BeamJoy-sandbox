---@class ServerCommand
---@field command string
---@field args string key or text
---@field desc string key or text
---@field callback fun(args: string[], printUsage: fun())

local M = {
    baseCommand = "bj",

    ---@type table<string, ServerCommand>
    registered = {},
}

local function Help()
    local out = "\n" .. services_lang.get("commands.help.title")
    local indent = "  "
    local args = {}
    local commandMaxLength = 0
    local descs = {}
    local commands = table.sort(M.registered, function(a, b)
        return a.command < b.command
    end) or Table()
    commands:forEach(function(v)
        args[v.command] = services_lang.get(v.args, services_config.data.Console.Lang)
        local length = (#args[v.command] > 0 and #args[v.command] + 1 or 0) + #v.command
        if commandMaxLength < length then
            commandMaxLength = length
        end
        descs[v.command] = services_lang.get(v.desc, services_config.data.Console.Lang)
    end)

    commands:forEach(function(v)
        out = out .. "\n" .. string.format("%s%s %s - %s", indent,
            M.baseCommand,
            string.normalize(v.command .. (#args[v.command] > 0 and " " .. args[v.command] or ""), commandMaxLength),
            descs[v.command])
    end)
    print(out)
end

---@param args string[]
local function Say(args)
    local msg = table.join(args, " ")
    while msg:find("  ") do msg = msg:gsub("  ", " ") end
    services_chat.sendServerChat(communications_tx.ALL_PLAYERS, msg)
end

local function List()
    local out = "\n" .. services_lang.get("commands.list.title")
    services_players.players:forEach(function(player, playerName)
        out = out .. "\n" .. string.format("- [%d] %s (%s) : %d %s%s%s",
            player.playerID, playerName, player.group,
            player.vehicles:length(), services_lang.get("commands.list.vehicles"),
            services_config.data.Traffic.enabled and
            string.format(" (%d %s)", player.vehicles:filter(function(v) return v.isAi end):length(),
                services_lang.get("commands.list.trafficVehicles")) or "",
            player.muted and string.format(" [%s]",
                services_lang.get("commands.list.muted")) or "")
    end)
    print(GetConsoleColor(CONSOLE_COLORS.FOREGROUNDS.YELLOW) ..
        out .. GetConsoleColor(CONSOLE_COLORS.STYLES.RESET))
end

---@param args string[]
local function tryOverrideBaseCommands(args)
    if args[1]:lower() == "help" then
        Help()
    elseif args[1]:lower() == "say" then
        Say(table.filter(args, function(_, i) return i > 1 end))
    elseif args[1]:lower() == "list" then
        List()
    end
end

local function onInit()
    M.register("help", "", "commands.help.desc", Help)
    M.register("say", "commands.say.args", "commands.say.desc", Say)
    M.register("list", "", "commands.list.desc", List)
end

local function printUsage(command)
    local args = services_lang.get(command.args, services_config.data.Console.Lang, "")
    print(string.format("\n%s : %s %s %s",
        services_lang.get("commands.usage"), M.baseCommand,
        command.command, args
    ))
end

---@param message string
local function onConsoleInput(message)
    -- remove extra spaces
    message = message:trim()
    if #message == 0 then return end
    while message:find("  ") do message = message:gsub("  ", " ") end
    -- extracts arguments
    local args = message:split2(" ")
    args = table.filter(args, function(a) return #a > 0 end)

    if args[1] ~= M.baseCommand then
        -- not bj command
        return tryOverrideBaseCommands(args)
    end

    args = args:filter(function(_, i) return i > 1 end)
    if not args[1] then
        return Help()
    end
    local command = M.registered[args[1]:lower()]
    if not command or type(command) ~= "table" then return Help() end


    command.callback(args:filter(function(_, i) return i > 1 end),
        function() printUsage(command) end)
end

---@param command string
---@param args string key or text
---@param desc string key or text
---@param callback fun(args: string[], printUsage: fun())
local function register(command, args, desc, callback)
    command = command:lower()
    if not M.registered[command] then
        M.registered[command] = {
            command = command,
            args = args,
            desc = desc,
            callback = callback,
        }
    end
end

M.onInit = onInit
M.onConsoleInput = onConsoleInput

M.register = register

return M
