local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap =
  fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
end

require("packer").startup(function(use)
  -- Plugin Manager
  use("wbthomason/packer.nvim")

  -- LSP
  use({
    "junnplus/lsp-setup.nvim",
    requires = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("plugins.lsp")
    end,
  })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("plugins.nvim-treesitter")
    end,
    requires = {
      "nvim-treesitter/playground",
      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
  })

  -- Telescope
  use({
    "nvim-telescope/telescope.nvim",
    config = function()
      require("plugins.telescope")
    end,
    requires = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    },
  })

  -- File Explorer
  use({
    "nvim-tree/nvim-tree.lua",
    requires = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icons
    },
    config = function()
      require("plugins.nvim-tree")
    end,
  })

  -- Autopairs
  use({
    "windwp/nvim-autopairs",
    config = function()
      require("plugins.nvim-autopairs")
    end,
  })

  -- Comments
  use("tpope/vim-commentary")

  -- Completion
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require("plugins.nvim-cmp")
    end,
  })

  -- Statusline
  use({
    "nvim-lualine/lualine.nvim",
    config = function()
      require("plugins.lualine")
    end,
  })

  --   use({ -- Debugging
  --     "mfussenegger/nvim-dap",
  --     requires = {
  --       "rcarriga/nvim-dap-ui",
  --     },
  --   })

  -- Git
  use({
    "tpope/vim-fugitive",
    "lewis6991/gitsigns.nvim",
    config = function()
      require("plugins.git")
    end,
  })

  --   use({
  --     "ThePrimeagen/git-worktree.nvim",
  --     config = conf("git-worktree"),
  --   })

  -- Colorscheme
  use({
    "rose-pine/neovim",
    as = "rose-pine",
    config = function()
      require("plugins.colors")
    end,
  })

  if packer_bootstrap then
    require("packer").sync()
  end
end)
