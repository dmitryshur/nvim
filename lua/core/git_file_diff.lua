-- Pick commits from the current file's history and diff them in Diffview.
--
-- Neogit's diff popup can produce a range (`d` then `r`) but always diffs every
-- file in it -- its "paths" action is an unimplemented placeholder. Telescope's
-- git_bcommits is file-scoped but checks the file out on <CR> instead of
-- diffing. This fills the gap: file-scoped history, range selection, straight
-- into Diffview.
local M = {}

-- Diffview lays out a range oldest-on-the-left, and `git log` lists newest
-- first, so the highest log index is the left side of the range.
local function build_range(marked)
  table.sort(marked, function(left, right) return left.log_index < right.log_index end)
  return marked[#marked].value .. '..' .. marked[1].value
end

local function git(args, cwd)
  local result = vim.system(vim.list_extend({ 'git' }, args), { cwd = cwd, text = true }):wait()
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr or '')
  end
  return vim.split(vim.trim(result.stdout or ''), '\n', { trimempty = true })
end

-- `--follow` keeps the history intact across renames.
local function collect_commits(root, file)
  local lines, err = git({ 'log', '--follow', '--pretty=format:%h\t%as\t%an\t%s', '--', file }, root)
  if not lines then
    return nil, err
  end

  local commits = {}
  for index, line in ipairs(lines) do
    local sha, date, author, subject = line:match '^(%S+)\t(%S+)\t([^\t]*)\t(.*)$'
    if sha then
      commits[#commits + 1] = {
        sha = sha,
        date = date,
        author = author,
        subject = subject,
        log_index = index,
      }
    end
  end
  return commits
end

local function notify(message, level)
  vim.notify(message, level, { title = 'Git file diff' })
end

function M.pick()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' or vim.bo.buftype ~= '' then
    return notify('Current buffer is not a file', vim.log.levels.WARN)
  end

  local toplevel, err = git({ 'rev-parse', '--show-toplevel' }, vim.fs.dirname(file))
  if not toplevel then
    return notify(err ~= '' and err or 'Not inside a git repository', vim.log.levels.WARN)
  end
  local root = toplevel[1]

  local commits, log_err = collect_commits(root, file)
  if not commits then
    return notify(log_err, vim.log.levels.ERROR)
  end
  if #commits == 0 then
    return notify('No commits touch this file', vim.log.levels.WARN)
  end

  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local previewers = require 'telescope.previewers'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local entry_display = require 'telescope.pickers.entry_display'
  local conf = require('telescope.config').values

  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = 9 },
      { width = 10 },
      { width = 16 },
      { remaining = true },
    },
  }

  pickers
    .new({}, {
      prompt_title = string.format('Diff %s (<Tab> two commits)', vim.fn.fnamemodify(file, ':t')),
      finder = finders.new_table {
        results = commits,
        entry_maker = function(commit)
          return {
            value = commit.sha,
            ordinal = table.concat({ commit.sha, commit.subject, commit.author, commit.date }, ' '),
            -- `index` is telescope's own field on entries, so keep ours separate.
            log_index = commit.log_index,
            display = function()
              return displayer {
                { commit.sha, 'TelescopeResultsIdentifier' },
                { commit.date, 'TelescopeResultsNumber' },
                { commit.author, 'TelescopeResultsComment' },
                commit.subject,
              }
            end,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      -- Preview is scoped to the file too: just this commit's changes to it.
      previewer = previewers.git_commit_diff_to_parent.new { current_file = file, cwd = root },
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local marked = picker:get_multi_selection()

          local revision
          if #marked >= 2 then
            revision = build_range(marked)
          else
            -- Nothing marked: a bare revision makes Diffview compare it against
            -- the working tree, so uncommitted changes show up too.
            local entry = action_state.get_selected_entry()
            revision = entry and entry.value
          end

          actions.close(prompt_bufnr)
          if not revision then
            return notify('No commit selected', vim.log.levels.WARN)
          end
          vim.cmd(string.format('DiffviewOpen %s -- %s', revision, vim.fn.fnameescape(file)))
        end)
        return true
      end,
    })
    :find()
end

return M
