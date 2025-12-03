local M = {
    dependencies = {},

    data = {
        ---@type GizmoObject[]
        safeZones = {},
    },
}

local function onInit()
    beamjoy_communications.addHandler("sendCache", M.retrieveCache)
end

local function retrieveCache(caches)
    if caches.activities then
        local changes = table.filter(caches.activities, function(v, k)
            return not table.compare(v, M.data[k])
        end):keys()
        M.data = caches.activities
        table.forEach(M.data.safeZones, ParseGizmoObject)
        extensions.hook("onBJActivityChanged", changes)
    end
end

M.onInit = onInit

M.retrieveCache = retrieveCache

return M
