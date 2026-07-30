local option = vim.opt

-- line numbers
option.number = true
option.relativenumber = true

-- tabs & indentation
option.tabstop = 2 -- 2 spaces for tabs (prettier default)
option.shiftwidth = 2 -- 2 spaces for indent width
option.expandtab = true -- expand tab to spaces
option.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
option.wrap = true -- enable line wrapping
-- No `colorcolumn` here: the ruler is off at startup and `:Ruler` turns it on. Its
-- width lives with that command, further down.

-- search settings
option.ignorecase = true -- ignore case when searching
option.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
option.cursorline = true -- highlight the current cursor line

-- turn on termguicolors for nightfly colorscheme to work
option.termguicolors = true
option.background = "dark" -- colorschemes that can be light or dark will be made dark
option.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
option.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
option.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
option.splitright = true -- split vertical window to the right
option.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
option.swapfile = false
vim.o.undofile = true

-- Highlight when yanking (copying) text
-- `:Ruler` shows or hides the column ruler. A command rather than a keymap because
-- it gets used rarely enough not to be worth a key, and nothing sets `colorcolumn`
-- at startup, so it begins hidden -- '' is Neovim's own default for the option.
--
-- The width is a constant rather than being read back off the option, precisely
-- because the option starts empty: there would be nothing to read.
--
-- `colorcolumn` is window-local, so setting only the current window would leave
-- splits disagreeing about whether the ruler is showing. The global default is set
-- too, otherwise windows opened after a toggle come back with the old state.
local RULER_WIDTH = '100'

vim.api.nvim_create_user_command('Ruler', function()
  local value = vim.wo.colorcolumn ~= '' and '' or RULER_WIDTH

  vim.go.colorcolumn = value
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.wo[win].colorcolumn = value
  end
end, { desc = 'Toggle the column ruler' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Nothing is drawn into the buffer: diagnostics show up as a sign in the
  -- signcolumn and an underline on the code, and the message itself only when
  -- asked for -- `]d`/`[d` (which opens the float below) or `<leader>3`, which
  -- toggles full virtual lines on for as long as you're working through a file.
  virtual_text = false,
  virtual_lines = false,

  -- `jump.float = true` is the older spelling of this and is deprecated for
  -- removal in 0.14; on_jump is the replacement. Same behaviour: scope = cursor
  -- and focus = false are what the compatibility shim passed. The border and
  -- source settings come from the `float` config above, which open_float reads.
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false }
    end,
  },
}
