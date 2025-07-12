local Player = require 'src.entities.Player'
local EnemyManager = require 'src.system.EnemyManager'

local player = Player:new()
local enemyManager = EnemyManager:new()
enemyManager:setTargetPosition(player.position)

function love.load()
    player:load()
    enemyManager:load()
end

function love.draw()
    player:draw()
    enemyManager:draw()
end

function love.update(dt)
    player:update(dt)
    enemyManager:update(dt)
end
