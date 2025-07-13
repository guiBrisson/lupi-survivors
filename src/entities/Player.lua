local StateMachine = require 'src.components.StateMachine'
local Position     = require 'src.components.Position'
local Movement     = require 'src.components.Movement'
local Control      = require 'src.components.Control'
local Health       = require 'src.components.Health'
local Collider     = require 'src.components.Collider'
local Params       = require 'src.utils.params'


local Player = {}
Player.__index = Player
Player.type = "player"


local STATE_ALIVE = "alive"
local STATE_DEAD  = "dead"

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
    self.components = {
        sm = StateMachine:new(),
        position = Position:new(self.params.x, self.params.y),
        movement = Movement:new(self.params.speed),
        control = Control:new(),
        health = Health:new(self.params.maxHp),
        collider = Collider:new(world, self.params.x, self.params.y, 'dynamic', self.params.size, self, true),
    }

    self:_load_states()
end

function Player:draw()
    local x, y = self.components.position:get()
    local size = self.params.size
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', x - size / 2, y - size / 2, size, size)
    self.components.collider:draw()
end

function Player:update(dt)
    self:_handle_state(dt)
end

function Player:_handle_state(dt)
    self.components.sm:update(dt)

    if self.components.health:get() <= 0 then
        self.components.sm:change_state(STATE_DEAD)
    end
end

function Player:_load_states()
    local sm = self.components.sm
    sm:add_state(STATE_ALIVE, {
        update = function(dt)
            self:_handle_movement(dt)
        end,
    })

    sm:add_state(STATE_DEAD)

    -- Set initial state
    sm:change_state(STATE_ALIVE)
end

function Player:_handle_movement(dt)
    local directionX, directionY = self.components.control:update(dt)
    local x, y = self.components.position:get()
    local newX, newY = self.components.movement:move(dt, x, y, directionX, directionY)
    self.components.position:set(newX, newY)
    self.components.collider:setPosition(newX, newY)
end

function Player:destroy()
    for _, component in pairs(self.components) do
        if component.destroy then
            component:destroy()
        end
        component = nil
    end
end

function Player:__tostring()
    local stringComponents = ""

    for name, component in pairs(self.components) do
        stringComponents = stringComponents .. tostring(name) .. ": " .. tostring(component) .. ", "
    end

    return "Player(" .. stringComponents .. ")"
end

return Player
