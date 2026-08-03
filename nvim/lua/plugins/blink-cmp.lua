-- Replaces nvim-cmp + LuaSnip + cmp_luasnip + cmp-nvim-lsp + cmp-path.
-- Snippet support is built in, so no separate snippet engine is needed.

return {
  'saghen/blink.cmp',
  -- version = '*' pulls a release with a prebuilt fuzzy-matcher binary.
  -- Without it, blink wants a local Rust toolchain to build from source.
  version = '*',
  event = 'InsertEnter',
  opts = {
    keymap = {
      -- the default preset already matches the old nvim-cmp bindings:
      --   <C-y> accept, <C-n>/<C-p> next/prev, <C-b>/<C-f> scroll docs,
      --   <C-space> show completions, <C-e> hide
      preset = 'default',

      -- ...except snippet navigation, which defaulted to <Tab>/<S-Tab>.
      -- Keep the previous <C-l>/<C-h>.
      ['<C-l>'] = { 'snippet_forward', 'fallback' },
      ['<C-h>'] = { 'snippet_backward', 'fallback' },
    },

    appearance = { nerd_font_variant = 'mono' },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev', 'buffer' },
      providers = {
        -- lazydev.nvim feeds Neovim API completions when editing this config
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
      },
    },

    -- warn rather than silently fall back to the slow Lua matcher if the
    -- prebuilt binary is missing
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
}
