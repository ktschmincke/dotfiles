-- Debugging via DAP: Go (delve), Node, and Angular in Chrome (js-debug).
--
-- mason-nvim-dap is absent for the same reason mason-lspconfig is: it registers
-- adapter configs for every Mason package it recognises. Adapters are declared
-- explicitly below and Mason only installs the binaries -- the `ensure_installed`
-- list lives in nvim-lsp-config.lua, which owns mason-tool-installer.

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Mason is what puts js-debug-adapter and dlv on PATH, and it only does that
    -- once loaded. Without this it arrives via nvim-lspconfig's BufReadPre, which
    -- would make debugging silently depend on the LSP plugin loading first.
    'mason-org/mason.nvim',

    -- nvim-nio is a hard requirement of dap-ui, not a convenience.
    { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' }, opts = {} },

    -- inline variable values next to the code while stopped
    { 'theHamsta/nvim-dap-virtual-text', opts = {} },

    -- delve adapter plus `debug nearest test`, which is the reason for the dependency
    { 'leoluz/nvim-dap-go', opts = {} },
  },
  -- stylua: ignore
  keys = {
    { '<F5>',      '<cmd>DapContinue<CR>', desc = 'Debug: Start/Continue' },
    { '<F10>',     '<cmd>DapStepOver<CR>', desc = 'Debug: Step Over' },
    { '<F11>',     '<cmd>DapStepInto<CR>', desc = 'Debug: Step Into' },
    { '<S-F11>',   '<cmd>DapStepOut<CR>',  desc = 'Debug: Step Out' },
    -- tmux doesn't forward Shift+F11 as <S-F11>, so F12 steps out as well.
    { '<F12>',     '<cmd>DapStepOut<CR>',  desc = 'Debug: Step Out' },

    { '<leader>db', '<cmd>DapToggleBreakpoint<CR>', desc = 'Debug: Toggle [B]reakpoint' },
    { '<leader>dB', function()
      vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(condition)
        if condition and condition ~= '' then
          require('dap').set_breakpoint(condition)
        end
      end)
    end, desc = 'Debug: Conditional [B]reakpoint' },
    { '<leader>du', function() require('dapui').toggle() end,     desc = 'Debug: Toggle [U]I' },
    { '<leader>dr', '<cmd>DapToggleRepl<CR>',                     desc = 'Debug: Open [R]EPL' },
    { '<leader>dt', '<cmd>DapTerminate<CR>',                      desc = 'Debug: [T]erminate' },
    { '<leader>dl', function() require('dap').run_last() end,     desc = 'Debug: Run [L]ast' },

    { '<leader>dgt', function() require('dap-go').debug_test() end,      desc = 'Debug: [G]o nearest [T]est' },
    { '<leader>dgl', function() require('dap-go').debug_last_test() end, desc = 'Debug: [G]o [L]ast test' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Reuse the diagnostic highlight groups so signs follow the colorscheme.
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticSignError' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticSignWarn' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DiagnosticSignHint' })
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DiagnosticSignInfo' })
    vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticSignInfo', linehl = 'Visual' })

    dap.listeners.after.event_initialized['dapui'] = dapui.open
    dap.listeners.before.event_terminated['dapui'] = dapui.close
    dap.listeners.before.event_exited['dapui'] = dapui.close

    -- js-debug speaks DAP over a socket on a port nvim-dap picks, so it's a
    -- server adapter rather than an executable one. `js-debug-adapter` is Mason's
    -- shim. `node` and `chrome` are js-debug's own legacy type names, aliased here
    -- so a project's .vscode/launch.json loads without editing.
    for _, name in ipairs { 'pwa-node', 'pwa-chrome', 'node', 'chrome' } do
      dap.adapters[name] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'js-debug-adapter',
          args = { '${port}' },
        },
      }
    end

    local js_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

    for _, ft in ipairs(js_filetypes) do
      dap.configurations[ft] = {
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch Chrome against localhost:8080',
          url = 'http://localhost:8080',
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
        {
          -- Keeps the existing Chrome profile, so an SSO session survives. Chrome
          -- must already be running with --remote-debugging-port=9222.
          type = 'pwa-chrome',
          request = 'attach',
          name = 'Attach to Chrome (:9222)',
          port = 9222,
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
        {
          -- Attach is by inspector port, not by pid: js-debug will not turn the
          -- inspector on for you, so a `processId` picker just hangs. Start the
          -- process with --inspect, or flip it on for one already running with
          -- `kill -USR1 <pid>` -- node opens 9229 without restarting.
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to node on :9229',
          port = 9229,
          cwd = '${workspaceFolder}',
        },
      }
    end

    -- Launching a .ts file needs a project-specific loader (tsx, ts-node, a jest
    -- binary), so TypeScript launch configs belong in the project's launch.json.
    for _, ft in ipairs { 'javascript', 'javascriptreact' } do
      table.insert(dap.configurations[ft], {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch current file',
        program = '${file}',
        cwd = '${workspaceFolder}',
      })
    end

    -- A project's .vscode/launch.json needs no wiring: nvim-dap's built-in
    -- `dap.launch.json` config provider reads ./.vscode/launch.json on every
    -- continue, so those entries show up alongside the ones above and stay
    -- correct after a :cd. (dap.ext.vscode.load_launchjs is deprecated.)
  end,
}
