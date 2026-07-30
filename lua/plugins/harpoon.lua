return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- The lualine indicator asks harpoon whether the current file is pinned on every
  -- redraw, so the plugin is needed from the first statusline draw regardless. This
  -- makes that explicit rather than having the first redraw pull it in through
  -- lazy's require hook, which would mean loading a plugin mid-redraw.
  event = 'VeryLazy',
  config = function()
    -- setup() is what registers the autocmds that persist the list.
    require('harpoon'):setup {
      settings = {
        -- Off by default, which makes the menu a liar: you can `dd` a line, close
        -- with q, and the list is unchanged unless you happened to `:w` first.
        -- With this on, editing the menu and closing it is a real edit.
        save_on_toggle = true,
      },
    }
  end,
}
