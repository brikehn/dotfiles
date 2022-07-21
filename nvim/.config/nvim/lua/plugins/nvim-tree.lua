require('nvim-tree').setup({
  create_in_closed_folder = true,
  disable_netrw = true,
  hijack_cursor = true,
  update_cwd = true,
  sort_by = 'extension',
  respect_buf_cwd = false,
  reload_on_bufenter = true,
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  update_focused_file = {
    enable = true,
    update_root = true,
  },
  view = {
    adaptive_size = true,
    centralize_selection = true,
    hide_root_folder = false,
    preserve_window_proportions = true,
    width = 40,
  },
  git = {
    ignore = true,
  },
  actions = {
    change_dir = {
      global = true,
    },
    open_file = {
      quit_on_open = true,
      resize_window = false,
      window_picker = {
        enable = true,
      },
    },
  },
  renderer = {
    indent_markers = {
      enable = true,
    },
    root_folder_modifier = ':t',
    icons = {
      show = {
        folder_arrow = false
      },
      glyphs = {
        default = ' ',
        symlink = ' ',
        git = {
          unstaged = '',
          staged = 'S',
          unmerged = '',
          renamed = '➜',
          untracked = 'U',
          deleted = '✘',
          ignored = '?',
        },
        folder = {
          arrow_open = '',
          arrow_closed = '',
          default = '',
          open = '',
          empty = '',
          empty_open = '',
          symlink = '',
          symlink_open = '',
        },
      }
    },
    highlight_git = true
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  filesystem_watchers = {
    enable= true
  }
})
