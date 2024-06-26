return {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup {
      toggler = {
        line = 'cl',
        block = 'cb',
      },
      opleader = {
        line = 'cl',
        block = 'cb',
      },
    }
  end,
}
