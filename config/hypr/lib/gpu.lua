-- Which GPU should own the session. Aquamarine takes the kernel's boot_vga
-- card as primary, and on a cold boot with no UEFI framebuffer that flag can
-- land on a GPU with nothing plugged in. See docs/adr/0003.
local M = {}

--- DRM card nodes ordered by how many monitors are attached, most first.
--- Ties go to the kernel's boot_vga card, then the lower card number. One
--- `ls` spawn for the listing; everything else is a sysfs read.
---@return string[] paths under /dev/dri, primary first
function M.cards_by_connected_outputs()
    local ok, pipe = pcall(io.popen, "ls -1 /sys/class/drm 2>/dev/null")
    if not ok or not pipe then
        return {}
    end
    local listing = pipe:read("*a") or ""
    pipe:close()

    local cards = {}
    local function card(name)
        if not cards[name] then
            cards[name] = { name = name, connected = 0, boot_vga = 0 }
        end
        return cards[name]
    end
    local function read(path)
        local f = io.open(path, "r")
        if not f then
            return nil
        end
        local v = f:read("*l")
        f:close()
        return v
    end

    for entry in listing:gmatch("[^\n]+") do
        local owner = entry:match("^(card%d+)%-")
        if owner then
            if read("/sys/class/drm/" .. entry .. "/status") == "connected" then
                local c = card(owner)
                c.connected = c.connected + 1
            end
        elseif entry:match("^card%d+$") then
            local c = card(entry)
            c.boot_vga = tonumber(read("/sys/class/drm/" .. entry .. "/device/boot_vga")) or 0
        end
    end

    local ordered = {}
    for _, c in pairs(cards) do
        ordered[#ordered + 1] = c
    end
    table.sort(ordered, function(a, b)
        if a.connected ~= b.connected then
            return a.connected > b.connected
        end
        if a.boot_vga ~= b.boot_vga then
            return a.boot_vga > b.boot_vga
        end
        return a.name < b.name
    end)

    local paths = {}
    for i, c in ipairs(ordered) do
        paths[i] = "/dev/dri/" .. c.name
    end
    return paths
end

return M
