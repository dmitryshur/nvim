return {
  'folke/persistence.nvim',
  -- Needs to load on its own rather than via the require hook in a keymap: the
  -- session is written by an autocmd registered at setup, so a plugin that only
  -- woke up when you pressed the restore key would never have saved anything.
  event = 'BufReadPre',
  -- Defaults are what we want: sessions under stdpath('state')/sessions, keyed by
  -- cwd *and* git branch, and skipped entirely unless at least one real file
  -- buffer is open (`need = 1`) so quitting out of an empty nvim doesn't clobber
  -- a good session.
  opts = {},
  config = function(_, opts)
    require('persistence').setup(opts)

    -- Neither Neo-tree nor the toggleterm terminals survive `mksession` in any
    -- useful form -- the tree comes back as an empty window, the terminal as a
    -- dead buffer -- and `sessionoptions` includes `terminal`. Close them while
    -- the session is being written so what gets restored is just the real files.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'PersistenceSavePre',
      group = vim.api.nvim_create_augroup('persistence-cleanup', { clear = true }),
      callback = function()
        pcall(vim.cmd, 'Neotree close')
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == 'terminal' then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
        end
      end,
    })
  end,
}
