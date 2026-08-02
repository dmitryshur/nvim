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
--
-- The listing itself lives in core.git_branches, shared with pull and merge.

local branches = require 'core.git_branches'

local M = {}

local function notify(message, level) vim.notify(message, level, { title = 'Git branch diff' }) end

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

      -- --imply-local points the HEAD end at the real files rather than buffers
      -- built from git, which is what keeps LSP working while you read.
      vim.cmd(string.format('DiffviewOpen %s...%s --imply-local', base, head))
    end,
  }
end

return M
