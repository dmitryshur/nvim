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
      -- Neovim 0.12 renders textDocument/documentColor results as coloured
      -- backgrounds and enables it by default, so tailwindcss-language-server
      -- paints every colour-bearing class -- `text-black-35 dark:text-black-15`
      -- and so on -- in the colour it resolves to. Informative in a stylesheet,
      -- noise in a className list, where most of the string isn't a colour.
      --
      -- Off globally rather than per-filetype: tailwind is the only server here
      -- with a colorProvider, so there is nothing else to preserve. `style` also
      -- accepts 'foreground' or 'virtual' if a quieter form is ever wanted.
      vim.lsp.document_color.enable(false)

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
      local force_diagnostic_pull = {}
      local reload_hooks = {}

      -- `_refresh` is private. If a future Neovim drops it, skip the gating
      -- entirely rather than gate pulls we can no longer restart -- stale
      -- diagnostics forever is a worse failure than the churn we're fixing.
      if refresh_diagnostics then
        local function attach_reload_hook(bufnr)
          if reload_hooks[bufnr] then return end
          reload_hooks[bufnr] = true

          vim.api.nvim_buf_attach(bufnr, false, {
            on_reload = function(_, reloaded_bufnr)
              -- Neovim's pull-diagnostic handler also refreshes on reload, but
              -- the insert-mode gate above intentionally rejects that request.
              -- Allow one pull for the new on-disk contents without re-enabling
              -- diagnostic churn for ordinary insert-mode changes.
              if vim.fn.mode():sub(1, 1) ~= 'i' then return end

              vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(reloaded_bufnr) then return end

                force_diagnostic_pull[reloaded_bufnr] = true
                for _, client in ipairs(vim.lsp.get_clients { bufnr = reloaded_bufnr, method = 'textDocument/diagnostic' }) do
                  if gated_linters[client.name] then refresh_diagnostics(reloaded_bufnr, client.id) end
                end
                force_diagnostic_pull[reloaded_bufnr] = nil
              end)
            end,
            on_detach = function(_, detached_bufnr)
              force_diagnostic_pull[detached_bufnr] = nil
              reload_hooks[detached_bufnr] = nil
            end,
          })
        end

        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('lsp-gate-insert-mode-pulls', { clear = true }),
          callback = function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if not client or not gated_linters[client.name] then return end

            attach_reload_hook(event.buf)
            if client.insert_pull_gated then return end
            client.insert_pull_gated = true -- one client serves many buffers; only wrap it once

            local request = client.request
            client.request = function(self, method, params, handler, bufnr)
              -- Neovim's pull loop ignores the return value, so claiming
              -- success keeps the skip from reading as a dead client.
              if method == 'textDocument/diagnostic' and vim.fn.mode():sub(1, 1) == 'i' and not force_diagnostic_pull[bufnr] then return true, nil end
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

      -- nvim-lspconfig 2.x dropped :LspRestart and Neovim 0.12 ships no built-in
      -- :Lsp, so restore it. Needed mostly for writes that bypass Neovim (an agent
      -- editing files, a rebase): a server keeps its own copy of every file it read
      -- off disk, and only the buffers Neovim has open stay in sync via
      -- didOpen/didChange. tsgo relies entirely on the client to tell it a file
      -- changed, and Neovim doesn't by default, so an unopened dependency goes stale
      -- and reports errors `tsc` never sees.
      -- How long a server gets to honour `shutdown` before it is killed. Measured
      -- rather than picked: lua_ls never exits politely at all -- `is_stopped()`
      -- flips true within a millisecond but the client sits in the registry
      -- indefinitely -- and the forced kill then completes in tens of
      -- milliseconds. The old 3000 was three seconds of waiting for something
      -- that does not happen. This is a grace period for well-behaved servers,
      -- not a deadline anything is expected to use.
      local POLITE_EXIT_MS = 300
      local FORCED_EXIT_MS = 2000
      local POLL_MS = 25

      -- What vim.lsp.enable() itself uses to attach pre-existing buffers. Unlike
      -- :edit it leaves unsaved changes alone, and it covers every loaded buffer
      -- rather than only the current one.
      local reattach = function() vim.cmd.doautoall 'nvim.lsp.enable FileType' end

      vim.api.nvim_create_user_command('LspRestart', function()
        local stopped = vim.lsp.get_clients()
        if #stopped == 0 then return reattach() end

        for _, client in ipairs(stopped) do
          client:stop()
        end

        local function all_exited()
          for _, client in ipairs(stopped) do
            if vim.lsp.get_client_by_id(client.id) then return false end
          end
          return true
        end

        -- Polled on a uv timer rather than through vim.wait. vim.wait spins the
        -- event loop but refuses input for its whole duration, so waiting on the
        -- servers froze the editor; this returns immediately and finishes in the
        -- background. stop() is async and the attach path skips a buffer whose
        -- config is already running, so the re-attach still has to wait for the
        -- old clients to actually go -- it just no longer does that in the
        -- foreground.
        local timer = vim.uv.new_timer()
        local elapsed, forced = 0, false

        local finish = function(warning)
          timer:stop()
          timer:close()
          reattach()
          if warning then vim.notify(warning, vim.log.levels.WARN, { title = 'LspRestart' }) end
        end

        timer:start(
          POLL_MS,
          POLL_MS,
          vim.schedule_wrap(function()
            elapsed = elapsed + POLL_MS

            if all_exited() then return finish() end

            -- A forced kill exits non-zero, which makes Neovim warn, so it is
            -- worth asking politely first -- but only briefly, since a wedged
            -- server is half the reason to reach for this command.
            if not forced and elapsed >= POLITE_EXIT_MS then
              forced = true
              for _, client in ipairs(stopped) do
                if vim.lsp.get_client_by_id(client.id) then client:stop(true) end
              end
            end

            if elapsed >= POLITE_EXIT_MS + FORCED_EXIT_MS then
              finish 'Some clients ignored both shutdown and kill; re-attached anyway'
            end
          end)
        )
      end, { desc = 'Restart all LSP clients so they re-read files from disk' })

      -- Deliberately global rather than buffer-local like the LspAttach maps below:
      -- a server that crashed or never attached is exactly when this is needed, and
      -- a buffer-local map wouldn't exist in that case.
      vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart<CR>', { desc = '[L]sp [R]estart' })

      -- Runs when an LSP attaches to a buffer, to configure that buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', '<cmd>Telescope lsp_definitions<CR>', '[G]oto [D]efinition')
          -- Always a fresh textDocument/references request. <leader>r (telescope
          -- resume) is the deliberate way back to the previous picker, so gr does
          -- not need to second-guess whether you wanted the old results.
          map('gr', '<cmd>Telescope lsp_references<CR>', '[G]oto [R]eferences')
          map('gI', '<cmd>Telescope lsp_implementations<CR>', '[G]oto [I]mplementation')
          -- Finding a symbol rather than following one. Buffer-local like the rest
          -- of these because both need a client attached to answer.
          --
          -- `gs` shadows the built-in "goto sleep" (:sleep for N seconds), which is
          -- not something anyone reaches for by accident. `gS` has no built-in
          -- meaning at all.
          map('gs', '<cmd>Telescope lsp_document_symbols<CR>', '[G]oto [S]ymbol in file')
          map('gS', '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>', '[G]oto [S]ymbol in project')
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
            map('<leader>lh', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[L]sp Inlay [H]ints')
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
        -- One TypeScript server at a time: two would double every diagnostic and
        -- every completion entry.
        --
        -- tsgo is the native (Go) port, distributed as @typescript/native-preview,
        -- and much faster to typecheck. The known cost: it returns nothing for
        -- completions inside an unfinished import clause (`import {Butt`), where
        -- vtsls -- VS Code's Node tsserver engine, and what Zed runs -- offers every
        -- importable symbol. Type the bare name in the body instead and accept the
        -- auto-import; tsgo handles that case fine.
        --
        -- Swap the two lines below to try vtsls again. It stays installed in Mason.
         tsgo = {},
        -- vtsls = {},

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
          settings = { typeAware = false },
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
      -- Neovim's own default is `dynamicRegistration = false`, which tells every
      -- server "I cannot watch files for you". Servers then never register any
      -- watchers, Neovim never sends workspace/didChangeWatchedFiles, and a file
      -- changed on disk by anything other than Neovim is invisible to them --
      -- which is the whole reason :LspRestart gets reached for so often. Buffers
      -- Neovim has open recover by themselves (checktime reloads them and the
      -- reload sends didChange); it is the files that aren't open that go stale.
      --
      -- Turning it on is affordable here: with inotifywait installed Neovim uses
      -- it instead of polling, it excludes node_modules and .git/objects the same
      -- way VS Code does, and this tree is ~7k watchable directories against an
      -- inotify limit of ~530k.
      vim.lsp.config('*', {
        flags = { debounce_text_changes = 500 },
        capabilities = {
          workspace = {
            didChangeWatchedFiles = { dynamicRegistration = true },
          },
        },
      })

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  }
