-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "ayu_dark",
  transparency = false,
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

-- M.nvdash = {
--   load_on_startup = true,
-- }

M.ui = {
  statusline = {
    theme = "default",
    -- separator_style = "round",
  },
  cmp = {
    lspkind_text = true,
    style = "flat_dark", -- default/flat_light/flat_dark/atom/atom_colored
    format_colors = {
      tailwind = true,
    },
    icons_left = true,
  },

  tabufline = {
    enabled = true,
  },
  -- telescope = { style = "borderless" }, -- borderless / bordered
}

M.lsp = { signature = true }

-- M.mason = {
--   pkgs = {
--     "biome",
--     "lua-language-server",
--     "ruff",
--     "css-lsp",
--     "pyright",
--     "stylua",
--     "typescript-language-server",
--     "tailwindcss-language-server",
--     "html-lsp",
--   },
-- }

M.colorify = {
  enabled = true,
  mode = "virtual", -- fg, bg, virtual
  virt_text = "󱓻 ",
  highlight = { hex = true, lspvars = true },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
