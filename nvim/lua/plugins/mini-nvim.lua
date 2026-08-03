-- mini.nvim owns buffer-local text editing.
-- Windows and UI chrome live in snacks-nvim.lua.

return {
  'echasnovski/mini.nvim',
  version = '*',
  config = function()
    -- text objects and editing
    require('mini.ai').setup()
    require('mini.surround').setup()
    require('mini.pairs').setup()

    -- motion and highlighting
    require('mini.bracketed').setup()
    require('mini.cursorword').setup()

    -- icon provider; snacks and blink.cmp both auto-detect this
    require('mini.icons').setup()

    require('mini.statusline').setup()

    require('mini.files').setup()
    vim.keymap.set('n', '-', function()
      MiniFiles.open(vim.api.nvim_buf_get_name(0))
    end, { desc = 'Open parent directory' })

    -- NOTE: mini.comment is deliberately absent -- Neovim ships `gc` since 0.10.
    -- mini.pick and mini.extra were replaced by snacks.picker, which centers its
    -- window by default and needed none of the ~200 lines of helpers this file
    -- used to carry.
  end,
}
