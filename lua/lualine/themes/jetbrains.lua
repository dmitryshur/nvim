-- lualine theme matching the local `jetbrains` colorscheme.
-- lualine's `theme = 'auto'` looks for a theme named after vim.g.colors_name
-- before falling back to its generator, so this file gets picked up as-is.
local c = require 'jetbrains.palette'

local function mode(color)
  return {
    a = { fg = c.bg, bg = color, gui = 'bold' },
    b = { fg = c.fg_bright, bg = c.bg_element },
    c = { fg = c.fg_muted, bg = c.bg_panel },
  }
end

return {
  normal = mode(c.accent),
  insert = mode(c.git_add),
  visual = mode(c.constant),
  replace = mode(c.deleted),
  command = mode(c.warning),
  terminal = mode(c.type_param),
  inactive = {
    a = { fg = c.fg_dim, bg = c.bg_panel },
    b = { fg = c.fg_dim, bg = c.bg_panel },
    c = { fg = c.line_nr, bg = c.bg_panel },
  },
}
