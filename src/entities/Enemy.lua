local StateMachine    = require 'src.components.StateMachine'
local Position        = require 'src.components.Position'
local Health          = require 'src.components.Health'
local Collider        = require 'src.components.Collider'
local Params          = require 'src.utils.params'

local Enemy           = {}
Enemy.__index         = Enemy

Enemy.type            = "enemy"
local STATE_TARGETING = "targeting"
local STATE_IDLE      = "idle"
local STATE_ALIVE     = "alive"
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
    return instance
end

function Enemy:load(world)
    self.type = "enemy"
    self.sm = StateMachine:new()
    self.position = Position:new(self.params.x, self.params.y)
    self.health = Health:new(self.params.maxHp)
    self.collider = Collider:new(world, self.params.x, self.params.y, 'dynamic', self.params.size, self)
    self.collider:setFixedRotation(true)
    self.target = {}

    self:_load_states()
end

function Enemy:update(dt)
    self:_handle_state(dt)
end

function Enemy:draw()
    local x, y = self.position:get()
    local size = 20
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', x - size / 2, y - size / 2, size, size)
    self.collider:draw()
end

function Enemy:_load_states()
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
        local speed = self.params.speed
        local targetX, targetY = self.target.position:get()
        local directionX = targetX - x
        local directionY = targetY - y

        -- Normalize the direction vector
        local length = math.sqrt(directionX ^ 2 + directionY ^ 2)
        if length > 0 then
            directionX = directionX / length
            directionY = directionY / length
            self.collider:setLinearVelocity(directionX * speed, directionY * speed)
        end

        self.position:set(self.collider:getPosition())
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
