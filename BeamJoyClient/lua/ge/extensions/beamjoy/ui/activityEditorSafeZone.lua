---@class BJActivityEditorSafeZone: BJActivityEditor
local M = {
    ---@type GizmoObject[]
    zones = {},
    ---@type integer?
    activeIndex = nil,
    dirty = false,
}
---@type BJActivityEditorCommon?
local parent

---@param zone GizmoObject?
local function updateRender(zone)
    shape.reset()
    local zoneLabel = beamjoy_lang.translate("beamjoy.activities.safeZone.label")
    if zone then
        shape.addCuboid(zone.pos, zone.dir, vec3(zone.scales.x, zone.scales.z, zone.scales.y),
            zone.up, BJColor(1, 1, 1, .2))
        shape.addText(
            string.format("%s %d", zoneLabel, M.activeIndex),
            zone.pos, BJColor(1, 1, 1, .8), BJColor(0, 0, 0, .3))
    else
        -- draw all zones
        table.forEach(M.zones, function(z, i)
            shape.addCuboid(z.pos, z.dir, vec3(z.scales.x, z.scales.z, z.scales.y),
                z.up, BJColor(1, 1, 1, .2))
            shape.addText(
                string.format("%s %d", zoneLabel, i),
                z.pos, BJColor(1, 1, 1, .8), BJColor(0, 0, 0, .3))
        end)
    end
end

---@param zone GizmoObject?
local function updateGizmo(zone)
    gizmo.hide()
    if zone then
        gizmo.show(zone, function(updated) ---@param updated GizmoObject
            if not parent or not M.activeIndex then return end
            M.zones[M.activeIndex] = updated
            updateRender(M.zones[M.activeIndex])
            if not M.dirty then
                M.dirty = true
                beamjoy_communications_ui.send("BJEditorDirty", M.dirty)
            end
        end)
    end
end

local function onOpen()
    if not parent then return end
    if parent.activeEditor and
        parent.activeEditor ~= M then
        -- close other active editor if any
        parent.activeEditor.onClose()
    end
    parent.activeEditor = M
    beamjoy_communications_ui.send("BJEditorChangeTool", gizmo.tool)

    M.zones = table.clone(beamjoy_activity_manager.data.safeZones)
    updateRender()
    beamjoy_communications_ui.send("BJEditorSafeZonesUpdate", M.zones)
    beamjoy_communications_ui.send("BJEditorDirty", M.dirty)
end

local function onSelectToggle(iZone)
    if not parent then return end
    if parent.activeEditor == M then
        M.activeIndex = M.activeIndex ~= iZone and iZone or nil
        updateRender(M.zones[M.activeIndex])
        updateGizmo(M.zones[M.activeIndex])
        beamjoy_communications_ui.send("BJEditorActiveUpdate", M.activeIndex)
    end
end

local function onCreate()
    if not parent then return end
    local currVeh = beamjoy_vehicles.getCurrent()
    local pos, dir, up
    if not currVeh or camera.getCamera() == camera.CAMERAS.FREE then
        pos, dir, up = camera.getPositionRotation(false)
    else
        pos, dir, up = beamjoy_vehicles.getVehiclePositionRotation(currVeh.veh)
    end
    table.insert(M.zones, {
        pos = pos,
        dir = dir,
        up = up,
        scales = vec3(5, 5, 5),
    })
    M.activeIndex = #M.zones
    updateRender(M.zones[M.activeIndex])
    updateGizmo(M.zones[M.activeIndex])
    beamjoy_communications_ui.send("BJEditorSafeZonesUpdate", M.zones)
    beamjoy_communications_ui.send("BJEditorActiveUpdate", M.activeIndex)
    M.dirty = true
    beamjoy_communications_ui.send("BJEditorDirty", M.dirty)
end

local function onDuplicate(iZone)
    if not parent then return end
    local orig = M.zones[iZone]
    if not orig then return end
    local currVeh = beamjoy_vehicles.getCurrent()
    local pos, dir, up
    if not currVeh or camera.getCamera() == camera.CAMERAS.FREE then
        pos = camera.getPositionRotation(false)
        dir = vec3(orig.dir)
        up = vec3(orig.up)
    else
        pos, dir, up = beamjoy_vehicles.getVehiclePositionRotation(currVeh.veh)
    end
    table.insert(M.zones, {
        pos = pos,
        dir = dir,
        up = up,
        scales = vec3(orig.scales),
    })
    M.activeIndex = #M.zones
    updateRender(M.zones[M.activeIndex])
    updateGizmo(M.zones[M.activeIndex])
    beamjoy_communications_ui.send("BJEditorSafeZonesUpdate", M.zones)
    beamjoy_communications_ui.send("BJEditorActiveUpdate", M.activeIndex)
    M.dirty = true
    beamjoy_communications_ui.send("BJEditorDirty", M.dirty)
end

local function onDelete(iZone)
    if not parent then return end
    table.remove(M.zones, iZone)
    M.activeIndex = nil
    updateRender(M.zones[M.activeIndex])
    updateGizmo(M.zones[M.activeIndex])
    beamjoy_communications_ui.send("BJEditorSafeZonesUpdate", M.zones)
    beamjoy_communications_ui.send("BJEditorActiveUpdate", M.activeIndex)
    if not M.dirty then
        M.dirty = true
        beamjoy_communications_ui.send("BJEditorDirty", M.dirty)
    end
end

local function onSave()
    if not parent then return end
    beamjoy_communications.send("safeZonesSave", table.map(M.zones, function(zone)
        zone.scales.x = math.abs(zone.scales.x)
        zone.scales.y = math.abs(zone.scales.y)
        zone.scales.z = math.abs(zone.scales.z)
        return math.roundPosRotDirUp(zone)
    end))
    beamjoy_communications.addOneUseHandler("safeZonesSaved", function(status, zones)
        if status then
            M.zones = zones
            table.forEach(M.zones, ParseGizmoObject)
            beamjoy_communications_ui.send("BJEditorSafeZonesUpdate", M.zones)
            M.activeIndex = nil
            updateRender(M.zones[M.activeIndex])
            updateGizmo(M.zones[M.activeIndex])
            beamjoy_communications_ui.send("BJEditorActiveUpdate", M.activeIndex)
            if M.dirty then
                M.dirty = false
                beamjoy_communications_ui.send("BJEditorDirty", M.dirty)
            end
        else
            toast.error("Failed to save data")
        end
    end, 5000)
end

---@param activityEditor BJActivityEditorCommon
local function onInit(activityEditor)
    parent = activityEditor

    beamjoy_communications_ui.addHandler("BJEditorSafeZoneOpen", onOpen)
    beamjoy_communications_ui.addHandler("BJEditorSafeZoneClose", parent.onClose)
    beamjoy_communications_ui.addHandler("BJEditorSafeZoneSelect", onSelectToggle)
    beamjoy_communications_ui.addHandler("BJEditorSafeZoneCreate", onCreate)
    beamjoy_communications_ui.addHandler("BJEditorSafeZoneDuplicate", onDuplicate)
    beamjoy_communications_ui.addHandler("BJEditorSafeZoneDelete", onDelete)
    beamjoy_communications_ui.addHandler("BJEditorSafeZoneSave", onSave)
end

local function onClose()
    if not parent then return end
    if parent.activeEditor == M then
        gizmo.hide()
        shape.reset()
        M.zones = {}
        M.activeIndex = nil
        M.dirty = false
    end
end

M.onInit = onInit
M.onClose = onClose

return M
