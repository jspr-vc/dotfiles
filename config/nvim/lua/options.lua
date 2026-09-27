require "nvchad.options"

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!
o.relativenumber = true
o.scrolloff = 10
vim.opt.inccommand = "split" -- Preview substitutions live, as you type!
o.colorcolumn = "80"
o.cursorline = true
o.wrap = true
o.linebreak = true -- wrap at word boundaries, not mid-word
o.breakindent = true
o.showbreak = "↪ "

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format { bufnr = args.buf }
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Make neovim background transparent
-- Requires terminal to have background-opacity set (e.g., Ghostty's `background-opacity`)
vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
  callback = function()
    local highlights = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "SignColumn",
      "EndOfBuffer",
      "NvimTreeNormal",
      "NvimTreeNormalNC",
    }
    for _, hl in ipairs(highlights) do
      vim.api.nvim_set_hl(0, hl, { bg = "NONE" })
    end
  end,
})
