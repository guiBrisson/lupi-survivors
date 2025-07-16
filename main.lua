local Player          = require 'src.entities.Player'
local Enemy           = require 'src.entities.Enemy'
local EnemyManager    = require 'src.system.EnemyManager'
local Camera          = require 'src.components.Camera'
local CollisionSystem = require 'src.system.CollisionSystem'
local Weapon          = require 'src.entities.Weapon'
local Circle          = require 'src.data.weapons.Circle'


DEBUG_MODE = true

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setBackgroundColor(1, 1, 1, 1)

local width, height   = love.window.getMode()
local collisionSystem = CollisionSystem:new()
local camera          = Camera:new()
local player          = Player:new({ x = width / 2, y = height / 2 })
local enemyManager    = EnemyManager:new()
local weapon          = Weapon:new(Circle)

collisionSystem:addContactCallbacks(
    Player.type, Enemy.type, function(p, e)
        --TODO: the amount of damage should be comming from the player
        -- e:takeDamage(100)
    end)

collisionSystem:addEntity(player)
enemyManager:onAddEnemy(function(enemy)
    collisionSystem:addEntity(enemy)
end)

function love.load()
    local world = collisionSystem:getWorld()
    player:load(world)
    enemyManager:load(world)
    weapon:load()
    weapon:setParentTransform(player.components.transform)
end

function love.draw()
    camera:drawWithCamera(function()
        weapon:draw()
        enemyManager:draw()
        player:draw()
    end)
end

function love.update(dt)
    player:update(dt)
    enemyManager:update(dt)
    weapon:update(dt)
    enemyManager:setTargetPosition(player:getPosition())
    collisionSystem:update(dt)
    camera:lookAt(player:getPosition())
end
