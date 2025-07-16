local Params = require 'src.utils.params'

local Transform = {}
Transform.__index = Transform

function Transform:new(params)
    local instance = setmetatable({}, self)
    local default = {
        x = 0,
        y = 0,
        rotation = 0, -- radians
        scaleX = 1,
        scaleY = 1,
        parent = nil -- optional parent transform
    }

    instance.params = Params.Merge(default, params)
    return instance
end

---@param dx number
---@param dy number
function Transform:move(dx, dy)
    self.params.x = self.params.x + dx
    self.params.y = self.params.y + dy
end

---@param dradians number
function Transform:rotate(dradians)
    self.params.rotation = self.params.rotation + dradians
end

---@param transform Transform
function Transform:setParentTransform(transform)
    self.params.parent = transform
end

---@param x number
---@param y number
function Transform:setPosition(x, y)
    self.params.x, self.params.y = x, y
end

---@param radians number
function Transform:setRotation(radians)
    self.params.rotation = radians
end

---@param sx number
---@param sy number|nil
function Transform:setScale(sx, sy)
    self.params.scaleX = sx
    self.params.scaleY = sy or sx -- Uniform scaling if sy omitted
end

--- Get world position considering parent hierarchy
--- @return x number, y number
function Transform:getWorldPosition()
    if self.params.parent then
        local parentX, parentY = self.params.parent:getWorldPosition()
        local rot = self.params.parent.params.rotation
        local x = parentX + self.params.x * math.cos(rot) - self.params.y * math.sin(rot)
        local y = parentY + self.params.x * math.sin(rot) + self.params.y * math.cos(rot)
        return x, y
    end
    return self.params.x, self.params.y
end

function Transform:getRotation()
    return self.params.rotation
end

return Transform
