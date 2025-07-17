local Params       = require 'src.utils.params'
local StateMachine = require 'src.components.StateMachine'
local Transform    = require 'src.components.Transform'
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

---@param params table|nil
function Player:new(params)
    local instance = setmetatable({}, self)
    local default = {
        x = 0,
        y = 0,
        speed = 150,
        maxHP = 100,
        imagePath = "src/assets/player.jpg",
        scale = 3,
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
    return instance
end

function Player:load(world)
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
        anchorX = self.params.sprite.anchorX,
        anchorY = self.params.sprite.anchorY,
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
        syncDirection = Collider.SYNC_TRANSFORM_TO_PHYSICS,
        userData = self,
    })

    self.components = {
        sm = StateMachine:new(),
        transform = transform,
        movement = Movement:new(self.params.speed),
        control = Control:new(),
        health = Health:new(self.params.maxHp),
        collider = collider,
        sprite = sprite,
    }

    self:_load_states()
end

function Player:draw()
    self.components.sprite:draw()

    if DEBUG_MODE then
        self.components.collider:draw()
    end
end

function Player:update(dt)
    self:_handle_state(dt)
    self.components.collider:update(dt)
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
    local x, y = self:getPosition()
    local newX, newY = self.components.movement:move(dt, x, y, directionX, directionY)
    self.components.transform:setPosition(newX, newY)
end

---@return number
---@return number
function Player:getPosition()
    return self.components.transform:getWorldPosition()
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
