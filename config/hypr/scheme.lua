-- Colours come from Caelestia. Its CLI rewrites scheme/current.lua on every
-- scheme change; default.lua only covers the first boot before that happens.
local util = require("lib.util")

local colours = util.try_require("scheme.current") or require("scheme.default")

local function c(name, alpha)
    return util.rgba(colours[name], alpha)
end

local active_border = { colors = { c("primary"), c("tertiary") }, angle = 45 }
local inactive_border = { colors = { c("outlineVariant", "cc"), c("outline", "cc") }, angle = 45 }

hl.config({
    general = {
        col = {
            active_border = active_border,
            inactive_border = inactive_border,
        },
    },

    group = {
        col = {
            border_active = active_border,
            border_inactive = inactive_border,
            border_locked_active = active_border,
            border_locked_inactive = inactive_border,
        },
        groupbar = {
            enabled = true,
            font_family = "JetBrainsMono Nerd Font",
            font_size = 12,
            gradients = true,
            gradient_rounding = 5,
            height = 24,
            indicator_height = 0,
            gaps_in = 3,
            gaps_out = 3,
            text_color = c("onPrimary"),
            col = {
                active = c("primary", "d4"),
                inactive = c("outline", "d4"),
                locked_active = c("primary", "d4"),
                locked_inactive = c("secondary", "d4"),
            },
        },
    },

    decoration = {
        shadow = {
            color = c("shadow", "66"),
        },
    },

    misc = {
        background_color = "rgb(" .. colours.surfaceContainer .. ")",
        font_family = "JetBrainsMono Nerd Font",
    },
})

return colours
