local Player          = require 'src.entities.Player'
local Enemy           = require 'src.entities.Enemy'
local EnemyManager    = require 'src.system.EnemyManager'
local Camera          = require 'src.components.Camera'
local CollisionSystem = require 'src.system.CollisionSystem'


local collisionSystem = CollisionSystem:new()
local camera          = Camera:new()
local player          = Player:new()
local enemyManager    = EnemyManager:new(collisionSystem)

collisionSystem:addContactCallbacks(Player.type, Enemy.type, function(p, e)
    print("player x enemy contact")
    print(p)
    print(e)
    print("")
end)

collisionSystem:addEntity(player)

function love.load()
    local world = collisionSystem:getWorld()
    player:load(world)
    enemyManager:load(world)
    enemyManager:setTargetPosition(player.position)
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
    camera:lookAt(player.position:get())
end
