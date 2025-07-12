local Player = require 'src.entities.Player'
local EnemyManager = require 'src.system.EnemyManager'
local Camera = require 'src.components.Camera'

local camera = Camera:new()
local player = Player:new()
print(player)
local enemyManager = EnemyManager:new()
enemyManager:setTargetPosition(player.position)

function love.load()
    player:load()
    enemyManager:load()
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
    camera:lookAt(player.position:get())
end
