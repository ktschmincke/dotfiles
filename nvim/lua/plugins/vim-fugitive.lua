return {
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>')
    vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<CR>')
    vim.keymap.set('n', '<leader>gco', '<cmd>Git checkout<CR>')
    vim.keymap.set('n', '<leader>gp', '<cmd>Git push<CR>')
    vim.keymap.set('n', '<leader>gl', '<cmd>Git pull<CR>')
    vim.keymap.set('n', '<leader>gd', '<cmd>Git diff<CR>')
    vim.keymap.set('n', '<leader>gw', '<cmd>GBrowse<CR>')
  end,
}
