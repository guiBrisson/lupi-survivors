local Control = {}
Control.__index = Control

function Control:new()
    return setmetatable({}, self)
end

---@param dt number
---@return number
---@return number
function Control:update(dt)
    local directionX, directionY = 0, 0

    if love.keyboard.isDown("up") then
        directionY = directionY - 1
    end
    if love.keyboard.isDown("down") then
        directionY = directionY + 1
    end
    if love.keyboard.isDown("left") then
        directionX = directionX - 1
    end
    if love.keyboard.isDown("right") then
        directionX = directionX + 1
    end

    -- Normalize the direction vector if moving diagonally
    if directionX ~= 0 or directionY ~= 0 then
        local length = math.sqrt(directionX ^ 2 + directionY ^ 2)
        directionX = directionX / length
        directionY = directionY / length
    end

    return directionX, directionY
end

function Control:__tostring()
    return "Control()"
end

return Control
