local actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    layout_strategy = 'flex',
    layout_config = {
      flip_columns = 120,
      vertical = {
        preview_cutoff = 20,
        preview_height = 0.7,
      },
      horizontal = {
        preview_cutoff = 80
      }
    },
    file_ignore_patterns = { 'node_modules' },
    color_devicons = true,
    mappings = {
      i = {
        ['<C-c>'] = actions.close,
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
        ['<CR>'] = actions.select_default,
        ['<C-x>'] = actions.select_horizontal,
        ['<C-v>'] = actions.select_vertical,
        ['<C-u>'] = actions.preview_scrolling_up,
        ['<C-d>'] = actions.preview_scrolling_down,
      },
      n = {
        ['<CR>'] = actions.select_default,
        ['j'] = actions.move_selection_next,
        ['k'] = actions.move_selection_previous,
        ['<C-x>'] = actions.select_horizontal,
        ['<C-v>'] = actions.select_vertical,
        ['<C-u>'] = actions.preview_scrolling_up,
        ['<C-d>'] = actions.preview_scrolling_down,
      },
    },
  },
  pickers = {
    help_tags = {
      theme = 'dropdown',
    },
    current_buffer_fuzzy_find = {
      previewer = false,
    },
    buffers = {
      previewer = false,
      layout_config = {
        height = 20,
        width = 80,
      },
    },
  },
})
