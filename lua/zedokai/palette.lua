-- Zedokai palette, ported from the "Zedokai Darker (Filter Spectrum)" variant of
-- the Zed theme -- the variant ~/.config/zed/settings.json selects:
--   ~/.local/share/zed/extensions/installed/zedokai/themes/zedokai.json
-- Keys are grouped the way the Zed theme groups them so the two stay comparable.
-- Zed paints several surfaces with a translucent white wash (#f7f1ffXX); those are
-- flattened onto the editor background here, since a highlight group can't blend.

-- Monokai Pro's Spectrum hues. Every syntax colour in the theme is one of these
-- six, so the syntax keys further down only say which one each Zed scope uses.
local red = '#fc618d'
local orange = '#fd9353'
local yellow = '#fce566'
local green = '#7bd88f'
local blue = '#5ad4e6'
local purple = '#948ae3'

-- Monokai Pro's greys, brightest to darkest (its dimmed1 .. dimmed5).
local fg = '#f7f1ff'
local dimmed1 = '#bab6c0'
local dimmed2 = '#8b888f'
local dimmed3 = '#69676c'
local dimmed4 = '#525053'
local dimmed5 = '#363537'

return {
  ---------------------------------------------------------------- surfaces --
  bg = '#222222', -- editor.background
  bg_panel = '#1c1c1c', -- panel / status bar / tab bar / elevated_surface
  -- element.background. Zed marks a selected row with ghost_element.selected, a
  -- 5% white wash (#262627 on a panel) -- too faint for a terminal popup, so
  -- menus and pickers select with the element colour instead.
  bg_element = dimmed5,
  bg_cursorline = '#2c2c2c', -- editor.active_line.background (#f7f1ff0c)
  bg_scrollbar = '#39383a', -- scrollbar.thumb.background (#bab6c026)

  border = '#0f0f0f', -- border / pane_group.border
  border_focused = dimmed3, -- border.focused
  -- DERIVED: the theme's #0f0f0f border all but vanishes against #1c1c1c floats.
  border_float = dimmed4,

  ------------------------------------------------------------------- text --
  fg = fg, -- editor.foreground / text
  fg_dim = dimmed1,
  fg_muted = dimmed2, -- text.muted
  line_nr = dimmed4, -- editor.line_number
  line_nr_active = fg, -- editor.active_line_number
  accent = yellow, -- text.accent

  ------------------------------------------------------- editor highlights --
  selection = '#383739', -- players[0].selection (#f7f1ff1a)
  cursor = fg,
  search = '#383838', -- search.match_background
  ref_read = '#383838', -- document_highlight.read_background

  ----------------------------------------------------------------- status --
  error = red,
  warning = orange,
  info = yellow,
  hint = dimmed2,
  success = green, -- no status colour in the theme; `created` is the nearest
  status_bg = '#1c1c1c', -- error/warning/info/hint.background, all the same
  conflict = orange,
  ignored = dimmed4,
  hidden = dimmed2,
  created = green,
  deleted = red,
  modified = orange,

  --------------------------------------------------------- version control --
  -- The theme leaves version_control.* to Zed's defaults; these three come from
  -- the theme_overrides in ~/.config/zed/settings.json, so the gutter matches.
  git_add = '#5fa967',
  git_change = '#548af7',
  git_delete = '#c9635a',
  -- DERIVED: the theme has no diff_hunk backgrounds. These are the three hues
  -- above over #222222 -- 12% for a changed line, 25% for the changed words.
  git_add_bg = '#29322a',
  git_change_bg = '#282e3c',
  git_delete_bg = '#362a29',
  git_word_add = '#314433',
  git_word_change = '#2e3c57',
  git_word_delete = '#4c3230',

  ----------------------------------------------------------------- syntax --
  keyword = red, -- keyword
  operator = red, -- operator
  tag = red, -- tag
  func = green, -- function
  label = green, -- label
  string = yellow, -- string / string.regex / text.literal
  string_special = orange, -- string.special / string.special.symbol
  string_escape = fg, -- string.escape
  constant = purple, -- constant / number / boolean
  preproc = purple, -- preproc
  type = blue, -- type
  attribute = blue, -- attribute (italic in Zed)
  variable = fg, -- variable
  var_special = dimmed1, -- variable.special (italic in Zed)
  property = fg, -- property
  punctuation = dimmed2, -- punctuation.*
  comment = dimmed3, -- comment / comment.doc (italic in Zed)
  title = yellow, -- title
  link_text = red, -- link_text
  link_uri = green, -- link_uri

  --------------------------------------------------------------- terminal --
  -- Ordered 0-15 for vim.g.terminal_color_*, from terminal.ansi.* -- including
  -- Monokai's quirk of an orange "blue".
  terminal = {
    dimmed5, -- 0  black
    red, -- 1  red
    green, -- 2  green
    yellow, -- 3  yellow
    orange, -- 4  blue
    purple, -- 5  magenta
    blue, -- 6  cyan
    fg, -- 7  white
    dimmed3, -- 8  bright black
    red, -- 9  bright red
    green, -- 10 bright green
    yellow, -- 11 bright yellow
    orange, -- 12 bright blue
    purple, -- 13 bright magenta
    blue, -- 14 bright cyan
    fg, -- 15 bright white
  },
}
