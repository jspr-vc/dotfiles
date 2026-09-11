local util = require("lib.util")

local cursor_theme = "Bibata-Modern-Ice"
local cursor_size = 24

hl.env("XCURSOR_THEME", cursor_theme)
hl.env("XCURSOR_SIZE", tostring(cursor_size))
hl.env("HYPRCURSOR_THEME", cursor_theme)
hl.env("HYPRCURSOR_SIZE", tostring(cursor_size))

-- Toolkits
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qtengine")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- Session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("SSH_AUTH_SOCK", util.home .. "/.1password/agent.sock")

-- NVIDIA, only when the driver is actually live. Reading procfs is cheap;
-- probing the GPU with nvidia-smi is not and can blow the config load budget
-- on a hybrid laptop with the dGPU asleep.
local function nvidia_live()
    if not util.file_exists("/proc/driver/nvidia/version") then
        return false
    end
    local state = util.read_file("/sys/module/nvidia/initstate")
    return state == nil or state:match("^live")
end

if nvidia_live() then
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("GBM_BACKEND", "nvidia-drm")
end

return { cursor_theme = cursor_theme, cursor_size = cursor_size }
