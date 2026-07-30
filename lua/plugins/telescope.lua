return {
    'nvim-telescope/telescope.nvim', version = '*',
    cmd = 'Telescope',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
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
            buffers = {
              sort_mru = true,
              ignore_current_buffer = true,
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
      end,
}
