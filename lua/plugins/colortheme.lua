return {
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    theme = 'dragon', -- wave, dragon, lotus
    background = { dark = 'dragon', light = 'lotus' },
    transparent = true, -- let Ghostty's background-opacity show through
    overrides = function(colors)
      return {
        -- dimmer neo-tree indent guides (default links to NonText)
        NeoTreeIndentMarker = { fg = colors.palette.dragonBlack5 },
      }
    end,
  },
  config = function(_, opts)
    require('kanagawa').setup(opts)
    vim.cmd.colorscheme 'kanagawa-dragon'
  end
}
