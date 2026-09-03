return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  main = "nvim-treesitter",
  -- build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  init = function()
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
