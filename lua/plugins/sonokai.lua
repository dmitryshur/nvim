return {
  'sainnhe/sonokai',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    vim.g.sonokai_style = 'default'

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('sonokai-custom-highlights', { clear = true }),
      pattern = 'sonokai',
      callback = function()
        local config = vim.fn['sonokai#get_configuration']()
        local palette = vim.fn['sonokai#get_palette'](config.style, config.colors_override)

        vim.api.nvim_set_hl(0, 'NeoTreeNormal', { fg = palette.fg[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { fg = palette.fg[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeEndOfBuffer', { fg = palette.bg0[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeWinSeparator', { fg = palette.bg1[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeIndentMarker', { fg = palette.bg1[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = palette.grey_dim[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { fg = palette.fg[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeExpander', { fg = palette.grey_dim[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeRootName', { fg = palette.fg[1], bold = true })
        vim.api.nvim_set_hl(0, 'ComplHint', { fg = palette.grey[1], italic = true })
      end,
    })

    vim.cmd.colorscheme 'sonokai'
  end,
}
