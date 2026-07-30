-- Entry maker for the live_grep picker.
--
-- gen_from_vimgrep builds each row with a bare `string.format("%s%s%s", path,
-- ":lnum:col:", text)` and no displayer, so nothing aligns; and ripgrep emits the
-- matched line with its original indentation, so a deeply nested match starts far
-- to the right of everything around it. Three aligned columns instead:
--
--   Portfolio.tsx         42:8    const holdings = usePortfolio()
--   utils.ts             118:3    export function formatHoldings(x)
--   PortfolioHeader.tsx  204:12   <PortfolioTable holdings={holdings} onSo…
--
-- The text is trimmed for the display only. `lnum` and `col` stay exactly as
-- ripgrep reported them so the jump still lands on the match -- which is why the
-- trimming happens here rather than by passing `--trim` to ripgrep, where the
-- reported column would no longer agree with the line it was measured against.
--
-- Only the filename is shown, no directory: the preview pane names the file, and
-- the width is better spent on the matched code.

local columns = require 'core.picker_columns'

local SEPARATOR = '  '
local POSITION_WIDTH = 7

-- Filename leads, so the eye runs down a single column of names. It is generous
-- on purpose -- the matched line is what should give way when the row runs out of
-- room -- but it is a fixed width, so a name longer than the column still gets
-- cut: alignment means every row shares one width, and some cap has to exist.
local filename_width = columns.share(0.35, 16, 40)

local build_displayer = columns.displayer {
  separator = SEPARATOR,
  links = {
    TelescopePickerFile = 'Directory',
    TelescopePickerPosition = 'Number',
    TelescopePickerText = 'Identifier',
  },
  items = {
    { width = filename_width },
    { width = POSITION_WIDTH },
    -- Last, so the code takes whatever is left and its padding is invisible
    -- trailing whitespace.
    { width = columns.remaining({ filename_width, POSITION_WIDTH }, #SEPARATOR * 2, 10) },
  },
}

local function make_display(entry)
  return build_displayer() {
    { vim.fn.fnamemodify(entry.filename, ':t'), 'TelescopePickerFile' },
    -- Defaulted: a nil here would throw inside the render loop, which telescope
    -- reports as a bare "Finder failed" with no usable context.
    { (entry.lnum or 0) .. ':' .. (entry.col or 0), 'TelescopePickerPosition' },
    { vim.trim(entry.text or ''), 'TelescopePickerText' },
  }
end

-- Telescope hands an entry maker the raw ripgrep line, so rather than re-parse
-- `path:lnum:col:text` here, the stock maker does the parsing (lazily, per field)
-- and only its `display` is swapped out.
--
-- Keyed by cwd because gen_from_vimgrep captures it at construction: a single
-- cached maker would keep resolving paths against whichever directory happened to
-- be current the first time you grepped.
local makers = {}

local function base_maker()
  local cwd = vim.uv.cwd()
  makers[cwd] = makers[cwd] or require('telescope.make_entry').gen_from_vimgrep { cwd = cwd }
  return makers[cwd]
end

local M = {}

function M.entry_maker(line)
  local entry = base_maker()(line)
  if not entry then return nil end

  entry.display = make_display
  return entry
end

return M
