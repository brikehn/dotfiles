-- General
vim.opt.scrolloff = 8   -- start scrolling this many lines from edge
vim.opt.wrap = false    -- display long lines as just one line
vim.opt.updatetime = 50 -- increase how often updates happen

-- Appearance
vim.opt.number = true         -- show numbered lines
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.signcolumn = "yes"    -- show the sign column
vim.opt.colorcolumn = "80"    -- use for max line length guide
vim.opt.termguicolors = true  -- set term gui colors
vim.opt.background = 'dark'

-- Tabs
vim.opt.tabstop = 4      -- length of \t in spaces
vim.opt.softtabstop = 4  -- length of tab/backspace keypress in spaces
vim.opt.shiftwidth = 4   -- length of indentation in spaces
vim.opt.expandtab = true -- converts \t to spaces
vim.opt.smartindent = true

-- Backups
vim.opt.backup = false   -- don't create backups
vim.opt.swapfile = false -- don't create a swap file
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true  -- persistent undo

-- Search
vim.opt.inccommand = "split" -- show a split for substitutions
vim.opt.incsearch = true     -- update search while typing
vim.opt.hlsearch = false     -- stops highlighting when searching
