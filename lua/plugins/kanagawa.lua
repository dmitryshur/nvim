return {
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    require('kanagawa').setup {
      overrides = function(colors)
        return {
          NeoTreeIndentMarker = { fg = colors.palette.sumiInk5 },
        }
      end,
    }
    vim.cmd.colorscheme 'kanagawa-wave'
  end,
}
