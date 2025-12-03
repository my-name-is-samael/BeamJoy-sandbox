local M = {
    dependencies = { "camera", "beamjoy_vehicles", "beamjoy_players" },

    lastGen = 0,
    ---@type TickContext?
    ctxt = nil,
}

local function onVehicleDestroyed(vid)
    if M.ctxt and M.ctxt.mpVeh and M.ctxt.mpVeh.vid == vid then
        M.ctxt.mpVeh = nil
    end
end

---@return TickContext
local function get()
    local now = GetCurrentTimeMillis()
    local gen = math.round(now / 100)
    if not M.ctxt or M.lastGen < gen then
        local mpVeh = beamjoy_vehicles.getCurrent()
        M.ctxt = {
            now = now,
            camera = camera.getCamera(),
            self = beamjoy_players.getSelf(),
            players = beamjoy_players.players,
            mpVeh = mpVeh,
        }
        M.lastGen = gen
    end
    return M.ctxt
end

M.onVehicleDestroyed = onVehicleDestroyed

M.get = get

return M
