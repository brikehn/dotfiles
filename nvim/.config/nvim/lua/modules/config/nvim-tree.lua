local g = vim.g
g.nvim_tree_indent_markers = 1
g.nvim_tree_git_hl = 1
g.nvim_tree_root_folder_modifier = ":t" -- see ":h filename-modifiers"
g.nvim_tree_respect_buf_cwd = 1
g.nvim_tree_create_in_closed_folder = 1
g.nvim_tree_refresh_wait = 500
g.nvim_tree_icons = {
  default = " ",
  symlink = " ",
  git = {
    unstaged = "",
    staged = "S",
    unmerged = "",
    renamed = "➜",
    untracked = "U",
    deleted = "✘",
    ignored = "?",
  },
  folder = {
    arrow_open = "",
    arrow_closed = "",
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
    symlink_open = "",
  },
}

return function()
  local nvim_tree = safe_require("nvim-tree")
  if not nvim_tree then
    return
  end

  nvim_tree.setup({
    auto_close = true,
    hijack_cursor = true,
    update_cwd = true,
    update_to_buf_dir = {
      enable = true,
      auto_open = true,
    },
    update_focused_file = {
      enable = true,
      update_cwd = true,
      ignore_list = {},
    },
    view = {
      auto_resize = true,
      width = 40,
    },
    git = {
      ignore = true,
    },
    actions = {
      open_file = {
        window_picker = {
          enable = 1
        }
      }
    }
  })
end
