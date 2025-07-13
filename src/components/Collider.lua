local Params = require 'src.utils.params'

local Collider = {}
Collider.__index = Collider

---@param params table
function Collider:new(params)
    local instance = setmetatable({}, self)
    local default = {
        world = nil,          -- love.physics.World
        x = nil,              -- number
        y = nil,              -- number
        width = nil,          -- number
        height = nil,         -- number
        type = 'dynamic',     -- 'static'|'dynamic'|'kinematic'
        size = nil,           -- number
        userData = nil,       -- any
        fixedRotation = true, -- boolean
        shape = 'rectangle'   --
    }

    instance.params = Params.Merge(default, params)

    instance.body = love.physics.newBody(
        instance.params.world,
        instance.params.x,
        instance.params.y,
        instance.params.type
    )
    instance.body:setFixedRotation(instance.params.fixedRotation)

    instance.shape = love.physics.newRectangleShape(
        instance.params.width,
        instance.params.height
    )

    instance.fixture = love.physics.newFixture(instance.body, instance.shape)
    instance.fixture:setUserData(instance.params.userData)
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
