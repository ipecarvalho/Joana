local PlayerLogic  = require "src.player"
local NetworkLogic = require "src.network"
local ShaderLogic  = require "src.shader"
local CameraLogic  = require "src.camera"
local Renderer     = require "src.renderer"
local UILogic      = require "src.ui"

-- CONFIG
local PUBLIC_ADDR = "civil-box.gl.at.ply.gg:42227"

-- Variables
local host, server, color_shader, player_img, font, cam
local world = {}
local my_id = nil
local status = "Connecting..."
local gameState = "LOGIN" -- Start at login

-- Initialize player and UI
local local_p = PlayerLogic.create("Pending...")
local ui_state = UILogic.new()

local send_timer, SEND_RATE = 0, 1/60 
local id_request_timer = 0

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setFullscreen(true, "desktop")
    
    font = love.graphics.newFont(14)
    player_img = love.graphics.newImage("Joana.png")
    color_shader = ShaderLogic.load()
    
    host, server = NetworkLogic.connect(PUBLIC_ADDR)
    cam = CameraLogic.new()
end

-- --- INPUT HANDLING ---
function love.textinput(t)
    -- Only add text if the chat/login was already active 
    -- and the key pressed wasn't the "T" used to open it.
    if gameState == "LOGIN" then
        ui_state.current_input = ui_state.current_input .. t
    elseif gameState == "PLAYING" and ui_state.is_chatting then
        -- This prevents the 't' from leaking in
        if t ~= "t" and t ~= "T" or #ui_state.current_input > 0 then
            ui_state.current_input = ui_state.current_input .. t
        end
    end
end

function love.keypressed(key)
    if gameState == "LOGIN" then
        if key == "return" and #ui_state.current_input > 0 then
            local_p.name = ui_state.current_input
            ui_state.current_input = ""
            gameState = "PLAYING"
        elseif key == "backspace" then
            ui_state.current_input = ui_state.current_input:sub(1, -2)
        end
    
    elseif gameState == "PLAYING" then
        -- Open chat
        if key == "t" and not ui_state.is_chatting then
            ui_state.is_chatting = true
            ui_state.current_input = ""
            -- We return here so the 't' doesn't get processed further in this frame
            return 
        end

        -- Handle active chat
        if ui_state.is_chatting then
            if key == "return" then
                if #ui_state.current_input > 0 then
                    server:send("CHAT:" .. ui_state.current_input)
                    UILogic.add_message(ui_state, local_p.name .. ": " .. ui_state.current_input)
                end
                ui_state.is_chatting = false
                ui_state.current_input = ""
            elseif key == "backspace" then
                ui_state.current_input = ui_state.current_input:sub(1, -2)
            elseif key == "escape" then
                ui_state.is_chatting = false
                ui_state.current_input = ""
            end
        end
    end
end

function love.update(dt)
    if not host then return end

    -- --- 1. LOCAL PLAYER & CAMERA ---
    local moving = false
    if gameState == "PLAYING" and not ui_state.is_chatting then
        local dx, dy = 0, 0
        if love.keyboard.isDown("w") then dy = dy - 1 end
        if love.keyboard.isDown("s") then dy = dy + 1 end
        if love.keyboard.isDown("a") then dx = dx - 1 end
        if love.keyboard.isDown("d") then dx = dx + 1 end
        
        moving = (dx ~= 0 or dy ~= 0)
        if moving then
            local mag = math.sqrt(dx*dx + dy*dy)
            local_p.x = local_p.x + (dx/mag) * local_p.speed * dt
            local_p.y = local_p.y + (dy/mag) * local_p.speed * dt
        end
        
        local mx, my = love.mouse.getPosition()
        local world_mx, world_my = mx + cam.x, my + cam.y
        local_p.angle = math.atan2(world_my - local_p.y, world_mx - local_p.x)
    end
    
    PlayerLogic.update_animation(local_p, dt, moving)
    CameraLogic.update(cam, dt, local_p.x, local_p.y)

    -- --- 2. NETWORK ---
    if status == "Online" and server then
        -- Send movement only after logging in
        if gameState == "PLAYING" then
            send_timer = send_timer + dt
            if send_timer >= SEND_RATE then
                send_timer = 0
                server:send(NetworkLogic.format_packet(local_p))
            end
        end
        
        if not my_id then
            id_request_timer = id_request_timer + dt
            if id_request_timer >= 0.5 then
                id_request_timer = 0
                server:send("REQUEST_ID")
            end
        end
    end
    
    -- Process Incoming
    local event = host:service()
    while event do
        if event.type == "connect" then status = "Online"
        elseif event.type == "receive" then
            -- Handle Chat
            local chat_msg = event.data:match("^CHAT:(.+)$")
            if chat_msg then
                UILogic.add_message(ui_state, chat_msg)
            
            -- Handle ID
            elseif event.data:match("^ID:%d+$") then
                my_id = tonumber(event.data:match("ID:(%d+)"))
            
            -- Handle World Update
            elseif my_id then
                local seen_ids = {}
                for id_s, x, y, ang, nm, r, g, b, f in event.data:gmatch("(%d+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),(%d)|") do
                    local id = tonumber(id_s)
                    if id ~= my_id then
                        seen_ids[id] = true
                        if not world[id] then world[id] = { color = {tonumber(r), tonumber(g), tonumber(b)} } end
                        world[id].x, world[id].y = tonumber(x), tonumber(y)
                        world[id].angle, world[id].name = tonumber(ang), nm
                        world[id].flipped = (f == "1")
                    end
                end
                for id, _ in pairs(world) do if not seen_ids[id] then world[id] = nil end end
            end
        elseif event.type == "disconnect" then
            status = "Disconnected"; world = {}; my_id = nil
        end
        event = host:service()
    end 
end 

function love.draw()
    CameraLogic.apply(cam)
        Renderer.draw_grid(2000)
        for id, p in pairs(world) do
            Renderer.draw_player(p, player_img, color_shader, font, false)
        end
        if gameState == "PLAYING" then
            Renderer.draw_player(local_p, player_img, color_shader, font, true)
        end
    CameraLogic.detach()

    -- UI (Login or Chat)
    UILogic.draw(ui_state, gameState, font)
    
    -- Mini Status Info
    love.graphics.setColor(1,1,1,0.5)
    love.graphics.print(status .. (my_id and " | ID: "..my_id or ""), 10, 10)
    love.graphics.setColor(1,1,1,1)
end