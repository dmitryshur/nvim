-- Shared plumbing for the custom telescope entry makers -- the reference, grep,
-- harpoon and buffer pickers all draw rows the same way, and this is the part that
-- was identical in each of them.
--
-- Telescope resolves a column width once per displayer, against the live results
-- window, which is why widths are functions of `max_columns` rather than numbers,
-- and why a displayer has to be built per row rather than cached: a shared one
-- would keep using the width it measured in the first picker it ever rendered.

local M = {}

--- A column width that scales with the window: `fraction` of it, clamped. The
--- clamp is what keeps a filename column readable on a narrow pane without letting
--- it grow past any name that actually exists.
---@param fraction number
---@param min integer
---@param max integer|nil defaults to unbounded
function M.share(fraction, min, max)
  max = max or math.huge
  return function(_, max_columns)
    return math.max(min, math.min(max, math.floor(max_columns * fraction)))
  end
end

--- A column that takes whatever the others leave. `taken` holds the other columns'
--- widths -- plain numbers, or width functions to resolve -- and `separators` the
--- total width of the gaps between them.
---@param taken (integer|fun(self: any, max_columns: integer): integer)[]
---@param separators integer
---@param min integer|nil
function M.remaining(taken, separators, min)
  return function(self, max_columns)
    local used = separators

    for _, width in ipairs(taken) do
      used = used + (type(width) == 'function' and width(self, max_columns) or width)
    end

    return math.max(min or 8, max_columns - used)
  end
end

--- Returns a function that builds the row's displayer.
---
--- `links` are applied on first use rather than at file scope: with `default =
--- true` a colorscheme that defines these wins, and the targets should be
--- foreground-only groups, since a background would tint one cell differently to
--- the rest of the row.
---@param spec { separator: string, items: table[], links: table<string, string>|nil }
function M.displayer(spec)
  local links_applied = false

  return function()
    if not links_applied then
      for group, target in pairs(spec.links or {}) do
        vim.api.nvim_set_hl(0, group, { link = target, default = true })
      end
      links_applied = true
    end

    return require('telescope.pickers.entry_display').create {
      separator = spec.separator,
      items = spec.items,
    }
  end
end

return M
