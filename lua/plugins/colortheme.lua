return {
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  config = function()
    require('catppuccin').setup({
      flavour = 'frappe', -- latte, frappe, macchiato, mocha
    })

    vim.cmd.colorscheme 'catppuccin'
  end
}
