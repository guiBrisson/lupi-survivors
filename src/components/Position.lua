local Position = {}
Position.__index = Position

--- @param x number
--- @param y number
function Position:new(x, y)
    local instance = setmetatable({}, self)
    instance.x = x or 0
    instance.y = y or 0
    return instance
end

function Position:set(x, y)
    self.x = x
    self.y = y
end

---@return number
---@return number
function Position:get()
    return self.x, self.y
end

function Position:__tostring()
    return "Position(x: " .. self.x .. " y: " .. self.y .. ")"
end

return Position
