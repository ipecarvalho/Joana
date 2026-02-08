local enet = require "enet"
local Network = {}

function Network.connect(addr)
    local host = enet.host_create()
    local server = host:connect(addr)
    return host, server
end

function Network.format_packet(p)
    local f_val = p.flipped and 1 or 0
    return string.format("%.1f,%.1f,%.2f,%s,%.2f,%.2f,%.2f,%d", 
        p.x, p.y, p.angle, p.name, p.r, p.g, p.b, f_val)
end

return Network