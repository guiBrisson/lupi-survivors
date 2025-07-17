local Params     = require 'src.utils.params'
local Sprite     = require 'src.components.Sprite'
local Transform  = require 'src.components.Transform'
local AreaAttack = require 'src.components.attacks.AreaAttack'


local Weapon = {}
Weapon.__index = Weapon

function Weapon:new(params)
    local instance = setmetatable({}, self)
    local default = {
        name = "unamed weapon",
        type = "area",      -- 'area'|'projectile'
        pattern = "expand", -- 'expand'|'fixed' TODO: add patterns for projectile
        levels = {
            {
                atkSprite = nil,
                damage = 10,
                range = 10,
                cooldown = 1,         -- in seconds
                amount = 1,
                activeCooldown = nil, -- in seconds
            }
        },
    }

    instance.params = Params.Merge(default, params)
    instance.params.maxLevel = #instance.params.levels

    instance.currentLevel = 1
    instance.transform = Transform:new()
    instance.levelsSprite = {}
    instance.levelsAttack = {}

    return instance
end

function Weapon:load()
    for i, level in ipairs(self.params.levels) do
        local sprite = self:_createSpriteForLevel(level)
        table.insert(self.levelsSprite, i, sprite)

        local attack = self:_createAttackForLevel(level)
        table.insert(self.levelsAttack, i, attack)
    end
end

function Weapon:draw()
    if self.currentLevel <= self.params.maxLevel then
        local sprite = self.levelsSprite[self.currentLevel]
        local attack = self.levelsAttack[self.currentLevel]
        if attack.isActive then
            sprite:draw()
        end
    end
end

function Weapon:update(dt)
    if self.currentLevel <= self.params.maxLevel then
        local attack = self.levelsAttack[self.currentLevel]
        attack:update(dt)
    end
end

function Weapon:levelUp()
    if self:canLevelUp() then
        self.currentLevel = self.currentLevel + 1
        return true
    end
    return false
end

function Weapon:canLevelUp()
    return self.currentLevel < #self.params.maxLevel
end

---@param transform Transform
function Weapon:setParentTransform(transform)
    self.transform:setParentTransform(transform)
end

function Weapon:_createSpriteForLevel(level)
    return Sprite:new({
        transform = self.transform,
        imagePath = level.atkSprite,
        scaleX = level.spriteScaleX,
        scaleY = level.spriteScaleY,
    })
end

function Weapon:_createAttackForLevel(level)
    if self.params.type == "area" then
        return AreaAttack:new({
            name = self.params.name,
            pattern = self.params.pattern,
            cooldown = level.cooldown,
            damage = level.damage,
            areaOfEffect = level.range,
            amount = level.amount,
            activeCooldown = level.activeCooldown,
        })
    elseif self.params.type == "projectile" then
        -- TODO
    else
        error("not a valid weapon type: " .. self.params.type)
    end
end

function Weapon:__tostring()
    local levels = "levels: {"
    for i, level in ipairs(self.params.levels) do
        levels = levels .. i .. ": {"
        for key, value in pairs(level) do
            levels = levels .. tostring(key) .. ": " .. tostring(value) .. ", "
        end
        -- Remove the trailing comma and space
        levels = levels:sub(1, -3)
        levels = levels .. "}"
        if i ~= #self.params.levels then
            levels = levels .. ", "
        end
    end
    levels = levels .. '}'

    return "Weapon(" ..
        "name: " .. self.params.name .. ", " ..
        "type: " .. self.params.type .. ", " ..
        "maxLevel: " .. tostring(self.params.maxLevel) .. ", " ..
        levels ..
        ")"
end

return Weapon
