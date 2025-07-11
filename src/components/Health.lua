local Health = {}
Health.__index = Health

---@param maxHP number
function Health:new(maxHP)
    local instance = setmetatable({}, self)

    instance.maxHp = maxHP or 100
    instance.currentHp = instance.maxHp

    return instance
end

---Increase the current health by the specified amount
---@param amount number
---@return number actualAmount: returns the actual healed amount
function Health:heal(amount)
    if amount < 0 then return 0 end

    local missingHp = self.maxHp - self.currentHp
    local actual = math.min(amount, missingHp)
    self.currentHp = self.currentHp + actual
    return actual
end

---Reduce the current health by the specified amount
---@param amount number
---@return number actualAmount: returns the actual damage amount
function Health:damage(amount)
    if amount < 0 then return 0 end

    local actual = math.min(amount, self.currentHp)
    self.currentHp = self.currentHp - actual
    return actual
end

---Get the current Health
---@return number
function Health:get()
    return self.currentHp
end

function Health:__tostring()
    return "Health(currentHp: " .. self.currentHp .. ", " .. "maxHP: " .. self.maxHp .. ")"
end

return Health
