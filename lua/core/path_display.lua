-- A `path_display` function for telescope.
--
-- The point is that it hands the path back *unchanged* and only returns a style.
-- Telescope scores `entry.ordinal` -- the full path -- but computes match
-- highlights against whatever the display turned out to be (pickers.lua, at the
-- `hi_sorter` call). Any path_display that rewrites the string breaks that pair:
--
--   * `smart` chops leading directories, so a prompt matching the part it
--     removed leaves a row that is listed but has nothing to mark. That is the
--     "why did this match?" case.
--   * `filename_first` reorders the string, so the marked characters aren't
--     necessarily the ones that scored.
--
-- Handing back the same string that was scored means the highlight always
-- explains the match. The directory still recedes, just via a highlight rather
-- than by deleting text.

local M = {}

--- Telescope calls this before its own absolute -> relative step, so that has to
--- happen here or pickers handing over absolute paths (`buffers`, the LSP symbol
--- pickers) would start rendering full paths. Mirrors utils' own `path_abs`.
local function relative(path, opts)
  local cwd = opts and opts.cwd or nil
  if cwd and not vim.in_fast_event() then cwd = vim.fn.expand(cwd) end
  return require('plenary.path'):new(path):make_relative(cwd or vim.uv.cwd())
end

--- @return string path, table style
function M.dim_directory(opts, path)
  local display = relative(path, opts)

  -- Byte offset one past the final separator, i.e. the length of the directory
  -- part including its trailing slash. `find` is 1-based, and the ranges here are
  -- 0-based with an exclusive end, which works out to the same number.
  local directory_end = display:find '/[^/]*$'
  if not directory_end then return display, {} end

  -- Offsets are relative to the path alone; gen_from_file shifts them along for
  -- the devicon itself via utils.merge_styles.
  return display, { { { 0, directory_end }, 'TelescopeResultsComment' } }
end

return M
