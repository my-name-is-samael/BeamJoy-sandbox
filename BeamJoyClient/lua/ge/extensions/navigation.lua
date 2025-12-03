local M = {}

local function onSlowUpdate()
    local mpVeh = beamjoy_vehicles.getCurrent()
    if not mpVeh then return end
    local pos = beamjoy_vehicles.getVehiclePositionRotation(mpVeh.veh)

    local wps = extensions.core_groundMarkers.endWP or {}
    if wps[1] and pos:distance(vec3(wps[1])) < 5 then
        extensions.core_groundMarkers.setPath(table.filter(wps,
            function(_, i) return i > 1 end))
        if extensions.freeroam_bigMapMode.bigMapActive() then
            extensions.freeroam_bigMapMode.setNavFocus(extensions.core_groundMarkers.endWP[1])
        end
    end
end

M.onSlowUpdate = onSlowUpdate

return M
