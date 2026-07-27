return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'oxfmt' },
      javascriptreact = { 'oxfmt' },
      typescript = { 'oxfmt' },
      typescriptreact = { 'oxfmt' },
    },
    -- Fall back to LSP formatting (rustfmt via rust-analyzer, clangd, ...)
    -- for filetypes without an entry above.
    format_on_save = {
      timeout_ms = 1000,
      lsp_format = 'fallback',
    },
  },
}
