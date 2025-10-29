return {
  'f-person/auto-dark-mode.nvim',
  enabled = false,
  opts = {
    set_dark_mode = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
    set_light_mode = function()
      vim.cmd.colorscheme 'catppuccin-latte'
    end,
    update_interval = 5000,
    fallback = 'dark',
  },
}
