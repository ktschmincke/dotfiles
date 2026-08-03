-- globals
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

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
vim.opt.colorcolumn    = '80'               -- highlight column 80
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
vim.opt.sidescrolloff  = 5                  -- Minimal number of screen columns to keep to the left and right of the cursor.
vim.opt.signcolumn     = 'yes'              -- always show sign column so lines don't shift
vim.opt.smartcase      = true               -- ignore case if search pattern is all lowercase, case-sensitive otherwise
vim.opt.smarttab       = true               -- use shiftwidth for tabstop
vim.opt.spell          = true               -- spellcheck everywhere, including code:
                                            -- catches typos in comments. With treesitter
                                            -- highlighting active this is limited to
                                            -- @spell captures (comments and strings).
vim.opt.spelloptions    = 'camel'           -- split camelCase into words, so getUserNmae
                                            -- flags only 'Nmae' rather than the whole word
vim.opt.splitbelow     = true               -- open new splits below
vim.opt.splitright     = true               -- open new splits to the right
                                            -- NOTE: textwidth is deliberately NOT set
                                            -- globally -- it hard-wraps code as you type.
                                            -- Prose filetypes get it via autocmd below;
                                            -- code relies on prettier/stylua printWidth,
                                            -- with colorcolumn as the visual guide.
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
-- NOTE: ]d and [d are Neovim defaults since 0.10, so they are not remapped here.
-- (The old mappings used vim.diagnostic.goto_prev/goto_next, both deprecated in
-- favour of vim.diagnostic.jump.)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- NOTE: <C-hjkl> window navigation is owned by vim-tmux-navigator, which maps
-- the same keys and also hands off to tmux at the edges. Defining plain
-- <C-w> equivalents here as well only shadowed it confusingly.

-- center the screen when moving up and down, and when searching
vim.keymap.set('n', '<C-d>', '<C-d>zz0', { desc = 'Scroll down half a page' })
vim.keymap.set('n', '<C-u>', '<C-u>zz0', { desc = 'Scroll up half a page' })
vim.keymap.set('n', 'n', 'nzz', { desc = 'Move to next search result' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Move to previous search result' })

-- yank file name and path into system clipboard
vim.keymap.set('n', '<leader>yfn', ':let @+ = expand("%:t")<CR>', { desc = 'Yank [F]ile [N]ame' })
vim.keymap.set('n', '<leader>yfp', ':let @+ = expand("%")<CR>', { desc = 'Yank [F]ile [P]ath' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Hard-wrap prose at 80 columns. Deliberately not global: textwidth wraps code
-- as you type, and prettier/stylua already enforce width for code.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Wrap prose filetypes at 80 columns',
  group = vim.api.nvim_create_augroup('prose-textwidth', { clear = true }),
  pattern = { 'markdown', 'gitcommit', 'text' },
  callback = function()
    vim.opt_local.textwidth = 80
  end,
})

-- Install `lazy.nvim` plugin manager
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup 'plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
