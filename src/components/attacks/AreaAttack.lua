local Params = require 'src.utils.params'

local AreaAttack = {}
AreaAttack.__index = AreaAttack

function AreaAttack:new(params)
    local instance = setmetatable({}, self)
    local default = {
        name = "area attack",
        cooldown = 1.0, -- in seconds
        damage = 10,

        areaOfEffect = 20,
        pattern = "expand",   -- 'expand'|'fixed'
        speed = 100,          -- for expand pattern (TODO)
        amount = 1,
        activeCooldown = nil, -- in seconds
    }

    instance.params = Params.Merge(default, params)
    instance.isActive = true
    instance.remainingCooldown = 0
    return instance
end

function AreaAttack:update(dt)
    if self.params.pattern == "expand" then
        -- TODO
    elseif self.params.pattern == "fixed" then
        self:_calculateFixedPatternUpdate(dt)
    else
        error("not a valid area of attack pattern: " .. self.params.pattern)
    end
end

function AreaAttack:_calculateFixedPatternUpdate(dt)
    self.params.remainingCooldown = (self.params.remainingCooldown or 0) - dt

    if self.params.remainingCooldown <= 0 then
        self.isActive = not self.isActive
        if self.isActive then
            self.params.remainingCooldown = self.params.activeCooldown
        else
            self.params.remainingCooldown = self.params.cooldown
        end
    end
end

return AreaAttack
