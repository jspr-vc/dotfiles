local env = require("env")

-- `DOTFILES_SMOKE_TEST=1 Hyprland -c ...` runs nested inside a live session
-- to check the config loads; spawning a second shell and daemons there would
-- fight the real ones.
if os.getenv("DOTFILES_SMOKE_TEST") then
    return
end

hl.on("hyprland.start", function()
    -- Session plumbing
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd "
            .. "WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP QT_QPA_PLATFORMTHEME"
    )
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Cursor for apps that do not read the env
    hl.exec_cmd("hyprctl setcursor " .. env.cursor_theme .. " " .. env.cursor_size)

    -- Clipboard history and persistence
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    -- Daemons
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("udiskie --no-automount --smart-tray")
    hl.exec_cmd("xsettingsd")
    hl.exec_cmd("hyprpm reload -n")

    -- Shell
    hl.exec_cmd("caelestia shell -d")
end)
