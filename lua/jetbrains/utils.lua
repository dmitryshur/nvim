local M = {}

--- Apply a `{ [group] = spec }` table via nvim_set_hl.
function M.apply(groups)
  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

--- Populate vim.g.terminal_color_0 .. 15 from an ordered list of 16 colors.
function M.set_terminal_colors(colors)
  for index, color in ipairs(colors) do
    vim.g['terminal_color_' .. (index - 1)] = color
  end
end

return M
