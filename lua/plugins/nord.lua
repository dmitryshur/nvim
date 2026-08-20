return {
  'gbprod/nord.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    require('nord').setup {
      on_highlights = function(hl, colors)
        local blend = require('nord.utils').blend
        local background = colors.polar_night.origin

        hl.DiffAdd = { bg = blend(colors.aurora.green, background, 0.12) }
        hl.DiffChange = { bg = blend(colors.aurora.yellow, background, 0.1) }
        hl.DiffDelete = { bg = blend(colors.aurora.red, background, 0.12) }
        hl.DiffText = { bg = blend(colors.frost.artic_water, background, 0.24) }
        hl.NeoTreeIndentMarker = { fg = '#2c2c32' }
      end,
    }
    vim.cmd.colorscheme 'nord'
  end,
}
