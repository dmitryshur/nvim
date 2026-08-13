local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- Local colorscheme (colors/jetbrains.lua), so it needs no plugin spec. Set
-- before lazy.setup so lualine's `theme = 'auto'` sees vim.g.colors_name and
-- picks up lua/lualine/themes/jetbrains.lua when it loads.
vim.cmd.colorscheme 'jetbrains'

require('lazy').setup({
  require 'plugins.neotree',
  require 'plugins.lualine',
  require 'plugins.treesitter',
  require 'plugins.telescope',
  require 'plugins.lsp',
  require 'plugins.blink',
  require 'plugins.diffview',
  require 'plugins.neogit',
  require 'plugins.gitsigns',
  require 'plugins.conform',
  require 'plugins.persistence',
  require 'plugins.harpoon'
});

require 'core.options'
require 'core.keymaps'
require 'core.buffer_limit'
require 'core.mark_signs'
require 'core.quickfix_persist'
