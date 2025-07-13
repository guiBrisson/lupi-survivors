local Player = require 'src.entities.Player'
local EnemyManager = require 'src.system.EnemyManager'
local Camera = require 'src.components.Camera'

love.physics.setMeter(64)
local world = love.physics.newWorld(0, 0, true)
local camera = Camera:new()
local player = Player:new()
local enemyManager = EnemyManager:new()

function love.load()
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
    camera:lookAt(player.position:get())
    world:update(dt)
end
