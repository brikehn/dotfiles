local o = vim.opt

-- General
o.scrolloff = 8 -- start scrolling this many lines from edge
o.wrap = false -- display long lines as just one line
o.updatetime = 50 -- increase how often updates happen

-- Appearance
o.number = true -- show numbered lines
o.relativenumber = true -- show relative line numbers
o.signcolumn = "yes" -- show the sign column
o.colorcolumn = "80" -- use for max line length guide
o.shortmess:append("c") -- disable some stuff on shortmess
o.cursorline = true -- highlights current line
o.termguicolors = true -- set term gui colors

-- Tabs
o.tabstop = 4 -- length of \t in spaces
o.softtabstop = 4 -- length of tab/backspace keypress in spaces
o.shiftwidth = 4 -- length of indentation in spaces
o.expandtab = true -- converts \t to spaces

-- Backups
o.backup = false -- don't create backups
o.swapfile = false -- don't create a swap file
o.undodir = vim.fn.stdpath("cache") .. "/undo"
o.undofile = true -- persistent undo

-- Search
o.inccommand = "split" -- show a split for substitutions
o.incsearch = true -- update search while typing
o.hlsearch = false -- stops highlighting when searching
