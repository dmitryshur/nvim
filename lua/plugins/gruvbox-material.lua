return {
  'sainnhe/gruvbox-material',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    vim.g.gruvbox_material_background = 'medium'
    vim.g.gruvbox_material_foreground = 'material'

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('gruvbox-material-custom-highlights', { clear = true }),
      pattern = 'gruvbox-material',
      callback = function()
        local config = vim.fn['gruvbox_material#get_configuration']()
        local palette = vim.fn['gruvbox_material#get_palette'](config.background, config.foreground, config.colors_override)

        vim.api.nvim_set_hl(0, 'NeoTreeNormal', { fg = palette.fg0[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { fg = palette.fg0[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeEndOfBuffer', { fg = palette.bg0[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeWinSeparator', { fg = palette.bg1[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeIndentMarker', { fg = palette.bg1[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = palette.grey0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { fg = palette.fg0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeExpander', { fg = palette.grey0[1] })
        vim.api.nvim_set_hl(0, 'NeoTreeRootName', { fg = palette.fg0[1], bold = true })
        vim.api.nvim_set_hl(0, 'ComplHint', { fg = palette.grey0[1], italic = true })
        vim.api.nvim_set_hl(0, 'FFFNormal', { fg = palette.fg0[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'FFFBorder', { fg = palette.bg2[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'FFFTitle', { fg = palette.fg0[1], bg = palette.bg0[1], bold = true })
        vim.api.nvim_set_hl(0, 'FFFCursor', { fg = palette.fg0[1], bg = palette.bg1[1] })
      end,
    })

    vim.cmd.colorscheme 'gruvbox-material'
  end,
}
