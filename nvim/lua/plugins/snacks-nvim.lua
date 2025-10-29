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
    statuscolumn = { enabled = true },
    win = { enabled = true },
  },
  config = function()
    vim.keymap.set('n', '<leader>lg', ':lua Snacks.lazygit()<CR>')
  end,
}
