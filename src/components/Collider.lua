local Collider = {}
Collider.__index = Collider

---@param world love.physics.World
---@param x number
---@param y number
---@param type 'static'|'dynamic'|'kinematic'
---@param size number
---@param userData any
---@param fixedRotation boolean
function Collider:new(world, x, y, type, size, userData, fixedRotation)
    local instance = setmetatable({}, self)
    instance.body = love.physics.newBody(world, x, y, type)
    instance.body:setFixedRotation(fixedRotation or true)

    instance.shape = love.physics.newRectangleShape(size, size)
    instance.fixture = love.physics.newFixture(instance.body, instance.shape)
    instance.fixture:setUserData(userData)
    return instance
end

function Collider:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
end

---@param x number
---@param y number
function Collider:setPosition(x, y)
    self:getBody():setPosition(x, y)
end

---@return x number
---@return y number
function Collider:getPosition()
    return self:getBody():getPosition()
end

function Collider:getBody()
    return self.fixture:getBody()
end

---@param x number
---@param y number
function Collider:setLinearVelocity(x, y)
    return self:getBody():setLinearVelocity(x, y)
end

---@param isFixed any
function Collider:setFixedRotation(isFixed)
    self:getBody():setFixedRotation(isFixed)
end

function Collider:destroy()
    if self.fixture then
        self.fixture:destroy()
        self.fixture = nil
    end

    if self.body then
        self.body:destroy()
        self.body = nil
    end
end

return Collider
