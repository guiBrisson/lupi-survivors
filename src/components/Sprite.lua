local Params = require 'src.utils.params'


local Sprite = {}
Sprite.__index = Sprite

function Sprite:new(params)
    local instance = setmetatable({}, self)
    local default = {
        transform = nil, --Transform (not optional)
        imagePath = nil, --string (not optional)
        scaleX = 1,
        scaleY = 1,
        rotation = 0,
        color = { 1, 1, 1, 1 },
    }

    instance.params = Params.Merge(default, params)
    instance.image = love.graphics.newImage(instance.params.imagePath)

    return instance
end

function Sprite:draw()
    local x, y = self.params.transform:getWorldPosition()
    local width = self.image:getWidth()
    local height = self.image:getHeight()
    love.graphics.setColor(self.params.color)
    love.graphics.draw(
        self.image,
        x - (width / 2) * self.params.scaleX,
        y - (height / 2) * self.params.scaleY,
        self.params.rotation,
        self.params.scaleX,
        self.params.scaleY
    )
end

return Sprite
