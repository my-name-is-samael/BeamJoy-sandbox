local M = {
    _windowName = "BJDebug",
    ---@type BJWindow?
    windowConfig = nil,

    filter = "",
    renderString = true,
    maxLines = 200,
}
local totalLines, nextValue, ok, value, filtered

---@param val any
---@return string
local function prepareValue(val)
    ok, value = pcall(function() return type(val) ~= "string" and tostring(val) or '"' .. val .. '"' end)
    return ok and value or "nil"
end

---@param el any
---@param key? string|integer
---@return boolean
local function filterMatch(el, key)
    if key and tostring(key):lower():find(M.filter:lower()) ~= nil then
        return true
    end
    if type(el) == "table" then
        return Table(el):any(function(v, k) return filterMatch(v, k) end)
    end
    return tostring(el):lower():find(M.filter:lower()) ~= nil
end

---@generic T
---@param obj T
---@return T
local function applyFilter(obj)
    if type(obj) == "table" then
        return Table(obj):reduce(function(res, v, k)
            if type(v) == "table" then
                res[k] = filterMatch(v, k) and applyFilter(v) or nil
            else
                res[k] = filterMatch(v, k) and v or nil
            end
            return res
        end, {})
    else
        return filterMatch(obj) and obj or nil
    end
end

---@param ctxt TickContext
local function updateCacheAndFilter(ctxt)
    value = table.clone(DEBUG)
    if value and type(value) ~= "function" then
        filtered = #M.filter == 0 and value or applyFilter(value)
    end
end

---@param ctxt TickContext
local function header(ctxt)
    if #M.filter == 0 then
        Icon(beamjoy_imgui_icon.ICONS.ab_filter_default)
    else
        if IconButton("debug-filter-clear", beamjoy_imgui_icon.ICONS.ab_filter_default,
                { btnStyle = beamjoy_imgui_style.BTN_PRESETS.ERROR, bgLess = true }) then
            M.filter = ""
            updateCacheAndFilter(ctxt)
        end
    end
    SameLine()
    nextValue = InputText("debug-filter", M.filter)
    if nextValue then
        M.filter = nextValue
        updateCacheAndFilter(ctxt)
    end

    Text("Render type")
    SameLine()
    if Button("debug-render-type", M.renderString and "String" or "Tree") then
        M.renderString = not M.renderString
    end

    Text("Max lines")
    SameLine()
    nextValue = SliderIntPrecision("debug-max-lines", M.maxLines, 50, 500, {
        step = 5, stepFast = 10, formatRender = "%d lines", disabled = not M.renderString,
    })
    if nextValue then M.maxLines = nextValue end

    Separator()
end

local function drawContentString(obj, key)
    if key then Text(prepareValue(key) .. " =") end
    if type(obj) == "table" then
        SameLine()
        Text(string.var("(table, {1} child.ren)", { table.length(obj) }))
        Indent()
        table.map(obj, function(v, k)
            return { k = k, v = v }
        end):sort(function(a, b)
            return tostring(a.k):lower() < tostring(b.k):lower()
        end):forEach(function(el)
            if totalLines >= M.maxLines then return end
            drawContentString(el.v, el.k)
        end)
        Unindent()
    else
        SameLine()
        Text(string.var("{1} ({2})", { prepareValue(obj), type(obj) }))
    end
    totalLines = totalLines + 1
end

local function drawContentTree(obj, key)
    if type(obj) == "table" then
        local opened = not key and true or BeginTree(tostring(key) .. "")
        if opened then
            table.map(obj, function(v, k)
                return { k = k, v = v }
            end):sort(function(a, b)
                return tostring(a.k):lower() < tostring(b.k):lower()
            end):forEach(function(el)
                drawContentTree(el.v, el.k)
            end)
        end
        if key and opened then
            EndTree()
        end
    else
        if key then
            Text(prepareValue(key) .. " =")
            SameLine()
        end
        Text(string.var("{1} ({2})", { prepareValue(obj), type(obj) }))
    end
end

local function body(ctxt)
    if type(DEBUG) == "table" and not table.compare(DEBUG, value) or
        DEBUG ~= value then
        updateCacheAndFilter(ctxt)
    end
    if not value then return end
    if type(value) == "function" then
        ok, filtered = pcall(value, ctxt)
        if not ok then
            Text(tostring(filtered), { wrap = true, color = beamjoy_imgui_style.TEXT_COLORS.ERROR })
            return
        end
        if #M.filter > 0 then
            filtered = applyFilter(filtered)
        end
    end

    if M.renderString then
        totalLines = 0
        drawContentString(filtered)
        if totalLines >= M.maxLines then
            Text("...")
        end
    else
        drawContentTree(filtered)
    end
end

---@param ctxt TickContext
local function render(ctxt)
    header(ctxt)
    body(ctxt)
end

local function onInit()
    beamjoy_imgui_manager.GUI.registerWindow(M._windowName)

    M.windowConfig = {
        name = M._windowName,
        alpha = .5,
        render = render,
        onClose = function() DEBUG = nil end
    }
end

local function onUpdate()
    ---@diagnostic disable-next-line : undefined-global
    if DEBUG ~= nil and M.windowConfig and beamjoy_context then
        RenderWindow(beamjoy_context.get(), M.windowConfig.name,
            M.windowConfig)
    end
end

M.onInit = onInit
M.onUpdate = onUpdate

return M
