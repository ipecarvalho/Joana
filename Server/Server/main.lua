local enet = require "enet"

function love.load()
    -- Listen on all interfaces at port 12345
    -- If using Playit, ensure your tunnel points to 12345
    host = enet.host_create("0.0.0.0:12345")
    world = {} 
    
    print("SERVER STARTED - 60Hz Mode")
    
    broadcast_timer = 0
    BROADCAST_RATE = 1/60 -- Matches client for maximum smoothness
end

function love.update(dt)
    if not host then return end

    -- 1. Listen for data
    local event = host:service()
    while event do
        if event.type == "connect" then
            local id = event.peer:index()
            print("Player " .. id .. " connected.")
            -- Immediate ID assignment
            event.peer:send("ID:" .. id)
            
elseif event.type == "receive" then
            local id = event.peer:index()
            
            -- 1. Handle Chat
            local chat_content = event.data:match("^CHAT:(.+)$")
            if chat_content then
                local name = world[id] and world[id].nm or "Unknown"
                local chat_message = "CHAT:" .. name .. ": " .. chat_content
                -- Broadcast to all peers except the sender
                for _, peer in ipairs(host:peers()) do
                    if peer:index() ~= id then
                        peer:send(chat_message)
                    end
                end
                print("[CHAT] " .. name .. ": " .. chat_content)

            -- 2. Handle ID Request
            elseif event.data == "REQUEST_ID" then
                event.peer:send("ID:" .. id)

            -- 3. Handle Movement (The 8 variables)
            else
                local x, y, ang, nm, r, g, b, f = event.data:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
                if x and y and ang and nm and r then
                    world[id] = {
                        x = x, y = y, ang = ang, nm = nm, 
                        r = r, g = g, b = b, f = f, 
                        last_update = love.timer.getTime()
                    }
                end
            end
            
        elseif event.type == "disconnect" then
            local id = event.peer:index()
            world[id] = nil
            print("Player " .. id .. " left.")
        end
        event = host:service()
    end

    -- 2. BROADCAST to everyone
    broadcast_timer = broadcast_timer + dt
    if broadcast_timer >= BROADCAST_RATE then
        broadcast_timer = 0
        
        local packet = ""
        for id, p in pairs(world) do
            -- Building the string with 8 variables + ID
            packet = packet .. string.format("%d,%s,%s,%s,%s,%s,%s,%s,%s|", 
                id, p.x, p.y, p.ang, p.nm, p.r, p.g, p.b, p.f)
        end
        
        if packet ~= "" then
            host:broadcast(packet)
        end
    end
    
    -- 3. Cleanup stale players (5-second timeout)
    local current_time = love.timer.getTime()
    for id, p in pairs(world) do
        if current_time - (p.last_update or 0) > 5 then
            world[id] = nil
            print("Player " .. id .. " timed out.")
        end
    end
end

function love.draw()
    love.graphics.print("Server running at 60Hz", 10, 10)
    love.graphics.print("Active Joanas:", 10, 30)
    local y = 50
    for id, p in pairs(world) do
        love.graphics.print("ID " .. id .. ": " .. (p.nm or "unknown") .. " (Flip: ".. (p.f or "0") ..")", 20, y)
        y = y + 20
    end
end