-- JetBrains Dark palette, ported from the Zed theme:
--   ~/.local/share/zed/extensions/installed/jetbrains-themes/themes/jetbrains-dark.json
-- Keys are grouped the way the Zed theme groups them so the two stay comparable.

return {
  ---------------------------------------------------------------- surfaces --
  bg = '#1e1f22', -- editor.background
  bg_panel = '#26282b', -- panel / status bar / tab bar / floats
  bg_element = '#393b41', -- element.background
  bg_hover = '#3c3e41',
  bg_active = '#494a4d',
  bg_selected = '#43454a',
  bg_disabled = '#2b2d30',
  bg_cursorline = '#26282e', -- editor.active_line.background
  bg_inactive_title = '#3c3f41',

  border = '#393b41',
  border_focused = '#467ff2',
  border_selected = '#3474f0',

  ------------------------------------------------------------------- text --
  fg = '#bcbec4', -- editor.foreground
  fg_bright = '#dfe1e5', -- text
  fg_muted = '#b0b1b3',
  fg_dim = '#6f737a', -- text.placeholder / editor.invisible
  line_nr = '#4b5059',
  line_nr_active = '#a1a3ab',
  wrap_guide = '#393b40',

  accent = '#3474f0',
  link = '#548af7',

  ------------------------------------------------------- editor highlights --
  selection = '#214283', -- players[0].selection
  cursor = '#ced0d6',
  search = '#114957',
  search_active = '#2d543f',
  line_highlight = '#2d543f',
  ref_read = '#373b39', -- document_highlight.read
  ref_write = '#402f33', -- document_highlight.write

  ----------------------------------------------------------------- status --
  error = '#fa6675',
  error_bg = '#402929',
  warning = '#f2c55c',
  warning_bg = '#665014',
  info = '#3592c4',
  info_bg = '#393b41',
  success = '#57965d',
  success_bg = '#253627',
  hint = '#868a91',
  hint_bg = '#2d2e32',
  hint_border = '#5a5d63',
  conflict = '#e0bb65',
  ignored = '#808080',
  hidden = '#6f737a',

  --------------------------------------------------------- version control --
  git_add = '#549159',
  git_change = '#375fad',
  git_delete = '#a75749',
  git_add_bg = '#1f2b26', -- diff_hunk.added
  git_delete_bg = '#2b2322', -- diff_hunk.deleted
  git_word_add = '#294436', -- version_control.word_added
  git_word_delete = '#45302b', -- version_control.word_deleted
  -- DERIVED, not from the Zed theme -- the only two colours in this file that
  -- aren't. Zed has no diff_hunk.modified background because it renders a change
  -- as separate add and delete hunks; vim's side-by-side diff has a third state,
  -- DiffChange, shown on *both* panes at once. Painting it with git_add_bg made
  -- the old text on the left read as an addition. Tinted from git_change
  -- (#375fad, version_control.modified) at the same weight as the pair above.
  git_change_bg = '#1f2530',
  git_word_change = '#26344a',
  created = '#73bd7a',
  deleted = '#f75464',
  modified = '#70aeff',

  ----------------------------------------------------------------- syntax --
  keyword = '#cf8e6d',
  control = '#cc7832', -- operator.controlFlow (bold in Zed)
  string = '#6aab73',
  comment = '#7a7e85',
  doc = '#5f826b',
  number = '#2aacb8',
  constant = '#c77dbb',
  property = '#c77dbb',
  func = '#6aa2d7',
  func_special = '#d5a563',
  type = '#a6bb77',
  interface = '#8d91dc',
  enum_member = '#8cc8d4',
  type_param = '#3cacac',
  attribute = '#b3ae60',
  tag = '#d5b778',
  variable = '#bcbec4',
  var_special = '#e59eae',
  constructor = '#57aaf7',
  lifetime = '#20999d',
  link_text = '#56a8f5',
  link_uri = '#57aaf7',
  punct_special = '#b3ae60',

  --------------------------------------------------------------- terminal --
  -- Ordered 0-15 for vim.g.terminal_color_*, from terminal.ansi.*
  terminal = {
    '#000000', -- 0  black
    '#f27481', -- 1  red
    '#6bcc62', -- 2  green
    '#e0ce70', -- 3  yellow
    '#5594fa', -- 4  blue
    '#c092fa', -- 5  magenta
    '#47ccbd', -- 6  cyan
    '#ced0d6', -- 7  white
    '#4e5157', -- 8  bright black
    '#ff6b7a', -- 9  bright red
    '#67ff59', -- 10 bright green
    '#ffec1a', -- 11 bright yellow
    '#3399ff', -- 12 bright blue
    '#d970ff', -- 13 bright magenta
    '#40ffe9', -- 14 bright cyan
    '#ffffff', -- 15 bright white
  },
}
