local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "biome-check" },
    typescript = { "biome-check" },
    javascriptreact = { "biome-check" },
    typescriptreact = { "biome-check" },
    svelte = { "biome-check" },
    css = { "biome-check" },
    html = { "biome-check" },
    json = { "biome" },
    yaml = { "biome-check" },
    markdown = { "biome" },
    grapql = { "biome-check" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
