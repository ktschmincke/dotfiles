-- globals
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true
vim.g.fugitive_gitlab_domains = { 'git.kion.io' }

----------------
--            --
--  Settings  --
--            --
----------------

-- See `:help vim.keymap.set()`
vim.opt.autoindent     = true               -- automatically indent new lines
vim.opt.autoread       = true               -- automatically reload files when changed outside of vim
vim.opt.backspace      = 'indent,eol,start' -- allow backspacing over everything in insert mode
vim.opt.belloff        = 'all'              -- disable all bells
vim.opt.breakindent    = true               -- keep wrapped lines indented
vim.opt.clipboard      = 'unnamedplus'      -- use system clipboard
vim.opt.confirm        = true               -- confirm before closing unsaved buffers
vim.opt.cursorline     = true               -- Show which line your cursor is on
vim.opt.hlsearch       = true               -- highlight search results
vim.opt.ignorecase     = true               -- ignore case when searching
vim.opt.inccommand     = 'split'            -- Preview substitutions live, as you type!
vim.opt.list           = true               -- show whitespace chars
vim.opt.listchars      = {                  -- configure whitespace chars
  nbsp                 = '␣',
  tab                  = '» ',
  trail                = '·',
}
vim.opt.mouse          = 'a'                -- enable mouse support
vim.opt.number         = true               -- line numbers
vim.opt.relativenumber = true               -- relative line numbers
vim.opt.scrolloff      = 10                 -- Minimal number of screen lines to keep above and below the cursor.
vim.opt.showmode       = false              -- don't show mode
vim.opt.signcolumn     = 'yes'              -- always show sign column so lines don't shift
vim.opt.smartcase      = true               -- ignore case if search pattern is all lowercase, case-sensitive otherwise
vim.opt.smarttab       = true               -- use shiftwidth for tabstop
vim.opt.spell          = true               -- don't spellcheck by default
vim.opt.splitbelow     = true               -- open new splits below
vim.opt.splitright     = true               -- open new splits to the right
vim.opt.undofile       = true               -- save undo history to file
vim.opt.updatetime     = 250                -- decrease update time
vim.opt.wrap           = false              -- don't wrap lines by default

-------------------------------------------------
--                                             --
--                   Keymaps                   --
--    (plugin-specific mappings are defined    --
--     in plugin files under lua/plugins/)     --
--                                             --
-------------------------------------------------

-- clear search highlights on <Esc>
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Use CTRL+<hjkl> to switch between windows
-- See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- center the screen when moving up and down, and when searching
vim.keymap.set('n', '<C-d>', '<C-d>zz0', { desc = 'Scroll down half a page' })
vim.keymap.set('n', '<C-u>', '<C-u>zz0', { desc = 'Scroll up half a page' })
vim.keymap.set('n', 'n', 'nzz', { desc = 'Move to next search result' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Move to previous search result' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Install `lazy.nvim` plugin manager
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup 'plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
