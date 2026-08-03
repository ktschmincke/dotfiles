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

    -- No mini.comment: Neovim ships `gc`. No mini.pick: snacks owns pickers.
  end,
}
