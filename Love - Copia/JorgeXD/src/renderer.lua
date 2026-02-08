local Renderer = {}

function Renderer.draw_player(p, img, shader, font, is_local)
    -- 1. Setup Shader
    shader:send("targetColor", {0.592, 0.161, 0.184})
    
    -- If it's a remote player, p.color is a table. 
    -- If it's local_p, we grab the individual r,g,b.
    local color = is_local and {p.r, p.g, p.b} or p.color
    shader:send("replaceColor", color)
    
    love.graphics.setShader(shader)
    
    -- 2. Draw Sprite
    love.graphics.push()
    love.graphics.translate(p.x, p.y)
    love.graphics.rotate(p.angle - math.pi/2)
    
    local scale = 2
    local sx = p.flipped and -scale or scale
    love.graphics.draw(img, 0, 0, 0, sx, scale, img:getWidth()/2, img:getHeight()/2)
    
    love.graphics.pop()
    love.graphics.setShader()
    
    -- 3. Draw Name Tag
    if is_local then love.graphics.setColor(0, 1, 0) else love.graphics.setColor(1, 1, 1) end
    love.graphics.print(p.name, p.x - font:getWidth(p.name)/2, p.y - 60)
    love.graphics.setColor(1, 1, 1) -- Reset color
end

function Renderer.draw_grid(size)
    love.graphics.setColor(0.2, 0.2, 0.2)
    for i = -size, size, 100 do
        love.graphics.line(i, -size, i, size)
        love.graphics.line(-size, i, size, i)
    end
    love.graphics.setColor(1, 1, 1)
end

return Renderer