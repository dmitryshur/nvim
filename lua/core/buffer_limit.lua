-- Keep the buffer list bounded, so the telescope picker on <tab> stays useful:
-- files opened once and never returned to shouldn't sit in it forever.
--
-- Eviction is least-recently-used. `lastused` comes from getbufinfo() and is
-- maintained by Neovim itself, so this is a real access order rather than an
-- approximation from buffer numbers.
local LIMIT = 50

-- Buffers that are never candidates for eviction, no matter how stale:
--   * unsaved changes -- deleting them would throw work away
--   * currently displayed in a window
--   * anything that isn't a plain file buffer (terminal, help, quickfix,
--     Neo-tree, Neogit, ...), which is what a non-empty buftype means
local function is_protected(info, visible)
  return info.changed == 1 or visible[info.bufnr] or vim.bo[info.bufnr].buftype ~= ''
end

local function prune()
  -- `mksession` sets SessionLoad while a session is being sourced. A restore
  -- adds every buffer in one go, and pruning mid-source would fight it -- the
  -- SessionLoadPost autocmd below trims once the restore has finished instead.
  if vim.g.SessionLoad == 1 then return end

  local visible = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    visible[vim.api.nvim_win_get_buf(win)] = true
  end

  local buffers = vim.fn.getbufinfo { buflisted = 1 }
  local excess = #buffers - LIMIT
  if excess <= 0 then return end

  local candidates = vim.tbl_filter(function(info) return not is_protected(info, visible) end, buffers)
  -- `lastused` is only second-granular, so opening a batch of files at once
  -- leaves them all tied. Break ties on buffer number, which is monotonic --
  -- otherwise the eviction order within a tie is arbitrary.
  table.sort(candidates, function(a, b)
    if a.lastused ~= b.lastused then return a.lastused < b.lastused end
    return a.bufnr < b.bufnr
  end)

  for index = 1, math.min(excess, #candidates) do
    pcall(vim.api.nvim_buf_delete, candidates[index].bufnr, {})
  end
end

local group = vim.api.nvim_create_augroup('buffer-limit', { clear = true })

-- Deferred rather than run inline: deleting a buffer from inside BufAdd runs
-- while Neovim is still wiring the new one up, which trips textlock.
vim.api.nvim_create_autocmd({ 'BufAdd', 'SessionLoadPost' }, {
  desc = 'Keep at most ' .. LIMIT .. ' listed buffers, evicting least recently used',
  group = group,
  callback = vim.schedule_wrap(prune),
})
