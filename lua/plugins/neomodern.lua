return {
  'casedami/neomodern.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    require('neomodern').setup {
      overrides = {
        hlgroups = {
          NeoTreeIndentMarker = { guifg = '#2c2c32' },
        },
      },
    }
    require('neomodern').load 'moon'
  end,
}
