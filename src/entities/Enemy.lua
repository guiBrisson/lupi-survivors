local StateMachine = require 'src.components.StateMachine'
local Position     = require 'src.components.Position'
local Health       = require 'src.components.Health'
local Collider     = require 'src.components.Collider'
local Params       = require 'src.utils.params'


local Enemy = {}
Enemy.__index = Enemy
Enemy.type = "enemy"


local STATE_TARGETING = "targeting"
local STATE_IDLE      = "idle"
local STATE_DEAD      = "dead"


function Enemy:new(params)
    local instance = setmetatable({}, self)
    local default = {
        x = 0,
        y = 0,
        size = 20,
        speed = 100,
        maxHp = 100,
    }

    instance.params = Params.Merge(default, params)
    instance.components = {}
    instance.callbacks = {
        onDeadState = {}
    }
    return instance
end

function Enemy:load(world)
    self.components = {
        sm = StateMachine:new(),
        position = Position:new(self.params.x, self.params.y),
        health = Health:new(self.params.maxHp),
        collider = Collider:new(world, self.params.x, self.params.y, 'dynamic', self.params.size, self, true),
    }

    self.target = {}

    self:_load_states()
end

function Enemy:update(dt)
    self:_handle_state(dt)
end

function Enemy:draw()
    local x, y = self.components.position:get()
    local size = 20
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', x - size / 2, y - size / 2, size, size)
    self.components.collider:draw()
end

function Enemy:_load_states()
    local sm = self.components.sm
    sm:add_state(STATE_IDLE)

    sm:add_state(STATE_TARGETING, {
        update = function(dt)
            self:_handle_movement(dt)
        end
    })

    sm:add_state(STATE_DEAD, {
        enter = function()
            self:_notifyCallback(self.callbacks.onDeadState)
        end,
    })

    sm:change_state(STATE_IDLE) -- Initial state
end

function Enemy:_handle_state(dt)
    local sm = self.components.sm
    sm:update(dt)

    if (self.components.health:get() <= 0) then
        sm:change_state(STATE_DEAD)
    end
end

function Enemy:_handle_movement(dt)
    if (self.target.position ~= nil) then
        local x, y = self.components.position:get()
        local speed = self.params.speed
        local targetX, targetY = self.target.position:get()
        local directionX = targetX - x
        local directionY = targetY - y

        -- Normalize the direction vector
        local length = math.sqrt(directionX ^ 2 + directionY ^ 2)
        if length > 0 then
            directionX = directionX / length
            directionY = directionY / length
            self.components.collider:setLinearVelocity(directionX * speed, directionY * speed)
        end

        self.components.position:set(self.components.collider:getPosition())
        return
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

---@param position Position
function Enemy:update_target_position(position)
    self.target.position = position
    self.components.sm:change_state(STATE_TARGETING)
end

function Enemy:clear_target_position()
    self.target.position = nil
    self.components.sm:change_state(STATE_IDLE)
end

---@param amount number
function Enemy:takeDamage(amount)
    local health = self.components.health
    health:damage(amount)
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
