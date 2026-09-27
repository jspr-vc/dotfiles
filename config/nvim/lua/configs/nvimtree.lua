return {
  filters = {
    dotfiles = false,
    custom = { "^\\.git$", "node_modules", "^\\.turbo" },
  },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = {
      min = 1,
      max = 45,
      padding = 1,
    },
    -- preserve_window_proportions = true,
    -- adaptive_size = true,
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = { unmerged = "" },
      },
    },
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
}
