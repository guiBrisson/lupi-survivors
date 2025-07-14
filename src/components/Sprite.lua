local Params = require 'src.utils.params'


local Sprite = {}
Sprite.__index = Sprite

function Sprite:new(params)
    local instance = setmetatable({}, self)
    local default = {
        imagePath = nil,
        offsetX = 0,
        offsetY = 0,
        scaleX = 1,
        scaleY = 1,
        rotation = 0,
        color = { 1, 1, 1, 1 },
        anchorX = 0,
        anchorY = 0
    }

    instance.params = Params.Merge(default, params)
    instance.image = love.graphics.newImage(instance.params.imagePath)

    instance.anchorOffsetX = instance.image:getWidth() * instance.params.anchorX * instance.params.scaleX
    instance.anchorOffsetY = instance.image:getHeight() * instance.params.anchorY * instance.params.scaleY

    return instance
end

function Sprite:draw(x, y)
    local width = self.image:getWidth()
    local height = self.image:getHeight()

    love.graphics.setColor(self.params.color)
    love.graphics.draw(
        self.image,
        x + self.anchorOffsetX + self.params.offsetX,
        y + self.anchorOffsetY + self.params.offsetY,
        self.params.rotation,
        self.params.scaleX,
        self.params.scaleY
    )
end

return Sprite
