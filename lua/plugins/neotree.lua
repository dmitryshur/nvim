return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = 'Neotree',
  opts = {
    filesystem = {
      -- Without this, nothing watches the filesystem: `enable_refresh_on_write`
      -- only fires when *Neovim* writes a file, so anything that changes files
      -- behind the tree's back (git restore, a toggleterm command, Neogit)
      -- leaves it showing stale entries and stale git status.
      --
      -- It also gates the `.git` watcher (see neo-tree/git/init.lua) -- that's
      -- the part that refreshes git decorations. The only other automatic
      -- trigger neo-tree ships is `User FugitiveChanged`, which never fires
      -- here because we use Neogit.
      use_libuv_file_watcher = true,
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false, -- close auto-expanded dirs when leaving them
      },
      filtered_items = {
        -- Gitignored files are hidden by default, which makes things like a
        -- `logs/` directory unreachable from the tree. `H` still toggles
        -- dotfiles/hidden items on top of this.
        hide_gitignored = false,
      },
    },
  },
  config = function(_, opts)
    require('neo-tree').setup(opts)

    -- neo-tree bridges only Fugitive into its own GIT_EVENT
    -- (`events.define_autocmd_event(events.GIT_EVENT, { 'User FugitiveChanged' })`
    -- in neo-tree/setup/init.lua), so Neogit actions never reach it. Discarding
    -- changes is the worst case: Neogit rewrites files on disk, and the tree
    -- keeps showing the pre-discard state.
    --
    -- `NeogitStatusRefreshed` is the only User event Neogit fires. GIT_EVENT
    -- refreshes the git decorations; the manager refresh is what re-scans the
    -- directory so files that came back actually reappear.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'NeogitStatusRefreshed',
      group = vim.api.nvim_create_augroup('neotree-refresh-on-neogit', { clear = true }),
      callback = function()
        local events = require 'neo-tree.events'
        events.fire_event(events.GIT_EVENT)
        require('neo-tree.sources.manager').refresh 'filesystem'
      end,
    })
  end,
}
