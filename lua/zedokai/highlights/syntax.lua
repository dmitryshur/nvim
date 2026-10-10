-- Legacy syntax groups, treesitter captures and LSP semantic tokens.
-- Mapping follows the `syntax` block of the Zed theme, plus the captures Zed's own
-- TS/TSX queries use where they differ from nvim-treesitter's.
local c = require 'zedokai.palette'

local groups = {
  ------------------------------------------------------- legacy vim groups --
  Comment = { fg = c.comment, italic = true },
  Constant = { fg = c.constant },
  String = { fg = c.string },
  Character = { fg = c.string },
  Number = { fg = c.constant },
  Float = { fg = c.constant },
  Boolean = { fg = c.constant },
  Identifier = { fg = c.variable },
  Function = { fg = c.func },
  Statement = { fg = c.keyword },
  Conditional = { fg = c.keyword },
  Repeat = { fg = c.keyword },
  Label = { fg = c.label },
  Operator = { fg = c.operator },
  Keyword = { fg = c.keyword },
  Exception = { fg = c.keyword },
  PreProc = { fg = c.preproc },
  Include = { fg = c.keyword },
  Define = { fg = c.preproc },
  Macro = { fg = c.preproc },
  PreCondit = { fg = c.preproc },
  Type = { fg = c.type },
  StorageClass = { fg = c.keyword },
  Structure = { fg = c.type },
  Typedef = { fg = c.type },
  Special = { fg = c.string_special },
  SpecialChar = { fg = c.string_escape },
  Tag = { fg = c.tag },
  Delimiter = { fg = c.punctuation },
  SpecialComment = { fg = c.comment, italic = true },
  Debug = { fg = c.warning },
  Underlined = { underline = true },
  Ignore = { fg = c.ignored },
  Error = { fg = c.error },
  Todo = { fg = c.bg, bg = c.warning, bold = true },

  ---------------------------------------------------- treesitter: comments --
  ['@comment'] = { fg = c.comment, italic = true },
  ['@comment.documentation'] = { fg = c.comment, italic = true },
  ['@comment.error'] = { fg = c.error, bold = true },
  ['@comment.warning'] = { fg = c.warning, bold = true },
  ['@comment.todo'] = { fg = c.bg, bg = c.warning, bold = true },
  ['@comment.note'] = { fg = c.bg, bg = c.info, bold = true },

  --------------------------------------------------- treesitter: keywords --
  ['@keyword'] = { fg = c.keyword },
  ['@keyword.function'] = { fg = c.keyword },
  ['@keyword.operator'] = { fg = c.keyword },
  ['@keyword.import'] = { fg = c.keyword },
  ['@keyword.type'] = { fg = c.keyword },
  ['@keyword.modifier'] = { fg = c.keyword },
  ['@keyword.coroutine'] = { fg = c.keyword },
  ['@keyword.debug'] = { fg = c.keyword },
  ['@keyword.directive'] = { fg = c.preproc },
  ['@keyword.directive.define'] = { fg = c.preproc },
  ['@keyword.repeat'] = { fg = c.keyword },
  ['@keyword.return'] = { fg = c.keyword },
  ['@keyword.conditional'] = { fg = c.keyword },
  ['@keyword.conditional.ternary'] = { fg = c.operator },
  ['@keyword.exception'] = { fg = c.keyword },

  ------------------------------------------------ treesitter: identifiers --
  -- Zed's theme has no variable.parameter, so parameters fall back to variable.
  ['@variable'] = { fg = c.variable },
  ['@variable.builtin'] = { fg = c.var_special, italic = true },
  ['@variable.parameter'] = { fg = c.variable },
  ['@variable.parameter.builtin'] = { fg = c.var_special, italic = true },
  ['@variable.member'] = { fg = c.property },

  ['@constant'] = { fg = c.constant },
  ['@constant.builtin'] = { fg = c.constant },
  ['@constant.macro'] = { fg = c.preproc },

  ['@module'] = { fg = c.variable },
  ['@label'] = { fg = c.label },

  ---------------------------------------------------- treesitter: strings --
  ['@string'] = { fg = c.string },
  ['@string.documentation'] = { fg = c.string },
  ['@string.regexp'] = { fg = c.string },
  ['@string.escape'] = { fg = c.string_escape },
  ['@string.special'] = { fg = c.string_special },
  ['@string.special.symbol'] = { fg = c.string_special },
  ['@string.special.path'] = { fg = c.string_special },
  ['@string.special.url'] = { fg = c.link_uri, underline = true },

  ['@character'] = { fg = c.string },
  ['@character.special'] = { fg = c.string_special },
  ['@number'] = { fg = c.constant },
  ['@number.float'] = { fg = c.constant },
  ['@boolean'] = { fg = c.constant },

  ------------------------------------------------------ treesitter: types --
  ['@type'] = { fg = c.type },
  ['@type.builtin'] = { fg = c.type },
  ['@type.definition'] = { fg = c.type },
  ['@type.qualifier'] = { fg = c.keyword },
  -- Any capitalised identifier, which nvim-treesitter's ecma query guesses is a
  -- type (renamed from @type in plugins/treesitter.lua). Zed's queries make no
  -- such guess, so `PortfoliosContext` in an import list stays plain.
  ['@type.capitalised'] = { fg = c.variable },
  ['@attribute'] = { fg = c.attribute, italic = true },
  ['@attribute.builtin'] = { fg = c.attribute, italic = true },
  ['@property'] = { fg = c.property },

  -------------------------------------------------- treesitter: functions --
  ['@function'] = { fg = c.func },
  ['@function.builtin'] = { fg = c.func },
  ['@function.call'] = { fg = c.func },
  ['@function.macro'] = { fg = c.func },
  ['@function.method'] = { fg = c.func },
  ['@function.method.call'] = { fg = c.func },
  -- nvim-treesitter uses @constructor mostly for `new Foo()`, which Zed's queries
  -- capture as type.class -- the theme's red `constructor` only reaches the
  -- `constructor` method name. Lua table braces get it too; Zed calls those
  -- punctuation.
  ['@constructor'] = { fg = c.type },
  ['@constructor.lua'] = { fg = c.punctuation },
  ['@operator'] = { fg = c.operator },

  ------------------------------------------------ treesitter: punctuation --
  ['@punctuation.delimiter'] = { fg = c.punctuation },
  ['@punctuation.bracket'] = { fg = c.punctuation },
  ['@punctuation.special'] = { fg = c.punctuation },

  -------------------------------------------------- treesitter: markup/md --
  ['@markup.strong'] = { bold = true },
  ['@markup.italic'] = { italic = true },
  ['@markup.strikethrough'] = { strikethrough = true },
  ['@markup.underline'] = { underline = true },
  ['@markup.heading'] = { fg = c.title, bold = true },
  ['@markup.heading.1'] = { fg = c.title, bold = true },
  ['@markup.heading.2'] = { fg = c.title, bold = true },
  ['@markup.heading.3'] = { fg = c.title },
  ['@markup.heading.4'] = { fg = c.title },
  ['@markup.heading.5'] = { fg = c.title },
  ['@markup.heading.6'] = { fg = c.title },
  ['@markup.quote'] = { fg = c.fg_dim, italic = true },
  ['@markup.math'] = { fg = c.constant },
  ['@markup.link'] = { fg = c.link_text },
  ['@markup.link.label'] = { fg = c.link_text },
  ['@markup.link.url'] = { fg = c.link_uri, underline = true },
  ['@markup.raw'] = { fg = c.string },
  ['@markup.raw.block'] = { fg = c.string },
  ['@markup.list'] = { fg = c.punctuation },
  ['@markup.list.checked'] = { fg = c.success },
  ['@markup.list.unchecked'] = { fg = c.punctuation },

  ['@diff.plus'] = { fg = c.git_add, bg = c.git_add_bg },
  ['@diff.minus'] = { fg = c.git_delete, bg = c.git_delete_bg },
  ['@diff.delta'] = { fg = c.git_change },

  ['@tag'] = { fg = c.tag },
  ['@tag.builtin'] = { fg = c.tag },
  ['@tag.attribute'] = { fg = c.attribute, italic = true },
  ['@tag.delimiter'] = { fg = c.punctuation },
  -- In JSX nvim-treesitter gives capitalised components @tag and lowercase
  -- elements @tag.builtin. Zed captures components as @type, so they're blue,
  -- while `<div>` keeps the red tag colour.
  ['@tag.javascript'] = { fg = c.type },
  ['@tag.tsx'] = { fg = c.type },

  ['@none'] = {},
}

---------------------------------------------------- LSP semantic tokens --
-- Zed colours code by treesitter alone, so this port ignores semantic tokens.
-- Neovim links each @lsp.* group to a treesitter group by default, and tokens
-- outrank treesitter: tsgo marks every variable holding a function as
-- `function` and every component as `class`, so destructured callbacks came out
-- green and component props blue where Zed leaves them plain. A cleared group
-- keeps the token but draws nothing, letting the treesitter colour show
-- through. Cleared here rather than switching tokens off in the LSP config
-- because the jetbrains theme does colour them.
--
-- load() runs `highlight clear` before requiring this file, so what's listed
-- here is Neovim's defaults rather than whatever the previous theme left.
for group in pairs(vim.api.nvim_get_hl(0, {})) do
  if vim.startswith(group, '@lsp') then
    groups[group] = {}
  end
end

return groups
