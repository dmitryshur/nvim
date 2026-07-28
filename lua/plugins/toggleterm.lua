return {
  'akinsho/toggleterm.nvim',
  version = '*',
  cmd = { 'ToggleTerm', 'TermExec' },
  opts = {
    direction = 'float',
    -- Terminals start in insert mode, and the toggle keymap covers terminal
    -- mode, so there's no need to reach for `<C-\><C-n>` just to close it.
    start_in_insert = true,
    float_opts = {
      border = 'curved',
      width = function() return math.floor(vim.o.columns * 0.85) end,
      height = function() return math.floor(vim.o.lines * 0.85) end,
    },
  },
}
