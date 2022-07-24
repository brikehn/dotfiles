local o = vim.opt

-- General
o.iskeyword:append('-'); -- treat dash separated words as a word text object
o.mouse = 'a'; -- enable mouse
o.scrolloff = 8; -- start scrolling this many lines from edge
o.wrap = false; -- display long lines as just one line
o.splitbelow = true; -- horizontal splits will automatically be below
o.splitright = true; -- vertical splits will automatically be to the right
o.updatetime = 50; -- increase how often updates happen
o.clipboard:append('unnamedplus'); -- clipboard

-- Appearance
o.showmode = false; -- hides current mode
o.number = true; -- show numbered lines
o.relativenumber = true; -- show relative line numbers
o.signcolumn = 'yes'; -- show the sign column
o.colorcolumn = '80'; -- use for max line length guide
-- o.cmdheight = 2; -- more space for displaying messages
o.shortmess:append('c'); -- disable some stuff on shortmess
o.cursorline = false; -- highlights current line
o.laststatus = 2; -- always show statusline
o.list = true;
o.listchars = { eol = '↲', nbsp = '␣', trail = '·', tab = '│·' };
o.showtabline = 1; -- show tabs
o.termguicolors = true; -- set term gui colors

-- Tabs
o.tabstop = 4; -- length of \t in spaces
o.softtabstop = 4; -- length of tab/backspace keypress in spaces
o.shiftwidth = 4; -- length of indentation in spaces
o.expandtab = true; -- converts \t to spaces

-- Backups
o.backup = false; -- don't create backups
o.writebackup = false; -- don't create a backup before overwriting a file
o.swapfile = false; -- don't create a swap file
o.hidden = true; -- required to keep multiple buffers open
o.undodir = vim.fn.stdpath('cache') .. '/undo';
o.undofile = true; -- persistent undo

-- Search
o.inccommand = 'split'; -- make substitution work in realtime
o.incsearch = true; -- update search while typing
o.hlsearch = false; -- stop highlighting when searching
o.wildmenu = true; -- cmdline completion menu
o.wildmode = { 'longest:full', 'full' };
o.wildoptions = { 'pum', 'tagfile' }; -- cmdline completion

-- Completion
o.completeopt = { 'menuone', 'noselect', 'noinsert', 'preview' }; -- completion menu
