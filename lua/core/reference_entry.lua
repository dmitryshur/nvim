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
-- The displayer is built per row rather than at file scope: telescope resolves
-- column widths from the live picker's results window, so `create` is only
-- meaningful once a picker exists.

local SEPARATOR = '  '

-- Fits `1234:56`. Left-justified, so its slack falls before the directory rather
-- than before the number.
local POSITION_WIDTH = 7

-- Filename is the column that has to be a stable width -- it's what the eye runs
-- down -- so it gets a share of the window, clamped to stay sane on a narrow
-- results pane and to stop growing once it's wider than any real name.
local FILENAME_MIN, FILENAME_MAX, FILENAME_SHARE = 14, 30, 0.32

local function filename_width(_, max_columns)
  return math.max(FILENAME_MIN, math.min(FILENAME_MAX, math.floor(max_columns * FILENAME_SHARE)))
end

-- The directory takes everything left over. It's last on the row on purpose:
-- it's the variable-length column, so as the *last* one its padding is trailing
-- whitespace, which is invisible.
local function directory_width(self, max_columns)
  local used = filename_width(self, max_columns) + POSITION_WIDTH + (#SEPARATOR * 2)
  return math.max(8, max_columns - used)
end


-- Linked with `default = true`, so a colorscheme that defines these wins while
-- the picker still stays readable under one that has never heard of them. The
-- targets are all foreground-only groups: anything carrying a background would
-- paint its cell a different colour than the rest of the row.
local DEFAULT_LINKS = {
  TelescopeReferenceFile = 'Directory',
  TelescopeReferenceDirectory = 'Comment',
  TelescopeReferencePosition = 'Number',
}

local links_applied = false

-- Built per row rather than cached: telescope's displayer resolves each column
-- width once and then keeps it for its own lifetime, so a shared instance would
-- go on using the width it measured in the first picker it ever rendered --
-- wrong as soon as the window is a different size.
local function build_displayer()
  if not links_applied then
    for group, target in pairs(DEFAULT_LINKS) do
      vim.api.nvim_set_hl(0, group, { link = target, default = true })
    end
    links_applied = true
  end

  return require('telescope.pickers.entry_display').create {
    separator = SEPARATOR,
    items = {
      { width = filename_width },
      { width = POSITION_WIDTH },
      { width = directory_width },
    },
  }
end

-- Both columns are handed to the displayer untruncated: it truncates to whatever
-- the resolved width turns out to be, which is the only place that knows it.
local function make_display(entry)
  local relative = vim.fn.fnamemodify(entry.filename, ':.')
  local directory = vim.fn.fnamemodify(relative, ':h')

  return build_displayer() {
    { vim.fn.fnamemodify(relative, ':t'), 'TelescopeReferenceFile' },
    -- Defaulted: a nil here would throw inside the render loop, which telescope
    -- reports as a bare "Finder failed" with no usable context.
    { (entry.lnum or 0) .. ':' .. (entry.col or 0), 'TelescopeReferencePosition' },
    { directory == '.' and '' or directory .. '/', 'TelescopeReferenceDirectory' },
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
