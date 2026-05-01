vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<backspace>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal float toggle<CR>', { desc = 'Move focus to the upper window' })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader><leader>', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<tab>', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>r', builtin.resume, { desc = 'Telescope buffers' })
