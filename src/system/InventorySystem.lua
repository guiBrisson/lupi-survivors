local Weapon = require 'src.entities.Weapon'


local InventorySystem = {}
InventorySystem.__index = InventorySystem

function InventorySystem:new(player)
    local instance = setmetatable({}, self)
    instance.maxSpots = 5
    instance.availableSpots = instance.maxSpots
    instance.player = player
    instance.inventory = {
        weapons = {},
        --TODO: add the passive inventory
    }
    return instance
end

function InventorySystem:draw()
    for _, weapon in pairs(self.inventory.weapons) do
        weapon:draw()
    end
end

function InventorySystem:update(dt)
    for _, weapon in pairs(self.inventory.weapons) do
        weapon:update(dt)
    end
end

---@param weaponData table The table that represents the params for a weapon
function InventorySystem:addWeapon(weaponData)
    if self.availableSpots > 0 then
        for i, value in pairs(self.inventory.weapons) do
            if value.params.name == weaponData.name then
                self:_levelUpWeaponAt(i)
                return
            end
        end

        local weapon = Weapon:new(weaponData)
        weapon:setParentTransform(self.player.components.transform)
        weapon:load()
        table.insert(self.inventory.weapons, weapon)
        self.availableSpots = self.availableSpots - 1
    end
end

---@param index number
function InventorySystem:_levelUpWeaponAt(index)
    local weapon = self.inventory.weapons[index]
    weapon:levelUp()
end

return InventorySystem
