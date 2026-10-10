-- Pick branches and diff every file that differs between them, in CodeDiff.
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
--
-- The listing itself lives in core.git_branches, shared with pull and merge.

local branches = require 'core.git_branches'

local M = {}

local function notify(message, level) vim.notify(message, level, { title = 'Git branch diff' }) end

-- Whether `head` is the commit you have checked out, either by name or because
-- the branch points at it.
local function is_checked_out(head)
  if head == 'HEAD' then return true end
  local result = vim.system({ 'git', 'rev-parse', head, 'HEAD' }, { cwd = branches.root(), text = true }):wait()
  local shas = vim.split(vim.trim(result.stdout or ''), '\n')
  return result.code == 0 and shas[1] == shas[2]
end

function M.pick()
  branches.pick {
    title = 'Diff branches (<CR> vs HEAD, or <Tab> base then head)',
    on_select = function(selected, marked)
      local base, head
      if #marked >= 2 then
        base, head = marked[1], marked[2]
      else
        -- Nothing marked: diff the highlighted branch against where you are.
        -- This is the pull-request case once you've checked the branch out --
        -- highlight the base branch and press <CR>.
        base, head = selected, 'HEAD'
      end

      if not base then return notify('No branch selected', vim.log.levels.WARN) end
      if base == head then return notify('Base and head are the same', vim.log.levels.WARN) end

      -- Leaving the target off (`base...`) diffs the merge base against the
      -- working tree, so when head is what you have checked out, that side is
      -- the real files rather than buffers built from git -- which is what keeps
      -- LSP working while you read.
      local target = is_checked_out(head) and '' or head
      vim.cmd(string.format('CodeDiff %s...%s', base, target))
    end,
  }
end

return M
