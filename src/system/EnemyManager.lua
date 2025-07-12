local Enemy = require 'src.entities.Enemy'

local EnemyManager = {}
EnemyManager.__index = EnemyManager

function EnemyManager:new()
    local instance = setmetatable({}, self)
    instance.enemies = {}
    instance.target = {}
    return instance
end

function EnemyManager:load()
    for i = 1, 10 do
        local x = math.random(0, love.graphics.getWidth())
        local y = math.random(0, love.graphics.getHeight())
        local enemy = Enemy:new({ x = x, y = y })
        self:_addEnemy(enemy)
        enemy:load()
    end
end

function EnemyManager:update(dt)
    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt)

        if self.target.position then
            enemy:update_target_position(self.target.position)
        end
    end
end

function EnemyManager:draw()
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end
end

---@param position Position
function EnemyManager:setTargetPosition(position)
    self.target.position = position
end

function EnemyManager:clearTargetPosition()
    self.target.position = nil
end

---@param enemy Enemy
function EnemyManager:_addEnemy(enemy)
    table.insert(self.enemies, enemy)
end

return EnemyManager
