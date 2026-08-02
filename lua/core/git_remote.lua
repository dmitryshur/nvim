-- Fetch and pull without leaving the editor.
--
-- Neogit can do both, but through popups that want more keystrokes to confirm;
-- these are the no-argument cases that come up constantly while reviewing
-- someone's branch, so they run straight away and report through vim.notify.
--
-- Everything is async. `vim.system` without `:wait()` means a slow remote blocks
-- nothing, and the callback is wrapped in `vim.schedule` because it lands on the
-- libuv thread where most of the Neovim API is off limits.

local M = {}

-- One at a time per command. Mashing the key on a slow remote otherwise stacks
-- up processes that all report separately, and for pull would have them racing
-- over the same working tree.
local running = {}

local function notify(message, level) vim.notify(message, level, { title = 'Git' }) end

local function run(name, args, opts)
  opts = opts or {}
  if running[name] then return notify(name .. ' already running', vim.log.levels.WARN) end
  running[name] = true
  notify(name .. '...', vim.log.levels.INFO)

  vim.system(
    vim.list_extend({ 'git' }, args),
    { cwd = opts.cwd or vim.uv.cwd(), text = true },
    vim.schedule_wrap(function(result)
      running[name] = nil

      -- Which stream carries the interesting text depends on the outcome, and
      -- both are often populated at once. A pull that refuses to clobber local
      -- changes still prints "Updating <old>..<new>" to stdout before failing,
      -- so preferring stdout on an error would report the attempt as if it were
      -- the result. Failures come from stderr, successes from stdout -- with the
      -- other stream as the fallback, since git reports fetch progress on stderr
      -- even when it works.
      local stdout = vim.trim(result.stdout or '')
      local stderr = vim.trim(result.stderr or '')

      if result.code ~= 0 then
        local message = stderr ~= '' and stderr or stdout
        return notify(message ~= '' and message or (name .. ' failed'), vim.log.levels.ERROR)
      end

      local message = stdout ~= '' and stdout or stderr
      notify(message ~= '' and message or (name .. ': nothing new'), vim.log.levels.INFO)
      if opts.on_success then opts.on_success() end
    end)
  )
end

-- `--prune` drops remote-tracking refs for branches deleted upstream. Without it
-- they accumulate forever in the <leader>gR branch picker, which reads
-- refs/remotes directly and can't tell a stale ref from a live one.
function M.fetch() run('Fetch', { 'fetch', '--prune' }) end

-- Both pull and merge write to the working tree, so both need this afterwards.
local function reload_working_tree()
  -- For immediacy, not correctness: the check-external-file-changes autocmd in
  -- core.options would catch this on the next CursorHold anyway, but that is
  -- `updatetime` away (4s) and only once you stop typing. Same reason telescope
  -- runs checktime after its own `git checkout`.
  vim.cmd 'checktime'
  -- Likewise redundant-but-immediate: gitsigns keeps a libuv watcher on the git
  -- directory (`watch_gitdir` defaults to enabled) and would notice on its own.
  pcall(function() require('gitsigns').refresh() end)
end

-- `origin/feature/foo` has to become `origin` + `feature/foo`, and splitting on
-- the first slash only works because branch names contain slashes far more often
-- than remote names do. Matching against the actual remotes is exact.
local function split_remote_ref(ref, remotes)
  for _, remote in ipairs(remotes) do
    local branch = ref:match('^' .. vim.pesc(remote) .. '/(.+)$')
    if branch then return remote, branch end
  end
end

-- `--no-edit` on both: a pull or merge that produces a merge commit would
-- otherwise try to open $EDITOR for its message, and vim.system gives it no
-- terminal to open one in.
function M.pull()
  require('core.git_branches').pick {
    title = 'Pull branch',
    remote_only = true, -- there is nothing to pull from a local branch
    on_select = function(selected, _, root)
      if not selected then return notify('No branch selected', vim.log.levels.WARN) end

      local remote, branch = split_remote_ref(selected, require('core.git_branches').remotes(root))
      if not remote then return notify('Not a remote branch: ' .. selected, vim.log.levels.WARN) end

      run('Pull', { 'pull', '--no-edit', remote, branch }, { cwd = root, on_success = reload_working_tree })
    end,
  }
end

function M.merge()
  require('core.git_branches').pick {
    -- Local and remote both listed: `git merge origin/main` after a fetch is as
    -- common as merging a branch you have checked out.
    title = 'Merge branch into HEAD',
    on_select = function(selected, _, root)
      if not selected then return notify('No branch selected', vim.log.levels.WARN) end
      run('Merge', { 'merge', '--no-edit', selected }, { cwd = root, on_success = reload_working_tree })
    end,
  }
end

return M
