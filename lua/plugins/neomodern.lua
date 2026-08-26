return {
  'cdmill/neomodern.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    theme = 'gyokuro',
    overrides = {
      hlgroups = {
        NeoTreeIndentMarker = { guifg = '$visual' },
      },
    },
  },
  config = function(_, opts)
    require('neomodern').setup(opts)
    require('neomodern').load()
  end,
}
