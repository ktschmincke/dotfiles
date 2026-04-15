return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    dim = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scratch = { enabled = true },
    statuscolumn = { enabled = true },
    win = { enabled = true },
  },
  keys = {
    {
      '<leader>.',
      function()
        Snacks.scratch()
      end,
      desc = 'Toggle Scratch Buffer',
    },
    {
      '<leader>S',
      function()
        Snacks.scratch.select()
      end,
      desc = 'Select Scratch Buffer',
    },
  },
}
