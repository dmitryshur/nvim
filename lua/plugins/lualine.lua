return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

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
          }
        }
      },
    })
  end,
}
