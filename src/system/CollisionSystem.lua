local CollisionSystem = {}
CollisionSystem.__index = CollisionSystem

function CollisionSystem:new()
    local instance = setmetatable({}, self)
    instance.world = love.physics.newWorld(0, 0, true)
    instance.colliders = {}
    instance.contactCallbacks = {}

    instance.world:setCallbacks(
        function(...) instance:beginContact(...) end,
        function(...) instance:endContact(...) end,
        nil, nil
    )
    return instance
end

---@param dt number
function CollisionSystem:update(dt)
    self.world:update(dt)
end

---@return world love.physics.World
function CollisionSystem:getWorld()
    return self.world
end

--- Register a collision handler for specific entity types
---@param typeA string|nil
---@param typeB string|nil
---@param callback function
function CollisionSystem:addContactCallbacks(typeA, typeB, callback)
    table.insert(self.contactCallbacks, {
        classA = typeA,
        classB = typeB,
        callback = callback,
    })
end

function CollisionSystem:beginContact(fixtureA, fixtureB, contact)
    local entityA = fixtureA:getUserData()
    local entityB = fixtureB:getUserData()

    for _, callbackInfo in ipairs(self.contactCallbacks) do
        local matchForward = self:matchEntities(callbackInfo.classA, entityA, callbackInfo.classB, entityB)
        local matchReverse = self:matchEntities(callbackInfo.classA, entityB, callbackInfo.classB, entityA)

        if matchForward then
            callbackInfo.callback(entityA, entityB, contact)
        elseif matchReverse then
            callbackInfo.callback(entityB, entityA, contact)
        end
    end
end

function CollisionSystem:endContact(fixtureA, fixtureB, contact)
    --TODO: handle end of collisions if needed
end

function CollisionSystem:matchEntities(typeA, entityA, typeB, entityB)
    local aMatches = typeA == nil or (entityA and entityA.type == typeA)
    local bMatches = typeB == nil or (entityB and entityB.type == typeB)
    return aMatches and bMatches
end

function CollisionSystem:addEntity(entity)
    if entity.collider then
        self.colliders[entity] = true
    end
end

function CollisionSystem:removeEntity(entity)
    self.colliders[entity] = nil
end

return CollisionSystem
