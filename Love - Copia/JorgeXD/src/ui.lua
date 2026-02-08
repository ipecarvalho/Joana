local UI = {}

function UI.new()
    return {
        chat_history = {},
        current_input = "",
        is_chatting = false,
        typing_name = true -- Starts here
    }
end

function UI.draw(ui, gameState, font)
    local sw, sh = love.graphics.getDimensions()
    
    if gameState == "LOGIN" then
        -- Darken background for login
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("WHO ARE YOU?", 0, sh/2 - 60, sw, "center")
        -- Draw input box
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", sw/2 - 100, sh/2 - 20, 200, 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(ui.current_input .. (math.floor(love.timer.getTime()*2)%2 == 0 and "|" or ""), 0, sh/2 - 10, sw, "center")
        love.graphics.printf("Press ENTER to Join", 0, sh/2 + 40, sw, "center")
        
    else
        -- Draw Chat (Bottom Left)
        love.graphics.setFont(font)
        for i, msg in ipairs(ui.chat_history) do
            -- Shadow for readability
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print(msg, 16, sh - 151 + (i * 20))
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(msg, 15, sh - 150 + (i * 20))
        end

        if ui.is_chatting then
            love.graphics.setColor(0, 0, 0, 0.6)
            love.graphics.rectangle("fill", 10, sh - 40, 500, 30)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Say: " .. ui.current_input .. "|", 20, sh - 35)
        end
    end
end

function UI.add_message(ui, msg)
    table.insert(ui.chat_history, msg)
    if #ui.chat_history > 6 then table.remove(ui.chat_history, 1) end
end

return UI