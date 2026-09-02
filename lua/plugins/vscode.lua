return {
  'Mofiqul/vscode.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark'

    local colors = require('vscode.colors').get_colors()
    local diff = {
      add = '#2e3226',
      add_text = '#373d29',
      change = '#2e1d1d',
      change_text = '#391b1b',
      delete = '#3b1b1b',
      delete_text = '#4f1818',
    }

    require('vscode').setup {
      style = 'dark',
      transparent = false,
      disable_nvimtree_bg = true,
      group_overrides = {
        DiffAdd = { bg = diff.add },
        DiffChange = { bg = diff.change },
        DiffDelete = { bg = diff.delete },
        DiffText = { bg = diff.delete_text },
        GitSignsAddLn = { bg = diff.add },
        GitSignsChangeLn = { bg = diff.change },
        GitSignsDeleteLn = { bg = diff.delete },
        GitSignsAddInline = { bg = diff.add_text },
        GitSignsChangeInline = { bg = diff.change_text },
        GitSignsDeleteInline = { bg = diff.delete_text },
        GitSignsAddPreview = { bg = diff.add },
        GitSignsDeletePreview = { bg = diff.delete },
        DiffviewDiffTextAdd = { bg = diff.add_text },
        DiffviewDiffTextAsDelete = { bg = diff.delete_text },
        NeogitDiffAdd = { fg = colors.vscGitAdded, bg = diff.add },
        NeogitDiffAddHighlight = { fg = colors.vscGitAdded, bg = diff.add_text },
        NeogitDiffDelete = { fg = colors.vscGitDeleted, bg = diff.delete },
        NeogitDiffDeleteHighlight = { fg = colors.vscGitDeleted, bg = diff.delete_text },
        NeoTreeNormal = { fg = colors.vscFront, bg = colors.vscBack },
        NeoTreeNormalNC = { fg = colors.vscFront, bg = colors.vscBack },
        NeoTreeEndOfBuffer = { fg = colors.vscBack, bg = colors.vscBack },
        NeoTreeWinSeparator = { fg = colors.vscTabOther, bg = colors.vscBack },
        NeoTreeIndentMarker = { fg = colors.vscTabOther },
        NeoTreeDirectoryIcon = { fg = colors.vscLineNumber },
        NeoTreeDirectoryName = { fg = colors.vscFront },
        NeoTreeExpander = { fg = colors.vscLineNumber },
        NeoTreeRootName = { fg = colors.vscFront, bold = true },
      },
    }

    vim.cmd.colorscheme 'vscode'
  end,
}
