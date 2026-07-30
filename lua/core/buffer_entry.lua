-- Entry maker for the `<tab>` buffers picker, laid out like the reference picker:
-- filename, then where you left the cursor, then the directory dimmed behind it.
--
--   keymaps.lua ●          141  lua/core/
--   PortfolioTabItem.tsx    59  src/screens/Account/Portfolio/ActivePortfolioPage/
--
-- The stock gen_from_buffer leads with the buffer number and a four-character
-- status indicator, then crams `path:lnum` into one string. The buffer number
-- isn't useful when you pick by name, but the modified flag is -- so that survives
-- as a ● after the filename rather than as its own column.
--
-- gen_from_buffer does the work (bufnr, the cwd-relative name, a clamped lnum for
-- buffers that shrank since you left them) and only its display is swapped out,
-- the same way core.grep_entry wraps the vimgrep maker.

local columns = require 'core.picker_columns'

local SEPARATOR = '  '
local LNUM_WIDTH = 5

local filename_width = columns.share(0.34, 14, 34)

-- The directory takes what's left and sits last, so its padding is trailing
-- whitespace rather than a visible gap mid-row.
local build_displayer = columns.displayer {
  separator = SEPARATOR,
  links = {
    TelescopePickerFile = 'Directory',
    TelescopePickerPosition = 'Number',
    TelescopePickerDirectory = 'Comment',
  },
  items = {
    { width = filename_width },
    -- Right-justified so the numbers line up rather than drifting with the length
    -- of the name in front of them.
    { width = LNUM_WIDTH, right_justify = true },
    { width = columns.remaining({ filename_width, LNUM_WIDTH }, #SEPARATOR * 2) },
  },
}

local function make_display(entry)
  local relative = entry.filename
  local directory = vim.fn.fnamemodify(relative, ':h')

  -- `indicator` is flag/hidden/readonly/changed; only the last is worth a glance.
  local modified = (entry.indicator or ''):find '%+' and ' ●' or ''

  return build_displayer() {
    { vim.fn.fnamemodify(relative, ':t') .. modified, 'TelescopePickerFile' },
    -- 0 means telescope had no position for it, which reads better as blank than
    -- as a line number that doesn't exist.
    { entry.lnum and entry.lnum > 0 and tostring(entry.lnum) or '', 'TelescopePickerPosition' },
    { directory == '.' and '' or directory .. '/', 'TelescopePickerDirectory' },
  }
end

-- Keyed by cwd because gen_from_buffer captures it at construction: a single
-- cached maker would keep resolving names against whichever directory happened to
-- be current the first time the picker opened.
local makers = {}

local function base_maker()
  local cwd = vim.uv.cwd()
  makers[cwd] = makers[cwd] or require('telescope.make_entry').gen_from_buffer { cwd = cwd }
  return makers[cwd]
end

local M = {}

function M.entry_maker(entry)
  local made = base_maker()(entry)
  if not made then return nil end

  made.display = make_display
  return made
end

return M
