local Player          = require 'src.entities.Player'
local Enemy           = require 'src.entities.Enemy'
local EnemyManager    = require 'src.system.EnemyManager'
local Camera          = require 'src.components.Camera'
local CollisionSystem = require 'src.system.CollisionSystem'
local InventorySystem = require 'src.system.InventorySystem'
local Circle          = require 'src.data.weapons.Circle'
local EventBus        = require 'src.components.EventBus'


DEBUG_MODE = true

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setBackgroundColor(1, 1, 1, 1)

local width, height   = love.window.getMode()
local eventBus        = EventBus:new()
local collisionSystem = CollisionSystem:new()
local camera          = Camera:new()
local player          = Player:new({ x = width / 2, y = height / 2 })
local inventory       = InventorySystem:new(player)
local enemyManager    = EnemyManager:new()

collisionSystem:addContactCallbacks(
    Player.type, Enemy.type, function(p, e)
        --TODO: the amount of damage should be comming from the player's weapon
        e:takeDamage(100)
    end)

function love.load()
    local world = collisionSystem:getWorld()
    player:load(world)
    enemyManager:load(world, eventBus)
    inventory:addWeapon(Circle)

    collisionSystem:addEntity(player)

    eventBus:on(EnemyManager.event.onAddEnemy, function(enemy)
        collisionSystem:addEntity(enemy)
    end)

    eventBus:on(EnemyManager.event.onRemoveEnemy, function(enemy)
        collisionSystem:removeEntity(enemy)
    end)
end

function love.draw()
    camera:drawWithCamera(function()
        inventory:draw()
        enemyManager:draw()
        player:draw()
    end)
end

function love.update(dt)
    player:update(dt)
    inventory:update(dt)
    enemyManager:update(dt)
    enemyManager:setTargetPosition(player:getPosition())
    collisionSystem:update(dt)
    camera:lookAt(player:getPosition())
end
