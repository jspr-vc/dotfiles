-- ASUS ROG Flow X13: AMD iGPU + NVIDIA dGPU, 2560x1600 165Hz touch panel.
local panel = "desc:Thermotrex Corporation TL134ADXP01-0"

-- By description: the connector name is not stable, it has been both eDP-1
-- and eDP-2.
hl.monitor({ output = panel, mode = "2560x1600@165", position = "0x0", scale = 1, transform = 0, vrr = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60", position = "0x-1080", scale = 1, transform = 0 })

local external = "HDMI-A-2"

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = panel, default = i == 1 })
end
-- Bound to the external screen; Hyprland moves them there when it connects
-- and back to the panel when it goes. The handler covers the case where the
-- rule is not re-evaluated on hotplug.
for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = external, default = i == 6 })
end

hl.on("monitor.added", function(m)
    if m and m.name == external then
        for i = 6, 10 do
            hl.dispatch(hl.dsp.workspace.move({ workspace = i, monitor = external }))
        end
    end
end)

hl.config({
    input = {
        kb_options = "ctrl:nocaps",
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("iio-hyprland")
end)
