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
      map('n', 'hs', gitsigns.stage_hunk, 'Stage hunk (again to unstage)')
      map('n', 'hr', gitsigns.reset_hunk, 'Reset hunk')
      -- Same action on the <leader>g* git prefix. Note this does not shadow the
      -- built-in `g-` (older text state): that's a bare `g-`, this is the
      -- three-key sequence <leader>g-.
      map('n', '<leader>g-', gitsigns.reset_hunk, 'Reset hunk')
      map('n', '<leader>hb', gitsigns.blame_line, 'Blame line')
    end,
  },
  config = function(_, opts)
    require('gitsigns').setup(opts)

    -- Whole hunk lines stay subtle; word-level regions carry the stronger tint.
    -- Background-only groups preserve Treesitter and semantic-token foregrounds.
    for group, highlight in pairs {
      GitSignsAddLn = { bg = '#242927' },
      GitSignsChangeLn = { bg = '#262a32' },
      GitSignsDeleteVirtLn = { bg = '#2f2627' },
      GitSignsAddInline = { bg = '#303b33' },
      GitSignsChangeInline = { bg = '#333a4b' },
      GitSignsDeleteInline = { bg = '#483233' },
      GitSignsAddLnInline = { bg = '#303b33' },
      GitSignsChangeLnInline = { bg = '#333a4b' },
      GitSignsDeleteLnInline = { bg = '#483233' },
      GitSignsDeleteVirtLnInLine = { bg = '#483233' },
    } do
      vim.api.nvim_set_hl(0, group, highlight)
    end
  end,
}
