return {
    'nvim-telescope/telescope.nvim', version = '*',
    cmd = 'Telescope',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        'LukasPietzschmann/telescope-tabs',
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")

        telescope.setup({
          defaults = {
            -- Not "smart": that chops leading directories, which both truncated
            -- paths at the start and silently killed match highlighting whenever
            -- the matched text was in the part it removed. This keeps the path
            -- intact and only dims the directory.
            path_display = require("core.path_display").dim_directory,
            -- Off by default, which leaves the preview titled a static "Preview".
            -- The previewers already carry a `dyn_title` returning the path
            -- relative to cwd; this is what actually lets it be used. Matters now
            -- that the grep and reference rows show only a filename -- without it
            -- there is nowhere the directory appears at all.
            dynamic_preview_title = true,
            -- Prompt on top with the best match directly under it, filling
            -- downward -- the fzf arrangement. Both settings are needed: telescope
            -- defaults to the prompt at the bottom *and* to filling the results
            -- window bottom-up, so changing only one leaves the best match at the
            -- far end of the list from the prompt. prompt_position sits directly
            -- under layout_config rather than inside `horizontal` so it survives a
            -- change of layout_strategy.
            sorting_strategy = "ascending",
            layout_config = { prompt_position = "top" },
            cache_picker = { num_pickers = 10 }, -- keep recent pickers resumable, not just the last one
            mappings = {
              i = {
                ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                ["<C-j>"] = actions.move_selection_next, -- move to next result
                ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                ["<esc>"] = actions.close
              },
            },
          },
          pickers = {
            find_files = {
              find_command = function(opts)
                local cwd = opts.cwd or vim.uv.cwd()
                local root = vim.fs.root(cwd, '.git') or cwd
                local ignore_file = vim.fs.joinpath(root, '.vim', 'telescope-ignore')
                local command = {
                  "fd",
                  "--type",
                  "f",
                  "--color",
                  "never",
                  "--hidden",
                  "--exclude",
                  ".git",
                }

                if vim.uv.fs_stat(ignore_file) then
                  vim.list_extend(command, { "--no-ignore", "--ignore-file", ignore_file })
                end
                return command
              end,
            },
            buffers = {
              sort_mru = true,
              ignore_current_buffer = true,
              -- Filename / last cursor line / directory, matching the reference
              -- picker, instead of the stock bufnr + status-flags + path:lnum.
              entry_maker = require("core.buffer_entry").entry_maker,
            },
            -- `<leader><leader>` live grep. Same problem as the references
            -- picker: the stock vimgrep entry maker concatenates
            -- path:lnum:col:text into one unaligned string, and ripgrep's line
            -- arrives with its original indentation.
            live_grep = {
              entry_maker = require("core.grep_entry").entry_maker,
            },
            -- `gr` references. The stock quickfix entry maker crams
            -- path:lnum:col:text into one uncoloured string; this lays it out in
            -- aligned, separately highlighted columns instead.
            lsp_references = {
              -- Usages only. The definition is what you pressed gr *from*, so
              -- listing it again is a row that never gets picked.
              include_declaration = false,
              entry_maker = require("core.reference_entry").entry_maker,
            }
          }
        })

        -- The plugin was already a dependency and was already being built, but
        -- without this it was never actually in play: telescope kept using its
        -- bundled Lua `fzy` sorter. Loading it swaps in the native matcher and
        -- brings fzf's query syntax ('exact, ^prefix, suffix$, !negate).
        telescope.load_extension("fzf")
        telescope.load_extension("telescope-tabs")
      end,
}
