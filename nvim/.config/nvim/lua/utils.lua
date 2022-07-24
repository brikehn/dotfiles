local M = {}

M.project_files = function()
  local opts = {
    show_untracked = true
  } -- define here if you want to define something
  local ok = pcall(require('telescope.builtin').git_files, opts)
  if not ok then
    require('telescope.builtin').find_files(opts)
  end
end

local options = { noremap = true, silent = true }

function M.buf_map(mode, key, cmd, opts)
  vim.api.nvim_buf_set_keymap(0, mode, key, cmd, opts or options)
end

function M.map(mode, key, cmd, opts)
  vim.api.nvim_set_keymap(mode, key, cmd, opts or options)
end

return M
