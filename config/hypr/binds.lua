local binds = require("lib.binds")
local rules = require("rules")

local bind = binds.bind
local MOD = "SUPER"

local terminal = "ghostty"
local browser = "zen-browser"
local explorer = "dolphin"

local locked = { locked = true }
local repeating = { repeating = true }
local locked_repeating = { locked = true, repeating = true }
local mouse = { mouse = true }

--------------------------------------------------------------------------
-- Shell (Caelestia)
--------------------------------------------------------------------------

bind(MOD .. " + A", hl.dsp.global("caelestia:launcher"), "[Launcher|Apps] app launcher")
bind(MOD .. " + N", hl.dsp.exec_cmd("caelestia shell drawers toggle sidebar"), "[Launcher|Apps] notifications sidebar")
bind(MOD .. " + Backspace", hl.dsp.global("caelestia:session"), "[Window Management] session menu")
bind(MOD .. " + Delete", hl.dsp.global("caelestia:session"), "[Window Management] session menu")
bind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"), "[Window Management] session menu")
bind(MOD .. " + CTRL + Escape", hl.dsp.global("caelestia:lock"), "[Window Management] lock screen")
bind(
    MOD .. " + CTRL + R",
    hl.dsp.exec_cmd("caelestia shell -k; sleep 0.5; caelestia shell -d"),
    "[Window Management] restart caelestia shell"
)
bind("CTRL + SHIFT + space", hl.dsp.exec_cmd("1password --quick-access"), "[Launcher|Apps] 1password quick access")
bind(MOD .. " + slash", hl.dsp.exec_cmd("keys-hint"), "[Launcher|Apps] keybind cheat sheet")
bind(MOD .. " + comma", hl.dsp.exec_cmd("caelestia emoji -p"), "[Launcher|Apps] emoji and glyph picker")
bind(MOD .. " + SHIFT + V", hl.dsp.exec_cmd("caelestia clipboard"), "[Launcher|Apps] clipboard history")
bind(
    MOD .. " + SHIFT + CTRL + V",
    hl.dsp.exec_cmd("caelestia clipboard -d"),
    "[Launcher|Apps] delete from clipboard history"
)
bind(MOD .. " + Tab", hl.dsp.exec_cmd("win-pick"), "[Launcher|Apps] window switcher")

--------------------------------------------------------------------------
-- Apps
--------------------------------------------------------------------------

bind(MOD .. " + Q", hl.dsp.exec_cmd(terminal), "[Launcher|Apps] terminal")
bind(MOD .. " + T", hl.dsp.exec_cmd(terminal), "[Launcher|Apps] terminal")
bind(MOD .. " + ALT + T", hl.dsp.workspace.toggle_special("terminal"), "[Launcher|Apps] dropdown terminal")
bind(MOD .. " + D", hl.dsp.workspace.toggle_special("ai"), "[Launcher|Apps] AI scratchpad")
bind(MOD .. " + E", hl.dsp.exec_cmd(explorer), "[Launcher|Apps] file explorer")
bind(MOD .. " + B", hl.dsp.exec_cmd(browser), "[Launcher|Apps] web browser")
bind(
    "CTRL + SHIFT + Escape",
    hl.dsp.exec_cmd(
        terminal .. " -e btop",
        { float = true, size = { "monitor_w*0.7", "monitor_h*0.8" }, center = true }
    ),
    "[Launcher|Apps] system monitor"
)

hl.workspace_rule({
    workspace = "special:terminal",
    on_created_empty = "[float; center; size 70% 60%; animation slide top] " .. terminal,
})

--------------------------------------------------------------------------
-- Window management
--------------------------------------------------------------------------

-- Steam minimises to tray on close, killing it takes the tray with it.
local function close_or_hide()
    local win = hl.get_active_window()
    if win and win.class:lower() == "steam" then
        hl.dispatch(hl.dsp.window.move({ workspace = "special:hidden", follow = false }))
    else
        hl.dispatch(hl.dsp.window.close())
    end
end

-- A lone window that gets floated would otherwise keep its full tiled size,
-- so shrink it to half the monitor first.
local function float_centered()
    local ws = hl.get_active_workspace()
    local alone = ws ~= nil and ws.windows == 1
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local win = hl.get_active_window()
    if not (win and win.floating) then
        return
    end
    local mon = win.monitor
    if alone and mon and type(mon.size) == "table" then
        hl.dispatch(hl.dsp.window.resize({
            x = math.floor(mon.size.width / 2),
            y = math.floor(mon.size.height / 2),
        }))
    end
    hl.dispatch(hl.dsp.window.center())
end

local function cycle_to_top()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end

bind(MOD .. " + W", close_or_hide, "[Window Management] close focused window")
bind(
    MOD .. " + SHIFT + W",
    hl.dsp.workspace.toggle_special("hidden"),
    "[Window Management] show hidden windows (Steam)"
)
bind("ALT + F4", close_or_hide, "[Window Management] close focused window")
bind(MOD .. " + V", float_centered, "[Window Management] toggle float")
bind(MOD .. " + SHIFT + F", hl.dsp.window.pin(), "[Window Management] toggle pin")
bind(MOD .. " + G", hl.dsp.group.toggle(), "[Window Management] toggle group")
bind(MOD .. " + CTRL + H", hl.dsp.group.prev(), "[Window Management] previous window in group")
bind(MOD .. " + CTRL + L", hl.dsp.group.next(), "[Window Management] next window in group")
bind(
    "SHIFT + F11",
    hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
    "[Window Management] toggle fullscreen"
)
bind(
    "ALT + Return",
    hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }),
    "[Window Management] fullscreen without telling the app"
)
bind(
    "SHIFT + ALT + Return",
    hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
    "[Window Management] maximize"
)
bind(MOD .. " + ALT + J", hl.dsp.layout("togglesplit"), "[Window Management] toggle split")
bind("ALT + Tab", cycle_to_top, "[Window Management] cycle focus")

-- Focus
local directions =
    { H = "left", J = "down", K = "up", L = "right", Left = "left", Down = "down", Up = "up", Right = "right" }
for key, dir in pairs(directions) do
    bind(MOD .. " + " .. key, hl.dsp.focus({ direction = dir }), "[Window Management|Change focus] focus " .. dir)
end

-- Resize
local resize_delta = { left = { -30, 0 }, right = { 30, 0 }, up = { 0, -30 }, down = { 0, 30 } }
for key, dir in pairs(directions) do
    local d = resize_delta[dir]
    bind(
        MOD .. " + SHIFT + " .. key,
        hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }),
        "[Window Management|Resize Active Window] resize " .. dir,
        repeating
    )
end

-- Move: floating windows nudge by pixels, tiled windows swap in a direction
local function move_window(dir)
    return function()
        local win = hl.get_active_window()
        if win and win.floating then
            local d = resize_delta[dir]
            hl.dispatch(hl.dsp.window.move({ x = d[1], y = d[2], relative = true }))
        else
            hl.dispatch(hl.dsp.window.move({ direction = dir }))
        end
    end
end
for key, dir in pairs(directions) do
    bind(
        MOD .. " + SHIFT + CTRL + " .. key,
        move_window(dir),
        "[Window Management|Move active window] move " .. dir,
        repeating
    )
end

-- Mouse
bind(MOD .. " + mouse:272", hl.dsp.window.drag(), "[Window Management|Mouse] hold to move window", mouse)
bind(MOD .. " + mouse:273", hl.dsp.window.resize(), "[Window Management|Mouse] hold to resize window", mouse)
bind(MOD .. " + Z", hl.dsp.window.drag(), "[Window Management|Mouse] hold to move window", mouse)
bind(MOD .. " + X", hl.dsp.window.resize(), "[Window Management|Mouse] hold to resize window", mouse)

--------------------------------------------------------------------------
-- Workspaces
--------------------------------------------------------------------------

for i = 1, 10 do
    local key = tostring(i % 10)
    bind(MOD .. " + " .. key, hl.dsp.focus({ workspace = i }), "[Workspaces] go to workspace " .. i)
    bind(
        MOD .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i }),
        "[Workspaces] move window to workspace " .. i
    )
    bind(
        MOD .. " + ALT + " .. key,
        hl.dsp.window.move({ workspace = i, follow = false }),
        "[Workspaces] move window to workspace " .. i .. " silently"
    )
end

bind(MOD .. " + CTRL + J", hl.dsp.focus({ workspace = "r+1" }), "[Workspaces] next workspace")
bind(MOD .. " + CTRL + K", hl.dsp.focus({ workspace = "r-1" }), "[Workspaces] previous workspace")
bind(MOD .. " + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }), "[Workspaces] next workspace")
bind(MOD .. " + CTRL + Left", hl.dsp.focus({ workspace = "r-1" }), "[Workspaces] previous workspace")
bind(MOD .. " + CTRL + Down", hl.dsp.focus({ workspace = "empty" }), "[Workspaces] nearest empty workspace")
bind(
    MOD .. " + CTRL + ALT + Right",
    hl.dsp.window.move({ workspace = "r+1" }),
    "[Workspaces] move window to next workspace"
)
bind(
    MOD .. " + CTRL + ALT + Left",
    hl.dsp.window.move({ workspace = "r-1" }),
    "[Workspaces] move window to previous workspace"
)
bind(MOD .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "[Workspaces] next workspace")
bind(MOD .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), "[Workspaces] previous workspace")

bind(MOD .. " + S", hl.dsp.workspace.toggle_special("special"), "[Workspaces] toggle scratchpad")
bind(
    MOD .. " + SHIFT + S",
    hl.dsp.window.move({ workspace = "special:special" }),
    "[Workspaces] move window to scratchpad"
)
bind(
    MOD .. " + ALT + S",
    hl.dsp.window.move({ workspace = "special:special", follow = false }),
    "[Workspaces] move window to scratchpad silently"
)

--------------------------------------------------------------------------
-- Hardware
--------------------------------------------------------------------------

local sink = "@DEFAULT_AUDIO_SINK@"
local source = "@DEFAULT_AUDIO_SOURCE@"
local volume_up = "wpctl set-mute " .. sink .. " 0; wpctl set-volume -l 1 " .. sink .. " 5%+"
local volume_down = "wpctl set-mute " .. sink .. " 0; wpctl set-volume " .. sink .. " 5%-"
local volume_mute = "wpctl set-mute " .. sink .. " toggle"

bind("F10", hl.dsp.exec_cmd(volume_mute), "[Hardware Controls|Audio] toggle mute output", locked)
bind("F11", hl.dsp.exec_cmd(volume_down), "[Hardware Controls|Audio] decrease volume", locked_repeating)
bind("F12", hl.dsp.exec_cmd(volume_up), "[Hardware Controls|Audio] increase volume", locked_repeating)
bind("XF86AudioMute", hl.dsp.exec_cmd(volume_mute), "[Hardware Controls|Audio] toggle mute output", locked)
bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(volume_down),
    "[Hardware Controls|Audio] decrease volume",
    locked_repeating
)
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(volume_up), "[Hardware Controls|Audio] increase volume", locked_repeating)
bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute " .. source .. " toggle"),
    "[Hardware Controls|Audio] toggle mute microphone",
    locked
)

bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), "[Hardware Controls|Media] play or pause", locked)
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), "[Hardware Controls|Media] play or pause", locked)
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), "[Hardware Controls|Media] next track", locked)
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), "[Hardware Controls|Media] previous track", locked)

bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
    "[Hardware Controls|Brightness] increase brightness",
    locked_repeating
)
bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
    "[Hardware Controls|Brightness] decrease brightness",
    locked_repeating
)

bind(MOD .. " + O", hl.dsp.exec_cmd("audio-pick output"), "[Hardware Controls|Audio] select audio output")
bind(MOD .. " + I", hl.dsp.exec_cmd("audio-pick input"), "[Hardware Controls|Audio] select audio input")
bind(
    MOD .. " + SHIFT + O",
    hl.dsp.exec_cmd("caelestia shell audio cycleOutput"),
    "[Hardware Controls|Audio] cycle audio output"
)
bind(MOD .. " + U", hl.dsp.exec_cmd("bt-pick"), "[Hardware Controls|Bluetooth] connect or disconnect a device")

--------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------

bind(MOD .. " + ALT + Return", hl.dsp.exec_cmd("game-mode"), "[Utilities] toggle game mode")
bind(MOD .. " + ALT + G", hl.dsp.exec_cmd("game-mode"), "[Utilities] toggle game mode")

-- Caelestia's picker and notification hand off to `swappy`, which bin/swappy
-- redirects to satty.
bind(MOD .. " + P", hl.dsp.exec_cmd("caelestia screenshot -r"), "[Utilities|Screenshot] snip region")
bind(
    MOD .. " + CTRL + P",
    hl.dsp.exec_cmd("caelestia screenshot -r -f"),
    "[Utilities|Screenshot] freeze and snip region"
)
bind(
    MOD .. " + ALT + P",
    hl.dsp.exec_cmd("caelestia screenshot"),
    "[Utilities|Screenshot] print focused monitor",
    locked
)
bind("Print", hl.dsp.exec_cmd("screenshot all"), "[Utilities|Screenshot] print all monitors", locked)
bind(
    MOD .. " + SHIFT + ALT + P",
    hl.dsp.exec_cmd("screenshot-unblocked s"),
    "[Utilities|Screenshot] snip ignoring screen-share protection"
)
bind(
    MOD .. " + SHIFT + ALT + M",
    hl.dsp.exec_cmd("screenshot-unblocked m"),
    "[Utilities|Screenshot] print monitor ignoring screen-share protection",
    locked
)
bind(MOD .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -an"), "[Utilities] colour picker to clipboard")

bind(
    MOD .. " + SHIFT + ALT + S",
    rules.toggle_screenshare_protection,
    "[Utilities|Privacy] toggle screen-share protection"
)

bind(MOD .. " + ALT + Right", hl.dsp.exec_cmd("caelestia wallpaper -r"), "[Utilities] random wallpaper")
