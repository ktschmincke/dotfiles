-- Adds git related signs to the gutter, as well as utilities for managing changes.
-- Gutter signs and inline hunk actions. History and diff browsing are snacks
-- pickers in snacks-nvim.lua; staging and committing is lazygit.

return {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPre',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    current_line_blame = true,
    on_attach = function(bufnr)
      local gitsigns = require 'gitsigns'

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation. Not ]c/[c -- mini.bracketed owns those, and a buffer-local
      -- map would shadow it in every tracked file.
      map('n', ']h', function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk 'next'
        end
      end, { desc = 'Jump to next git [h]unk' })

      map('n', '[h', function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk 'prev'
        end
      end, { desc = 'Jump to previous git [h]unk' })

      -- Blame
      map('n', '<leader>gb', function()
        gitsigns.blame_line { full = true }
      end, { desc = 'git [b]lame line' })
      map('n', '<leader>gB', gitsigns.blame, { desc = 'git [B]lame file' })

      -- Hunk actions
      -- visual mode
      map('v', '<leader>ghs', function()
        gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, { desc = 'stage git hunk' })
      map('v', '<leader>ghr', function()
        gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, { desc = 'reset git hunk' })
      -- normal mode
      map('n', '<leader>ghp', gitsigns.preview_hunk_inline, { desc = 'hunk [p]review inline' })
      map('n', '<leader>ghP', gitsigns.preview_hunk, { desc = 'hunk [P]review float' })
      map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = 'hunk [s]tage' })
      map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = 'hunk [r]eset' })
      map('n', '<leader>ghS', gitsigns.stage_buffer, { desc = 'hunk [S]tage buffer' })
      -- no unstage map: stage_hunk toggles, so ghs on a staged hunk unstages it
      map('n', '<leader>ghR', gitsigns.reset_buffer, { desc = 'hunk [R]eset buffer' })
      map('n', '<leader>ghd', gitsigns.diffthis, { desc = 'hunk [d]iff against index' })
      map('n', '<leader>ghD', function()
        gitsigns.diffthis '@'
      end, { desc = 'hunk [D]iff against last commit' })
      map('n', '<leader>ghw', gitsigns.toggle_word_diff, { desc = 'hunk toggle [w]ord diff' })
    end,
  },
}
