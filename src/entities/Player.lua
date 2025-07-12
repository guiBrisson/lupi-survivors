local StateMachine = require 'src.components.StateMachine'
local Position = require 'src.components.Position'
local Movement = require 'src.components.Movement'
local Control = require 'src.components.Control'
local Health = require 'src.components.Health'

local Player = {}
Player.__index = Player

local STATE_ALIVE = "alive"
local STATE_DEAD = "dead"

function Player:new()
    local instance = setmetatable({}, self)

    instance.sm = StateMachine:new()
    instance.position = Position:new(0, 0)
    instance.movement = Movement:new(150)
    instance.control = Control:new()
    instance.health = Health:new(100)
    return instance
end

function Player:load()
    self.sm:add_state(STATE_ALIVE, {
        update = function(dt)
            self:_handle_movement(dt)
        end,
    })

    self.sm:add_state(STATE_DEAD)

    -- Set initial state
    self.sm:change_state(STATE_ALIVE)
end

function Player:draw()
    local x, y = self.position:get()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', x, y, 50, 50)
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

function Player:_handle_movement(dt)
    local directionX, directionY = self.control:update(dt)
    local x, y = self.position:get()
    local newX, newY = self.movement:move(dt, x, y, directionX, directionY)
    self.position:set(newX, newY)
end

function Player:__tostring()
    return "Player(" ..
        "position: " .. tostring(self.position) .. ", " ..
        "movement: " .. tostring(self.movement) .. ", " ..
        "health: " .. tostring(self.health) ..
        ")"
end

return Player
