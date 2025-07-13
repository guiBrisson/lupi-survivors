local StateMachine = require 'src.components.StateMachine'
local Position     = require 'src.components.Position'
local Movement     = require 'src.components.Movement'
local Control      = require 'src.components.Control'
local Health       = require 'src.components.Health'
local Collider     = require 'src.components.Collider'
local Params       = require 'src.utils.params'

local Player       = {}
Player.__index     = Player

local STATE_ALIVE  = "alive"
local STATE_DEAD   = "dead"

function Player:new(params)
    local instance = setmetatable({}, self)
    local default = {
        x = 0,
        y = 0,
        size = 50,
        speed = 150,
        maxHP = 100,
    }

    instance.params = Params.Merge(default, params)
    return instance
end

function Player:load(world)
    self.sm = StateMachine:new()
    self.position = Position:new(self.params.x, self.params.y)
    self.movement = Movement:new(self.params.speed)
    self.control = Control:new()
    self.health = Health:new(self.params.maxHp)
    self.collider = Collider:new(world, self.params.x, self.params.y, 'dynamic', self.params.size, self)
    self.collider:setFixedRotation(true)

    self:_load_states()
end

function Player:draw()
    local x, y = self.position:get()
    local size = self.params.size
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', x - size / 2, y - size / 2, size, size)
    self.collider:draw()
end

function Player:update(dt)
    self:_handle_state(dt)
end

function Player:_handle_state(dt)
    self.sm:update(dt)


    if self.health:get() <= 0 then
        self.sm.change_state(STATE_DEAD)
    end
end

function Player:_load_states()
    self.sm:add_state(STATE_ALIVE, {
        update = function(dt)
            self:_handle_movement(dt)
        end,
    })

    self.sm:add_state(STATE_DEAD)

    -- Set initial state
    self.sm:change_state(STATE_ALIVE)
end

function Player:_handle_movement(dt)
    local directionX, directionY = self.control:update(dt)
    local x, y = self.position:get()
    local newX, newY = self.movement:move(dt, x, y, directionX, directionY)
    self.position:set(newX, newY)
    self.collider:setPosition(newX, newY)
end

function Player:__tostring()
    return "Player(" ..
        "position: " .. tostring(self.position) .. ", " ..
        "movement: " .. tostring(self.movement) .. ", " ..
        "health: " .. tostring(self.health) ..
        ")"
end

return Player
