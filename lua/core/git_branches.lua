-- A telescope picker over the repository's branches.
--
-- Shared by everything that starts with "which branch?": diffing two of them
-- (core.git_branch_diff), pulling one, merging one (core.git_remote). Only the
-- selection contract differs between those, so callers pass an `on_select` and
-- get the listing, the columns and the log preview for free.

local columns = require 'core.picker_columns'

local SEPARATOR = ' '
local DATE_WIDTH = 10
local AUTHOR_WIDTH = 16

local M = {}

local function notify(message, level) vim.notify(message, level, { title = 'Git' }) end

local function git(args, cwd)
  local result = vim.system(vim.list_extend({ 'git' }, args), { cwd = cwd, text = true }):wait()
  if result.code ~= 0 then return nil, vim.trim(result.stderr or '') end
  return vim.split(vim.trim(result.stdout or ''), '\n', { trimempty = true })
end

-- Resolved from the current buffer rather than the cwd, so a file opened from
-- another repository operates on *its* repository.
function M.root()
  local file = vim.api.nvim_buf_get_name(0)
  local from = (file ~= '' and vim.bo.buftype == '') and vim.fs.dirname(file) or vim.uv.cwd()
  local toplevel, err = git({ 'rev-parse', '--show-toplevel' }, from)
  if not toplevel then return nil, err ~= '' and err or 'Not inside a git repository' end
  return toplevel[1]
end

function M.remotes(root) return git({ 'remote' }, root) or {} end

-- Most recently committed first -- the branch you want is nearly always near the
-- top. `remote_only` is for operations that need something to fetch from.
local function collect(root, remote_only)
  local refs = remote_only and { 'refs/remotes' } or { 'refs/heads', 'refs/remotes' }
  local lines, err = git(
    vim.list_extend({
      'for-each-ref',
      '--sort=-committerdate',
      '--format=%(refname:short)\t%(committerdate:short)\t%(authorname)\t%(symref)\t%(contents:subject)',
    }, refs),
    root
  )
  if not lines then return nil, err end

  local branches = {}
  for _, line in ipairs(lines) do
    local name, date, author, symref, subject = line:match '^(%S+)\t(%S*)\t([^\t]*)\t([^\t]*)\t(.*)$'
    -- origin/HEAD is a pointer at another entry in this same list, not a branch.
    -- Testing %(symref) rather than the name: `refname:short` renders it as plain
    -- `origin`, so matching on a /HEAD suffix silently misses it.
    if name and symref == '' then
      branches[#branches + 1] = { name = name, date = date, author = author, subject = subject }
    end
  end
  return branches
end

local branch_width = columns.share(0.35, 18, 44)

local build_displayer = columns.displayer {
  separator = SEPARATOR,
  links = {
    TelescopePickerFile = 'Directory',
    TelescopePickerPosition = 'Number',
    TelescopePickerDirectory = 'Comment',
  },
  items = {
    { width = branch_width },
    { width = DATE_WIDTH },
    { width = AUTHOR_WIDTH },
    { width = columns.remaining({ branch_width, DATE_WIDTH, AUTHOR_WIDTH }, #SEPARATOR * 3) },
  },
}

--- @param opts { title: string, remote_only?: boolean, on_select: fun(selected: string?, marked: string[], root: string) }
function M.pick(opts)
  local root, err = M.root()
  if not root then return notify(err, vim.log.levels.WARN) end

  local branches, list_err = collect(root, opts.remote_only)
  if not branches then return notify(list_err, vim.log.levels.ERROR) end
  if #branches == 0 then return notify('No branches found', vim.log.levels.WARN) end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local previewers = require 'telescope.previewers'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local conf = require('telescope.config').values

  pickers
    .new({}, {
      prompt_title = opts.title,
      finder = finders.new_table {
        results = branches,
        entry_maker = function(branch)
          return {
            value = branch.name,
            ordinal = table.concat({ branch.name, branch.subject, branch.author }, ' '),
            display = function()
              return build_displayer() {
                { branch.name, 'TelescopePickerFile' },
                { branch.date, 'TelescopePickerPosition' },
                { branch.author, 'TelescopePickerDirectory' },
                branch.subject,
              }
            end,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = previewers.git_branch_log.new { cwd = root },
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          -- MultiSelect:get() preserves the order things were marked in, which is
          -- what lets a caller treat the first <Tab> as the base and the second
          -- as the head.
          local marked = vim.tbl_map(function(entry) return entry.value end, picker:get_multi_selection())
          local entry = action_state.get_selected_entry()

          actions.close(prompt_bufnr)
          opts.on_select(entry and entry.value, marked, root)
        end)
        return true
      end,
    })
    :find()
end

return M
