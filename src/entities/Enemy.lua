local StateMachine = require 'src.components.StateMachine'
local Transform    = require 'src.components.Transform'
local Health       = require 'src.components.Health'
local Collider     = require 'src.components.Collider'
local Params       = require 'src.utils.params'
local Sprite       = require 'src.components.Sprite'


local Enemy = {}
Enemy.__index = Enemy
Enemy.type = "enemy"


local STATE_TARGETING = "targeting"
local STATE_IDLE      = "idle"
local STATE_DEAD      = "dead"

---@param params table|nil
function Enemy:new(params)
    local instance = setmetatable({}, self)
    local default = {
        x = 0,
        y = 0,
        speed = 100,
        maxHp = 100,
        imagePath = "src/assets/orc.jpg",
        scale = 2.5,
        sprite = {
            -- Sprite anchoring (0-1, where 0.5 is center)
            anchorX = 0.5,
            anchorY = 0.5,
        },
        collider = {
            shapeType = "rectangle",
            width = nil,  -- auto-calculated
            height = nil, -- auto-calculated
            offsetX = 0,
            offsetY = 0,
            radius = nil,    -- For circle shapes
            verticies = nil, -- For polygon shapes
        },
    }

    instance.params = Params.Merge(default, params)
    instance.components = {}
    instance.callbacks = {
        onDeadState = {},
    }
    instance.target = {
        position = { x = nil, y = nil },
    }
    return instance
end

function Enemy:load(world)
    local transform = Transform:new({
        x = self.params.x,
        y = self.params.y,
        scaleX = self.params.scale,
        scaleY = self.params.scale,
    })

    local sprite = Sprite:new({
        transform = transform,
        imagePath = self.params.imagePath,
        scaleX = self.params.scale,
        scaleY = self.params.scale,
    })

    local spriteWidth = sprite.image:getWidth() * self.params.scale
    local spriteHeight = sprite.image:getHeight() * self.params.scale

    self.params.sprite.spriteWidth = spriteWidth
    self.params.sprite.spriteHeight = spriteHeight

    local colliderConfig = self.params.collider
    colliderConfig.width = colliderConfig.width or spriteWidth
    colliderConfig.height = colliderConfig.height or spriteHeight

    local collider = Collider:new({
        world = world,
        transform = transform,
        x = self.params.x,
        y = self.params.y,
        shapeType = colliderConfig.shapeType,
        width = colliderConfig.width,
        height = colliderConfig.height,
        radius = colliderConfig.radius,
        verticies = colliderConfig.verticies,
        offsetX = colliderConfig.offsetX,
        offsetY = colliderConfig.offsetY,
        syncDirection = Collider.SYNC_PHYSICS_TO_TRANSFORM,
        userData = self,
    })

    self.components = {
        sm = StateMachine:new(),
        transform = transform,
        health = Health:new(self.params.maxHp),
        collider = collider,
        sprite = sprite,
    }

    self:_loadStates()
end

function Enemy:update(dt)
    self:_handleState(dt)
    self.components.collider:update(dt)
end

function Enemy:draw()
    self.components.sprite:draw()
    if DEBUG_MODE then
        self.components.collider:draw()
    end
end

function Enemy:_loadStates()
    local sm = self.components.sm
    sm:add_state(STATE_IDLE)

    sm:add_state(STATE_TARGETING, {
        update = function(dt)
            self:_handleMovement(dt)
        end
    })

    sm:add_state(STATE_DEAD, {
        enter = function()
            self:_notifyCallback(self.callbacks.onDeadState)
        end,
    })

    sm:change_state(STATE_IDLE) -- Initial state
end

function Enemy:_handleState(dt)
    local sm = self.components.sm
    sm:update(dt)

    if (self.components.health:get() <= 0) then
        sm:change_state(STATE_DEAD)
    end
end

function Enemy:_handleMovement(dt)
    if (self.target.position.x ~= nil and self.target.position.y ~= nil) then
        local x, y = self:getPosition()
        local speed = self.params.speed
        local directionX = self.target.position.x - x
        local directionY = self.target.position.y - y

        -- Normalize the direction vector
        local length = math.sqrt(directionX ^ 2 + directionY ^ 2)
        if length > 0 then
            directionX = directionX / length
            directionY = directionY / length
            self.components.collider:setLinearVelocity(directionX * speed, directionY * speed)
        end
    end
end

function Enemy:_notifyCallback(callbacks, ...)
    for _, callback in ipairs(callbacks) do
        callback(...)
    end
end

---@param callback function
function Enemy:onDeadState(callback)
    local callbacks = self.callbacks.onDeadState
    table.insert(callbacks, callback)
end

---@param x number
---@param y number
function Enemy:updateTargetPosition(x, y)
    self.target.position.x = x
    self.target.position.y = y
    self.components.sm:change_state(STATE_TARGETING)
end

function Enemy:clearTargetPosition()
    self.target.position.x = nil
    self.target.position.y = nil
    self.components.sm:change_state(STATE_IDLE)
end

---@param amount number
function Enemy:takeDamage(amount)
    local health = self.components.health
    health:damage(amount)
end

function Enemy:getPosition()
    return self.components.transform:getWorldPosition()
end

---@return width number
---@return height number
function Enemy:getSize()
    local image = self.components.sprite.image
    return image:getWidth(), image:getHeight()
end

function Enemy:destroy()
    for _, component in pairs(self.components) do
        if component.destroy then
            component:destroy()
        end
        component = nil
    end

    for _, callback in pairs(self.callbacks) do
        callback = nil
    end
end

function Enemy:__tostring()
    local stringComponents = ""

    for name, component in pairs(self.components) do
        stringComponents = stringComponents .. tostring(name) .. ": " .. tostring(component) .. ", "
    end

    return "Enemy(" .. stringComponents .. ")"
end

return Enemy
