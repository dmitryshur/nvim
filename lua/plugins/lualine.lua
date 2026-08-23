return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count
    local palette = require 'jetbrains.palette'

    -- Shows the harpoon slot when the current file is pinned, so <leader>bb's
    -- effect is visible without opening the list. Empty when it isn't pinned, so
    -- the statusline stays as it was for everything else.
    --
    -- Compares against `display()`, which is already compacted, so the count is
    -- the slot number you'd see in the list. Cheap enough to run per redraw: a
    -- handful of string compares over a list that is never long.
    local function harpoon_slot()
      local ok, harpoon = pcall(require, "harpoon")
      if not ok then return "" end

      local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
      if path == "" then return "" end

      local slot = 0
      for _, line in ipairs(harpoon:list():display()) do
        if line ~= "" then
          slot = slot + 1
          if line == path then return " " .. slot end
        end
      end

      return ""
    end

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = "auto", -- picks up the active colorscheme
      },
      sections = {
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "branch" },
          { "fileformat" },
          { "filetype" },
        },
        lualine_c = {
          {
            'filename',
            file_status = true,      -- Displays file status (readonly status, modified status)
            path = 1,                -- 0: Just the filename
                                     -- 1: Relative path
                                     -- 2: Absolute path
            symbols = {
              modified = ' ●',      -- Text to show when the file is modified
              readonly = ' ',      -- Text to show when the file is non-modifiable or readonly
              unnamed = '[No Name]', -- Text to show for unnamed buffers
              newfile = '[New]',     -- Text to show for newly created file before first write
            }
          },
          {
            harpoon_slot,
            color = { fg = palette.link },
          }
        }
      },
    })
  end,
}
