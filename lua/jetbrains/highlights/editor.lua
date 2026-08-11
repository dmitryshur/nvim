-- Native editor / UI highlight groups.
local c = require 'jetbrains.palette'

return {
  ---------------------------------------------------------------- buffers --
  Normal = { fg = c.fg, bg = c.bg },
  NormalNC = { fg = c.fg, bg = c.bg },
  NormalFloat = { fg = c.fg_bright, bg = c.bg_panel },
  FloatBorder = { fg = c.border, bg = c.bg_panel },
  FloatTitle = { fg = c.fg_bright, bg = c.bg_panel, bold = true },
  FloatFooter = { fg = c.fg_dim, bg = c.bg_panel },

  Cursor = { fg = c.bg, bg = c.cursor },
  lCursor = { fg = c.bg, bg = c.cursor },
  CursorIM = { fg = c.bg, bg = c.cursor },
  TermCursor = { fg = c.bg, bg = c.cursor },
  TermCursorNC = { bg = c.bg_active },

  CursorLine = { bg = c.bg_cursorline },
  CursorColumn = { bg = c.bg_cursorline },
  ColorColumn = { bg = c.wrap_guide },
  Visual = { bg = c.selection },
  VisualNOS = { bg = c.selection },

  LineNr = { fg = c.line_nr },
  LineNrAbove = { fg = c.line_nr },
  LineNrBelow = { fg = c.line_nr },
  CursorLineNr = { fg = c.line_nr_active, bg = c.bg_cursorline },
  CursorLineSign = { bg = c.bg_cursorline },
  CursorLineFold = { bg = c.bg_cursorline },
  SignColumn = { fg = c.line_nr, bg = c.bg },
  FoldColumn = { fg = c.line_nr, bg = c.bg },
  Folded = { fg = c.comment, bg = c.bg_disabled },

  NonText = { fg = c.line_nr },
  Whitespace = { fg = c.line_nr },
  EndOfBuffer = { fg = c.bg },
  SpecialKey = { fg = c.fg_dim },
  Conceal = { fg = c.fg_dim },
  MatchParen = { bg = c.bg_active, bold = true },

  ----------------------------------------------------------------- search --
  Search = { bg = c.search },
  IncSearch = { bg = c.search_active },
  CurSearch = { bg = c.search_active },
  Substitute = { bg = c.search_active },

  -------------------------------------------------------------- statusline --
  StatusLine = { fg = c.fg_muted, bg = c.bg_panel },
  StatusLineNC = { fg = c.fg_dim, bg = c.bg_panel },
  WinBar = { fg = c.fg_muted, bg = c.bg },
  WinBarNC = { fg = c.fg_dim, bg = c.bg },
  WinSeparator = { fg = c.border, bg = c.bg },
  VertSplit = { fg = c.border, bg = c.bg },

  TabLine = { fg = c.fg_muted, bg = c.bg_panel },
  TabLineFill = { bg = c.bg_panel },
  TabLineSel = { fg = c.fg_bright, bg = c.bg },

  ------------------------------------------------------------------ popups --
  Pmenu = { fg = c.fg_bright, bg = c.bg_panel },
  PmenuSel = { bg = c.bg_selected, bold = true },
  PmenuKind = { fg = c.func, bg = c.bg_panel },
  PmenuKindSel = { fg = c.func, bg = c.bg_selected },
  PmenuExtra = { fg = c.fg_dim, bg = c.bg_panel },
  PmenuExtraSel = { fg = c.fg_muted, bg = c.bg_selected },
  PmenuSbar = { bg = c.bg_disabled },
  PmenuThumb = { bg = c.bg_active },
  PmenuMatch = { fg = c.link, bg = c.bg_panel, bold = true },
  PmenuMatchSel = { fg = c.link, bg = c.bg_selected, bold = true },
  WildMenu = { bg = c.bg_selected },

  ---------------------------------------------------------------- messages --
  ErrorMsg = { fg = c.error },
  WarningMsg = { fg = c.warning },
  MoreMsg = { fg = c.info },
  ModeMsg = { fg = c.fg_bright, bold = true },
  Question = { fg = c.info },
  MsgArea = { fg = c.fg },
  MsgSeparator = { fg = c.border, bg = c.bg_panel },

  ------------------------------------------------------------------- misc --
  Directory = { fg = c.fg_bright },
  Title = { fg = c.constant, bold = true },
  QuickFixLine = { bg = c.bg_selected },
  debugPC = { bg = c.info_bg },
  debugBreakpoint = { fg = c.error },

  SpellBad = { sp = c.error, undercurl = true },
  SpellCap = { sp = c.warning, undercurl = true },
  SpellLocal = { sp = c.info, undercurl = true },
  SpellRare = { sp = c.hint, undercurl = true },

  ------------------------------------------------------------------- diff --
  -- Backgrounds come from editor.diff_hunk.*; DiffText uses the word-level pair.
  --
  -- DiffChange is the third state: a line present on both sides but altered. Vim
  -- paints it on *both* panes with one group, so it must not be the add colour --
  -- that made the pre-change text on the left look inserted. The derived
  -- git_change_bg pair keeps green meaning "added" and nothing else.
  DiffAdd = { bg = c.git_add_bg },
  DiffDelete = { bg = c.git_delete_bg },
  DiffChange = { bg = c.git_change_bg },
  DiffText = { bg = c.git_word_change },
  diffAdded = { fg = c.git_add },
  diffRemoved = { fg = c.git_delete },
  diffChanged = { fg = c.git_change },
  diffFile = { fg = c.fg_bright, bold = true },
  diffLine = { fg = c.comment },
  diffIndexLine = { fg = c.fg_dim },
  diffOldFile = { fg = c.git_delete },
  diffNewFile = { fg = c.git_add },

  ------------------------------------------------------------ diagnostics --
  DiagnosticError = { fg = c.error },
  DiagnosticWarn = { fg = c.warning },
  DiagnosticInfo = { fg = c.info },
  DiagnosticHint = { fg = c.hint },
  DiagnosticOk = { fg = c.success },

  DiagnosticVirtualTextError = { fg = c.error, bg = c.error_bg },
  DiagnosticVirtualTextWarn = { fg = c.warning, bg = c.warning_bg },
  DiagnosticVirtualTextInfo = { fg = c.info, bg = c.info_bg },
  DiagnosticVirtualTextHint = { fg = c.hint, bg = c.hint_bg },
  DiagnosticVirtualTextOk = { fg = c.success, bg = c.success_bg },

  DiagnosticUnderlineError = { sp = c.error, undercurl = true },
  DiagnosticUnderlineWarn = { sp = c.warning, undercurl = true },
  DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
  DiagnosticUnderlineHint = { sp = c.hint, undercurl = true },
  DiagnosticUnderlineOk = { sp = c.success, undercurl = true },

  DiagnosticFloatingError = { fg = c.error, bg = c.bg_panel },
  DiagnosticFloatingWarn = { fg = c.warning, bg = c.bg_panel },
  DiagnosticFloatingInfo = { fg = c.info, bg = c.bg_panel },
  DiagnosticFloatingHint = { fg = c.hint, bg = c.bg_panel },
  DiagnosticFloatingOk = { fg = c.success, bg = c.bg_panel },

  DiagnosticSignError = { fg = c.error, bg = c.bg },
  DiagnosticSignWarn = { fg = c.warning, bg = c.bg },
  DiagnosticSignInfo = { fg = c.info, bg = c.bg },
  DiagnosticSignHint = { fg = c.hint, bg = c.bg },
  DiagnosticSignOk = { fg = c.success, bg = c.bg },

  DiagnosticDeprecated = { fg = c.fg_dim, strikethrough = true },
  DiagnosticUnnecessary = { fg = c.fg_dim },

  --------------------------------------------------------------------- lsp --
  LspReferenceText = { bg = c.ref_read },
  LspReferenceRead = { bg = c.ref_read },
  LspReferenceWrite = { bg = c.ref_write },
  LspReferenceTarget = { bg = c.ref_read },
  LspInlayHint = { fg = c.hint, bg = c.hint_bg },
  LspCodeLens = { fg = c.hint },
  LspCodeLensSeparator = { fg = c.line_nr },
  LspSignatureActiveParameter = { fg = c.fg_bright, bg = c.bg_selected, bold = true },
  LspInfoBorder = { fg = c.border, bg = c.bg_panel },
  ComplHint = { fg = c.fg_dim, italic = true },
  ComplHintMore = { fg = c.hint },

  --------------------------------------------------------------- snippets --
  SnippetTabstop = { bg = c.bg_selected },
  SnippetTabstopActive = { bg = c.selection },
}
