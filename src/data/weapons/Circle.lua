local atkSprite = "src/assets/weapons/circle/circle-white.png"
local spriteScale = 0.3

--- This is a placeholder for an area atack
local Circle = {
    name = "circle",
    type = "area",
    pattern = "fixed",
    levels = {
        {
            atkSprite = atkSprite,
            spriteScaleX = spriteScale,
            spriteScaleY = spriteScale,
            damage = 10,
            range = 10,
            cooldown = 3,
            activeCooldown = 0.8,
        },
        {
            atkSprite = atkSprite,
            spriteScaleX = spriteScale,
            spriteScaleY = spriteScale,
            damage = 20,
            range = 15,
            cooldown = 2.5,
            activeCooldown = 1,
        },
        {
            atkSprite = atkSprite,
            spriteScaleX = spriteScale,
            spriteScaleY = spriteScale,
            damage = 40,
            range = 22,
            cooldown = 2,
            activeCooldown = 1.5,
        },
        {
            atkSprite = atkSprite,
            spriteScaleX = spriteScale,
            spriteScaleY = spriteScale,
            damage = 50,
            range = 25,
            cooldown = 1.5,
            activeCooldown = 1.9,
        },
        {
            atkSprite = atkSprite,
            spriteScaleX = spriteScale,
            spriteScaleY = spriteScale,
            damage = 80,
            range = 30,
            cooldown = 0.5,
            activeCooldown = 2.2,
        }
    }
}

return Circle
