vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Neovim 0.11+ ships built-in gr* LSP mappings; delete them so `gr` (references)
-- fires instantly instead of waiting timeoutlen for a second key.
for _, lhs in ipairs { 'grn', 'grr', 'gri', 'gra', 'grt', 'grx' } do
  pcall(vim.keymap.del, 'n', lhs)
end
pcall(vim.keymap.del, 'x', 'gra')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Diagnostics are quiet by default (signs and underline only -- see core.options).
-- This expands the whole buffer to full virtual lines for when you're actually
-- working through the errors in a file, rather than reading around them.
--
-- `vim.diagnostic.config` merges per key, so passing only virtual_lines leaves the
-- underline, float and severity_sort settings from core.options untouched.
--
-- `gh` shadows the built-in "start Select mode, charwise" -- Select mode being the
-- one almost nobody uses on purpose, and `v` is unaffected.
local diagnostics_expanded = false
vim.keymap.set('n', 'gh', function()
  diagnostics_expanded = not diagnostics_expanded
  vim.diagnostic.config { virtual_lines = diagnostics_expanded }
  vim.notify(
    diagnostics_expanded and 'Diagnostics: virtual lines' or 'Diagnostics: signs only',
    vim.log.levels.INFO,
    { title = 'Diagnostics' }
  )
end, { desc = 'Toggle expanded diagnostics (virtual lines)' })

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

-- What is this key bound to: every active mapping, with its description and the
-- plugin bindings your config never declared. `<leader>?` because that is the
-- question it answers.
vim.keymap.set('n', '<leader>?', function() require('telescope.builtin').keymaps() end, { desc = 'Telescope keymaps' })

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
-- The repo-wide sibling of <leader>gr: pick branches instead of commits, and get
-- every changed file rather than just this one. Reviewing a pull request locally.
vim.keymap.set('n', '<leader>gf', function() require('core.git_branch_diff').pick() end, { desc = 'Diff all files between branches' })

-- Manual format. In visual mode conform narrows to the selected range.
-- `lsp_format = 'fallback'` mirrors conform's format_on_save so the manual and
-- automatic paths use the same formatter for a given filetype.
local format_buffer = function() require('conform').format { async = true, lsp_format = 'fallback' } end

vim.keymap.set({ 'n', 'x' }, '<leader>1', format_buffer, { desc = 'Format buffer' })

-- Same key toggles the floating terminal open and closed from anywhere,
-- including from inside the terminal itself (terminal mode). `<Cmd>` runs
-- without leaving the current mode, so insert/terminal mode are unaffected.
vim.keymap.set({ 'n', 'i', 't' }, [[<C-\>]], '<Cmd>ToggleTerm<CR>', { desc = 'Toggle floating terminal' })

-- Harpoon: a short, ordered list of files scoped to the cwd, so this project and
-- the next one keep separate lists. Unlike marks A-Z, which are one global
-- namespace shared across every project, and unlike the buffer list, which
-- core.buffer_limit prunes out from under you.
--
-- The `require` is what pulls the plugin in (no `event` on the spec), matching how
-- conform and telescope are loaded. Behaviour lives in core.harpoon; `<leader>b`
-- is a bare prefix on purpose, so none of these wait for timeoutlen.
vim.keymap.set('n', '<leader>bb', function() require('core.harpoon').toggle() end, { desc = 'Harpoon: pin/unpin file' })
vim.keymap.set('n', '<leader>bl', function() require('core.harpoon').list() end, { desc = 'Harpoon: list files' })
-- Clears immediately, with no confirmation and no undo -- the notification's count
-- is the only trace of what was there.
vim.keymap.set('n', '<leader>br', function() require('core.harpoon').clear() end, { desc = 'Harpoon: remove all' })

vim.keymap.set('n', '<leader>p', function()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  vim.notify(path, vim.log.levels.INFO, { title = 'Copied relative path' })
end, { desc = 'Copy relative path of current file' })

-- Sessions. persistence writes one per directory (and git branch) on exit, but
-- nothing is restored automatically -- starting nvim always gives a clean slate
-- and these keys are the way back. `<leader>s` is a bare prefix on purpose: no
-- single-key `<leader>s` mapping exists, so none of these wait for timeoutlen.
vim.keymap.set('n', '<leader>ss', function() require('persistence').load() end, { desc = 'Restore session for this directory' })
vim.keymap.set('n', '<leader>sl', function() require('persistence').load { last = true } end, { desc = 'Restore last session (any directory)' })
vim.keymap.set('n', '<leader>sp', function() require('persistence').select() end, { desc = 'Pick a session to restore' })
-- Escape hatch: after a throwaway detour (opening one unrelated file, a big
-- refactor you abandoned) this leaves the saved session as it was on disk.
vim.keymap.set('n', '<leader>sd', function() require('persistence').stop() end, { desc = "Don't save the session on exit" })
