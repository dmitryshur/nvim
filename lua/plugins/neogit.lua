return {
  'NeogitOrg/neogit',
  cmd = 'Neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    -- No diff viewer. Neogit's codediff integration still calls codediff's
    -- pre-v4 API and crashes on open (NeogitOrg/neogit#2008), and auto-detect
    -- would pick it the moment codediff is installed. With both off, the `d`
    -- popup hides its diff actions; <leader>gd covers those, conflicts included.
    integrations = {
      diffview = false,
      codediff = false,
    },
    -- Neogit sets `kind` per view and most of them default to "tab", which is
    -- what made its buffers pile up as tabpages (see <leader>o / :tabonly).
    -- Floating every view keeps the underlying window layout untouched.
    kind = 'floating', -- the status buffer
    commit_editor = { kind = 'floating' },
    commit_select_view = { kind = 'floating' },
    commit_view = { kind = 'floating' }, -- was "vsplit"
    log_view = { kind = 'floating' },
    reflog_view = { kind = 'floating' },
    rebase_editor = { kind = 'floating' }, -- was "auto"
    merge_editor = { kind = 'floating' }, -- was "auto"
    preview_buffer = { kind = 'floating' }, -- was "floating_console"
    popup = { kind = 'floating' }, -- was "split"
    stash = { kind = 'floating' },
    refs_view = { kind = 'floating' },
  },
}
