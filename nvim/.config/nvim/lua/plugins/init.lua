local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use { -- LSP
    'junnplus/nvim-lsp-setup',
    requires = {
      'neovim/nvim-lspconfig',
      'williamboman/nvim-lsp-installer',
      'lukas-reineke/lsp-format.nvim'
    },
    config = function()
      require('plugins.lsp')
    end
  }
  use { -- Treesitter
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('plugins.nvim-treesitter')
    end,
    requires = {
      'nvim-treesitter/playground',
      'windwp/nvim-ts-autotag',
      'JoosepAlviste/nvim-ts-context-commentstring',
    }
  }
  use { -- Telescope
    'nvim-telescope/telescope.nvim',
    config = function()
      require('plugins.telescope')
    end,
    requires = {
      'nvim-lua/plenary.nvim',
    }
  }
  use { -- File Explorer
    'kyazdani42/nvim-tree.lua',
    requires = {
      {
        'kyazdani42/nvim-web-devicons',
        config = function()
          require('plugins.nvim-web-devicons')
        end
      }
    },
    config = function()
      require('plugins.nvim-tree')
    end
  }
  use { -- Autopairs
    'windwp/nvim-autopairs',
    config = function()
      require('plugins.nvim-autopairs')
    end
  }
  use { -- Comments
    'numToStr/Comment.nvim',
    config = function()
      require('plugins.comment')
    end
  }
  use { -- Completion
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-buffer',
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind.nvim',
      'L3MON4D3/LuaSnip'
    },
    config = function()
      require('plugins.nvim-cmp')
    end
  }
  use { -- Statusline
    'nvim-lualine/lualine.nvim',
    config = function()
      require('plugins.lualine')
    end
  }
  --   use({ -- Debugging
  --     "mfussenegger/nvim-dap",
  --     requires = {
  --       "rcarriga/nvim-dap-ui",
  --     },
  --   })
  --   use({ -- Git diff
  --     "sindrets/diffview.nvim",
  --     config = conf("diffview"),
  --   })
  use { -- Git Gutter
    'lewis6991/gitsigns.nvim',
    config = function()
      require('plugins.gitsigns')
    end
  }
  use 'tpope/vim-fugitive'
  --   use({
  --     "ThePrimeagen/git-worktree.nvim",
  --     config = conf("git-worktree"),
  --   })
  use { -- Indent guides
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('plugins.indent')
    end
  }
  use { -- Colorscheme
    'sainnhe/gruvbox-material',
    -- 'folke/tokyonight.nvim',
    -- 'rose-pine/neovim',
    config = function()
      require('plugins.colors')
      -- vim.cmd('colorscheme rose-pine')
      -- vim.cmd('colorscheme tokyonight')
      vim.cmd('colorscheme gruvbox-material')
    end
  }
  use { -- Colorizer
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('plugins.nvim-colorizer')
    end
  }
  --   use({ -- Extended language support
  --     "jxnblk/vim-mdx-js",
  --   })
  --   use({
  --     "tpope/vim-rails",
  --   })
  if packer_bootstrap then
    require('packer').sync()
  end
end)
