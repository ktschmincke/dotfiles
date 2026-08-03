-- LSP setup using Neovim's native vim.lsp.config / vim.lsp.enable.
--
-- mason-lspconfig is absent on purpose: it auto-enables any installed Mason
-- package that maps to a server, which starts servers you never asked for (a
-- `stylua --lsp` on every Lua buffer, say). Servers are enabled explicitly here.
--
-- Mason only installs. It prepends its bin/ to vim.env.PATH, so servers resolve.

return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- LSP progress messages
    { 'j-hui/fidget.nvim', opts = {} },

    -- Lua LSP tuned for editing Neovim config
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
  },
  config = function()
    -- Only the mappings Neovim doesn't already provide. grn, gra, grr, gri, grt,
    -- gO and K are all defaults -- don't re-add them.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- Highlight other references to the symbol under the cursor while it rests.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method 'textDocument/documentHighlight' then
          local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
            end,
          })
        end
      end,
    })

    -- Server defaults come from nvim-lspconfig's lsp/ directory; only overrides
    -- go here. blink.cmp advertises more completion capability than the default.
    vim.lsp.config('*', {
      capabilities = require('blink.cmp').get_lsp_capabilities(),
    })

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
        },
      },
    })

    -- `eslint` provides realtime lint diagnostics, including for Angular
    -- templates. It is a server rather than an nvim-lint entry because it stays
    -- warm and resolves monorepo configs itself.
    vim.lsp.enable {
      'angularls',
      'eslint',
      'gopls',
      'lua_ls',
      'ts_ls',
    }

    -- Mason *package* names, a different namespace from the server names above
    -- ('angularls' vs 'angular-language-server'), so the two lists can't be
    -- derived from each other.
    --
    -- Only tools with no project-local equivalent belong here -- prettier, eslint
    -- and stylelint come from node_modules/.bin instead.
    require('mason-tool-installer').setup {
      ensure_installed = {
        -- language servers
        'angular-language-server',
        'eslint-lsp',
        'gopls',
        'lua-language-server',
        'typescript-language-server',

        -- formatters and linters with no project-local equivalent
        'markdownlint',
        'stylua',

        -- fallback only; the project copy in node_modules/.bin wins when present
        'prettierd',
      },
    }

    vim.keymap.set('n', '<leader>lrs', '<cmd>LspRestart<CR>', { desc = '[L]SP [R]e[s]tart' })
  end,
}
