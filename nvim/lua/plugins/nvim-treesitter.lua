return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  event = {'BufNewFile', 'BufReadPre'},
  build = ':TSUpdate',
  opts = {
    ensure_installed = { 'angular', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'tmux', 'typescript', 'vimdoc' },
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = { enable = true, disable = { 'ruby' } },
    incremental_selection = {
      enable = true,
      keymaps = {
        node_incremental = 'v',
        node_decremental = 'V',
      },
    },
  },
  config = function(_, opts)
    require('nvim-treesitter.install').prefer_git = true
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup(opts)
  end,
}
