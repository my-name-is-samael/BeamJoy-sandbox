local function _baseSoundsPath(filename)
    return string.var("/art/sound/{1}.ogg", { filename })
end

local M = {
    SOUNDS = {
        RACE_COUNTDOWN = "event:UI_Countdown1",
        RACE_START = "event:UI_CountdownGo",
        RACE_WAYPOINT = "event:UI_Checkpoint",          -- same as "event:>UI>Missions>Checkpoint"
        BIGMAP_HOVER = "event:>UI>Bigmap>Hover_Icon",   -- slight click sound
        BIGMAP_SELECT = "event:>UI>Bigmap>Select_Icon", -- switch sound
        BIGMAP_ROUTE = "event:>UI>Bigmap>Route",        -- ting sound
        WOOSH_IN = "event:>UI>Bigmap>Whoosh_In",        -- click sound, same as "event:>UI>Bigmap>Whoosh_Out"
        FUEL_LOW = "event:>UI>Career>Fuel_Low",         -- 4x tings sound
        MAIN_CANCEL = "event:>UI>Main>Cancel",          -- boop sound
        INFO_OPEN = "event:>UI>Missions>Info_Open",     -- ting sound
    }
}

---@param sound string
---@param pos? vec3
local function play(sound, pos)
    if not table.includes(M.SOUNDS, sound) then
        LogError(string.format("Unknown sound \"%s\"", tostring(sound)))
    end

    Engine.Audio.playOnce('AudioGui', sound, pos and { position = pos } or nil)
end

M.play = play

return M
