-- LSP setup using Neovim's native vim.lsp.config / vim.lsp.enable (0.11+).
--
-- mason-lspconfig is deliberately absent. Its `handlers = {}` API was removed in
-- 2.x, and it also auto-enabled any installed Mason package that happened to map
-- to a server -- which silently started `stylua --lsp` on every Lua buffer purely
-- because stylua was listed as a formatter to install. Enabling servers by an
-- explicit list makes that impossible.
--
-- Mason's job here is installation only; it prepends its bin/ to vim.env.PATH,
-- so the servers below are found without any extra wiring.

return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    -- note: mason moved from williamboman/* to mason-org/*
    { 'mason-org/mason.nvim', opts = {} },
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- LSP progress messages
    { 'j-hui/fidget.nvim', opts = {} },

    -- Lua LSP tuned for editing Neovim config. Replaces the archived neodev.nvim.
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
    ---------------------------------------------------------------------------
    -- Keymaps on attach
    --
    -- Neovim 0.11+ already provides these as defaults, so they are NOT repeated
    -- here: grn (rename), gra (code action), grr (references),
    -- gri (implementation), grt (type definition), gO (document symbols),
    -- and K (hover). Only the genuinely missing ones are mapped.
    ---------------------------------------------------------------------------
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
        if client and client:supports_method('textDocument/documentHighlight') then
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

    ---------------------------------------------------------------------------
    -- Server configuration
    --
    -- Per-server defaults come from nvim-lspconfig's lsp/ directory, which is on
    -- the runtimepath. Only overrides need to be declared here.
    ---------------------------------------------------------------------------

    -- blink.cmp advertises more completion capability than Neovim's default;
    -- broadcast it to every server.
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

    -- lspconfig server names (these match files in nvim-lspconfig's lsp/ dir)
    --
    -- `eslint` here is what provides realtime eslint diagnostics. It is a server
    -- rather than an nvim-lint entry because it covers the `htmlangular`
    -- filetype (so Angular templates get linted), resolves monorepo configs
    -- natively, updates incrementally from one warm process, and declares
    -- workspace_required so it never spawns outside a JS project.
    vim.lsp.enable {
      'angularls',
      'eslint',
      'gopls',
      'lua_ls',
      'ts_ls',
    }

    ---------------------------------------------------------------------------
    -- Tool installation
    --
    -- These are Mason *package* names, which are a different namespace from the
    -- lspconfig server names above ('angularls' vs 'angular-language-server').
    -- mason-lspconfig used to translate between the two; without it the lists
    -- must be declared separately rather than derived from each other.
    --
    -- Only tools with no project-local equivalent belong here. prettier, eslint
    -- and stylelint are resolved from node_modules/.bin by conform and nvim-lint,
    -- so the project's own version and plugins are always used.
    ---------------------------------------------------------------------------
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
