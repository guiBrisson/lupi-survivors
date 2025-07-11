local Movement = {}
Movement.__index = Movement

---@param speed number
function Movement:new(speed)
    local instance = setmetatable({}, self)

    instance.speed = speed or 0
    return instance
end

---@param dt number
---@param x number
---@param y number
---@param directionX number
---@param directionY number
---@return number
---@return number
function Movement:move(dt, x, y, directionX, directionY)
    local newX = x + directionX * self.speed * dt
    local newY = y + directionY * self.speed * dt
    return newX, newY
end

---@param speed number
function Movement:setSpeed(speed)
    self.speed = speed or self.speed
end

---@return number
function Movement:getSpeed()
    return self.speed
end

function Movement:__tostring()
    return "Movement(speed: " .. self.speed .. ")"
end

return Movement
