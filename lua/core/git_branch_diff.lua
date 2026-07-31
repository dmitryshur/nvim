-- Pick branches and diff every file that differs between them, in Diffview.
--
-- The sibling of core.git_file_diff: that one is commit-scoped and file-scoped
-- (this file's history, one file in the diff), this one is branch-scoped and
-- repo-wide (all changed files). Reviewing someone's pull request is the case it
-- exists for.
--
-- Ranges use the triple dot -- `base...head` -- which diffs against the merge
-- base rather than the branch tip. That is what a pull request shows: commits
-- that landed on the base branch after the feature branch started are excluded.
-- Two dots would fold them in and make the review look bigger than it is.

local columns = require 'core.picker_columns'

local SEPARATOR = ' '
local DATE_WIDTH = 10
local AUTHOR_WIDTH = 16

local M = {}

local function notify(message, level)
  vim.notify(message, level, { title = 'Git branch diff' })
end

local function git(args, cwd)
  local result = vim.system(vim.list_extend({ 'git' }, args), { cwd = cwd, text = true }):wait()
  if result.code ~= 0 then return nil, vim.trim(result.stderr or '') end
  return vim.split(vim.trim(result.stdout or ''), '\n', { trimempty = true })
end

-- Local and remote branches together, most recently committed first -- the branch
-- you want to review is nearly always near the top.
local function collect_branches(root)
  local lines, err = git({
    'for-each-ref',
    '--sort=-committerdate',
    '--format=%(refname:short)\t%(committerdate:short)\t%(authorname)\t%(contents:subject)',
    'refs/heads',
    'refs/remotes',
  }, root)
  if not lines then return nil, err end

  local branches = {}
  for _, line in ipairs(lines) do
    local name, date, author, subject = line:match '^(%S+)\t(%S*)\t([^\t]*)\t(.*)$'
    -- origin/HEAD is a symbolic ref pointing at another entry in this same list.
    if name and name:match '/HEAD$' == nil then
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

function M.pick()
  local toplevel, err = git({ 'rev-parse', '--show-toplevel' }, vim.uv.cwd())
  if not toplevel then
    return notify(err ~= '' and err or 'Not inside a git repository', vim.log.levels.WARN)
  end
  local root = toplevel[1]

  local branches, list_err = collect_branches(root)
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
      prompt_title = 'Diff branches (<CR> vs HEAD, or <Tab> base then head)',
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
          local marked = picker:get_multi_selection()

          local base, head
          if #marked >= 2 then
            -- MultiSelect:get() sorts by the order things were marked, so the first
            -- <Tab> is the base and the second is the head.
            base, head = marked[1].value, marked[2].value
          else
            -- Nothing marked: diff the highlighted branch against where you are.
            -- This is the pull-request case once you've checked the branch out --
            -- highlight the base branch and press <CR>.
            local entry = action_state.get_selected_entry()
            base, head = entry and entry.value, 'HEAD'
          end

          actions.close(prompt_bufnr)
          if not base then return notify('No branch selected', vim.log.levels.WARN) end
          if base == head then return notify('Base and head are the same', vim.log.levels.WARN) end

          -- --imply-local points the HEAD end at the real files rather than buffers
          -- built from git, which is what keeps LSP working while you read.
          vim.cmd(string.format('DiffviewOpen %s...%s --imply-local', base, head))
        end)
        return true
      end,
    })
    :find()
end

return M
