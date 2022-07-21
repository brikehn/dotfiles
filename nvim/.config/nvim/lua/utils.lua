local M = {}

function _G.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify(string.format('Error requiring: %s', module), vim.log.levels.ERROR)
    return ok
  end
  return result
end

M.project_files = function()
  local opts = {} -- define here if you want to define something
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
