return {
  'softoika/ngswitcher.vim',
  config = function()
    vim.keymap.set('n', '<leader>u', ':NgSwitchTS<CR>')
    vim.keymap.set('n', '<leader>i', ':NgSwitchCSS<CR>')
    vim.keymap.set('n', '<leader>o', ':NgSwitchHTML<CR>')
    vim.keymap.set('n', '<leader>p', ':NgSwitchSpec<CR>')

    -- with horizontal split
    vim.keymap.set('n', '<leader>su', ':SNgSwitchTS<CR>')
    vim.keymap.set('n', '<leader>si', ':SNgSwitchCSS<CR>')
    vim.keymap.set('n', '<leader>so', ':SNgSwitchHTML<CR>')
    vim.keymap.set('n', '<leader>sp', ':SNgSwitchSpec<CR>')

    -- with vertical split
    vim.keymap.set('n', '<leader>vu', ':VNgSwitchTS<CR>')
    vim.keymap.set('n', '<leader>vi', ':VNgSwitchCSS<CR>')
    vim.keymap.set('n', '<leader>vo', ':VNgSwitchHTML<CR>')
    vim.keymap.set('n', '<leader>vp', ':VNgSwitchSpec<CR>')
  end,
}
