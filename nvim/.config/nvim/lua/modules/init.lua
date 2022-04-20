local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local package_root = vim.fn.stdpath("data") .. "/site/pack"
local compile_path = vim.fn.stdpath("data") .. "/site/plugin/packer_compiled.lua"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
end

local function conf(name)
  return require(string.format("modules.config.%s", name))
end

return require("packer").startup({
  function(use)
    use("wbthomason/packer.nvim")
    use({ -- LSP
      "neovim/nvim-lspconfig",
      config = conf("nvim-lspconfig"),
      requires = {
        "williamboman/nvim-lsp-installer",
        "ray-x/lsp_signature.nvim",
      },
    })
    use({ -- Treesitter
      "nvim-treesitter/nvim-treesitter",
      config = conf("nvim-treesitter"),
      run = ":TSUpdate",
      requires = {
        "nvim-treesitter/playground",
        "windwp/nvim-ts-autotag",
        "JoosepAlviste/nvim-ts-context-commentstring",
      },
    })
    use({ -- Telescope
      "nvim-telescope/telescope.nvim",
      config = conf("telescope"),
      requires = {
        "nvim-lua/plenary.nvim",
      },
    })
    use({ -- File Explorer
      "kyazdani42/nvim-tree.lua",
      config = conf("nvim-tree"),
      requires = {
        "kyazdani42/nvim-web-devicons",
      },
    })
    use({ -- Autopairs
      "windwp/nvim-autopairs",
      config = conf("nvim-autopairs"),
    })
    use({ -- Comments
      "numToStr/Comment.nvim",
      config = conf("comment"),
    })
    use({ -- Completion
      "hrsh7th/nvim-cmp",
      config = conf("nvim-cmp"),
      requires = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-calc",
        "hrsh7th/cmp-nvim-lsp",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "f3fora/cmp-spell",
        "ray-x/cmp-treesitter",
        "hrsh7th/cmp-cmdline",
        { "L3MON4D3/LuaSnip", requires = { "rafamadriz/friendly-snippets" } },
      },
    })
    use({
      "nvim-lualine/lualine.nvim",
      config = conf("lualine"),
    })
    use({ -- Debugging
      "mfussenegger/nvim-dap",
      requires = {
        "rcarriga/nvim-dap-ui",
      },
    })
    use({ -- Git diff
      "sindrets/diffview.nvim",
      config = conf("diffview"),
    })
    use({ -- Git Gutter
      "lewis6991/gitsigns.nvim",
      config = conf("gitsigns"),
    })
    use("tpope/vim-fugitive")
    use("junegunn/gv.vim")
    use({
      "ThePrimeagen/git-worktree.nvim",
      config = conf("git-worktree"),
    })
    use({ -- Indent guides
      "lukas-reineke/indent-blankline.nvim",
      config = conf("indent-blankline"),
    })
    use({ -- Colors
      "folke/tokyonight.nvim",
      -- "projekt0n/github-nvim-theme",
      config = conf("colors"),
    })
    use({ -- Colorizer
      "norcalli/nvim-colorizer.lua",
      config = conf("nvim-colorizer"),
    })
    use({ -- Extended language support
      "jxnblk/vim-mdx-js",
    })
    use({
      "tpope/vim-rails",
    })

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require("packer").sync()
    end
  end,
  config = {
    compile_path = compile_path,
    package_root = package_root,
    display = {
      open_fn = require("packer.util").float,
    },
  },
})
