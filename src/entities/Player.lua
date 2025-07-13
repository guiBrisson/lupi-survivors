local Params       = require 'src.utils.params'
local StateMachine = require 'src.components.StateMachine'
local Position     = require 'src.components.Position'
local Movement     = require 'src.components.Movement'
local Control      = require 'src.components.Control'
local Health       = require 'src.components.Health'
local Collider     = require 'src.components.Collider'
local Sprite       = require 'src.components.Sprite'


local Player = {}
Player.__index = Player
Player.type = "player"


local STATE_ALIVE = "alive"
local STATE_DEAD  = "dead"

---@param params tables|nil
function Player:new(params)
    local instance = setmetatable({}, self)
    local default = {
        x = 0,
        y = 0,
        speed = 150,
        maxHP = 100,
        imagePath = "src/assets/player.jpg",
        collisionMarginWidth = 0,
        collisionMarginHeight = 0,
        scale = 3,
    }

    instance.params = Params.Merge(default, params)
    return instance
end

function Player:load(world)
    local sprite = Sprite:new({
        imagePath = self.params.imagePath,
        scaleX = self.params.scale,
        scaleY = self.params.scale,
    })

    local colliderWidth = (sprite.image:getWidth() * self.params.scale) + self.params.collisionMarginWidth
    local colliderHeight = (sprite.image:getHeight() * self.params.scale) + self.params.collisionMarginHeight
    local collider = Collider:new({
        world = world,
        x = self.params.x,
        y = self.params.y,
        width = colliderWidth,
        height = colliderHeight,
        userData = self,
    })

    self.components = {
        sm = StateMachine:new(),
        position = Position:new(self.params.x, self.params.y),
        movement = Movement:new(self.params.speed),
        control = Control:new(),
        health = Health:new(self.params.maxHp),
        collider = collider,
        sprite = sprite,
    }

    self:_load_states()
end

function Player:draw()
    local x, y = self.components.position:get()
    local width, height = self:getSize()
    local drawX = x - (width * self.params.scale) / 2
    local drawY = y - (height * self.params.scale) / 2

    self.components.sprite:draw(drawX, drawY)
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
    local stateMachine = self.components.sm
    stateMachine:add_state(STATE_ALIVE, {
        update = function(dt)
            self:_handle_movement(dt)
        end,
    })

    stateMachine:add_state(STATE_DEAD)

    -- Set initial state
    stateMachine:change_state(STATE_ALIVE)
end

function Player:_handle_movement(dt)
    local directionX, directionY = self.components.control:update(dt)
    local x, y = self.components.position:get()
    local newX, newY = self.components.movement:move(dt, x, y, directionX, directionY)
    self.components.position:set(newX, newY)
    self.components.collider:setPosition(newX, newY)
end

---@return width number
---@return height number
function Player:getSize()
    local image = self.components.sprite.image
    return image:getWidth(), image:getHeight()
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
