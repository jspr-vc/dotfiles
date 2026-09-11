local util = require("lib.util")

local M = {}

M.cheat_sheet_path = util.state_dir .. "/keybinds.txt"

---@type { keys: string, description: string }[]
local registry = {}

--- hl.bind with a mandatory description, recorded for the cheat sheet.
--- Descriptions follow the `[Group|Subgroup] what it does` convention.
---@param keys string
---@param action HL.Dispatcher|function
---@param description string
---@param opts? HL.BindOptions
---@return HL.Keybind
function M.bind(keys, action, description, opts)
    opts = opts or {}
    opts.description = description
    registry[#registry + 1] = { keys = keys, description = description }
    return hl.bind(keys, action, opts)
end

--- Rebinds a key that a module further up already bound. Removing the old
--- one first keeps the cheat sheet honest and stops both binds firing.
---@param keys string
---@param action HL.Dispatcher|function
---@param description string
---@param opts? HL.BindOptions
function M.rebind(keys, action, description, opts)
    hl.unbind(keys)
    for i = #registry, 1, -1 do
        if registry[i].keys == keys then
            table.remove(registry, i)
        end
    end
    return M.bind(keys, action, description, opts)
end

---@param keys string
function M.unbind(keys)
    hl.unbind(keys)
    for i = #registry, 1, -1 do
        if registry[i].keys == keys then
            table.remove(registry, i)
        end
    end
end

--- One line per bind, tab separated, for `keys-hint` to pipe into fuzzel.
function M.write_cheat_sheet()
    util.mkdir_p(util.state_dir)
    local lines = {}
    for _, entry in ipairs(registry) do
        lines[#lines + 1] = entry.keys .. "\t" .. entry.description
    end
    table.sort(lines)
    util.write_file(M.cheat_sheet_path, table.concat(lines, "\n") .. "\n")
end

return M
