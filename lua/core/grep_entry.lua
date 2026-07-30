-- Entry maker for the live_grep picker.
--
-- gen_from_vimgrep builds each row with a bare `string.format("%s%s%s", path,
-- ":lnum:col:", text)` and no displayer, so nothing aligns; and ripgrep emits the
-- matched line with its original indentation, so a deeply nested match starts far
-- to the right of everything around it. Three aligned columns instead:
--
--   42:8    const holdings = usePortfolio()          Portfolio.tsx
--   118:3   export function formatHoldings(x)         utils.ts
--   204:12  <PortfolioTable holdings={holdings} on…   ActivePortfolioPageHeader.tsx
--
-- The filename is last so that it is the one thing never shortened; see
-- TEXT_SHARE below.
--
-- The text is trimmed for the display only. `lnum` and `col` stay exactly as
-- ripgrep reported them so the jump still lands on the match -- which is why the
-- trimming happens here rather than by passing `--trim` to ripgrep, where the
-- reported column would no longer agree with the line it was measured against.
--
-- Only the filename is shown, no directory: the preview pane names the file, and
-- the width is better spent on the matched code.

local SEPARATOR = '  '
local POSITION_WIDTH = 7

-- The matched line is the only text column given a width, which makes it the only
-- one the displayer truncates. The filename is last with no width at all, so it is
-- neither padded nor cut: a long name prints in full and, at worst, runs past the
-- edge of the results window.
--
-- That is also why the code column takes a *share* rather than the leftovers --
-- the remainder is what leaves room for the filename to be printed whole.
local TEXT_MIN, TEXT_SHARE = 20, 0.55

local DEFAULT_LINKS = {
  TelescopeGrepFile = 'Directory',
  TelescopeGrepPosition = 'Number',
  TelescopeGrepText = 'Identifier',
}

local function text_width(_, max_columns)
  return math.max(TEXT_MIN, math.floor(max_columns * TEXT_SHARE))
end

local links_applied = false

-- Built per row: telescope's displayer resolves each column width once and keeps
-- it, so a shared instance would go on using the width it measured in the first
-- picker it rendered.
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
      { width = POSITION_WIDTH },
      { width = text_width },
      -- No width: never padded, never truncated.
      { remaining = true },
    },
  }
end

local function make_display(entry)
  return build_displayer() {
    -- Defaulted: a nil here would throw inside the render loop, which telescope
    -- reports as a bare "Finder failed" with no usable context.
    { (entry.lnum or 0) .. ':' .. (entry.col or 0), 'TelescopeGrepPosition' },
    { vim.trim(entry.text or ''), 'TelescopeGrepText' },
    { vim.fn.fnamemodify(entry.filename, ':t'), 'TelescopeGrepFile' },
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
