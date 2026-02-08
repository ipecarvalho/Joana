local Player = {}

function Player.create(name)
    return {
        x = 400, y = 300, angle = 0, 
        name = name, speed = 250,
        r = love.math.random(), g = love.math.random(), b = love.math.random(),
        flipped = false, walk_timer = 0
    }
end

function Player.update_animation(p, dt, moving)
    if moving then
        p.walk_timer = p.walk_timer + dt
        if p.walk_timer >= 0.2 then
            p.walk_timer = 0
            p.flipped = not p.flipped
        end
    else
        p.flipped = false
        p.walk_timer = 0
    end
end

return Player