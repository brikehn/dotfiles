local builtin = require('telescope.builtin')

local search_dotfiles = function()
  builtin.find_files({
    prompt_title = "Dotfiles",
    cwd = vim.env.DOTFILES,
    hidden = true,
  })
end

vim.keymap.set('n', '<C-p>', builtin.git_files, {})

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>df', search_dotfiles, {})

vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
