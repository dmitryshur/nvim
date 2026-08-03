return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
  opts = {
    -- Vim's diff highlighting is per buffer and symmetric: DiffAdd means "in this
    -- buffer, not the other", so a block deleted by the change is *extra lines the
    -- old version has* and the left pane paints it DiffAdd -- green -- while
    -- DiffDelete only ever colours the filler rows opposite it. Reads backwards
    -- against every other diff you look at.
    --
    -- This remaps DiffAdd to DiffviewDiffAddAsDelete on the left pane only, so
    -- removed code is red there and added code stays green on the right. Off by
    -- default upstream. The theme already defines DiffviewDiffAddAsDelete; the
    -- DiffviewDiffDeleteDim it also pulls in links to Comment.
    enhanced_diff_hl = true,
    -- The left pane's buffer is named `diffview://<repo>/.git/:0:/<path>` -- git's
    -- index-stage notation, not a directory that exists. tsgo attaches to it all
    -- the same and resolves imports against that pseudo-path, so every one fails:
    -- `./constants.ts` next to the file, `#UI/...` aliases whose tsconfig project
    -- the path isn't inside, and then implicit-any errors downstream of the types
    -- that never arrived. None of it says anything about the old code.
    --
    -- Display-only (`vim.diagnostic.enable(false, { bufnr })` on attach, re-enabled
    -- on detach) and scoped to diffview's own buffers, so real files keep their
    -- diagnostics and the left pane keeps hover and goto-definition. merge_tool
    -- already defaults to true; these two do not.
    view = {
      default = { disable_diagnostics = true }, -- <leader>gd, <leader>gR
      file_history = { disable_diagnostics = true }, -- <leader>gh, <leader>gr
    },
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
