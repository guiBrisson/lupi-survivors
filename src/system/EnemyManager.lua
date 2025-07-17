local Enemy = require 'src.entities.Enemy'

local EnemyManager = {}
EnemyManager.__index = EnemyManager

EnemyManager.event = {
    onAddEnemy = "on_add_enemy",
    onRemoveEnemy = "on_remove_enemy",
}

function EnemyManager:new()
    local instance = setmetatable({}, self)
    instance.enemies = {}
    instance.deadEnemies = {}
    instance.deadEnemiesCount = 0
    instance.target = {
        position = { x = nil, y = nil }
    }
    instance.spawnCooldown = 1
    instance.remaningSpawnCooldown = 0
    return instance
end

function EnemyManager:load(world, eventBus)
    self.world = world
    self.eventBus = eventBus
    self.eventBus:on(Enemy.event.onDeadEvent, function(enemy)
        self:markForRemoval(enemy)
    end)
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

    self:_notifyEvent(EnemyManager.event.onAddEnemy, enemy)
end

---@param enemy Enemy
function EnemyManager:_removeEnemy(enemy)
    for i, e in ipairs(self.enemies) do
        if e == enemy then
            table.remove(self.enemies, i)
            e:destroy()
            self.deadEnemiesCount = self.deadEnemiesCount + 1
            break
        end
    end

    self:_notifyEvent(EnemyManager.event.onRemoveEnemy, enemy)
end

function EnemyManager:_notifyEvent(event, ...)
    if (self.eventBus) then
        self.eventBus:emit(event, ...)
    end
end

function EnemyManager:_spawnEnemy(dt)
    if self.target.position.x ~= nil and self.target.position.y ~= nil then
        self.remaningSpawnCooldown = self.remaningSpawnCooldown - dt

        if self.remaningSpawnCooldown <= 0 then
            local x, y = self:_generatePositionOutOfView()
            local enemy = Enemy:new({ x = x, y = y })
            self:_addEnemy(enemy)
            enemy:load(self.world, self.eventBus)
            self.remaningSpawnCooldown = self.spawnCooldown
        end
    end
end

function EnemyManager:_generatePositionOutOfView()
    local targetX = self.target.position.x or 0
    local targetY = self.target.position.y or 0
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local LEFT = 1
    local RIGHT = 2
    local TOP = 3
    local BOTTOM = 4
    local side = math.random(LEFT, BOTTOM) --TODO: this is not random
    local offset = 100
    local x, y

    if side == LEFT then
        x = targetX - (windowWidth / 2) - offset
        y = math.random(0, windowHeight)
    elseif side == RIGHT then
        x = targetX + (windowWidth / 2) + offset
        y = math.random(0, windowHeight)
    elseif side == TOP then
        x = math.random(0, windowWidth)
        y = targetY - (windowHeight / 2) - offset
    elseif side == BOTTOM then
        x = math.random(0, windowWidth)
        y = targetY + (windowHeight / 2) + offset
    end

    return x, y
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
