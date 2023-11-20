return {
  'nvim-telescope/telescope.nvim', tag = '0.1.4',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local builtin = require('telescope.builtin')
    local actions = require('telescope.actions')
    local icons = require("nvim-nonicons")

    local search_dotfiles = function()
      builtin.find_files({
        prompt_title = "Dotfiles",
        cwd = vim.env.DOTFILES,
        hidden = true,
      })
    end

    require('telescope').setup({
      defaults = {
        prompt_prefix = "  " .. icons.get("telescope") .. "  ",
        mappings = {
          i = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist
          },
          n = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist
          }
        }
      }
    })

    vim.keymap.set('n', '<C-p>', builtin.git_files, {})

    vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    vim.keymap.set('n', '<leader>df', search_dotfiles, {})

    vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
  end,
}
