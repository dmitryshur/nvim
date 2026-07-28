vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Neovim 0.11+ ships built-in gr* LSP mappings; delete them so `gr` (references)
-- fires instantly instead of waiting timeoutlen for a second key.
for _, lhs in ipairs { 'grn', 'grr', 'gri', 'gra', 'grt', 'grx' } do
  pcall(vim.keymap.del, 'n', lhs)
end
pcall(vim.keymap.del, 'x', 'gra')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<backspace>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- `<C-w>p` (last accessed window) rather than `<C-w>w` (cycle), so it toggles
-- back and forth instead of walking past the window you came from.
vim.keymap.set('n', '<leader>w', '<C-w>p', { desc = 'Switch to last accessed window' })
vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal left toggle<CR>', { desc = 'Toggle Neo-tree' })

vim.keymap.set('n', '<leader>f', function() require('telescope.builtin').find_files() end, { desc = 'Telescope find files' })
-- Reopen the last live grep (query and selection intact) if there is one;
-- clear the prompt to start a new search.
vim.keymap.set('n', '<leader><leader>', function()
  local cached = require('telescope.state').get_global_key 'cached_pickers' or {}
  for index, picker in ipairs(cached) do
    if picker.prompt_title == 'Live Grep' then
      return require('telescope.builtin').resume { cache_index = index }
    end
  end
  require('telescope.builtin').live_grep()
end, { desc = 'Telescope live grep (resumes last)' })
vim.keymap.set('n', '<tab>', function() require('telescope.builtin').buffers() end, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>r', function() require('telescope.builtin').resume() end, { desc = 'Telescope resume' })

vim.keymap.set('n', '<leader>gg', ':Neogit<CR>', { desc = 'Open Neogit' })

-- Diffview lives in its own tabpage, so `:q` only peels off one window at a
-- time. DiffviewClose tears the whole tab down in one go; toggling through it
-- means the same key that opened the view also closes it.
local toggle_diffview = function(open_cmd)
  return function()
    if require('diffview.lib').get_current_view() then
      vim.cmd 'DiffviewClose'
    else
      vim.cmd(open_cmd)
    end
  end
end

vim.keymap.set('n', '<leader>gd', toggle_diffview 'DiffviewOpen', { desc = 'Toggle git diff view' })
vim.keymap.set('n', '<leader>gh', toggle_diffview 'DiffviewFileHistory %', { desc = 'Toggle git history for current file' })
vim.keymap.set('n', '<leader>gb', ':Gitsigns blame<CR>', { desc = 'Git blame file' })

vim.keymap.set({ 'n', 'x' }, '<leader>=', function() require('conform').format { async = true, lsp_format = 'fallback' } end, { desc = 'Format buffer' })

-- Same key toggles the floating terminal open and closed from anywhere,
-- including from inside the terminal itself (terminal mode). `<Cmd>` runs
-- without leaving the current mode, so insert/terminal mode are unaffected.
vim.keymap.set({ 'n', 'i', 't' }, [[<C-\>]], '<Cmd>ToggleTerm<CR>', { desc = 'Toggle floating terminal' })

vim.keymap.set('n', '<leader>p', function()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  vim.notify(path, vim.log.levels.INFO, { title = 'Copied relative path' })
end, { desc = 'Copy relative path of current file' })
