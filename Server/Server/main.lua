-- Fix for chat broadcasting
-- Store connected peers in a table and iterate through them instead of using host:peers()

local connected_peers = {}  -- Initialize the table to store connected peers

function onPeerConnect(peer)  
    connected_peers[#connected_peers + 1] = peer  -- Add new peer to the table
end

function onPeerDisconnect(peer)
    for i, p in ipairs(connected_peers) do
        if p == peer then
            table.remove(connected_peers, i) -- Remove the disconnected peer from the table
            break
        end
    end
end

function broadcastChat(message)
    for _, peer in ipairs(connected_peers) do
        peer:send(message)  -- Iterate through connected peers and send the message
    end
end

-- Ensure to call onPeerConnect and onPeerDisconnect accordingly  
