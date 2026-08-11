local M = {}

local function notify(message, level)
  vim.notify(message, level, { title = 'Git pull request' })
end

local function blame_context()
  if vim.bo.filetype ~= 'gitsigns-blame' then
    return nil, 'Open the Gitsigns blame panel first'
  end

  local blame_bufname = vim.api.nvim_buf_get_name(0)
  local line = vim.api.nvim_win_get_cursor(0)[1]

  -- Gitsigns keeps the full SHA in the source buffer's cache; matching the
  -- generated blame buffer name avoids parsing its abbreviated display text.
  for _, entry in pairs(require('gitsigns.cache').cache) do
    local entry_blame_bufname = entry:get_rev_bufname():gsub('^gitsigns:', 'gitsigns-blame:')
    if entry_blame_bufname == blame_bufname then
      local info = entry.blame and entry.blame.entries[line]
      if not info then
        return nil, 'No commit found for this line'
      end
      if info.commit.sha:match '^0+$' then
        return nil, 'This line has not been committed yet'
      end

      return { root = entry.git_obj.repo.toplevel, sha = info.commit.sha }
    end
  end

  return nil, 'Could not find the source buffer for this blame panel'
end

local function copy_url(url)
  vim.fn.setreg('+', url)
  notify('Copied ' .. url, vim.log.levels.INFO)
end

function M.copy_url()
  local context, err = blame_context()
  if not context then
    return notify(err, vim.log.levels.WARN)
  end
  if vim.fn.executable 'gh' ~= 1 then
    return notify('GitHub CLI (gh) is not installed', vim.log.levels.ERROR)
  end

  local endpoint = 'repos/{owner}/{repo}/commits/' .. context.sha .. '/pulls'
  vim.system(
    { 'gh', 'api', endpoint, '--jq', '.[].html_url' },
    { cwd = context.root, text = true },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        local message = vim.trim(result.stderr or '')
        return notify(message ~= '' and message or 'Failed to query GitHub', vim.log.levels.ERROR)
      end

      local urls = vim.split(vim.trim(result.stdout or ''), '\n', { trimempty = true })
      if #urls == 0 then
        return notify('No pull request is associated with this commit', vim.log.levels.WARN)
      end
      if #urls == 1 then
        return copy_url(urls[1])
      end

      vim.ui.select(urls, { prompt = 'Pull request URL' }, function(url)
        if url then
          copy_url(url)
        end
      end)
    end)
  )
end

function M.setup()
  vim.api.nvim_create_user_command('GitCopyPullRequestUrl', M.copy_url, {
    desc = 'Copy the pull request URL for the selected Gitsigns blame commit',
    force = true,
  })

  local group = vim.api.nvim_create_augroup('GitPullRequest', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'gitsigns-blame',
    callback = function(args)
      vim.keymap.set('n', '<leader>gx', M.copy_url, {
        buffer = args.buf,
        desc = 'Copy pull request URL',
        silent = true,
      })
    end,
  })
end

return M
