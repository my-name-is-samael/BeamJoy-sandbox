local M = {
    dependencies = {
        "beamjoy_communications_ui"
    },
    state = {},

    ---@type table<string, string>
    tagNames = {},
}

local function updateState()
    local state = {
        hideNameTags = settings.getValue("hideNameTags", false),
        showSpectators = settings.getValue("showSpectators", true),
        nameTagsHideBehindObjects = settings.getValue("nameTagsHideBehindObjects", false),
        nameTagFadeEnabled = settings.getValue("nameTagFadeEnabled", true),
        nameTagFadeDistance = settings.getValue("nameTagFadeDistance", 40),
        nameTagFadeInvert = settings.getValue("nameTagFadeInvert", false),
        nameTagDontFullyHide = settings.getValue("nameTagDontFullyHide", true),
        shortenNametags = settings.getValue("shortenNametags", false),
        nametagCharLimit = settings.getValue("nametagCharLimit", 50),
        nameTagShowDistance = settings.getValue("nameTagShowDistance", true),
        playerColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_PLAYER_TEXT),
        playerBgColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_PLAYER_BG),
        idleColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_IDLE_TEXT),
        idleBgColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_IDLE_BG),
        specColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_SPEC_TEXT),
        specBgColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_SPEC_BG),
    }
    if not table.compare(M.state, state) then
        M.state = state
        beamjoy_communications_ui.send("BJNametagsState", M.state)
        extensions.hook("onNametagsSettingsChanged")
    end
end

local function onInit()
    updateState()

    beamjoy_communications_ui.addHandler("BJRequestNametagsState", function()
        beamjoy_communications_ui.send("BJNametagsState", M.state)
    end)
    beamjoy_communications_ui.addHandler("BJToggleNametagsHideState", function(newState)
        if newState == nil then newState = not M.state.hideNameTags end
        settings.setValue("hideNameTags", newState)
        M.state.hideNameTags = newState
        beamjoy_communications_ui.send("BJNametagsState", M.state)
    end)
    beamjoy_communications_ui.addHandler("BJUpdateNametagsState", function(newState)
        for k in pairs(newState) do
            if M.state[k] ~= nil then
                settings.setValue(k, newState[k])
            end
        end
    end)
    beamjoy_communications_ui.addHandler("BJUserSettings", function(newSettings)
        -- TODO check why color change does not update on the fly ?
        if not table.compare(M.state, newSettings.nametags) then
            settings.setValue("hideNameTags", newSettings.nametags.hideNameTags)
            settings.setValue("showSpectators", newSettings.nametags.showSpectators)
            settings.setValue("nameTagsHideBehindObjects", newSettings.nametags.nameTagsHideBehindObjects)
            settings.setValue("nameTagFadeEnabled", newSettings.nametags.nameTagFadeEnabled)
            settings.setValue("nameTagFadeDistance", newSettings.nametags.nameTagFadeDistance)
            settings.setValue("nameTagFadeInvert", newSettings.nametags.nameTagFadeInvert)
            settings.setValue("nameTagDontFullyHide", newSettings.nametags.nameTagDontFullyHide)
            settings.setValue("shortenNametags", newSettings.nametags.shortenNametags)
            settings.setValue("nametagCharLimit", newSettings.nametags.nametagCharLimit)
            settings.setValue("nameTagShowDistance", newSettings.nametags.nameTagShowDistance)
            localStorage.set(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_PLAYER_TEXT, newSettings.nametags.playerColor)
            localStorage.set(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_PLAYER_BG, newSettings.nametags.playerBgColor)
            localStorage.set(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_IDLE_TEXT, newSettings.nametags.idleColor)
            localStorage.set(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_IDLE_BG, newSettings.nametags.idleBgColor)
            localStorage.set(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_SPEC_TEXT, newSettings.nametags.specColor)
            localStorage.set(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_SPEC_BG, newSettings.nametags.specBgColor)

            extensions.hook("onNametagsSettingsChanged")
        end
    end)
end

local function onSlowUpdate()
    updateState()
end

---@param playerName string
---@return string
local function updateTagName(playerName)
    if playerName == beamjoy_players.getSelf().playerName then
        M.tagNames[playerName] = beamjoy_lang.translate("beamjoy.nametags.you")
        return M.tagNames[playerName]
    end
    if M.state.shortenNametags then
        M.tagNames[playerName] = string.sub(playerName, 1, M.state.nametagCharLimit)
        if M.tagNames[playerName] ~= playerName then
            M.tagNames[playerName] = M.tagNames[playerName] .. "..."
        end
    else
        M.tagNames[playerName] = playerName
    end
    return M.tagNames[playerName]
end

local function onNametagsSettingsChanged()
    table.forEach(M.tagNames, function(_, playerName)
        updateTagName(tostring(playerName))
    end)
end

---@param mpVeh BJVehicle
---@param orig vec3
local function drawNametag(mpVeh, orig)
    local textColor, bgColor
    local tag = M.tagNames[mpVeh.ownerName] or updateTagName(mpVeh.ownerName)
    if mpVeh.type == beamjoy_vehicles.TYPES.TRAILER then
        if mpVeh.ownerID == beamjoy_players.getSelf().playerID then
            tag = beamjoy_lang.translate("beamjoy.nametags.yourTrailer")
        else
            tag = beamjoy_lang.translate("beamjoy.nametags.othersTrailer")
                :var({ playerName = mpVeh.ownerName })
        end
    elseif mpVeh.isAi then
        if beamjoy_pursuit.fugitives[mpVeh.vid] ~= nil and
            beamjoy_pursuit.isPolice then
            tag = beamjoy_lang.translate("beamjoy.pursuit.fugitiveTag")
            textColor = BJColor()
            bgColor = BJColor(1)
        else
            tag = string.format("[AI] %d-%d", mpVeh.ownerID, mpVeh.vid)
        end
    end

    local dist = math.round(orig:distance(mpVeh.position) or 0)
    local distSuffix = ""
    if M.state.nameTagShowDistance then
        if dist > 10 then
            distSuffix = string.format(" %dm", dist)
        end
    end

    local alpha = 1
    if M.state.nameTagFadeEnabled then
        alpha = math.scale(dist, M.state.nameTagFadeDistance, 0, 0, 1, true)
        if camera.getCamera() ~= camera.CAMERAS.FREE and M.state.nameTagFadeInvert then
            alpha = 1 - alpha
        end
        if M.state.nameTagDontFullyHide then
            alpha = math.clamp(alpha, .3)
        end
    end

    if mpVeh.spectators[mpVeh.ownerName] then
        textColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_PLAYER_TEXT)
        bgColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_PLAYER_BG)
    elseif not textColor then
        textColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_IDLE_TEXT)
        bgColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_IDLE_BG)
    end
    textColor.a = alpha
    bgColor.a = alpha / 2

    local pos = mpVeh.position + vec3(0, 0, mpVeh.height)
    shape.Text(string.format("%s%s", tag, distSuffix), pos, textColor, bgColor, false,
        M.state.nameTagsHideBehindObjects)

    if M.state.showSpectators then
        mpVeh.spectators
            :filter(function(_, playerName)
                return playerName ~= mpVeh.ownerName and
                    not replay.replayPlayers[playerName] and
                    (camera.getCamera() == camera.CAMERAS.FREE or
                        playerName ~= beamjoy_players.getSelf().playerName)
            end)
            :forEach(function(_, specName, specs)
                specName = M.tagNames[specName] or
                    updateTagName(tostring(specName))

                textColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_SPEC_TEXT)
                bgColor = localStorage.get(localStorage.GLOBAL_VALUES.NAMETAGS_COLOR_SPEC_BG)
                textColor.a = alpha
                bgColor.a = alpha / 2

                pos = pos + vec3(0, 0, -math.max(mpVeh.height / specs:length(), .3))
                shape.Text(specName, pos, textColor, bgColor,
                    false, M.state.nameTagsHideBehindObjects)
            end)
    end
end

local ctxt, orig, veh, mpVeh, ray
local drawn = {}
local function onUpdate()
    MPVehicleGE.hideNicknames(true)
    if replay.isOn() then return end

    ctxt = beamjoy_context.get()
    orig = camera.getPositionRotation()
    if ctxt.mpVeh and ctxt.camera ~= camera.CAMERAS.FREE then
        orig = beamjoy_vehicles.getVehiclePositionRotation(ctxt.mpVeh.veh)
    end

    table.clear(drawn)
    if not M.state.hideNameTags then
        -- draw all
        ---@param v BJVehicle
        beamjoy_vehicles.vehicles:filter(function(v)
            if v.isAi then
                if DEBUG ~= nil then return true end
                return beamjoy_pursuit.fugitives[v.vid] ~= nil and
                    beamjoy_pursuit.isPolice
            end
            if v.type == beamjoy_vehicles.TYPES.PROP and
                v.jbeam ~= beamjoy_vehicles.WALKING then
                return false
            end
            if v.type == beamjoy_vehicles.TYPES.TRAILER then
                if v.ownerName ~= beamjoy_players.getSelf().playerName then
                    -- not own trailer
                    return false
                end
                ---@param veh2 BJVehicle
                if beamjoy_vehicles.vehicles:filter(function(veh2)
                        return not table.includes({
                            beamjoy_vehicles.TYPES.TRAILER,
                            beamjoy_vehicles.TYPES.PROP
                        }, veh2.type)
                    end):map(function(veh2) ---@param veh2 BJVehicle
                        return beamjoy_vehicles.getAttachedTrailers(veh2.vid)
                    end):any(function(avids) ---@param avids integer[]
                        return table.includes(avids, v.vid)
                    end) then
                    -- some vehicle is tracting it
                    return false
                end
            end
            if ctxt.camera ~= camera.CAMERAS.FREE and
                ctxt.mpVeh and ctxt.mpVeh.isLocal and
                ctxt.mpVeh.vid == v.vid then
                return false
            end
            if replay.replayPlayers[v.ownerName] then return false end
            return true
        end):forEach(function(v) ---@param v BJVehicle
            drawn[v.vid] = true
            drawNametag(beamjoy_vehicles.getVehicle(v.vid) or {}, orig)
        end)
    end

    -- mouse hover nametag
    ray = nil
    if ctxt.camera ~= camera.CAMERAS.FREE and ctxt.mpVeh then
        ctxt.mpVeh.veh:disableCollision()
        ray = cameraMouseRayCast(true, ui_imgui.flags(SOTVehicle), 200)
        ctxt.mpVeh.veh:enableCollision()
    else
        ray = cameraMouseRayCast(true, ui_imgui.flags(SOTVehicle), 200)
    end
    if ray then
        ---@type NGVehicle?
        veh = ray.object
        if not veh then goto skipHover end
        if drawn[veh:getID()] then goto skipHover end
        mpVeh = beamjoy_vehicles.getVehicle(veh:getID())
        if not mpVeh then goto skipHover end
        if mpVeh.isAi then goto skipHover end
        if not beamjoy_permissions.isStaff() and
            mpVeh.type == beamjoy_vehicles.TYPES.PROP and
            mpVeh.jbeam ~= beamjoy_vehicles.WALKING then
            goto skipHover
        end
        drawn[veh:getID()] = true
        drawNametag(mpVeh, orig)
    end
    ::skipHover::
end

M.onInit = onInit
M.onSlowUpdate = onSlowUpdate
M.onNametagsSettingsChanged = onNametagsSettingsChanged
M.onUpdate = onUpdate

return M
