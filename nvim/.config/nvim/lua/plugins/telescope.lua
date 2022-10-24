local actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    layout_strategy = 'flex',
    layout_config = {
      vertical = {
        preview_cutoff = 20,
        preview_height = 0.7,
      },
      horizontal = {
        preview_cutoff = 80
      }
    },
    file_ignore_patterns = { 'node_modules', '.git' },
    color_devicons = true,
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
      },
      n = {
        ['<C-c>'] = actions.close,
      },
    },
  },
  pickers = {
    buffers = {
      previewer = false,
      layout_config = {
        height = 20,
        width = 80,
      },
    },
    find_files = {
      hidden = true,
      no_ignore = true,
    },
    git_files = {
      show_untracked = true,
    }
  },
})

require('telescope').load_extension('fzf')

local M = {}

M.search_dotfiles = function()
  require("telescope.builtin").find_files({
    prompt_title = "Dotfiles",
    cwd = vim.env.DOTFILES,
  })
end

return M
