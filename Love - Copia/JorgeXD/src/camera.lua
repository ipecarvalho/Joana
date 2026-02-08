local Camera = {}

function Camera.new()
    return {
        x = 0,
        y = 0,
        lerp_speed = 5, -- Smoothness of the camera
        lean_factor = 0.2 -- How much it leans toward the mouse (0.1 to 0.3 is best)
    }
end

function Camera.update(cam, dt, player_x, player_y)
    local mouse_x, mouse_y = love.mouse.getPosition()
    local screen_w, screen_h = love.graphics.getDimensions()

    -- Calculate where the camera "wants" to be
    -- Center of screen + (Mouse offset from center * lean_factor)
    local target_x = player_x - screen_w / 2 + (mouse_x - screen_w / 2) * cam.lean_factor
    local target_y = player_y - screen_h / 2 + (mouse_y - screen_h / 2) * cam.lean_factor

    -- Smoothly slide the camera toward the target
    cam.x = cam.x + (target_x - cam.x) * cam.lerp_speed * dt
    cam.y = cam.y + (target_y - cam.y) * cam.lerp_speed * dt
end

function Camera.apply(cam)
    love.graphics.push()
    love.graphics.translate(-math.floor(cam.x), -math.floor(cam.y))
end

function Camera.detach()
    love.graphics.pop()
end

return Camera