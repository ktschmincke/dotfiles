-- Formatting only. Linting lives in lint.lua and the eslint language server.
--
-- Web formatters resolve from node_modules/.bin before Mason's copies, so the
-- project's own version and config are used.

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
    -- shared by every web filetype below
    local prettier = { 'prettierd', 'prettier', stop_after_first = true }

    return {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- languages without a standardised style
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        return {
          timeout_ms = 2000, -- prettierd's daemon can be slow to start
          lsp_format = 'fallback',
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'goimports', 'gofmt' },

        -- Angular templates are filetype `htmlangular`, not `html`, once they
        -- contain Angular syntax. Both are needed.
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
