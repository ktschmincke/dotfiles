return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = 'VimEnter',
    branch = "canary",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = true, -- Enable debugging
      context = 'buffers',

    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
