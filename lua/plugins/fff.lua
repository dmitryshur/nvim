return {
  'dmtrKovalenko/fff',
  build = function() require('fff.download').download_or_build_binary() end,
  lazy = false,
  opts = {
    follow_symlinks = true,
    wrap_around = false,
    layout = {
      prompt_position = 'top',
    },
    keymaps = {
      move_up = { '<Up>', '<C-k>' },
      move_down = { '<Down>', '<C-j>' },
      preview_scroll_up = '<C-b>',
      preview_scroll_down = '<C-f>',
      grep_jump_to_next_file = { '<C-d>', '<A-Down>' },
      grep_jump_to_prev_file = { '<C-u>', '<A-Up>' },
    },
    grep = {
      enable_filename_constraint = true,
      max_matches_per_file = 5,
    },
  },
}
