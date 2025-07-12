local cam = require 'libs.camera'
local Position = require 'src.components.Position'

local Camera = {}
Camera.__index = Camera

function Camera:new()
    local instance = setmetatable({}, self)
    instance.cam = cam()
    return instance
end

---@param draw function everything that will be drawn with the camera
function Camera:drawWithCamera(draw)
    self.cam:attach()
    draw()
    self.cam:detach()
end

function Camera:lookAt(x, y)
    self.cam:lookAt(x, y)
end

return Camera
