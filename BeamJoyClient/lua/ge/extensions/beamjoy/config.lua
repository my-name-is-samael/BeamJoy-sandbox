local M = {
    ---@type BJCConfig
    data = {}, --- @diagnostic disable-line
    core = nil,
}

local function onInit()
    beamjoy_communications.addHandler("sendCache", M.retrieveCache)

    beamjoy_communications_ui.addHandler("BJRequestConfigData", M.sendConfigToUI)
    beamjoy_communications_ui.addHandler("BJRequestModelsBlacklist", M.sendModelBlacklistToUI)
    beamjoy_communications_ui.addHandler("BJRequestWhitelistData", M.sendWhitelistToUI)
    beamjoy_communications_ui.addHandler("BJRequestCoreData", M.sendCoreToUI)
    beamjoy_communications_ui.addHandler("BJRequestBroadcastsData", M.sendBroadcastToUI)
end

---@param req RequestAuthorization
---@param model string
---@param config string?
local function onBJRequestCanSpawnVehicle(req, model, config)
    if beamjoy_permissions.isStaff() or
        beamjoy_permissions.hasAllPermissions(nil,
            BJ_PERMISSIONS.BypassModelBlacklist) then
        return
    end
    if table.includes(M.data.ModelBlacklist, model) then
        req.state = false
    end
end

---@param caches table
local function retrieveCache(caches)
    if caches.config then
        M.data = caches.config
        M.sendConfigToUI()
        M.sendModelBlacklistToUI()
        M.sendWhitelistToUI()
        M.sendBroadcastToUI()
    end
    if caches.core then
        M.core = caches.core
        M.sendCoreToUI()
    end
end

local function sendConfigToUI()
    beamjoy_communications_ui.send("BJSendConfigData", {
        AllowClientMods = M.data.AllowClientMods,
    })
end

local function sendModelBlacklistToUI()
    extensions.core_jobsystem.create(function(job)
        beamjoy_communications_ui.send("BJModelsBlacklist", {
            list = M.data.ModelBlacklist,
            models = table.map(beamjoy_vehicles.getAllVehicleConfigs(job,
                        { cars = true, trucks = true, trailers = true, props = true }),
                    function(model, modelKey)
                        return {
                            key = modelKey,
                            label = model.label,
                        }
                    end):values()
                :sort(function(a, b) return a.label < b.label end),
        })
    end)
end

local function sendWhitelistToUI()
    beamjoy_communications_ui.send("BJSendWhitelistData", {
        state = M.data.Whitelist ~= nil and M.data.Whitelist.Enabled,
        list = M.data.Whitelist and M.data.Whitelist.PlayerNames or {},
    })
end

local function sendCoreToUI()
    beamjoy_communications_ui.send("BJSendCoreData", M.core)
end

local function sendBroadcastToUI()
    beamjoy_communications_ui.send("BJSendBroadcastsData", { data = M.data.Broadcasts, langs = beamjoy_lang.langs })
end


M.onInit = onInit
M.onBJRequestCanSpawnVehicle = onBJRequestCanSpawnVehicle

M.retrieveCache = retrieveCache
M.sendConfigToUI = sendConfigToUI
M.sendModelBlacklistToUI = sendModelBlacklistToUI
M.sendWhitelistToUI = sendWhitelistToUI
M.sendCoreToUI = sendCoreToUI
M.sendBroadcastToUI = sendBroadcastToUI

return M
