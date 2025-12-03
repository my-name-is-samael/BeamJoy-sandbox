---@class BJColor
---@field r number 0-1
---@field g number 0-1
---@field b number 0-1
---@field a number 0-1
---@field fromRaw fun(self: BJColor, rawColor: {r: number?, g: number?, b: number?, a: number?}): BJColor self mutable
---@field fromArray fun(self: BJColor, array: number[]): BJColor self mutable
---@field fromVec4 fun(self: BJColor, vec4: vec4): BJColor self mutable
---@field vec4 fun(self: BJColor): vec4
---@field colorI fun(self:BJColor): ColorI
---@field colorF fun(self:BJColor): ColorF
---@field asPtr fun(self: BJColor): table<integer, number> index 0-3, value 0-255
---@field contrasted fun(self: BJColor): BJColor
---@field compare fun(self: BJColor, color2: BJColor): boolean

---@param r number? 0-1, default 0
---@param g number? 0-1, default 0
---@param b number? 0-1, default 0
---@param a number? 0-1, default 1
---@return BJColor
function BJColor(r, g, b, a)
    local obj = { r = r or 0, g = g or 0, b = b or 0, a = a or 1 }
    local meta = {
        fromRaw = function(self, rawColor)
            if not rawColor or not rawColor.r then return self end
            if not table.isObject(rawColor) then return self end
            self.r, self.g, self.b, self.a = rawColor.r or 0, rawColor.g or 0, rawColor.b or 0, rawColor.a or 1
            return self
        end,
        fromArray = function(self, array)
           if not array then return self end
           if not table.isArray(array) then return self end
           self.r, self.g, self.b, self.a = array[1] or 0, array[2] or 0, array[3] or 0, array[4] or 1
           return self
        end,
        fromVec4 = function(self, vec4)
            if not vec4 or not vec4.x then return end
            self.r, self.g, self.b, self.a = vec4.x, vec4.y, vec4.z, vec4.w
            return self
        end,
        vec4 = function(self)
            return ImVec4(self.r, self.g, self.b, self.a)
        end,
        colorI = function(self)
            return ColorI(self.r * 255, self.g * 255, self.b * 255, self.a * 255)
        end,
        colorF = function(self)
            return ColorF(self.r, self.g, self.b, self.a)
        end,
        asPtr = function(self)
            return { [0] = self.r * 255, [1] = self.g * 255, [2] = self.b * 255, [3] = self.a * 255 }
        end,
        contrasted = function(self)
            local contrast = 0.2126 * self.r * self.r + 0.7152 * self.g * self.g + 0.0722 * self.b * self.b
            if contrast > .3 then
                return BJColor(0, 0, 0, self.a)
            else
                return BJColor(1, 1, 1, self.a)
            end
        end,
        compare = function(self, color2)
            if not color2 then return false end
            return self.r == color2.r and self.g == color2.g and self.b == color2.b and self.a == color2.a
        end
    }

    return setmetatable(obj, { __index = meta })
end
