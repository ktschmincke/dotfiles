return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    spec = {
      { '<leader>d', group = 'debug' },
      { '<leader>dg', group = 'go' },
      { '<leader>g', group = 'git' },
      { '<leader>gh', group = 'hunk' },
    },
  },
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show { global = false }
      end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
}
