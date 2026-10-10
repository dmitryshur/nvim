-- Native editor / UI highlight groups.
local c = require 'zedokai.palette'

return {
  ---------------------------------------------------------------- buffers --
  Normal = { fg = c.fg, bg = c.bg },
  NormalNC = { fg = c.fg, bg = c.bg },
  NormalFloat = { fg = c.fg, bg = c.bg_panel },
  FloatBorder = { fg = c.border_float, bg = c.bg_panel },
  FloatTitle = { fg = c.fg, bg = c.bg_panel, bold = true },
  FloatFooter = { fg = c.fg_muted, bg = c.bg_panel },

  Cursor = { fg = c.bg, bg = c.cursor },
  lCursor = { fg = c.bg, bg = c.cursor },
  CursorIM = { fg = c.bg, bg = c.cursor },
  TermCursor = { fg = c.bg, bg = c.cursor },
  TermCursorNC = { bg = c.bg_element },

  CursorLine = { bg = c.bg_cursorline },
  CursorColumn = { bg = c.bg_cursorline },
  ColorColumn = { bg = c.bg_panel }, -- editor.wrap_guide is #0f0f0f: a line in Zed, a black slab here
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
  Folded = { fg = c.comment, bg = c.bg_panel },

  NonText = { fg = c.line_nr },
  Whitespace = { fg = c.line_nr },
  EndOfBuffer = { fg = c.bg },
  SpecialKey = { fg = c.fg_muted },
  Conceal = { fg = c.fg_muted },
  MatchParen = { bg = c.bg_element, bold = true },

  ----------------------------------------------------------------- search --
  -- Zed has only the one match colour, and it's the selection colour too. The
  -- current match gets the accent so it stands out from the rest -- DERIVED.
  Search = { bg = c.search },
  IncSearch = { fg = c.bg, bg = c.accent },
  CurSearch = { fg = c.bg, bg = c.accent },
  Substitute = { fg = c.bg, bg = c.accent },

  -------------------------------------------------------------- statusline --
  StatusLine = { fg = c.fg_muted, bg = c.bg_panel },
  StatusLineNC = { fg = c.line_nr, bg = c.bg_panel },
  WinBar = { fg = c.fg_muted, bg = c.bg },
  WinBarNC = { fg = c.line_nr, bg = c.bg },
  WinSeparator = { fg = c.border, bg = c.bg },
  VertSplit = { fg = c.border, bg = c.bg },

  TabLine = { fg = c.fg_muted, bg = c.bg_panel },
  TabLineFill = { bg = c.bg_panel },
  TabLineSel = { fg = c.fg, bg = c.bg },

  ------------------------------------------------------------------ popups --
  Pmenu = { fg = c.fg, bg = c.bg_panel },
  PmenuSel = { bg = c.bg_element, bold = true },
  PmenuKind = { fg = c.func, bg = c.bg_panel },
  PmenuKindSel = { fg = c.func, bg = c.bg_element },
  PmenuExtra = { fg = c.fg_muted, bg = c.bg_panel },
  PmenuExtraSel = { fg = c.fg_dim, bg = c.bg_element },
  PmenuSbar = { bg = c.bg_panel },
  PmenuThumb = { bg = c.bg_scrollbar },
  PmenuMatch = { fg = c.accent, bg = c.bg_panel, bold = true },
  PmenuMatchSel = { fg = c.accent, bg = c.bg_element, bold = true },
  WildMenu = { bg = c.bg_element },

  ---------------------------------------------------------------- messages --
  ErrorMsg = { fg = c.error },
  WarningMsg = { fg = c.warning },
  MoreMsg = { fg = c.info },
  ModeMsg = { fg = c.fg, bold = true },
  Question = { fg = c.info },
  MsgArea = { fg = c.fg },
  MsgSeparator = { fg = c.border, bg = c.bg_panel },

  ------------------------------------------------------------------- misc --
  Directory = { fg = c.fg },
  Title = { fg = c.title, bold = true },
  QuickFixLine = { bg = c.bg_element },
  debugPC = { bg = c.bg_element },
  debugBreakpoint = { fg = c.error },

  SpellBad = { sp = c.error, undercurl = true },
  SpellCap = { sp = c.warning, undercurl = true },
  SpellLocal = { sp = c.info, undercurl = true },
  SpellRare = { sp = c.hint, undercurl = true },

  ------------------------------------------------------------------- diff --
  -- DiffChange is the third state: a line present on both sides but altered. Vim
  -- paints it on *both* panes with one group, so it must not be the add colour --
  -- that made the pre-change text on the left look inserted.
  DiffAdd = { bg = c.git_add_bg },
  DiffDelete = { bg = c.git_delete_bg },
  DiffChange = { bg = c.git_change_bg },
  DiffText = { bg = c.git_word_change },
  diffAdded = { fg = c.git_add },
  diffRemoved = { fg = c.git_delete },
  diffChanged = { fg = c.git_change },
  diffFile = { fg = c.fg, bold = true },
  diffLine = { fg = c.comment },
  diffIndexLine = { fg = c.fg_muted },
  diffOldFile = { fg = c.git_delete },
  diffNewFile = { fg = c.git_add },

  ------------------------------------------------------------ diagnostics --
  DiagnosticError = { fg = c.error },
  DiagnosticWarn = { fg = c.warning },
  DiagnosticInfo = { fg = c.info },
  DiagnosticHint = { fg = c.hint },
  DiagnosticOk = { fg = c.success },

  DiagnosticVirtualTextError = { fg = c.error, bg = c.status_bg },
  DiagnosticVirtualTextWarn = { fg = c.warning, bg = c.status_bg },
  DiagnosticVirtualTextInfo = { fg = c.info, bg = c.status_bg },
  DiagnosticVirtualTextHint = { fg = c.hint, bg = c.status_bg },
  DiagnosticVirtualTextOk = { fg = c.success, bg = c.status_bg },

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

  DiagnosticDeprecated = { fg = c.fg_muted, strikethrough = true },
  DiagnosticUnnecessary = { fg = c.fg_muted },

  --------------------------------------------------------------------- lsp --
  LspReferenceText = { bg = c.ref_read },
  LspReferenceRead = { bg = c.ref_read },
  LspReferenceWrite = { bg = c.ref_read }, -- no document_highlight.write in the theme
  LspReferenceTarget = { bg = c.ref_read },
  LspInlayHint = { fg = c.hint, bg = c.status_bg },
  LspCodeLens = { fg = c.hint },
  LspCodeLensSeparator = { fg = c.line_nr },
  LspSignatureActiveParameter = { fg = c.fg, bg = c.bg_element, bold = true },
  LspInfoBorder = { fg = c.border_float, bg = c.bg_panel },
  ComplHint = { fg = c.hint, italic = true },
  ComplHintMore = { fg = c.hint },

  --------------------------------------------------------------- snippets --
  SnippetTabstop = { bg = c.bg_element },
  SnippetTabstopActive = { bg = c.selection },
}
