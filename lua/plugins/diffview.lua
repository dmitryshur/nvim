return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  opts = {
    -- `q` isn't bound by default, so quitting means `:q` per window. These
    -- keymaps are only active inside a Diffview tabpage, so `q` keeps its
    -- normal meaning (macro recording) everywhere else.
    keymaps = {
      view = {
        { 'n', 'q', '<cmd>DiffviewClose<CR>', { desc = 'Close Diffview' } },
      },
      file_panel = {
        { 'n', 'q', '<cmd>DiffviewClose<CR>', { desc = 'Close Diffview' } },
      },
      file_history_panel = {
        { 'n', 'q', '<cmd>DiffviewClose<CR>', { desc = 'Close Diffview' } },
      },
    },
  },
}
