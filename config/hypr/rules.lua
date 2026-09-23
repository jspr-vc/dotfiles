local util = require("lib.util")

local M = {}

--------------------------------------------------------------------------
-- Window rules
--------------------------------------------------------------------------

hl.window_rule({ name = "fullscreen-idle-inhibit", match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Floating windows open centred, except XWayland popups which position themselves.
hl.window_rule({ name = "center-floating", match = { float = true, xwayland = false }, center = true })

-- Modals
hl.window_rule({ name = "1password-float", match = { class = "^(1password)$" }, float = true })
hl.window_rule({
    name = "1password-quick-access",
    match = { title = "^(Quick Access — 1Password)$" },
    float = true,
    dim_around = true,
})
hl.window_rule({ name = "dolphin-float", match = { class = "^(org.kde.dolphin)$" }, float = true })
hl.window_rule({
    name = "pavucontrol-size",
    match = { class = "^(org.pulseaudio.pavucontrol|pavucontrol)$" },
    float = true,
    size = { 800, 600 },
})
hl.window_rule({
    name = "dialogs-float",
    match = { class = "^(yad|zenity|wev|nwg-look|hyprland-share-picker)$" },
    float = true,
})
hl.window_rule({
    name = "file-dialogs",
    match = { title = "^((Select|Open)( a)? (File|Folder)(s)?|Save As)$" },
    float = true,
    size = { "monitor_w*0.6", "monitor_h*0.7" },
    center = true,
})
hl.window_rule({
    name = "portal-dialogs",
    match = { class = "^(xdg-desktop-portal-(gtk|hyprland|kde))$" },
    float = true,
})

-- Picture in picture
hl.window_rule({
    name = "pip",
    match = { title = "^(Picture(-| )in(-| )[Pp]icture)$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    move = { "monitor_w*0.98-window_w", "monitor_h*0.97-window_h" },
})

-- XWayland popups: no decorations, they are menus and tooltips
hl.window_rule({
    name = "xwayland-popups",
    match = { xwayland = true, title = "^(win[0-9]+)$" },
    no_dim = true,
    no_shadow = true,
    no_blur = true,
    opaque = true,
    rounding = 10,
})
hl.window_rule({
    name = "xwayland-empty-popups",
    match = { xwayland = true, float = true, title = "^$", class = "^$" },
    no_focus = true,
    no_blur = true,
    no_shadow = true,
})

-- Games
hl.window_rule({
    name = "games",
    match = { class = "^(steam_app_[0-9]+|steam_app_default|gamescope)$" },
    opaque = true,
    immediate = true,
    idle_inhibit = "always",
})
hl.window_rule({ name = "steam-friends", match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })

-- Apps pinned to workspaces
hl.window_rule({ name = "spotify-ws", match = { class = "^(.*[Ss]potify.*)$" }, workspace = "10" })

-- HyprXEdge on the Xeneon Edge touchscreen
hl.window_rule({ name = "xeneon-edge", match = { title = "^(xeneon-edge)$" }, monitor = "HDMI-A-1", no_blur = true })

--------------------------------------------------------------------------
-- Screen-share protection: a group of windows hidden from capture.
-- The group toggles together; off state survives `hyprctl reload` through
-- the state file but never a compositor restart, so forgetting it is off
-- fails safe.
--------------------------------------------------------------------------

local protected = {
    { name = "1password", match = { class = "^(1password)$" } },
    { name = "1password-quick-access", match = { title = "^(Quick Access — 1Password)$" } },
    { name = "polkit-agent", match = { class = "^(hyprpolkitagent)$" } },
    { name = "discord", match = { class = "^(discord)$" } },
    { name = "slack", match = { class = "^(Slack)$" } },
    { name = "viber", match = { class = "^(ViberPC|viber)$" } },
    { name = "thunderbird", match = { class = "^(thunderbird|org.mozilla.Thunderbird)$" } },
    { name = "obs", match = { class = "^(com.obsproject.Studio)$" } },
    -- Ghostty titles a terminal with the typed command line while it runs
    {
        name = "secret-files",
        match = {
            title = "^((sudo )?(n?vim?|nano|hx|cat|bat|less|head|tail) .*"
                .. "(\\.env|\\.pem|\\.key|id_(rsa|ecdsa|ed25519)|credentials|\\.npmrc|\\.netrc|\\.pgpass|\\.tfvars|secrets?\\.).*)$",
        },
    },
    { name = "zen-private", match = { title = "^(.*Zen Browser Private Browsing)$" } },
    { name = "firefox-private", match = { title = "^(.*Mozilla Firefox Private Browsing)$" } },
    { name = "zen-mail", match = { class = "^(zen)$", title = "^(.*\\b(Gmail|Mail)\\b.* — Zen Browser)$" } },
    { name = "steam", match = { class = "^(steam)$" } },
}

local state_file = util.state_dir .. "/screenshare-protection"

---@type HL.WindowRule[]
local protection_rules = {}
for _, spec in ipairs(protected) do
    protection_rules[#protection_rules + 1] = hl.window_rule({
        name = "noscreenshare-" .. spec.name,
        match = spec.match,
        no_screen_share = true,
        enabled = util.read_file(state_file) ~= "off",
    })
end

local function protection_enabled()
    return protection_rules[1] == nil or protection_rules[1]:is_enabled()
end

local function set_protection(on)
    for _, rule in ipairs(protection_rules) do
        rule:set_enabled(on)
    end
    util.mkdir_p(util.state_dir)
    util.write_file(state_file, on and "on" or "off")

    if on then
        hl.exec_cmd(
            "caelestia shell toaster success 'Screen-share protection on' "
                .. "'protected windows are hidden from capture' visibility_off"
        )
    else
        hl.exec_cmd(
            "caelestia shell toaster warn 'Screen-share protection off' 'every window is now capturable' visibility"
        )
    end
end

function M.toggle_screenshare_protection()
    set_protection(not protection_enabled())
end

-- A fresh compositor always starts protected. The state file only bridges
-- `hyprctl reload`, which re-runs this file mid-session.
hl.on("hyprland.start", function()
    if util.read_file(state_file) == "off" then
        for _, rule in ipairs(protection_rules) do
            rule:set_enabled(true)
        end
        os.remove(state_file)
    end
    os.remove(util.state_dir .. "/share-dnd")
end)

hl.on("screenshare.state", function(active)
    hl.exec_cmd("share-dnd " .. (active and "start" or "stop"))
end)

--------------------------------------------------------------------------
-- Workspace rules
--------------------------------------------------------------------------

hl.workspace_rule({
    workspace = "special:ai",
    on_created_empty = "[float; center; size monitor_w*0.5 monitor_h*0.8; "
        .. "no_blur; animation slide top; no_screen_share; opaque] "
        .. "ghostty -e opencode",
})
hl.workspace_rule({ workspace = "special:special", gaps_out = 100 })

--------------------------------------------------------------------------
-- Layer rules
--------------------------------------------------------------------------

hl.layer_rule({
    name = "caelestia-static",
    match = { namespace = "^(caelestia-(border-exclusion|area-picker))$" },
    no_anim = true,
})
hl.layer_rule({
    name = "caelestia-fade",
    match = { namespace = "^(caelestia-(drawers|background))$" },
    animation = "fade",
})
hl.layer_rule({ name = "launcher-blur", match = { namespace = "^(launcher)$" }, animation = "popin 80%", blur = true })
hl.layer_rule({
    name = "picker-fade",
    match = { namespace = "^(hyprpicker|selection|wayfreeze)$" },
    animation = "fade",
})

return M
