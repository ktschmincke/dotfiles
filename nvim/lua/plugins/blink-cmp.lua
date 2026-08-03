-- Snippet support is built in, so no separate snippet engine is needed.

return {
  'saghen/blink.cmp',
  -- a release tag is required for the prebuilt fuzzy matcher; building from
  -- source needs a Rust toolchain
  version = '*',
  event = 'InsertEnter',
  opts = {
    keymap = {
      -- <C-y> accept, <C-n>/<C-p> next/prev, <C-b>/<C-f> scroll docs,
      -- <C-space> show, <C-e> hide
      preset = 'default',

      -- override the preset's <Tab>/<S-Tab> snippet navigation
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

    -- warn instead of silently falling back to the slow Lua matcher
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
}
