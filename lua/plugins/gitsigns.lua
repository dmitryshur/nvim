return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require('gitsigns')

      local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'Git: ' .. desc })
      end

      -- Jump between hunks; fall back to normal ]c/[c behavior in diff mode
      local next_hunk = function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gitsigns.nav_hunk('next')
        end
      end
      local prev_hunk = function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gitsigns.nav_hunk('prev')
        end
      end
      map('n', ']h', next_hunk, 'Next hunk')
      map('n', '[h', prev_hunk, 'Previous hunk')

      -- Show the diff for the whole buffer inline: highlight added/changed
      -- lines, render deleted lines as virtual lines, word-level diff.
      local toggle_inline_diff = function()
        gitsigns.toggle_linehl()
        gitsigns.toggle_deleted()
        gitsigns.toggle_word_diff()
      end
      map('n', '<leader>gc', toggle_inline_diff, 'Toggle inline diff (all hunks)')
      map('n', '<leader>hs', gitsigns.stage_hunk, 'Stage hunk (again to unstage)')
      map('n', '<leader>hr', gitsigns.reset_hunk, 'Reset hunk')
      map('n', '<leader>hb', gitsigns.blame_line, 'Blame line')
    end,
  },
}
