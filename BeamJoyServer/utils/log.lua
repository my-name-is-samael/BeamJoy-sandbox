CONSOLE_COLORS = {
    STYLES = {
        RESET = 0,
        BOLD = 1,
        UNDERLINE = 4,
        INVERSE = 7
    },
    FOREGROUNDS = {
        BLACK = 30,
        RED = 31,
        GREEN = 32,
        YELLOW = 33,
        BLUE = 34,
        MAGENTA = 35,
        CYAN = 36,
        LIGHT_GREY = 37,
        GREY = 90,
        LIGHT_RED = 91,
        LIGHT_GREEN = 92,
        LIGHT_YELLOW = 93,
        LIGHT_BLUE = 94,
        LIGHT_MAGENTA = 95,
        LIGHT_CYAN = 96,
        WHITE = 97,
    },
    BACKGROUNDS = {
        BLACK = 40,
        RED = 41,
        GREEN = 42,
        YELLOW = 43,
        BLUE = 44,
        MAGENTA = 45,
        CYAN = 46,
        LIGHT_GREY = 47,
        GREY = 100,
        LIGHT_RED = 101,
        LIGHT_GREEN = 102,
        LIGHT_YELLOW = 103,
        LIGHT_BLUE = 104,
        LIGHT_MAGENTA = 105,
        LIGHT_CYAN = 106,
        WHITE = 107,
    }
}
function GetConsoleColor(fg, bg)
    local strColor = string.format("%s[%s", string.char(27), tostring(fg))
    if bg then
        strColor = string.format("%s;%s", strColor, tostring(bg))
    end
    return string.format('%sm', strColor)
end

local logTypes = {}
function SetLogType(tag, tagColor, tagBgColor, stringColor, stringBgColor)
    tagColor = tagColor or 0
    stringColor = stringColor or 0
    logTypes[tag] = {
        headingColor = GetConsoleColor(tagColor, tagBgColor),
        stringColor = GetConsoleColor(stringColor, stringBgColor)
    }
end

function Log(content, tag)
    tag = tag or "BJS"

    local resetColor = GetConsoleColor(0)
    local prefix = ""

    local tagColor = resetColor
    local stringColor = resetColor
    if logTypes[tag] then
        tagColor = logTypes[tag].headingColor
        stringColor = logTypes[tag].stringColor
    end
    prefix = string.format("%s%s[%s]%s %s", prefix, tagColor, tag, resetColor, stringColor)

    if content == nil then
        content = "nil"
    elseif type(content) == "boolean" or type(content) == "number" then
        content = tostring(content)
    elseif type(content) == 'table' then
        content = string.format("table (%d children)", table.length(content))
    end

    print(string.format("%s%s%s", prefix, content, GetConsoleColor(0)))
end

SetLogType("DEBUG", CONSOLE_COLORS.FOREGROUNDS.WHITE, CONSOLE_COLORS.BACKGROUNDS.LIGHT_GREEN,
CONSOLE_COLORS.FOREGROUNDS.LIGHT_GREEN)
function LogDebug(content)
    local show = not MP.Get or MP.Get(MP.Settings.Debug)
    if not show then return end

    Log(content, "DEBUG")
end

SetLogType("INFO", CONSOLE_COLORS.FOREGROUNDS.LIGHT_BLUE, nil, CONSOLE_COLORS.FOREGROUNDS.CYAN)
function LogInfo(content)
    Log(content, "INFO")
end

SetLogType("ERROR", CONSOLE_COLORS.FOREGROUNDS.RED, nil, CONSOLE_COLORS.FOREGROUNDS.LIGHT_RED)
function LogError(content)
    Log(content, "ERROR")
end

SetLogType("WARN", CONSOLE_COLORS.FOREGROUNDS.YELLOW, nil, CONSOLE_COLORS.FOREGROUNDS.LIGHT_YELLOW)
function LogWarn(content)
    Log(content, "WARN")
end
