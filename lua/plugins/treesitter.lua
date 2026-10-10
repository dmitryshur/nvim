return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  main = "nvim-treesitter",
  -- build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    -- nvim-treesitter's ecma query, which javascript, typescript and tsx all
    -- inherit, captures every capitalised identifier as @type -- so the
    -- `PortfoliosContext` in an import list or in `use(PortfoliosContext)` is
    -- coloured like a type annotation. Renaming that one capture to
    -- @type.capitalised lets a colorscheme treat the guess on its own: one that
    -- doesn't define the group falls back to @type and looks the same as before.
    --
    -- The loaded query is rewritten rather than replaced by a copy of the file,
    -- which would go stale with every nvim-treesitter update. An `; extends` file
    -- can't do it either: it can only add patterns, and one added after the rest
    -- would also beat the @function, @constant and @tag captures on the same
    -- identifiers. query.set() only stores the text, so nothing is parsed -- and
    -- no parser loaded -- until a buffer of that language needs it.
    local CAPITALISED_TYPE = '((identifier) @type\n  (#lua-match? @type "^[A-Z]"))'
    local CAPITALISED_TYPE_RENAMED = '((identifier) @type.capitalised\n  (#lua-match? @type.capitalised "^[A-Z]"))'

    for _, lang in ipairs { "javascript", "typescript", "tsx" } do
      local files = vim.treesitter.query.get_files(lang, "highlights")
      local contents = vim.tbl_map(function(file)
        return table.concat(vim.fn.readfile(file), "\n")
      end, files)
      local source = table.concat(contents, "\n")
      local start, finish = source:find(CAPITALISED_TYPE, 1, true)

      if start then
        vim.treesitter.query.set(lang, "highlights", source:sub(1, start - 1) .. CAPITALISED_TYPE_RENAMED .. source:sub(finish + 1))
      elseif #files > 0 then
        vim.notify(
          string.format("The ecma query's capitalised @type pattern changed; %s keeps colouring it as a type", lang),
          vim.log.levels.WARN,
          { title = "Treesitter" }
        )
      end
    end

    local highlight = function(bufnr, lang)
      -------------------[ treesitter highlights ]-------------------------------
      if not vim.treesitter.language.add(lang) then
        return vim.notify(
          string.format("Treesitter cannot load parser for language: %s", lang),
          vim.log.levels.INFO,
          { title = "Treesitter" }
        )
      end
      vim.treesitter.start(bufnr)
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype
        local bt = vim.bo[buf].buftype
        local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
        -- FFF reuses this nofile buffer for real file contents and changes its
        -- filetype for each selection, so it still needs a Tree-sitter parser.
        local is_fff_preview = bt == 'nofile' and buffer_name == 'fffile preview'

        if bt ~= "" and not is_fff_preview then
          return
        end   -- don't run further.

        local ok, treesitter = pcall(require, "nvim-treesitter")
        if not ok then
          return
        end

        ---------------------[ treesitter indent ]-------------------------------

        if not is_fff_preview and not vim.tbl_contains({ "python", "html", "yaml", "markdown" }, ft) then
          vim.bo[buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end

        --------------------[ treesitter parsers ]-------------------------------
        if vim.fn.executable "tree-sitter" ~= 1 then
          return -- config() already reported the missing CLI once
        end

        -- get_installed()/get_available()/install() all speak parser (language)
        -- names, not filetypes. Most of the time they're spelled the same, which
        -- hides the difference -- but typescriptreact maps to `tsx`,
        -- javascriptreact to `javascript`, sh to `bash`. Passing `ft` there
        -- matched nothing for those, so highlighting silently never started.
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
          return
        end

        if vim.list_contains(treesitter.get_installed(), lang) then
          highlight(buf, lang)
        elseif vim.list_contains(treesitter.get_available(), lang) then
          treesitter.install(lang):await(function()
            highlight(buf, lang)
          end)
        end
      end,
    })
  end,
  opts = {
    install = {
      "css",
      "comment",
      "markdown",
      "markdown_inline",
      "regex",
      "vimdoc",
      "json",
      "javascript",
      "typescript",
      "tsx",
      "yaml",
      "html",
      "prisma",
      "svelte",
      "graphql",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      "gitignore",
      "query",
      "c",
      "ruby",
      "rust",
      "go",
      "zig",
    },
  },
  config = function(_, opts)
    local treesitter = require "nvim-treesitter"
    treesitter.setup(opts)
    if vim.fn.executable "tree-sitter" ~= 1 then
      vim.api.nvim_echo({
        {
          "tree-sitter CLI not found. Parsers cannot be installed.",
          "ErrorMsg",
        },
      }, true, {})
      return false
    end
    treesitter.install(opts.install)
  end,
}
