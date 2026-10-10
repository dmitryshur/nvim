-- Scroll the diff from the file list: run `keys` in the first diff pane of this
-- tab -- any window that isn't one of codediff's own panels. The panes are
-- scrollbound, so the other side follows, and the cursor stays in the list.
local function scroll_diff(keys)
  return function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local filetype = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      if vim.api.nvim_win_get_config(win).relative == '' and not filetype:find '^codediff%-' then
        return vim.api.nvim_win_call(win, function()
          vim.cmd.normal { vim.keycode(keys), bang = true }
        end)
      end
    end
  end
end

-- Stage or unstage the explorer entry under the cursor -- a file, or a folder
-- with everything in it. codediff itself only offers a toggle, so this calls it
-- only when the entry sits in one of `groups`: `s` on an already-staged file
-- does nothing rather than unstaging it. `lifecycle` and `explorer` are
-- codediff internals; the version is pinned in lazy-lock.json.
local function stage_entry(groups)
  return function()
    local explorer = require('codediff.ui.lifecycle').get_panel_view(vim.api.nvim_get_current_tabpage())
    local node = explorer and explorer.tree:get_node()
    if node and node.data and groups[node.data.group] then
      require('codediff.ui.explorer').toggle_stage_entry(explorer, explorer.tree)
    end
  end
end

return {
  'esmuellert/codediff.nvim',
  cmd = 'CodeDiff',
  config = function(_, opts)
    require('codediff').setup(opts)

    -- <C-f> / <C-b> in the explorer and history panels page through the selected
    -- file instead of the list; j/k still move through the list.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('codediff-scroll-diff', { clear = true }),
      pattern = { 'codediff-explorer', 'codediff-history' },
      callback = function(event)
        vim.keymap.set('n', '<C-f>', scroll_diff '<C-f>', { buffer = event.buf, desc = 'Scroll diff down a page' })
        vim.keymap.set('n', '<C-b>', scroll_diff '<C-b>', { buffer = event.buf, desc = 'Scroll diff up a page' })
      end,
    })

    -- s / u stage and unstage, like Neogit, but only in the explorer: codediff's
    -- own stage key also lands on the diff panes, where `u` is undo in the
    -- working-tree buffer. Staging a conflicted file marks it resolved.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('codediff-stage-keys', { clear = true }),
      pattern = 'codediff-explorer',
      callback = function(event)
        vim.keymap.set('n', 's', stage_entry { unstaged = true, conflicts = true }, { buffer = event.buf, desc = 'Stage file or folder' })
        vim.keymap.set('n', 'u', stage_entry { staged = true }, { buffer = event.buf, desc = 'Unstage file or folder' })
      end,
    })
  end,
  opts = {
    -- Line backgrounds already come from the colorscheme's DiffAdd / DiffDelete,
    -- red on the old side and green on the new. The word-level pair would
    -- otherwise be those two brightened; the themes' GitSigns*Inline groups carry
    -- their own git_word_add / git_word_delete, so changed words match gitsigns.
    highlights = {
      char_insert = 'GitSignsAddInline',
      char_delete = 'GitSignsDeleteInline',
    },
    diff = {
      -- Blank alignment rows, the same choice as `fillchars` `diff` in
      -- core/options.lua: the gap shows without drawing anything that reads like
      -- text.
      filler_text = '',
      -- Fold unchanged code, keeping 12 lines around each hunk -- what vim's
      -- diff mode did with `diffopt` `context:12`. zR / zM / zi still work.
      compact = true,
      compact_context_lines = 12,
    },
    -- Changed files grouped under their folders rather than a flat list, so
    -- where a file lives is visible at a glance. `i` flips back per session.
    explorer = { view_mode = 'tree' },
    history = { view_mode = 'tree' },
    keymaps = {
      view = {
        -- ]h / [h are the gitsigns hunk keys everywhere else. codediff hands
        -- shadowed buffer mappings back when the view closes.
        next_hunk = { ']c', ']h' },
        prev_hunk = { '[c', '[h' },
        -- These would shadow the `t` motion and the built-in `gc` comment
        -- operator on the working-tree buffer, which stays editable in the view.
        toggle_layout = false,
        toggle_compact = false,
        -- Replaced by s / u in the explorer (see config above).
        toggle_stage = false,
      },
    },
  },
}
