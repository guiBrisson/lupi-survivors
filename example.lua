function love.load()
    love.physics.setMeter(64)                 -- Set the meter for the physics world
    world = love.physics.newWorld(0, 0, true) -- Create a new physics world

    -- Create player
    player = {}
    player.body = love.physics.newBody(world, 100, 100, "dynamic") -- Dynamic body
    player.shape = love.physics.newRectangleShape(50, 50)          -- Rectangle shape
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.fixture:setUserData("player")                           -- Set user data for collision detection

    -- Create enemy
    enemy = {}
    enemy.body = love.physics.newBody(world, 300, 100, "static") -- Static body
    enemy.shape = love.physics.newRectangleShape(50, 50)         -- Rectangle shape
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape)
    enemy.fixture:setUserData("enemy")                           -- Set user data for collision detection

    -- Set up collision callbacks
    world:setCallbacks(beginContact)
end

local function beginContact(a, b, coll)
    -- Check if the player and enemy are colliding
    if (a:getUserData() == "player" and b:getUserData() == "enemy") or
        (a:getUserData() == "enemy" and b:getUserData() == "player") then
        print("Collision detected!")
        -- Handle collision (e.g., reduce health, end game, etc.)
    end
end

function love.update(dt)
    world:update(dt) -- Update the physics world

    -- Example player movement
    if love.keyboard.isDown("right") then
        player.body:setLinearVelocity(200, 0)
    elseif love.keyboard.isDown("left") then
        player.body:setLinearVelocity(-200, 0)
    else
        player.body:setLinearVelocity(0, 0)
    end
end

function love.draw()
    -- Draw the player
    love.graphics.setColor(1, 0, 0) -- Red for player
    love.graphics.polygon("fill", player.body:getWorldPoints(player.shape:getPoints()))

    -- Draw the enemy
    love.graphics.setColor(0, 0, 1) -- Blue for enemy
    love.graphics.polygon("fill", enemy.body:getWorldPoints(enemy.shape:getPoints()))
end
