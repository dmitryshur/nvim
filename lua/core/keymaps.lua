vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Neovim 0.11+ ships built-in gr* LSP mappings; delete them so `gr` (references)
-- fires instantly instead of waiting timeoutlen for a second key.
for _, lhs in ipairs { 'grn', 'grr', 'gri', 'gra', 'grt', 'grx' } do
  pcall(vim.keymap.del, 'n', lhs)
end
pcall(vim.keymap.del, 'x', 'gra')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Toggle the column ruler. Seeded from whatever core.options set (it runs first),
-- so the width itself stays defined in exactly one place.
--
-- `colorcolumn` is window-local, so flipping only the current window would leave
-- splits disagreeing about whether the ruler is showing. Set the global default
-- too, otherwise windows opened after a toggle come back with the old state.
local ruler_width = vim.go.colorcolumn
vim.keymap.set('n', '<leader>1', function()
  local showing = vim.wo.colorcolumn ~= ''
  if showing then ruler_width = vim.wo.colorcolumn end
  local value = showing and '' or ruler_width
  vim.go.colorcolumn = value
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    vim.wo[win].colorcolumn = value
  end
end, { desc = 'Toggle the column ruler' })

-- Re-run this config's own Lua modules so edits to options/keymaps take effect
-- without restarting. `require` caches, so the modules have to be dropped from
-- package.loaded first.
--
-- Deliberately does NOT re-run init.lua: that would call lazy.setup() a second
-- time. Plugin specs stay owned by lazy -- use `:Lazy reload <plugin>` for those.
--
-- Two things a reload cannot undo, because it only ever *adds*: a keymap or
-- autocmd you deleted from the file stays live until restart (the augroups here
-- all pass clear = true, so those at least don't stack up), and the ruler above
-- resets to the width in core.options rather than keeping its toggled state.
vim.keymap.set('n', '<leader>0', function()
  local dropped = {}
  for name in pairs(package.loaded) do
    if name == 'core' or name:match '^core%.' then
      package.loaded[name] = nil
      dropped[#dropped + 1] = name
    end
  end

  local ok, err = pcall(function()
    require 'core.options'
    require 'core.keymaps'
  end)

  if ok then
    vim.notify(string.format('Reloaded %d module(s)', #dropped), vim.log.levels.INFO, { title = 'Config' })
  else
    vim.notify(tostring(err), vim.log.levels.ERROR, { title = 'Config reload failed' })
  end
end, { desc = 'Reload config (core modules)' })

vim.keymap.set('n', '<backspace>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- Resize the current window. Pairs with the <C-hjkl> navigation above: same
-- modifier, arrows instead of letters.
vim.keymap.set('n', '<C-Up>', '<cmd>resize +3<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -3<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -5<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +5<CR>', { desc = 'Increase window width' })

-- Jump straight to window N, numbered as `:h winnr()` does it: top-left first,
-- so Neotree is 1 whenever it's open.
--
-- Ctrl with a digit has no legacy terminal encoding (Ctrl-1 would just send
-- `1`), so this only works because Ghostty speaks the kitty keyboard protocol
-- and Neovim asks for "CSI u" disambiguation when the terminal advertises it.
-- In a terminal without that, these mappings are simply never triggered.
for number = 1, 9 do
  vim.keymap.set('n', '<C-' .. number .. '>', function()
    -- `{count}wincmd w` past the last window is E16, so drop the keypress
    -- rather than let it beep.
    if number <= vim.fn.winnr '$' then vim.cmd(number .. 'wincmd w') end
  end, { desc = 'Move focus to window ' .. number })
end

-- `<C-w>p` (last accessed window) rather than `<C-w>w` (cycle), so it toggles
-- back and forth instead of walking past the window you came from.
vim.keymap.set('n', '<leader>w', '<C-w>p', { desc = 'Switch to last accessed window' })
-- Neogit opens most of its buffers as tabs, and Diffview lives in one too, so
-- they pile up. Diffview cleans itself up on TabClosed, so this is safe to use
-- instead of DiffviewClose.
vim.keymap.set('n', '<leader>o', '<cmd>tabonly<CR>', { desc = 'Close all other tabs' })
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
vim.keymap.set('n', '<leader>gs', function() require('telescope.builtin').git_branches() end, { desc = 'Switch git branch' })

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
vim.keymap.set('n', '<leader>gr', function() require('core.git_file_diff').pick() end, { desc = 'Diff current file between commits' })

-- Manual format. In visual mode conform narrows to the selected range.
-- `lsp_format = 'fallback'` mirrors conform's format_on_save so the manual and
-- automatic paths use the same formatter for a given filetype.
local format_buffer = function() require('conform').format { async = true, lsp_format = 'fallback' } end

vim.keymap.set({ 'n', 'x' }, '<leader>2', format_buffer, { desc = 'Format buffer' })

-- Same key toggles the floating terminal open and closed from anywhere,
-- including from inside the terminal itself (terminal mode). `<Cmd>` runs
-- without leaving the current mode, so insert/terminal mode are unaffected.
vim.keymap.set({ 'n', 'i', 't' }, [[<C-\>]], '<Cmd>ToggleTerm<CR>', { desc = 'Toggle floating terminal' })

vim.keymap.set('n', '<leader>p', function()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  vim.notify(path, vim.log.levels.INFO, { title = 'Copied relative path' })
end, { desc = 'Copy relative path of current file' })
