local M = {
    state = false,
    ---@type "translate"|"rotate"|"scale"
    tool = "translate",
    ---@type fun(updated: GizmoObject)?
    onChange = nil,
    obj = {},
}

local function onInit()
    beamjoy_communications_ui.addHandler("BJEditorChangeTool", M.setTool)
    if not editor.AxisGizmoMode_Translate then
        require("editor/api/gui").initialize(editor)
        require("editor/api/gizmo").initialize(editor)
    end
    M.setTool()
end

local function onDrag()
    if M.tool == "translate" then
        M.obj.pos = editor.getAxisGizmoTransform():getColumn(3)
    elseif M.tool == "rotate" then
        local gizmoTransform = editor.getAxisGizmoTransform()
        local rotation = QuatF(0, 0, 0, 1)
        rotation:setFromMatrix(gizmoTransform)
        M.obj.dir, M.obj.up = math.rotationQuatToDirAndUp(rotation)
    elseif M.tool == "scale" then
        local delta = worldEditorCppApi.getAxisGizmoScaleOffset()
        local axis = worldEditorCppApi.getAxisGizmoSelectedElement()
        if axis == editor.AxisX then
            M.obj.scales.x = M.obj.scales.x + delta.x
        elseif axis == editor.AxisY then
            M.obj.scales.y = M.obj.scales.y + delta.y
        elseif axis == editor.AxisZ then
            M.obj.scales.z = M.obj.scales.z + delta.z
        end
    end
    if M.onChange then
        M.onChange(M.obj)
    end
end

local function onUpdate()
    if M.state then
        debugDrawer:drawAxisGizmo()
        editor.updateAxisGizmo(nop, nop, onDrag)
    end
end

---@param obj GizmoObject
---@param onChange fun(updated: GizmoObject)
local function show(obj, onChange)
    M.state = true
    M.obj.pos = obj.pos
    M.obj.dir = obj.dir
    M.obj.up = obj.up
    M.obj.scales = obj.scales
    local rot = quatFromDir(obj.dir, obj.up)
    local transform = QuatF(rot.x, rot.y, rot.z, rot.w):getMatrix()
    transform:setPosition(obj.pos)
    worldEditorCppApi.setAxisGizmoAlignment(editor.AxisGizmoAlignment_Local)
    editor.setAxisGizmoTransform(transform, obj.scales)
    M.onChange = onChange

    worldEditorCppApi.setGizmoLineThicknessScale(1)
    worldEditorCppApi.setAxisGizmoRenderPlane(false)
    worldEditorCppApi.setAxisGizmoRenderPlaneHashes(false)
    worldEditorCppApi.setAxisGizmoRenderMoveGrid(false)
    worldEditorCppApi.setGridSnap(false, 0)
    worldEditorCppApi.setRotateSnap(false, 0)
    worldEditorCppApi.setScaleSnap(false, 0)
end

local function hide()
    M.state = false
    M.onChange = nil
    M.obj = {}
end

---@param tool "translate"|"rotate"|"scale"? default "translate"
local function setTool(tool)
    M.tool = tool or "translate"
    local mode = editor.AxisGizmoMode_Translate
    if tool == "rotate" then
        mode = editor.AxisGizmoMode_Rotate
    elseif tool == "scale" then
        mode = editor.AxisGizmoMode_Scale
    end
    worldEditorCppApi.setAxisGizmoMode(mode)
    beamjoy_communications_ui.send("BJEditorChangeTool", M.tool)
end

M.onInit = onInit
M.onUpdate = onUpdate

M.show = show
M.hide = hide
M.setTool = setTool

return M
