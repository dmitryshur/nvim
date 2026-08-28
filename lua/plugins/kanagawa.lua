return {
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    theme = 'dragon',
    colors = {
      theme = {
        dragon = {
          ui = {
            bg_gutter = '#181616',
          },
        },
      },
    },
    overrides = function(colors)
      return {
        NeoTreeIndentMarker = { fg = colors.theme.ui.bg_gutter },
      }
    end,
    background = {
      dark = 'dragon',
      light = 'lotus',
    },
  },
  config = function(_, opts)
    require('kanagawa').setup(opts)
    vim.cmd.colorscheme 'kanagawa-dragon'
  end,
}
