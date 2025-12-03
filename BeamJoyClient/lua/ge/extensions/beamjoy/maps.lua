local M = {
    ---@type table<string, BJMap>
    data = {}
}

local function onInit()
    beamjoy_communications.addHandler("sendCache", M.retrieveCache)

    beamjoy_communications_ui.addHandler("BJRequestMapsData", M.sendMapsToUI)
end

local function retrieveCache(caches)
    if caches.maps then
        M.data = caches.maps
        M.sendMapsToUI()
    end
end

local function sendMapsToUI()
    beamjoy_communications_ui.send("BJSendMapsData", M.data)
end

M.onInit = onInit

M.retrieveCache = retrieveCache
M.sendMapsToUI = sendMapsToUI

return M
