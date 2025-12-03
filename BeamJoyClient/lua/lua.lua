---@return true
function TrueFn()
    return true
end

---@return false
function FalseFn()
    return false
end

---@return integer
function GetCurrentTime()
    return os.time(os.date("!*t")) ---@diagnostic disable-line
end

---@return integer
function GetCurrentTimeMillis()
    local ms = require "socket".gettime() % 1
    local time = GetCurrentTime() + ms
    return math.round(time * 1000)
end

---@param str string
---@return any
function GetSubobject(str)
    local parts = str:split2(".")
    local obj = _G
    for i = 1, #parts do
        obj = obj[parts[i]]
        if obj == nil and i < #parts then
            error(string.format("Subobject has reached nil in %s", parts[i]))
            return nil
        end
    end
    return obj
end

local PRINTOBJ_MAX_TABLE_CHILDREN = 20
local PRINTOBJ_MAX_TABLE_CHILDREN_SHOW = 3
---@param name string
---@param obj any
---@param indent? integer
function _PrintObj(name, obj, indent)
    if indent == nil then indent = 0 end
    local baseIndent = string.rep(" ", 4)
    local strIndent = baseIndent:rep(indent)

    local key = ""
    if type(name) == "string" then
        key = string.format("\"%s\"", name:escape())
    else
        key = string.format("%s (%s)", name, type(name))
    end
    if type(obj) == "table" then
        key = string.format("%s%s = table ", strIndent, key)
        if table.length(obj) == 0 then
            print(string.format("%s(empty)", key))
        elseif table.length(obj) > PRINTOBJ_MAX_TABLE_CHILDREN then
            print(string.format("%s(%d child.ren)", key, table.length(obj)))
            local i = 1
            for k in pairs(obj) do
                if i <= PRINTOBJ_MAX_TABLE_CHILDREN_SHOW then
                    _PrintObj(k, obj[k], indent + 1)
                    i = i + 1
                end
            end
            print(string.format("%s%s...", strIndent, baseIndent))
        else
            print(string.format("%s(%d child.ren)", key, table.length(obj)))
            for k in pairs(obj) do
                _PrintObj(k, obj[k], indent + 1)
            end
        end
    elseif type(obj) == "function" then
        print(string.format("%s%s = function", strIndent, key))
    elseif type(obj) == "string" then
        print(string.format("%s%s = \"%s\" (%s)", strIndent, key, tostring(obj):escape(), type(obj)))
    else
        print(string.format("%s%s = %s (%s)", strIndent, key, tostring(obj), type(obj)))
    end
end

---@param ... any
function PrintObj(...)
    table.forEach({ ... }, function(el)
        _PrintObj("data", el)
    end)
end

dump = dump or PrintObj

---@param obj any
---@param filterStr? string
function PrintObj1Level(obj, filterStr)
    if type(obj) ~= "table" then
        print("Not a table")
        return
    end
    if table.length(obj) == 0 then
        print("empty table")
    else
        local i = 1
        for k, v in pairs(obj) do
            if not filterStr or k:upper():find(filterStr:upper()) then
                local key, val = "", ""

                if type(k) == "string" then
                    key = string.format("\"%s\"", k:escape())
                else
                    key = string.format("%s (%s)", tostring(k), type(k))
                end

                if type(v) == "table" then
                    print(string.format("%d-%s (%d children)", i, tostring(k), table.length(v)))
                elseif type(v) == "function" then
                    val = "function"
                elseif type(v) == "string" then
                    val = string.format("\"%s\"", v:escape())
                else
                    val = string.format("%s (%s)", tostring(v), type(v))
                end

                print(string.format("%d-%s = %s", i, key, val))
                i = i + 1
            end
        end
    end
end
