local Enemy = require 'src.entities.Enemy'

local EnemyManager = {}
EnemyManager.__index = EnemyManager

function EnemyManager:new()
    local instance = setmetatable({}, self)
    instance.world = nil -- must be passed via load function
    instance.enemies = {}
    instance.deadEnemies = {}
    instance.target = {
        position = { x = nil, y = nil }
    }
    instance.callbacks = {
        onAddEnemy = {},
        onRemoveEnemy = {},
    }
    instance.spawnCooldown = 1
    instance.remaningSpawnCooldown = 0
    return instance
end

function EnemyManager:load(world)
    self.world = world
end

function EnemyManager:update(dt)
    self:_spawnEnemy(dt)

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt)

        local hasTargetPosition = self.target.position.x ~= nil and self.target.position.y ~= nil
        if hasTargetPosition then
            enemy:updateTargetPosition(self.target.position.x, self.target.position.y)
        end
    end

    for _, enemy in ipairs(self.deadEnemies) do
        self:_removeEnemy(enemy)
    end
    self.deadEnemies = {}
end

function EnemyManager:draw()
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end

---@param enemy Enemy
function EnemyManager:_addEnemy(enemy)
    table.insert(self.enemies, enemy)

    self:_notifyCallback(self.callbacks.onAddEnemy, enemy)
end

---@param enemy Enemy
function EnemyManager:_removeEnemy(enemy)
    for i, e in ipairs(self.enemies) do
        if e == enemy then
            table.remove(self.enemies, i)
            e:destroy()
            break
        end
    end

    self:_notifyCallback(self.callbacks.onRemoveEnemy, enemy)
end

function EnemyManager:_notifyCallback(callbacks, ...)
    for _, callback in ipairs(callbacks) do
        callback(...)
    end
end

function EnemyManager:_spawnEnemy(dt)
    if self.target.position.x ~= nil and self.target.position.y ~= nil then
        self.remaningSpawnCooldown = self.remaningSpawnCooldown - dt

        if self.remaningSpawnCooldown <= 0 then
            local x, y = self:_generatePositionOutOfView()
            local enemy = Enemy:new({ x = x, y = y })
            self:_addEnemy(enemy)
            enemy:load(self.world)
            enemy:onDeadState(function()
                self:markForRemoval(enemy)
            end)

            self.remaningSpawnCooldown = self.spawnCooldown
        end
    end
end

---@return x integer
---@return y integer
function EnemyManager:_generatePositionOutOfView()
    local targetX = self.target.position.x or 0
    local targetY = self.target.position.y or 0
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local side = math.random(1, 4) -- 1: left, 2: right, 3: top, 4: bottom
    local offset = 100
    local x, y

    if side == 1 then
        -- Spawn on the left side, offset from the target's y position
        x = targetX - (windowWidth / 2) - offset
        y = math.random(0, windowHeight)
    elseif side == 2 then
        -- Spawn on the right side, offset from the target's y position
        x = targetX + (windowWidth / 2) + offset
        y = math.random(0, windowHeight)
    elseif side == 3 then
        -- Spawn on the top side, offset from the target's x position
        x = math.random(0, windowWidth)
        y = targetY - (windowHeight / 2) - offset
    else
        -- Spawn on the bottom side, offset from the target's x position
        x = math.random(0, windowWidth)
        y = targetY + (windowHeight / 2) + offset
    end

    return x, y
end

function EnemyManager:onAddEnemy(callback)
    local callbacks = self.callbacks.onAddEnemy
    table.insert(callbacks, callback)
end

function EnemyManager:onRemoveEnemy(callback)
    local callbacks = self.callbacks.onRemoveEnemy
    table.insert(callbacks, callback)
end

function EnemyManager:markForRemoval(enemy)
    table.insert(self.deadEnemies, enemy)
end

function EnemyManager:setTargetPosition(x, y)
    self.target.position.x = x
    self.target.position.y = y
end

function EnemyManager:clearTargetPosition()
    self.target.position = nil
end

return EnemyManager
