return {
  'catppuccin/nvim',
  -- The repo is named `nvim`, so without this the plugin dir (and the name
  -- `:Lazy` shows) would just be "nvim".
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  opts = {
    flavour = 'frappe', -- latte, frappe, macchiato, mocha
    background = { light = 'latte', dark = 'frappe' },
    transparent_background = true, -- let Ghostty's background-opacity show through
    integrations = {
      blink_cmp = true,
      diffview = true,
      fidget = true,
      gitsigns = true,
      mason = true,
      native_lsp = { enabled = true },
      neogit = true,
      neotree = true,
      telescope = { enabled = true },
      treesitter = true,
    },
    custom_highlights = function(colors)
      return {
        -- dimmer neo-tree indent guides
        NeoTreeIndentMarker = { fg = colors.surface1 },
      }
    end,
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme 'catppuccin'
  end,
}
