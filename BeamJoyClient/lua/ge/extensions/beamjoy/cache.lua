local M = {
    dependencies = {
        "beamjoy_communications"
    },
    DEBUG = true, -- TODO find better place
    loaded = false,
}

local function onInit()
    beamjoy_communications.addHandler("sendCache", function()
        M.loaded = true
    end)
end

local function requireCaches()
    beamjoy_communications.send("requireCaches")
end

M.onInit = onInit

M.requireCaches = requireCaches

return M
