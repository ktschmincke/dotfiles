-- On-save linters only. These have no daemon, so each run is a cold process and
-- linting on every edit would be slow.
--
-- eslint is absent here on purpose: it runs as a language server instead, which
-- gets realtime diagnostics from one warm process. See nvim-lsp-config.lua.
--
-- Binaries resolve from node_modules/.bin, so the project's config is used.

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

    vim.api.nvim_create_autocmd('BufWritePost', {
      group = vim.api.nvim_create_augroup('lint', { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
