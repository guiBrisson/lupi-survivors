local StateMachine = require 'src.components.StateMachine'
local Position = require 'src.components.Position'
local Movement = require 'src.components.Movement'
local Health = require 'src.components.Health'

local Enemy = {}
Enemy.__index = Enemy

local STATE_TARGETING = "targeting"
local STATE_IDLE = "idle"
local STATE_ALIVE = "alive"
local STATE_DEAD = "dead"

function Enemy:new(params)
    local instance = setmetatable({}, self)
    local default = {
        x = 0,
        y = 0,
        speed = 100,
        maxHp = 100,
    }

    -- Merge defaults with provided parameters
    instance.params = params or {}
    for key, value in pairs(default) do
        instance.params[key] = instance.params[key] or value
    end

    instance.sm = StateMachine:new()
    instance.position = Position:new(instance.params.x, instance.params.y)
    instance.movement = Movement:new(instance.params.speed)
    instance.health = Health:new(instance.params.maxHp)
    instance.target = {}
    return instance
end

function Enemy:load()
    self.sm:add_state(STATE_IDLE)

    self.sm:add_state(STATE_TARGETING, {
        update = function(dt)
            self:_handle_movement(dt)
        end
    })

    self.sm:add_state(STATE_DEAD, {
        enter = function(params)
            print("ENEMY STATE DEAD")
            -- TODO: notify dead state
        end
    })

    self.sm:change_state(STATE_IDLE)
end

function Enemy:update(dt)
    self:_handle_state(dt)
end

function Enemy:draw()
    local x, y = self.position:get()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', x, y, 20, 20)
end

---@param position Position
function Enemy:update_target_position(position)
    self.target.position = position
    self.sm:change_state(STATE_TARGETING)
end

function Enemy:clear_target_position()
    self.target.position = nil
    self.sm:change_state(STATE_IDLE)
end

function Enemy:_handle_state(dt)
    self.sm:update(dt)

    if (self.health:get() <= 0) then
        self.sm:change_state(STATE_DEAD)
    end
end

function Enemy:_handle_movement(dt)
    if (self.target.position ~= nil) then
        local x, y = self.position:get()
        local speed = self.movement:getSpeed()
        local targetX, targetY = self.target.position:get()
        local directionX = targetX - x
        local directionY = targetY - y

        -- Normalize the direction vector
        local length = math.sqrt(directionX ^ 2 + directionY ^ 2)
        if length > 0 then
            directionX = directionX / length
            directionY = directionY / length
        end

        local newX = x + directionX * speed * dt
        local newY = y + directionY * speed * dt
        self.position:set(newX, newY)
        return
    end
end

function Enemy:__tostring()
    return "Enemy(" ..
        "position: " .. tostring(self.position) .. ", " ..
        "movement: " .. tostring(self.movement) .. ", " ..
        "health: " .. tostring(self.health) ..
        ")"
end

return Enemy
