return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    init = function()
      vim.opt.background = 'light'
      vim.cmd.colorscheme("rose-pine")
    end
  },
}
