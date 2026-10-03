local env = require("env")
local util = require("lib.util")

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

    -- Cursor for apps that do not read the env
    hl.exec_cmd("hyprctl setcursor " .. env.cursor_theme .. " " .. env.cursor_size)

    -- Clipboard history and persistence
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")

    -- Daemons
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("udiskie --no-automount --smart-tray")
    hl.exec_cmd("xsettingsd")
    hl.exec_cmd("status-tray")
    hl.exec_cmd("localsend --hidden")
    hl.exec_cmd("hyprpm reload -n")

    -- Shell. A fresh compositor starts outside game mode, so undo any frame
    -- game-mode left stripped when the last session ended.
    hl.exec_cmd("game-mode restore; caelestia shell -d")

    -- The shell's polkit agent is one of our patches. When an upgrade leaves
    -- the patch unapplied, auth prompts would have no agent at all.
    if not util.file_exists("/etc/xdg/quickshell/caelestia/modules/polkit/Polkit.qml") then
        hl.exec_cmd("systemctl --user start hyprpolkitagent")
    end

    hl.exec_cmd("dotfiles-check")
end)
