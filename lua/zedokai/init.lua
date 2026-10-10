-- A local colorscheme ported from Zed's "Zedokai Darker (Filter Spectrum)" theme.
-- Entry point is `colors/zedokai.lua`, so `:colorscheme zedokai` just works.
local palette = require 'zedokai.palette'

local MODULES = {
  'zedokai.highlights.editor',
  'zedokai.highlights.syntax',
  'zedokai.highlights.plugins',
}

local M = {}

M.palette = palette

function M.load()
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' == 1 then
    vim.cmd 'syntax reset'
  end

  vim.o.termguicolors = true
  vim.o.background = 'dark'
  vim.g.colors_name = 'zedokai'

  for _, module in ipairs(MODULES) do
    -- Dropped from the cache so editing a highlight file and re-running
    -- `:colorscheme zedokai` picks the change up without restarting.
    package.loaded[module] = nil
    for group, spec in pairs(require(module)) do
      vim.api.nvim_set_hl(0, group, spec)
    end
  end

  for index, color in ipairs(palette.terminal) do
    vim.g['terminal_color_' .. (index - 1)] = color
  end
end

return M
