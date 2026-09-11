local M = {}

local home = os.getenv("HOME") or ""

M.home = home
M.config_dir = (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config"))
M.state_dir = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/hypr"
M.hypr_dir = M.config_dir .. "/hypr"

---@param path string
---@return string|nil
function M.read_file(path)
    local f = io.open(path, "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()
    return content
end

---@param path string
---@param content string
---@return boolean
function M.write_file(path, content)
    local f = io.open(path, "w")
    if not f then
        return false
    end
    f:write(content)
    f:close()
    return true
end

---@param path string
---@return boolean
function M.file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

---@param path string
function M.mkdir_p(path)
    os.execute(string.format("mkdir -p '%s'", path))
end

--- /etc/hostname is a plain read; spawning `hostname` would eat into the
--- config load budget.
---@return string
function M.hostname()
    local name = M.read_file("/etc/hostname")
    if not name then
        return "default"
    end
    return (name:gsub("%s+$", ""))
end

--- Like require, but returns nil instead of raising when the module is absent.
---@param name string
---@return any
function M.try_require(name)
    local ok, mod = pcall(require, name)
    if ok then
        return mod
    end
    if type(mod) == "string" and mod:find("module '" .. name .. "' not found", 1, true) then
        return nil
    end
    error(mod)
end

---@param name string
---@return boolean
function M.plugin_loaded(name)
    return hl.plugin ~= nil and hl.plugin[name] ~= nil
end

---@param hex string six hex digits, no hash
---@param alpha string two hex digits
---@return string
function M.rgba(hex, alpha)
    return "rgba(" .. hex .. (alpha or "ff") .. ")"
end

return M
