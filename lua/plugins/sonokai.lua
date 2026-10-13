-- `amount` of `fg` mixed into `bg`, both '#rrggbb'.
local function blend(fg, bg, amount)
  local function channel(i)
    local f, b = tonumber(fg:sub(i, i + 1), 16), tonumber(bg:sub(i, i + 1), 16)
    return math.floor(b + (f - b) * amount + 0.5)
  end
  return string.format('#%02x%02x%02x', channel(2), channel(4), channel(6))
end

return {
  'sainnhe/sonokai',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'
    vim.g.sonokai_style = 'default'
    vim.g.sonokai_colors_override = {
      bg0 = { '#23252a', '235' },
    }

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
        vim.api.nvim_set_hl(0, 'FFFNormal', { fg = palette.fg[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'FFFBorder', { fg = palette.bg2[1], bg = palette.bg0[1] })
        vim.api.nvim_set_hl(0, 'FFFTitle', { fg = palette.fg[1], bg = palette.bg0[1], bold = true })
        vim.api.nvim_set_hl(0, 'FFFCursor', { fg = palette.fg[1], bg = palette.bg1[1] })
        -- Word-level add/delete for gitsigns' word diff and CodeDiff
        -- (plugins/codediff.lua). sonokai leaves them to gitsigns, whose fallback
        -- is TermCursor -- reverse video, a white block on every changed word.
        -- The DiffAdd / DiffDelete backgrounds with a fifth of green / red mixed in.
        vim.api.nvim_set_hl(0, 'GitSignsAddInline', { bg = blend(palette.green[1], palette.bg_green[1], 0.2) })
        vim.api.nvim_set_hl(0, 'GitSignsDeleteInline', { bg = blend(palette.red[1], palette.bg_red[1], 0.2) })
      end,
    })

    vim.cmd.colorscheme 'sonokai'
  end,
}
