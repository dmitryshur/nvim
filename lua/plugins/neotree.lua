return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = 'Neotree',
  opts = {
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false, -- close auto-expanded dirs when leaving them
      },
    },
  },
}
