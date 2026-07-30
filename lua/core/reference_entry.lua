-- Entry maker for the `gr` (LSP references) telescope picker.
--
-- Telescope's stock version, make_entry.gen_from_quickfix, formats every row as
-- one flat string -- `path:lnum:col:text` -- built without a displayer. Nothing
-- lines up, the code keeps its full leading indentation, and the only fragment
-- that ever gets its own highlight is the path, and then only under
-- `path_display = { 'filename_first' }`. Under any other path_display the whole
-- row renders in a single colour, which is what makes the path and the code
-- impossible to tell apart at a glance.
--
-- This drops the code -- the picker has a preview window showing the selected
-- reference in context and syntax highlighted, so it was being said twice -- and
-- lays out what's left in three columns:
--
--   keymaps.lua     141:11  lua/core/
--   lsp.lua          39:9   lua/plugins/
--   constants.ts     42:18  src/screens/Account/Portfolio/ActivePor…
--
-- Both text columns are handed over untruncated: the displayer cuts them to the
-- resolved width, which is the only place that knows it, and cuts at the end --
-- so a path too deep to fit keeps its head and loses its tail.
--
-- The line text is still in `ordinal`, so it stays fuzzy-searchable: you can
-- type a fragment of a line to narrow the list without having to look at it.
--
-- Column plumbing (widths, the displayer, the fallback links) is shared with the
-- other custom pickers; see core.picker_columns.

local columns = require 'core.picker_columns'

local SEPARATOR = '  '

-- Fits `1234:56`. Left-justified, so its slack falls before the directory rather
-- than before the number.
local POSITION_WIDTH = 7

-- Filename is the column that has to be a stable width -- it's what the eye runs
-- down. The directory takes everything left over and sits last, so its padding is
-- trailing whitespace rather than a visible gap.
local filename_width = columns.share(0.32, 14, 30)

local build_displayer = columns.displayer {
  separator = SEPARATOR,
  links = {
    TelescopePickerFile = 'Directory',
    TelescopePickerDirectory = 'Comment',
    TelescopePickerPosition = 'Number',
  },
  items = {
    { width = filename_width },
    { width = POSITION_WIDTH },
    { width = columns.remaining({ filename_width, POSITION_WIDTH }, #SEPARATOR * 2) },
  },
}

local function make_display(entry)
  local relative = vim.fn.fnamemodify(entry.filename, ':.')
  local directory = vim.fn.fnamemodify(relative, ':h')

  return build_displayer() {
    { vim.fn.fnamemodify(relative, ':t'), 'TelescopePickerFile' },
    -- Defaulted: a nil here would throw inside the render loop, which telescope
    -- reports as a bare "Finder failed" with no usable context.
    { (entry.lnum or 0) .. ':' .. (entry.col or 0), 'TelescopePickerPosition' },
    { directory == '.' and '' or directory .. '/', 'TelescopePickerDirectory' },
  }
end

local M = {}

--- Telescope uses `opts.entry_maker` as-is, so this is the entry maker itself
--- rather than a generator that returns one.
function M.entry_maker(entry)
  local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)

  return require('telescope.make_entry').set_default_entry_mt({
    value = entry,
    -- Deliberately still carries the line's text even though it isn't drawn:
    -- what you can search and what you can see don't have to be the same thing.
    ordinal = filename .. ' ' .. (entry.text or ''),
    display = make_display,

    bufnr = entry.bufnr,
    filename = filename,
    lnum = entry.lnum,
    col = entry.col,
    text = entry.text,
    start = entry.start,
    finish = entry.finish,
  }, {})
end

return M
