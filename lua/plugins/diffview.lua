local function set_changed_line_highlight(winid, highlight)
  local changed_groups = {
    DiffChange = true,
    DiffText = true,
    DiffTextAdd = true,
  }
  local winhighlight = {}

  for entry in vim.gsplit(vim.wo[winid].winhighlight, ',', { plain = true, trimempty = true }) do
    local group = entry:match '^([^:]+):'
    if not changed_groups[group] then winhighlight[#winhighlight + 1] = entry end
  end

  for _, group in ipairs { 'DiffChange', 'DiffText', 'DiffTextAdd' } do
    winhighlight[#winhighlight + 1] = group .. ':' .. highlight
  end

  vim.wo[winid].winhighlight = table.concat(winhighlight, ',')
end

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
    hooks = {
      -- Wrapped lines can occupy different screen rows in each pane and make an
      -- otherwise aligned diff look offset. This event also runs after layouts
      -- change, so every window displaying a diff buffer stays unwrapped.
      diff_buf_win_enter = function(_, winid, ctx)
        vim.wo[winid].wrap = false

        -- Neovim classifies paired old/new rows as a third state, DiffChange.
        -- Render those as removals on the old side and additions on the new side,
        -- matching two-action diff viewers while preserving neutral merge panes.
        if ctx.layout_name:match '^diff2_' then
          local highlight = ctx.symbol == 'a' and 'DiffviewDiffAddAsDelete' or ctx.symbol == 'b' and 'DiffviewDiffAdd'
          if highlight then set_changed_line_highlight(winid, highlight) end
        end
      end,
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
