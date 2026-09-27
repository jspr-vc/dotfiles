require("nvchad.configs.lspconfig").defaults()

-- "ts_ls"
local servers = {
  "html",
  "cssls",
  "biome",
  "tailwindcss", --[[ "pyright",  ]]
  "ruff",
  "basedpyright",
  "ts_ls",
  "mdx_analyzer",
  "terraform",
  "terraformls",
}
local nvlsp = require "nvchad.configs.lspconfig"

local on_attach = function(client, bufnr)
  if client.server_capabilities.inlayHintProvider then
    vim.keymap.set("n", "<leader>ti", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { silent = true, desc = "Toggle inlay hints" })
  end
  nvlsp.on_attach(client, bufnr)
end

vim.lsp.config("ts_ls", {
  on_attach = on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  settings = {
    javascript = {
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = false,
      },
    },
    implicitProjectConfiguration = {
      checkJs = true,
    },
    typescript = {
      inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = false,
      },
    },
  },
})

vim.lsp.enable(servers)

-- add a border to LSP hover documentation (K)
local orig_hover = vim.lsp.buf.hover
vim.lsp.buf.hover = function(opts)
  return orig_hover(vim.tbl_extend("force", { border = "single" }, opts or {}))
end

-- read :h vim.lsp.config for changing options of lsp servers
