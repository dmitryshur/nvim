return {
  'casedami/neomodern.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    require('neomodern').load 'moon'
  end,
}
