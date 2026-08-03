-- Formatting only. Linting lives in lint.lua (stylelint, markdownlint) and in
-- the eslint language server (see nvim-lsp-config.lua).
--
-- conform resolves prettier/prettierd via util.from_node_modules(), so the
-- project's own binary in node_modules/.bin wins over Mason's global copy. That
-- means the project's prettier version, config and plugins are always used, and
-- formatting matches what the pre-commit hook produces.

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[C]ode [F]ormat buffer',
    },
    {
      '<leader>cF',
      function()
        -- eslint's autofix, via the language server
        if not pcall(vim.cmd, 'LspEslintFixAll') then
          vim.notify('No eslint server attached', vim.log.levels.WARN)
        end
        -- stylelint --fix, for stylesheets only
        if vim.tbl_contains({ 'css', 'scss', 'less' }, vim.bo.filetype) then
          require('conform').format { async = true, formatters = { 'stylelint' } }
        end
      end,
      desc = '[C]ode [F]ix (eslint + stylelint --fix)',
    },
  },
  opts = function()
    -- prettier and prettierd, preferring the daemon. Repeated across every web
    -- filetype, so build it once.
    local prettier = { 'prettierd', 'prettier', stop_after_first = true }

    return {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Languages without a standardised style. NOTE: scss used to be listed
        -- here, which silently prevented every SCSS file from ever formatting.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        return {
          -- 500ms was too tight for prettierd's daemon cold start
          timeout_ms = 2000,
          lsp_format = 'fallback',
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'goimports', 'gofmt' },

        -- Angular templates resolve to filetype `htmlangular`, NOT `html`, as
        -- soon as they contain Angular syntax (*ngIf, @if, ...). Registering
        -- only `html` is why template formatting appeared to work at random:
        -- plain .html files formatted, real components never did.
        html = prettier,
        htmlangular = prettier,

        javascript = prettier,
        javascriptreact = prettier,
        typescript = prettier,
        typescriptreact = prettier,

        css = prettier,
        scss = prettier,
        less = prettier,

        json = prettier,
        jsonc = prettier,
        yaml = prettier,
        markdown = prettier,
      },
    }
  end,
}
