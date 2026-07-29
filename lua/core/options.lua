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
option.colorcolumn = "100" -- vertical ruler marking the 100 character mark (<leader>1 toggles it)

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

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}
