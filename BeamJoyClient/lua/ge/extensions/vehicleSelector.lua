local M = {
    dependencies = { "uiHelpers", "beamjoy_vehicles" },

    baseFunctions = {},

    caches = {
        ---@type table?
        vueAllModelsGroups = nil,
    },
}

local function cloneCurrent()
    local veh = be:getPlayerVehicle(0)
    if not veh then return end
    local fullConfig = beamjoy_vehicles.getFullConfig(veh)
    if not fullConfig then return end
    local config = fullConfig.key or nil
    local req = CreateRequestAuthorization(true)
    extensions.hook("onBJRequestCanSpawnVehicle", req, veh.jbeam, config)
    if req.state then
        return M.baseFunctions.core_vehicles.cloneCurrent()
    end
end

local function spawnNewVehicle(model, opt)
    local config
    if type(opt) == "table" then
        if type(opt.config) == "string" then
            if opt.config:endswith(".pc") then
                config = string.match(opt.config, "([^./]*).pc")
            else
                config = opt.config
            end
        end
    end
    local req = CreateRequestAuthorization(true)
    extensions.hook("onBJRequestCanSpawnVehicle", req, model, config)
    if req.state then
        return M.baseFunctions.core_vehicles.spawnNewVehicle(model, opt)
    end
end

local function replaceVehicle(model, opt, otherVeh)
    local config
    if type(opt) == "table" then
        if type(opt.config) == "string" then
            if opt.config:endswith(".pc") then
                config = string.match(opt.config, "([^./]*).pc")
            else
                config = opt.config
            end
        end
    end
    local req = CreateRequestAuthorization(true)
    extensions.hook("onBJRequestCanSpawnVehicle", req, model, config)
    if req.state then
        return M.baseFunctions.core_vehicles.replaceVehicle(model, opt, otherVeh)
    end
end

local function removeCurrent(...)
    local current = beamjoy_vehicles.getCurrent()
    if current then
        if current.isLocal then
            beamjoy_vehicles:deleteCurrentOwnVehicle()
        else
            uiHelpers.popup(beamjoy_lang.translate("beamjoy.toast.vehicleSelector.removeOtherVeh"), {
                uiHelpers.popupButton(beamjoy_lang.translate("beamjoy.common.cancel")),
                uiHelpers.popupButton(beamjoy_lang.translate("beamjoy.common.confirm"),
                    beamjoy_vehicles.deleteCurrentOthersVehicle),
            })
        end
    end
end

-- Called when "Remove Others" button is clicked<br/>
-- We do not override core_vehicles here because BeamMP is doing it already
local function onVehicleSelectorRemoveOthers()
    beamjoy_vehicles.deleteOtherOwnVehicles()
end

---@param itemData {model:string, config: string}
---@return boolean
local function passesFilters(itemData)
    local req = CreateRequestAuthorization(true)
    extensions.hook("onBJRequestCanSpawnVehicle", req, itemData.model, itemData.config)
    return req.state
end

local function onInit()
    M.baseFunctions = {
        core_vehicles = {
            cloneCurrent = extensions.core_vehicles.cloneCurrent,
            spawnNewVehicle = extensions.core_vehicles.spawnNewVehicle,
            replaceVehicle = extensions.core_vehicles.replaceVehicle,
            removeCurrent = extensions.core_vehicles.removeCurrent,
        },
        ui_vehicleSelector_general = {
            passesFilters = extensions.ui_vehicleSelector_general.passesFilters,
        },
    }
    core_vehicles.cloneCurrent = cloneCurrent
    core_vehicles.spawnNewVehicle = spawnNewVehicle
    core_vehicles.replaceVehicle = replaceVehicle
    core_vehicles.removeCurrent = removeCurrent
    extensions.ui_vehicleSelector_general.passesFilters = passesFilters
end

local function resetCache()
    M.caches = {}
end

local function onUnload()
    RollBackNGFunctionsWrappers(M.baseFunctions)
end

M.onInit = onInit
M.onExtensionUnloaded = onUnload
M.onBJVehiclesCacheUpdate = resetCache
M.onBJPermissionsUpdate = resetCache
M.onBJUpdateSelf = resetCache
M.onVehicleSelectorRemoveOthers = onVehicleSelectorRemoveOthers

return M
