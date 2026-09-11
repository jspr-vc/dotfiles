-- Everything that is not a colour, a rule, a bind or a startup command.
-- Colours live in scheme.lua so they can follow Caelestia.

hl.config({
    general = {
        layout = "dwindle",
        gaps_in = 8,
        -- Matches Caelestia's screen frame: border rounding 25 minus this
        -- inset gives the 17px window rounding below, so the corners stay
        -- concentric.
        gaps_out = 16,
        border_size = 2,
        resize_on_border = false,
        allow_tearing = false,
        snap = {
            enabled = true,
            respect_gaps = true,
            border_overlap = true,
            window_gap = 1,
            monitor_gap = 1,
        },
    },

    decoration = {
        rounding = 17,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        dim_special = 0.3,
        blur = {
            enabled = true,
            xray = true,
            special = true,
            popups = true,
            ignore_opacity = true,
            new_optimizations = true,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        follow_mouse = 2,
        sensitivity = 0.3,
        force_no_accel = true,
        accel_profile = "flat",
        numlock_by_default = true,
        touchpad = {
            natural_scroll = false,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_resizing = true,
    },

    master = {
        new_status = "master",
    },

    cursor = {
        no_hardware_cursors = 0,
    },

    misc = {
        vrr = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        anr_missed_pings = 5,
        allow_session_lock_restore = true,
        session_lock_xray = true,
        focus_on_activate = true,
        middle_click_paste = false,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
    },

    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.15,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
    },

    debug = {
        error_position = 1,
    },
})

-- Animations, ported from the HyDE "theme" preset.
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.19, 1 }, { 0.22, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "easeOutExpo", style = "popin" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "easeOutExpo", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "easeOutExpo", style = "popin" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "layers", enabled = true, speed = 5, bezier = "easeOutExpo", style = "fade" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 5, bezier = "easeOutExpo" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 5, bezier = "easeOutExpo" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 5, bezier = "easeOutExpo" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 5, bezier = "easeOutExpo" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 5, bezier = "easeOutExpo" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 5, bezier = "easeOutExpo" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutExpo", style = "slidevert" })
hl.animation({ leaf = "border", enabled = false })
hl.animation({ leaf = "borderangle", enabled = false })
