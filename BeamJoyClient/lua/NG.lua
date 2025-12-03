function AddPreloadedDependencies(ext)
    if type(ext) == "table" and
        type(ext.preloadedDependencies) == "table" and
        type(ext.dependencies) == "table" then
        table.addAll(ext.dependencies, ext.preloadedDependencies, true)
    end
end

function InitPreloadedDependencies(ext)
    if type(ext) == "table" and
        type(ext.preloadedDependencies) == "table" then
        table.forEach(ext.preloadedDependencies, function(dep)
            setExtensionUnloadMode(extensions[dep], "manual")
        end)
    end
end

function RollBackNGFunctionsWrappers(baseFunctions)
    for extName, fns in pairs(baseFunctions) do
        if extensions.isExtensionLoaded(extName) then
            for fnName, fn in pairs(fns) do
                if type(extensions[extName][fnName]) == "function" and
                    type(fn) == "function" then
                    extensions[extName][fnName] = fn
                end
            end
        end
    end
end

---@param defaultState boolean?
---@return RequestAuthorization
function CreateRequestAuthorization(defaultState)
    return { state = defaultState == true, reasons = {} }
end

---@param obj GizmoObject
function ParseGizmoObject(obj)
    obj.pos = vec3(obj.pos)
    obj.dir = vec3(obj.dir)
    obj.scales = vec3(obj.scales)
    obj.up = vec3(obj.up)
end
