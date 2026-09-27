-- NOTE:
-- HACK:
-- FIXME:
-- BUG:
-- ISSUE:
-- FIXIT:
-- PERF:
-- TODO:
-- WARN:
-- TEST:

return {
  { "mg979/vim-visual-multi", lazy = false }, -- Visual multi cursor
  { "numToStr/Comment.nvim", opts = {}, lazy = false },
  { "echasnovski/mini.ai", opts = {}, lazy = false },
  { "nvim-mini/mini.misc", version = false },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      require("nvim-autopairs").setup {}
      -- If you want to automatically add `(` after selecting a function or method
      -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      -- local cmp = require("cmp")
      -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
  },
  -- {
  --   "lukas-reineke/indent-blankline.nvim",
  --   opts = {
  --     enabled = true,
  --     indent = {
  --       char = "▏",
  --       smart_indent_cap = true,
  --     },
  --     scope = {
  --       char = "▎",
  --       show_exact_scope = true,
  --       show_end = true,
  --     },
  --   },
  -- },
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    event = "LspAttach",
    opts = {
      backend = "delta",
      backend_opts = {
        delta = {
          -- Header from delta can be quite large.
          -- You can remove them by setting this to the number of lines to remove
          header_lines_to_remove = 4,

          -- The arguments to pass to delta
          -- If you have a custom configuration file, you can set the path to it like so:
          -- args = {
          --     "--config" .. os.getenv("HOME") .. "/.config/delta/config.yml",
          -- }
          args = {
            "--line-numbers",
          },
        },
      },
    },
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000, -- needs to be loaded in first
    config = function()
      require "configs.tiny-inline-diagnostic"
    end,
  },

  {
    "davidmh/mdx.nvim",
    event = "BufEnter *.mdx",
    config = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  { "nvzone/volt", lazy = true },
  { "nvzone/menu", lazy = true },
  {
    "rachartier/tiny-glimmer.nvim",
    lazy = false,
    priority = 10, -- Low priority to catch other plugins' keybindings
    config = function()
      require("tiny-glimmer").setup()
    end,
  },

  --
  -- {
  --   "rachartier/tiny-cmdline.nvim",
  --   init = function()
  --     vim.o.cmdheight = 0
  --     vim.g.tiny_cmdline = {
  --       width = { value = "70%" },
  --     }
  --   end,
  -- },

  -- lazy.nvim
  {
    "folke/snacks.nvim",
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      image = { enabled = true },
      gh = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      lazygit = { enabled = true },
      scratch = { enabled = true },
      -- scroll = {
      -- enabled = true,
      -- duration = 1,
      -- fps = 180,
      -- easing = "cubic",
      -- },
      picker = {
        sources = {
          gh_issue = {},
          gh_pr = {},
        },
      },
    },

    keys = {
      {
        "<leader>gi",
        function()
          Snacks.picker.gh_issue()
        end,
        desc = "GitHub Issues (open)",
      },
      {
        "<leader>gI",
        function()
          Snacks.picker.gh_issue { state = "all" }
        end,
        desc = "GitHub Issues (all)",
      },
      {
        "<leader>gp",
        function()
          Snacks.picker.gh_pr()
        end,
        desc = "GitHub Pull Requests (open)",
      },
      {
        "<leader>gP",
        function()
          Snacks.picker.gh_pr { state = "all" }
        end,
        desc = "GitHub Pull Requests (all)",
      },

      {
        "<leader>gl",
        function()
          Snacks.lazygit.open()
        end,
        desc = "LazyGit open",
      },
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
    },
  },
}
