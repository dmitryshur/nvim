-- Persist the quickfix list across restarts, keyed by directory.
--
-- Nothing in Neovim carries the quickfix list between sessions: shada stores
-- marks, registers and history but not lists, and `mksession` never writes one
-- (`sessionoptions` has no value that would add it -- appending `qf` is E474).
-- So persistence.nvim restores the buffers you were reading and leaves the
-- search results that sent you there behind.
--
-- Saving happens once, on VimLeavePre, rather than whenever the list changes:
-- Neovim has no "quickfix changed" event. The only two are QuickFixCmdPre and
-- QuickFixCmdPost, which fire for *commands* (`:grep`, `:vimgrep`, `:make`) and
-- so miss every direct `setqflist` call -- including vim.diagnostic.setqflist.
-- Writing at exit captures the final state whatever produced it, at the cost of
-- losing it if Neovim is killed rather than quit.
--
-- Restoring is deliberately manual (<leader>sq). A quickfix list from yesterday
-- restored silently at startup is stale results wearing the costume of fresh
-- ones, which is the same reason sessions here are opt-in.

-- Written once per session, so the cost is one encode at exit -- but a broad
-- `:vimgrep` can produce tens of thousands of entries, and none of the tail is
-- ever read. The restore notification says when this bit.
local MAX_ENTRIES = 1000

-- Fields `setqflist` accepts back. `bufnr` is deliberately absent: buffer
-- numbers mean nothing in the next session, so it's resolved to a filename at
-- save time and Neovim re-resolves it on the jump.
local ITEM_FIELDS = { 'lnum', 'end_lnum', 'col', 'end_col', 'vcol', 'nr', 'pattern', 'text', 'type', 'valid', 'module' }

local M = {}

local function notify(message, level) vim.notify(message, level, { title = 'Quickfix' }) end

local function state_dir() return vim.fs.joinpath(vim.fn.stdpath 'state', 'quickfix') end

-- Same escaping persistence.nvim uses for its session names, so the two sets of
-- files sort alongside each other and are recognisable by eye.
local function path_for_cwd()
  local name = vim.uv.cwd():gsub('[\\/:]+', '%%')
  return vim.fs.joinpath(state_dir(), name .. '.json')
end

local function serialize_item(item)
  local out = {}
  for _, field in ipairs(ITEM_FIELDS) do
    out[field] = item[field]
  end
  if item.bufnr and item.bufnr > 0 and vim.api.nvim_buf_is_valid(item.bufnr) then
    local filename = vim.api.nvim_buf_get_name(item.bufnr)
    if filename ~= '' then out.filename = filename end
  end
  return out
end

function M.save()
  local list = vim.fn.getqflist { all = 1 }
  -- An empty list carries no information, and quitting an nvim that never ran a
  -- search shouldn't wipe the results saved by one that did. Mirrors the `need`
  -- guard persistence.nvim applies to sessions.
  if #list.items == 0 then return end

  local items = {}
  for index = 1, math.min(#list.items, MAX_ENTRIES) do
    items[index] = serialize_item(list.items[index])
  end

  local payload = {
    title = list.title ~= '' and list.title or nil,
    items = items,
    total = #list.items,
  }

  vim.fn.mkdir(state_dir(), 'p')
  -- pcall because this runs during exit, where an error is both useless to the
  -- user and capable of holding up the quit.
  pcall(vim.fn.writefile, { vim.json.encode(payload) }, path_for_cwd())
end

function M.restore()
  local path = path_for_cwd()
  if vim.fn.filereadable(path) == 0 then
    return notify('No saved quickfix list for this directory', vim.log.levels.WARN)
  end

  local ok, payload = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(path), '\n')) end)
  if not ok or type(payload) ~= 'table' or type(payload.items) ~= 'table' then
    return notify('Saved quickfix list is unreadable', vim.log.levels.ERROR)
  end

  vim.fn.setqflist({}, ' ', { title = payload.title or 'Restored', items = payload.items })
  vim.cmd.copen()

  local restored = #payload.items
  local suffix = payload.total and payload.total > restored and (' of ' .. payload.total .. ', truncated when saved') or ''
  notify('Restored ' .. restored .. ' entries' .. suffix, vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd('VimLeavePre', {
  desc = 'Save the quickfix list for this directory',
  group = vim.api.nvim_create_augroup('quickfix-persist', { clear = true }),
  callback = M.save,
})

return M
