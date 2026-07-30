-- A local colorscheme ported from Zed's "JetBrains Dark" theme.
-- Entry point is `colors/jetbrains.lua`, so `:colorscheme jetbrains` just works.
local palette = require 'jetbrains.palette'
local utils = require 'jetbrains.utils'

local MODULES = {
  'jetbrains.highlights.editor',
  'jetbrains.highlights.syntax',
  'jetbrains.highlights.plugins',
}

local M = {}

M.palette = palette

function M.load()
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' == 1 then vim.cmd 'syntax reset' end

  vim.o.termguicolors = true
  vim.o.background = 'dark'
  vim.g.colors_name = 'jetbrains'

  for _, module in ipairs(MODULES) do
    -- Dropped from the cache so editing a highlight file and re-running
    -- `:colorscheme jetbrains` picks the change up without restarting.
    package.loaded[module] = nil
    utils.apply(require(module))
  end

  utils.set_terminal_colors(palette.terminal)
end

return M
