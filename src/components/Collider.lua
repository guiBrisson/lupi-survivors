local Params = require 'src.utils.params'

local Collider = {}
Collider.__index = Collider


Collider.SYNC_NONE                 = 0
Collider.SYNC_PHYSICS_TO_TRANSFORM = 1
Collider.SYNC_TRANSFORM_TO_PHYSICS = 2

---@param params table
function Collider:new(params)
    local instance = setmetatable({}, self)
    local default = {
        world = nil,             -- love.physics.World
        transform = nil,         -- Transform component
        shapeType = "rectangle", -- 'rectangle' | 'circle' | 'polygon'
        width = nil,             -- number For rectangle
        height = nil,            -- number For rectangle
        radius = nil,            -- number For circle
        vertices = nil,          -- table For polygon: {x1, y1, x2, y2, ...}
        offsetX = 0,             -- number
        offsetY = 0,             -- number
        type = 'dynamic',        -- 'static'|'dynamic'|'kinematic'
        isSensor = false,        -- boolean
        fixedRotation = true,    -- boolean
        userData = nil,          -- any
        syncDirection = nil,     -- 0|1|2 Auto-detected if nil
    }

    instance.params = Params.Merge(default, params)

    assert(instance.params.world, "Collider requires a physics world")
    assert(instance.params.transform, "Collider requires a Transform component")

    local x, y = instance.params.transform:getWorldPosition()

    instance.body = love.physics.newBody(
        instance.params.world,
        x, y,
        instance.params.type
    )
    instance.body:setFixedRotation(instance.params.fixedRotation)
    instance.body:setAngle(instance.params.transform:getRotation())

    if instance.params.shapeType == "rectangle" then
        assert(instance.params.width and instance.params.height, "Rectangle collider requires width and height")
        instance.shape = love.physics.newRectangleShape(
            instance.params.offsetX,
            instance.params.offsetY,
            instance.params.width,
            instance.params.height
        )
    elseif instance.params.shapeType == "circle" then
        assert(instance.params.radius, "Circle collider requires radius")
        instance.shape = love.physics.newCircleShape(
            instance.params.offsetX,
            instance.params.offsetY,
            instance.params.radius
        )
    elseif instance.params.shapeType == "polygon" then
        assert(instance.params.vertices, "Polygon collider requires vertices")
        instance.shape = love.physics.newPolyhonShape(instance.params.vertices)
    else
        error("invalid collision shape type: " .. tostring(instance.params.shapeType))
    end

    instance.fixture = love.physics.newFixture(instance.body, instance.shape)
    instance.fixture:setSensor(instance.params.isSensor)
    instance.fixture:setUserData(instance.params.userData)

    -- Set default sync direction
    if instance.params.syncDirection == nil then
        if instance.params.bodyType == "dynamic" then
            instance.syncDirection = Collider.SYNC_PHYSICS_TO_TRANSFORM
        else
            instance.syncDirection = Collider.SYNC_TRANSFORM_TO_PHYSICS
        end
    else
        instance.syncDirection = instance.params.syncDirection
    end

    return instance
end

function Collider:update(dt)
    if self.params.syncDirection == Collider.SYNC_PHYSICS_TO_TRANSFORM then
        self.params.transform:setPosition(self:getBody():getPosition())
        self.params.transform:setRotation(self:getBody():getAngle())
    elseif self.params.syncDirection == Collider.SYNC_TRANSFORM_TO_PHYSICS then
        self:getBody():setPosition(self.params.transform:getWorldPosition())
        self:getBody():setAngle(self.params.transform:getRotation())
    end
end

function Collider:draw()
    love.graphics.setColor(0, 1, 0, 0.7)

    if self.params.shapeType == "rectangle" or self.params.shapeType == "polygon" then
        love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
    elseif self.params.shapeType == "circle" then
        local cx, cy = self.body:getWorldPoint(self.shape:getPoint())
        love.graphics.circle('line', cx, cy, self.shape:getRadius())
    end

    -- Draw center point
    local x, y = self.body:getPosition()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.circle('fill', x, y, 3)
end

function Collider:setSyncDirection(direction)
    assert(
        direction == Collider.SYNC_NONE or
        direction == Collider.SYNC_PHYSICS_TO_TRANSFORM or
        direction == Collider.SYNC_TRANSFORM_TO_PHYSICS,
        "Invalid sync direction"
    )

    self.syncDirection = direction
end

--- @param fx number Force in x-direction
--- @param fy number Force in y-direction
function Collider:applyForce(fx, fy)
    self:getBody():applyForce(fx, fy)
end

--- @param ix number Impulse in x-direction
--- @param iy number Impulse in y-direction
function Collider:applyLinearImpulse(ix, iy)
    self:getBody():applyLinearImpulse(ix, iy)
end

---@param x number
---@param y number
function Collider:setLinearVelocity(x, y)
    return self:getBody():setLinearVelocity(x, y)
end

--- @return vx number, vy number
function Collider:getLinearVelocity()
    return self:getBody():getLinearVelocity()
end

---@param isFixed any
function Collider:setFixedRotation(isFixed)
    self:getBody():setFixedRotation(isFixed)
end

--- @param sensor boolean
function Collider:setSensor(sensor)
    self.fixture:setSensor(sensor)
end

function Collider:getBody()
    return self.fixture:getBody()
end

function Collider:destroy()
    if self.fixture and self.fixture:isDestroyed() == false then
        self.fixture:destroy()
    end

    if self.body and self.body:isDestroyed() == false then
        self.body:destroy()
    end

    self.fixture = nil
    self.body = nil
    self.shape = nil
end

return Collider
