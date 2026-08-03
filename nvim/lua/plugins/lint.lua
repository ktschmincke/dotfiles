-- On-save linters only.
--
-- eslint is deliberately NOT here -- it runs as a language server instead (see
-- nvim-lsp-config.lua), which gives realtime incremental diagnostics from one
-- warm process, covers the `htmlangular` filetype, and resolves monorepo configs
-- natively. nvim-lint would re-lint whole buffers via a cold process.
--
-- stylelint has no daemon, so every run is a cold Node process. Realtime linting
-- would spawn one per edit, which is the thing that actually drags performance.
-- On-save is the right trade. nvim-lint resolves it from node_modules/.bin, so
-- the project's version, config and plugins are used and diagnostics match what
-- the pre-commit hook reports.

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      css = { 'stylelint' },
      scss = { 'stylelint' },
      less = { 'stylelint' },
      markdown = { 'markdownlint' },
    }

    -- On save only. The previous BufEnter/InsertLeave triggers meant a cold
    -- stylelint process on every insert-mode exit.
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = vim.api.nvim_create_augroup('lint', { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
