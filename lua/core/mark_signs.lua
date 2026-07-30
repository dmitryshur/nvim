-- Shows uppercase marks in the signcolumn, so `mA` leaves something visible
-- rather than a position you have to remember having set.
--
-- Only A-Z: the lowercase ones are throwaway within-file jumps, and `'0`-`'9` are
-- shada's last-exit positions for recently closed files, which nobody sets on
-- purpose. Drawn with extmarks rather than the old `sign_place` API so the whole
-- lot can be cleared per buffer by namespace.

local NAMESPACE = vim.api.nvim_create_namespace 'mark-signs'

local function refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_loaded(bufnr) then return end

  vim.api.nvim_buf_clear_namespace(bufnr, NAMESPACE, 0, -1)

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return end

  local line_count = vim.api.nvim_buf_line_count(bufnr)

  for _, entry in ipairs(vim.fn.getmarklist()) do
    -- `entry.mark` arrives as "'A"; the leading quote is not part of the name.
    local letter = entry.mark:sub(2, 2)

    if letter:match '%u' and vim.fn.fnamemodify(entry.file, ':p') == path then
      local row = entry.pos[2] - 1
      -- A mark can outlive the line it pointed at -- the file may have been
      -- edited elsewhere, or outside Neovim entirely.
      if row >= 0 and row < line_count then
        vim.api.nvim_buf_set_extmark(bufnr, NAMESPACE, row, 0, {
          sign_text = letter,
          sign_hl_group = 'Constant',
        })
      end
    end
  end
end

local group = vim.api.nvim_create_augroup('mark-signs', { clear = true })

-- Neovim has no autocmd for "a mark was set", so `m` is wrapped to redraw
-- immediately after one is. Everything is passed through to the built-in `m`;
-- pcall because the pending key may be an Esc or something else that isn't a
-- valid mark name, and that should be a no-op rather than an error.
vim.keymap.set('n', 'm', function()
  local key = vim.fn.getcharstr()
  pcall(vim.cmd, 'normal! m' .. key)
  refresh()
end, { desc = 'Set mark (and refresh the signcolumn)' })

-- BufEnter covers revisiting a file whose marks were set in an earlier session,
-- and CursorHold eventually catches `:delmarks` and marks set by anything that
-- bypasses the mapping above.
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold' }, {
  desc = 'Redraw uppercase mark signs',
  group = group,
  callback = function(event) refresh(event.buf) end,
})

return { refresh = refresh }
