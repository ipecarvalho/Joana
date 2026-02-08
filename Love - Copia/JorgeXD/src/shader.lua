local Shader = {}

function Shader.load()
    return love.graphics.newShader[[
        extern vec3 targetColor;
        extern vec3 replaceColor;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture, texture_coords);
            if (distance(pixel.rgb, targetColor) < 0.01) {
                return vec4(replaceColor, pixel.a);
            }
            return pixel * color;
        }
    ]]
end

return Shader