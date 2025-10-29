return {
  'stevearc/oil.nvim',
  enabled = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('oil').setup {
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' }),
      skip_confirm_for_simple_edits = false,
      view_options = {
        show_hidden = true,
      },
    }
  end,
}
