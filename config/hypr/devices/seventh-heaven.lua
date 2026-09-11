-- Desktop: LG 4K main, Xeneon Edge touch strip, Samsung side monitor.
local util = require("lib.util")

local main = "desc:LG Electronics LG ULTRAGEAR+ 512NTKFF2261"
local edge = "desc:Cyrix Corporation XENEON EDGE 040625415656"
local side = "desc:Samsung Electric Company S24R35x H4TN901181"

-- 4K@144 leaves DP 1.4 bandwidth headroom and avoids DSC link-training
-- failures that caused intermittent black screens on cold boot. Try @165
-- again once cable, monitor and driver prove stable together.
hl.monitor({ output = main, mode = "3840x2160@144", position = "1920x0", scale = 1, transform = 0 })
hl.monitor({ output = edge, mode = "2560x720@60", position = "2560x2160", scale = 1 })
hl.monitor({ output = side, mode = "1920x1080@74.97", position = "0x360", scale = 1 })
-- Portable monitor, when attached:
-- hl.monitor({ output = "desc:BOE Display 0x00000001", mode = "2560x1440@144", position = "-1440x0", scale = 1, transform = 1 })

for i = 1, 5 do
    hl.workspace_rule({ workspace = tostring(i), monitor = main, default = i == 1 })
end
for i = 6, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = edge, default = i == 6 })
end

-- The Edge is a strip: no chrome on anything shown there.
hl.workspace_rule({ workspace = "m[HDMI-A-1]", gaps_in = 0, gaps_out = 0, no_rounding = true, border_size = 0 })

hl.config({
    cursor = {
        no_warps = false,
    },
    input = {
        touchdevice = {
            enabled = true,
            output = "HDMI-A-1",
        },
    },
    gestures = {
        workspace_swipe_create_new = true,
    },
})

hl.gesture({ fingers = 3, direction = "down", action = "workspace" })

-- hyprgrass touch gestures for the Edge. Configured only when the plugin is
-- actually loaded so a failed build does not take the session down.
if util.plugin_loaded("hyprgrass") then
    hl.config({
        plugin = {
            touch_gestures = {
                sensitivity = 4.0,
                workspace_swipe_fingers = 3,
                edge_margin = 10,
                emulate_touchpad_swipe = true,
            },
        },
    })
    -- hyprgrass-bind and hyprgrass-gesture keywords have no Lua form yet.
    -- Previous hyprlang config, for when they do:
    --   hyprgrass-bind = , edge:r:l, workspace, +1
    --   hyprgrass-bind = , edge:d:u, exec, firefox
    --   hyprgrass-gesture = edge, up, down, special
end
