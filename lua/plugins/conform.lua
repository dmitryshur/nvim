return {
  'stevearc/conform.nvim',
  -- No `event` trigger: formatting is manual only (<leader>1), so the plugin is
  -- loaded by lazy's require hook when the keymap calls require('conform').
  -- BufWritePre would only have pulled it in early for a format_on_save that no
  -- longer exists.
  cmd = { 'ConformInfo' },
  opts = {
    -- Filetypes without an entry here fall back to LSP formatting (rustfmt via
    -- rust-analyzer, clangd, ...) -- the keymap passes lsp_format = 'fallback'.
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'oxfmt' },
      javascriptreact = { 'oxfmt' },
      typescript = { 'oxfmt' },
      typescriptreact = { 'oxfmt' },
      html = { 'oxfmt' },
      json = { 'oxfmt' },
    },
  },
}
