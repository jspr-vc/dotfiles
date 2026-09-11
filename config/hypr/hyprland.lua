-- Entry point. Hyprland resolves require() against this file's directory, so
-- every module below is a path relative to ~/.config/hypr.
local root = debug.getinfo(1, "S").source:match("^@(.*)/") or (os.getenv("HOME") .. "/.config/hypr")
package.path = root .. "/?.lua;" .. root .. "/?/init.lua;" .. package.path

-- A reload re-runs this file, but package.loaded survives it. Every module of
-- ours has to re-evaluate: the scheme colours Caelestia rewrites underneath
-- us, the bind registry, the rule handles.
for _, name in ipairs({ "env", "options", "scheme", "rules", "binds", "autostart" }) do
    package.loaded[name] = nil
end
for name in pairs(package.loaded) do
    if name:match("^lib%.") or name:match("^scheme%.") or name:match("^devices%.") then
        package.loaded[name] = nil
    end
end

local util = require("lib.util")
local binds = require("lib.binds")

require("env")
require("options")
require("scheme")
require("rules")
require("binds")
require("autostart")

-- Per machine, keyed by hostname, loaded last so it can override anything.
local host = util.hostname()
if not util.try_require("devices." .. host) then
    require("devices.default")
end

binds.write_cheat_sheet()
