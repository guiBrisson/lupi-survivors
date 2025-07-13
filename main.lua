local Player          = require 'src.entities.Player'
local Enemy           = require 'src.entities.Enemy'
local EnemyManager    = require 'src.system.EnemyManager'
local Camera          = require 'src.components.Camera'
local CollisionSystem = require 'src.system.CollisionSystem'


local collisionSystem = CollisionSystem:new()
local camera          = Camera:new()
local player          = Player:new()
local enemyManager    = EnemyManager:new()

collisionSystem:addContactCallbacks(Player.type, Enemy.type, function(p, e)
    --TODO: the amount of damage should be comming from the player
    e:takeDamage(100)
end)

collisionSystem:addEntity(player)
enemyManager:onAddEnemy(function(enemy)
    collisionSystem:addEntity(enemy)
end)

function love.load()
    local world = collisionSystem:getWorld()
    player:load(world)
    enemyManager:load(world)
    enemyManager:setTargetPosition(player.components.position)
end

function love.draw()
    camera:drawWithCamera(function()
        player:draw()
        enemyManager:draw()
    end)
end

function love.update(dt)
    player:update(dt)
    enemyManager:update(dt)
    collisionSystem:update(dt)
    camera:lookAt(player.components.position:get())
end
