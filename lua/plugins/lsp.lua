return {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      {
        'mason-org/mason.nvim',
        cmd = 'Mason',
        ---@module 'mason.settings'
        ---@type MasonSettings
        ---@diagnostic disable-next-line: missing-fields
        opts = {},
      },
      -- Maps LSP server names between nvim-lspconfig and Mason package names.
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      -- `gr` on the same symbol reopens the previous references picker (query,
      -- selection and all) instead of starting a fresh search every time.
      local last_references_word = nil
      local smart_references = function()
        local word = vim.fn.expand '<cword>'
        if word == last_references_word then
          local cached = require('telescope.state').get_global_key 'cached_pickers' or {}
          for index, picker in ipairs(cached) do
            if picker.prompt_title == 'LSP References' then
              return require('telescope.builtin').resume { cache_index = index }
            end
          end
        end
        last_references_word = word
        require('telescope.builtin').lsp_references()
      end

      -- eslint and oxlint advertise `diagnosticProvider`, so Neovim pulls
      -- diagnostics on every didChange -- i.e. every ~150ms of typing. Worse,
      -- vim.diagnostic.show() hides the current extmarks *before* it consults
      -- `update_in_insert`, and defers the redraw to InsertLeave *or*
      -- CursorHoldI, so a half-typed line visibly churns its diagnostics.
      -- Skipping the pull while in insert mode freezes them at their last
      -- computed state instead, and costs nothing: the linters stop re-running
      -- between keystrokes. InsertLeave then pulls once, for real.
      local refresh_diagnostics = vim.lsp.diagnostic._refresh
      local gated_linters = { eslint = true, oxlint = true }

      -- `_refresh` is private. If a future Neovim drops it, skip the gating
      -- entirely rather than gate pulls we can no longer restart -- stale
      -- diagnostics forever is a worse failure than the churn we're fixing.
      if refresh_diagnostics then
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('lsp-gate-insert-mode-pulls', { clear = true }),
          callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if not client or not gated_linters[client.name] or client.insert_pull_gated then return end
            client.insert_pull_gated = true -- one client serves many buffers; only wrap it once

            local request = client.request
            client.request = function(self, method, params, handler, bufnr)
              -- Neovim's pull loop ignores the return value, so claiming
              -- success keeps the skip from reading as a dead client.
              if method == 'textDocument/diagnostic' and vim.fn.mode():sub(1, 1) == 'i' then return true, nil end
              return request(self, method, params, handler, bufnr)
            end
          end,
        })

        vim.api.nvim_create_autocmd('InsertLeave', {
          group = vim.api.nvim_create_augroup('lsp-pull-after-insert-leave', { clear = true }),
          callback = function(event)
            -- `mode()` already reports normal mode by the time InsertLeave
            -- runs, so the gate above lets these requests through.
            for _, client in ipairs(vim.lsp.get_clients { bufnr = event.buf, method = 'textDocument/diagnostic' }) do
              if gated_linters[client.name] then refresh_diagnostics(event.buf, client.id) end
            end
          end,
        })
      end

      -- Runs when an LSP attaches to a buffer, to configure that buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', '<cmd>Telescope lsp_definitions<CR>', '[G]oto [D]efinition')
          map('gr', smart_references, '[G]oto [R]eferences')
          map('gI', '<cmd>Telescope lsp_implementations<CR>', '[G]oto [I]mplementation')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Highlight references of the word under the cursor when it rests there
          -- for a little while; clear the highlights when the cursor moves.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --  See `:help lsp-config` for information about keys and how to configure
      -- Captured before the override below so oxlint's own root-marker logic
      -- (package.json mentioning oxlint, vite.config.ts with a lint field, ...)
      -- keeps working for real files.
      local upstream_oxlint_root_dir = vim.lsp.config.oxlint.root_dir

      ---@type table<string, vim.lsp.Config>
      local servers = {
         clangd = {},
        -- pyright = {},
         rust_analyzer = {},
        -- tsgo is the native (Go) TypeScript language server, distributed as
        -- @typescript/native-preview. Switch back to `ts_ls` if a feature is missing.
         tsgo = {},

        -- NOTE: `settings.run = 'onSave'` has no effect here. Both linters
        -- advertise `diagnosticProvider`, so Neovim pulls diagnostics on every
        -- didChange and never consults `run`, which only gates push diagnostics.
        -- Dropping the capability to force push silences them entirely.
        -- `update_in_insert = false` in core/options.lua is what keeps the
        -- display quiet while typing.
         eslint = {},
        -- Repos that lint with both eslint and oxlint partition their rules
        -- between the two, so eslint alone leaves gaps (e.g. react-hooks).
        -- Prefers the project-local node_modules/.bin/oxlint over the Mason one.
         oxlint = {
          -- Diffview's `diffview://...` buffers report filetype=typescript, so
          -- oxlint tries to start for them. Upstream's root_dir can't walk a
          -- pseudo-path: vim.fs.find falls back to the cwd and returns a
          -- *relative* marker, making root_dir '.'. The oxc server rejects
          -- `file://.` with InvalidParams, which surfaced as an error whenever
          -- <leader>gd / <leader>gh opened a diff. Real files only; everything
          -- else defers to upstream so the marker logic stays in one place.
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname == '' or fname:find '://' then return end
            return upstream_oxlint_root_dir(bufnr, on_dir)
          end,
        },
         tailwindcss = {},
         stylelint_lsp = {
           filetypes = { 'css', 'scss' }, -- keep it off js/ts; eslint covers those
           settings = {
             stylelint = {
               validate = { 'css', 'scss' }, -- server default omits scss
             },
           },
         },

        -- Special Lua Config, as recommended by neovim help docs
        lua_ls = {
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = {
                version = 'LuaJIT',
                path = { 'lua/?.lua', 'lua/?/init.lua' },
              },
              workspace = {
                checkThirdParty = false,
                -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                  '${3rd}/luv/library',
                  '${3rd}/busted/library',
                }),
              },
            })
          end,
          ---@type lspconfig.settings.lua_ls
          settings = {
            Lua = {
              format = { enable = false }, -- Disable formatting (formatting is done by stylua)
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed. To check the current
      -- status of installed tools and/or manually install other tools, run :Mason
      local ensure_installed = vim.tbl_keys(servers or {})
      -- mason-lspconfig maps stylelint_lsp to the deprecated 'stylelint-lsp' package,
      -- but nvim-lspconfig launches the official 'stylelint-language-server' binary.
      ensure_installed = vim.tbl_filter(function(name) return name ~= 'stylelint_lsp' end, ensure_installed)
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'oxfmt', -- Used to format JS/TS code
        'stylelint-language-server',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- mason-tool-installer only kicks off its install check from a VimEnter
      -- autocmd. This plugin spec is lazy on BufReadPre, so when the first file
      -- is opened after startup (bare `nvim`, then `:e`/Neotree) that autocmd is
      -- registered too late and never fires -- tools silently stay uninstalled.
      if vim.v.vim_did_enter == 1 then require('mason-tool-installer').check_install() end

      -- How long typing has to settle before didChange goes out (default 150).
      -- Every pull-diagnostic request rides on a didChange, so this is the
      -- other half of the insert-mode gating above -- it thins out the
      -- requests that *do* fire, tsgo's included. Must be set on '*': the
      -- debounce is per buffer and takes the minimum across attached clients,
      -- so raising it for eslint alone would change nothing while tsgo and
      -- tailwindcss sit at the default.
      vim.lsp.config('*', { flags = { debounce_text_changes = 500 } })

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  }
