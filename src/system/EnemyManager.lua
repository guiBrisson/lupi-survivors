local Enemy = require 'src.entities.Enemy'

local EnemyManager = {}
EnemyManager.__index = EnemyManager

function EnemyManager:new()
    local instance = setmetatable({}, self)
    instance.enemies = {}
    instance.deadEnemies = {}
    instance.target = {
        position = { x = nil, y = nil }
    }
    instance.callbacks = {
        onAddEnemy = {},
        onRemoveEnemy = {},
    }
    return instance
end

function EnemyManager:load(world)
    for i = 1, 10 do
        local x = math.random(0, love.graphics.getWidth())
        local y = math.random(0, love.graphics.getHeight())
        local enemy = Enemy:new({ x = x, y = y })
        self:_addEnemy(enemy)
        enemy:load(world)
        enemy:onDeadState(function()
            self:markForRemoval(enemy)
        end)
    end
end

function EnemyManager:update(dt)
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

function EnemyManager:markForRemoval(enemy)
    table.insert(self.deadEnemies, enemy)
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

function EnemyManager:onAddEnemy(callback)
    local callbacks = self.callbacks.onAddEnemy
    table.insert(callbacks, callback)
end

function EnemyManager:onRemoveEnemy(callback)
    local callbacks = self.callbacks.onRemoveEnemy
    table.insert(callbacks, callback)
end

function EnemyManager:setTargetPosition(x, y)
    self.target.position.x = x
    self.target.position.y = y
end

function EnemyManager:clearTargetPosition()
    self.target.position = nil
end

return EnemyManager
