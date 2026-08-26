local function set_changed_line_highlight(winid, line_highlight, text_highlight)
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

  winhighlight[#winhighlight + 1] = 'DiffChange:' .. line_highlight
  winhighlight[#winhighlight + 1] = 'DiffText:' .. text_highlight
  winhighlight[#winhighlight + 1] = 'DiffTextAdd:' .. text_highlight

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
    -- default upstream. Diffview also uses DiffviewDiffDeleteDim for the blank
    -- filler rows opposite added or removed content.
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
          local line_highlight = ctx.symbol == 'a' and 'DiffviewDiffAddAsDelete'
            or ctx.symbol == 'b' and 'DiffviewDiffAdd'
          local text_highlight = ctx.symbol == 'a' and 'DiffviewDiffTextAsDelete'
            or ctx.symbol == 'b' and 'DiffviewDiffTextAdd'
          if line_highlight and text_highlight then
            set_changed_line_highlight(winid, line_highlight, text_highlight)
          end
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
  config = function(_, opts)
    require('diffview').setup(opts)

    -- Keep syntax foregrounds intact and distinguish whole changed lines from
    -- the exact changed text with a slightly stronger background.
    for group, highlight in pairs {
      DiffviewDiffAdd = { bg = '#242927' },
      DiffviewDiffTextAdd = { bg = '#303b33' },
      DiffviewDiffAddAsDelete = { bg = '#2f2627' },
      DiffviewDiffTextAsDelete = { bg = '#483233' },
      DiffviewDiffChange = { bg = '#262a32' },
      DiffviewDiffText = { bg = '#333a4b' },
    } do
      vim.api.nvim_set_hl(0, group, highlight)
    end
  end,
}
