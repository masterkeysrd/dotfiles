local arrows = require('masterkeysrd.icons').arrows

vim.g.lsp = vim.g.lsp or {}

-- Set <space> as leader.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Show white spaces.
vim.o.list = true
-- vim.o.listchars = "tab:▸ ,trail:·,extends:»,precedes:«"

-- Show line numbers.
vim.o.number = true

-- Disable horizontal scrolling.
vim.o.mousescroll = 'ver:3,hor:0'

-- Wrap long line words.
vim.o.linebreak = true

-- Enable mouse mode.
vim.o.mouse = 'a'

-- Disable horizontal scrolling.
vim.o.mousescroll = 'ver:3,hor:0'

-- Indent
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Folding
vim.o.foldcolumn = "1"
vim.o.foldlevelstart = 99
vim.o.foldtext = ""

-- UI Characters
vim.opt.fillchars = {
    eob = ' ',
    fold = ' ',
    foldclose = arrows.right,
    foldopen = arrows.down,
    foldsep = ' ',
    msgsep = '─',
}

-- Use non-rounded border for floating windows.
vim.o.winborder = "single"

-- Sync clipboard between the OS and Neovim
vim.o.clipboard = "unnamedplus"

-- Save undo file
vim.o.undofile = true

-- Case insestive searching unless /C the search has capitals.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumns on defaults.
vim.o.signcolumn = 'yes'

-- Update time and timeouts.
vim.o.updatetime = 250
vim.o.timeoutlen = 500
vim.o.ttimeoutlen = 10


-- Completion
vim.o.wildmode = "longest:full,full"
vim.o.wildignorecase = true
vim.opt.wildignore:append { '.DS_Store' }
vim.o.completeopt = "fuzzy,menuone,noselect,noinsert"
vim.o.pumheight = 12

-- Diff mode settings.
-- Setting the context to a very large number disables folding.
vim.opt.diffopt:append 'vertical,context:99'

vim.opt.shortmess:append {
    w = true,
    s = true,
}


-- Status line.
vim.o.laststatus = 3
vim.o.cmdheight = 1

-- Disable cursor blinking in terminal mode.
vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:block-TermCursor'

vim.o.breakindent = true
vim.o.colorcolumn = "99"
vim.o.confirm = true
vim.o.cursorline = true
-- vim.o.cursorlineopt = "number"
vim.o.exrc = true
vim.o.expandtab = true
vim.o.jumpoptions = "view"
vim.o.scrolloff = 2
vim.o.sidescrolloff = 5
vim.o.smoothscroll = true
vim.o.splitright = true
vim.o.tagcase = "match"
vim.o.title = true
