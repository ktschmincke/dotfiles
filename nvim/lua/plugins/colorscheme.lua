return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      background = { -- :h background
        light = 'latte',
        dark = 'mocha',
      },
      integrations = {
        gitsigns = true,
        mini = {
          enabled = true,
        },
      },
    }
    vim.cmd.colorscheme 'catppuccin-mocha'
  end,
}
