-- snacks.nvim owns anything that opens a window or paints chrome.
-- Buffer-local text editing lives in mini-nvim.lua.

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bufdelete = { enabled = true },
    dashboard = {
      enabled = true,
      sections = {
        { section = 'header' },
        { icon = ' ', title = 'Keymaps', section = 'keys', indent = 2, padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
        { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        { section = 'startup' },
      },
    },
    dim = { enabled = true },
    git = { enabled = true },
    gitbrowse = { enabled = true },
    image = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    lazygit = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true }, -- default layout is centered

    scope = { enabled = true },
    scratch = { enabled = true },
    statuscolumn = { enabled = true },
    win = { enabled = true },
  },
  keys = {
    -- <leader>f* is the picker namespace. Don't map a bare <leader>f, or all of
    -- these stall waiting for `timeoutlen`.
    {
      '<leader>ff',
      function()
        Snacks.picker.files()
      end,
      desc = 'Find files',
    },
    {
      '<leader>fg',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Find by grep',
    },
    {
      '<leader>fh',
      function()
        Snacks.picker.help()
      end,
      desc = 'Find help',
    },
    {
      '<leader>fk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = 'Find keymaps',
    },
    {
      '<leader>fr',
      function()
        Snacks.picker.resume()
      end,
      desc = 'Resume last picker',
    },
    {
      '<leader>fd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = 'Find diagnostics',
    },
    {
      '<leader>fp',
      function()
        Snacks.picker()
      end,
      desc = 'Find pickers',
    },

    -- muscle-memory aliases; neither is a prefix of anything
    {
      '<leader>t',
      function()
        Snacks.picker.files()
      end,
      desc = 'Find files',
    },
    {
      '<leader>T',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Find by grep',
    },
    {
      '<leader><leader>',
      function()
        Snacks.picker.buffers()
      end,
      desc = 'Find buffers',
    },

    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete buffer',
    },

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

    -- <leader>g* is git. Anything that opens a window lives here; gutter signs
    -- and hunk actions are buffer-local maps in gitsigns.lua.
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
    {
      '<leader>gw',
      function()
        Snacks.gitbrowse()
      end,
      desc = 'Git browse',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log_file()
      end,
      desc = 'Git log: this file',
    },
    {
      '<leader>gL',
      function()
        Snacks.picker.git_log_line()
      end,
      desc = 'Git log: this line',
    },
    {
      '<leader>gc',
      function()
        Snacks.picker.git_log()
      end,
      desc = 'Git log: commits',
    },
    {
      '<leader>gd',
      function()
        Snacks.picker.git_diff()
      end,
      desc = 'Git diff hunks',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status()
      end,
      desc = 'Git status',
    },
    {
      '<leader>gS',
      function()
        Snacks.picker.git_stash()
      end,
      desc = 'Git stash',
    },
    {
      '<leader>gr',
      function()
        Snacks.picker.git_branches()
      end,
      desc = 'Git branches',
    },
  },
}
