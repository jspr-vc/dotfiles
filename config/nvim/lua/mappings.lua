-- require "nvchad.mappings"
local map = vim.keymap.set

-- PERSONAL KEYMAPS

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.keymap.set("x", "<leader>cl", function()
      vim.cmd 'normal! "ay'
      local yanked_text = vim.fn.getreg "a"
      local console_statement = string.format('console.log("%s:", %s)', yanked_text, yanked_text)
      vim.cmd("normal! o" .. console_statement)
    end, { buffer = true, noremap = true, desc = "Console log selected text" })
  end,
})

-- DEFAULT MAPPING

map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

map("n", "<leader>fm", function()
  require("conform").format()
end, { desc = "general format file" })

-- global lsp mappings
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- tabufline
local tabufline = require "nvchad.tabufline"
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<tab>", tabufline.next, { desc = "buffer goto next" })
map("n", "<S-tab>", tabufline.prev, { desc = "buffer goto prev" })
map("n", "<leader>x", tabufline.close_buffer, { desc = "buffer close" })

-- Comment
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- nvimtree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

-- telescope
-- map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
-- map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
-- map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
-- map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
-- map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
-- map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
-- map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
-- map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
-- map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

map("n", "<leader>th", function()
  require("nvchad.themes").open {
    style = "flat",
  }
end, { desc = "telescope nvchad themes" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

-- terminal
map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

-- new terminals
-- map("n", "<leader>h", function()
--   require("nvchad.term").new { pos = "sp" }
-- end, { desc = "terminal new horizontal term" })
--
-- map("n", "<leader>v", function()
--   require("nvchad.term").new { pos = "vsp" }
-- end, { desc = "terminal new vertical term" })

-- toggleable
map({ "n", "t" }, "<A-v>", function()
  require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" }
end, { desc = "terminal toggleable vertical term" })

map({ "n", "t" }, "<A-h>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
end, { desc = "terminal toggleable horizontal term" })

map({ "n", "t" }, "<A-i>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm" }
end, { desc = "terminal toggle floating term" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

-- END OF DEFAULT MAPPING

local gitsigns = require "gitsigns"
local telescope = require "telescope.builtin"

local nvim_files = function()
  telescope.find_files { cwd = vim.fn.stdpath "config" }
end

local config_files = function()
  telescope.find_files { cwd = "$HOME/.config" }
end

local git_stage_hunk_selected = function()
  gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
end

local git_reset_hunk_selected = function()
  gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
end

local git_blame_line = function()
  gitsigns.blame_line { full = true }
end

local git_diff_against_index = function()
  gitsigns.diffthis "~"
end

local code_action = function()
  require("tiny-code-action").code_action()
end

local find_files = function()
  telescope.find_files { hidden = true }
end

local find_all_files = function()
  telescope.find_files {
    hidden = true,
    no_ignore = true,
    file_ignore_patterns = { "%.git/", "node_modules/", "%.venv/", "__pycache__/", "%.mypy_cache/", "vendor/" },
  }
end

-- Good defaults
map("n", ";", ":", { desc = "CMD enter command mode" })
map({ "n", "v" }, "j", "gj")
map({ "n", "v" }, "k", "gk")

map("i", "jk", "<ESC>")
map("v", "p", "P") -- prevents replacing the register when pasting on visual mode
map("i", "jj", "<ESC>", { desc = "Navigation Escape insert mode" })
map("n", "<C-d>", "<C-d>zz", { desc = "Navigation Jump half page down and center the cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = "Navigation Jump half page up and center the cursor" })
map("n", "n", "nzzzv", { desc = "Navigation Next in search, center the page and unfold" })
map("n", "N", "Nzzzv", { desc = "Navigation Previous in search, center the page and unfold" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Navigation Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Navigation Move selection up" })

-- Telescope
map("n", "<leader>fg", telescope.live_grep, { desc = "FuzzyFind Find with Live Grep" })
map("n", "<leader>fh", telescope.help_tags, { desc = "FuzzyFind Find Help" })
map("n", "<leader>fo", telescope.oldfiles, { desc = "FuzzyFind Find Old files" })
map("n", "<leader>fk", telescope.keymaps, { desc = "FuzzyFind Find Keymaps" })
map("n", "<leader>fb", telescope.builtin, { desc = "FuzzyFind Find Telescope [B]uiltin" })
map("n", "<leader>fw", telescope.grep_string, { desc = "FuzzyFind Find current [W]ord" })
map("n", "<leader>fd", telescope.diagnostics, { desc = "FuzzyFind Find Diagnostics" })
map("n", "<leader>fr", telescope.resume, { desc = "FuzzyFind Find Resume" })
map("n", "<leader><leader>", telescope.buffers, { desc = "FuzzyFind Find existing buffers" })
map("n", "<leader>f/", telescope.current_buffer_fuzzy_find, { desc = "FuzzyFind Fuzzily search in current buffer" })
map("n", "<leader>ff", find_files, { desc = "FuzzyFind Find Files" })
map("n", "<leader>fF", find_all_files, { desc = "FuzzyFind Find All Files (incl. ignored)" })
map("n", "<leader>fn", nvim_files, { desc = "FuzzyFind Neovim Config files" })
map("n", "<leader>fc", config_files, { desc = "FuzzyFind Neovim Config files" })
map("n", "<leader>fp", telescope.registers, { desc = "FuzzyFind registers" })

-- LSP
map("n", "gr", telescope.lsp_references, { desc = "LSP Find References" })
map("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "LSP Find Symbols" })
map("n", "<leader>gd", telescope.lsp_definitions, { desc = "LSP Find Definition" })
map("n", "<leader>lf", vim.diagnostic.open_float, { desc = "LSP floating diagnostic" })
map("n", "<leader>ca", code_action, { desc = "LSP Code Action" })

-- Git
map("n", "<leader>gm", telescope.git_commits, { desc = "Git Git Commits" })
map("n", "<leader>gs", telescope.git_status, { desc = "Git Git Status" })
map("n", "]c", gitsigns.next_hunk, { desc = "Git Jump to next git change" })
map("n", "[c", gitsigns.prev_hunk, { desc = "Git Jump to previous git change" })
map("v", "<leader>hs", git_stage_hunk_selected, { desc = "Git Stage hunk" })
map("v", "<leader>hr", git_reset_hunk_selected, { desc = "Git Reset hunk" })
map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Git Stage hunk" })
map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Git Reset hunk" })
map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Git Stage buffer" })
map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Git Undo stage hunk" })
map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Git Reset buffer" })
map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Git Preview hunk" })
map("n", "<leader>hb", git_blame_line, { desc = "Git Blame line" })
map("n", "<leader>hD", git_diff_against_index, { desc = "Git Diff against index" })
map("n", "<leader>hd", gitsigns.diffthis, { desc = "Git Diff against last commit" })
map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Git Toggle git show blame line" })
map("n", "<leader>tD", gitsigns.toggle_deleted, { desc = "Git Toggle git show Deleted" })

local tf = require "nvchad.tabufline"
map("n", "<leader>q", tf.close_buffer, { desc = "general quit all" })
map("n", "<leader>Q", function()
  tf.closeAllBufs(false)
end, { desc = "general quit all except current" })
-- require("nvchad.tabufline").close_buffer()
--
-- -- closes all buffers
-- require("nvchad.tabufline").closeAllBufs(true)
-- require("nvchad.tabufline").closeAllBufs(false) -- excludes current buf
--
-- require("nvchad.tabufline").closeBufs_at_direction("left") -- or right
--

-- nvzone/menu
vim.keymap.set("n", "<C-t>", function()
  require("menu").open "default"
end, {})

-- mouse users + nvimtree users!
vim.keymap.set({ "n", "v" }, "<RightMouse>", function()
  require("menu.utils").delete_old_menus()

  vim.cmd.exec '"normal! \\<RightMouse>"'

  -- clicked buf
  local buf = vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)
  local options = vim.bo[buf].ft == "NvimTree" and "nvimtree" or "default"

  require("menu").open(options, { mouse = true })
end, {})
