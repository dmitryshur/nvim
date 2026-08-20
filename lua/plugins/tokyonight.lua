return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    require('tokyonight').setup {
      style = 'moon',
      on_highlights = function(hl)
        hl.NeoTreeIndentMarker = { fg = '#2c2c32' }
      end,
    }
    vim.cmd.colorscheme 'tokyonight-moon'
  end,
}
