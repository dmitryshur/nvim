-- Everything the <leader>b* keymaps do with the harpoon list, plus the telescope
-- UI that replaces harpoon's own quick menu.
--
-- The picker exists for the file preview, and for the two-column layout the
-- reference and grep pickers use -- filename, then the directory dimmed behind it:
--
--   keymaps.lua           lua/core/
--   PortfolioTabItem.tsx  src/screens/Account/Portfolio/ActivePortfolioPage/
--
-- gen_from_file does the parsing (cwd resolution, `path` for the previewer) and
-- only its display is swapped out, the same way core.grep_entry wraps the vimgrep
-- maker. `entry.value` stays the untouched path, which is also what harpoon
-- stores, so the two can be compared directly.

-- Telescope binds this to select_horizontal globally; the override below is scoped
-- to this picker, so <C-x> still opens a horizontal split everywhere else.
local UNPIN_KEY = '<C-x>'
local SEPARATOR = '  '

local columns = require 'core.picker_columns'

----------------------------------------------------------------------- list --

local function list()
  return require('harpoon'):list()
end

--- The list's contents as plain paths. `display()` yields "" for a slot that was
--- nil'd out, which nothing here has any use for.
local function paths(harpoon_list)
  local results = {}
  for _, line in ipairs(harpoon_list:display()) do
    if line ~= '' then results[#results + 1] = line end
  end
  return results
end

--- Write the list back from a compacted set of paths. resolve_displayed is the
--- same call harpoon's own menu makes when you edit it, so a removal can't leave
--- the hole that remove_at does -- which renders as a blank row and survives a
--- save. The sync is ours to do: save_on_toggle only fires for that menu, and the
--- autocmd only on exit.
local function remove(harpoon_list, removed_paths)
  local drop = {}
  for _, path in ipairs(removed_paths) do
    drop[path] = true
  end

  local kept = {}
  for _, line in ipairs(paths(harpoon_list)) do
    if not drop[line] then kept[#kept + 1] = line end
  end

  harpoon_list:resolve_displayed(kept, #kept)
  require('harpoon'):sync()
end

-------------------------------------------------------------------- display --

-- Filename holds a stable width -- it's what the eye runs down -- while the
-- directory takes everything left over and sits last, so its padding is trailing
-- whitespace rather than a visible gap mid-row.
local filename_width = columns.share(0.34, 14, 34)
local build_displayer = columns.displayer {
  separator = SEPARATOR,
  links = {
    TelescopePickerFile = 'Directory',
    TelescopePickerDirectory = 'Comment',
  },
  items = {
    { width = filename_width },
    { width = columns.remaining({ filename_width }, #SEPARATOR) },
  },
}

local function make_display(entry)
  local relative = vim.fn.fnamemodify(entry.value, ':.')
  local directory = vim.fn.fnamemodify(relative, ':h')

  return build_displayer() {
    { vim.fn.fnamemodify(relative, ':t'), 'TelescopePickerFile' },
    { directory == '.' and '' or directory .. '/', 'TelescopePickerDirectory' },
  }
end

local function entry_maker(line)
  local entry = require('telescope.make_entry').gen_from_file {}(line)
  entry.display = make_display
  return entry
end

--------------------------------------------------------------------- public --

local M = {}

--- Pin the current file, or unpin it if it is already in the list.
function M.toggle()
  local harpoon_list = list()
  local item = harpoon_list.config.create_list_item(harpoon_list.config)
  local _, index = harpoon_list:get_by_value(item.value)

  if index then
    remove(harpoon_list, { item.value })
    vim.notify('Unpinned ' .. item.value, vim.log.levels.INFO, { title = 'Harpoon' })
  else
    harpoon_list:add(item)
    require('harpoon'):sync()
    vim.notify('Pinned ' .. item.value, vim.log.levels.INFO, { title = 'Harpoon' })
  end
end

--- Empty the list for this project. Immediate and not undoable, which is why the
--- message carries the count -- it's the only record of what was there.
function M.clear()
  local harpoon_list = list()
  local removed = #paths(harpoon_list)

  if removed == 0 then
    vim.notify('Nothing pinned', vim.log.levels.INFO, { title = 'Harpoon' })
    return
  end

  harpoon_list:clear()
  require('harpoon'):sync()
  vim.notify(string.format('Cleared %d pinned file(s)', removed), vim.log.levels.WARN, { title = 'Harpoon' })
end

local function finder()
  return require('telescope.finders').new_table { results = paths(list()), entry_maker = entry_maker }
end

--- The list, with a preview of whatever is under the cursor.
function M.list()
  local conf = require('telescope.config').values

  require('telescope.pickers')
    .new({}, {
      prompt_title = 'Harpoon',
      finder = finder(),
      previewer = conf.file_previewer {},
      -- Sorted, so the prompt filters -- but with an empty prompt the list keeps
      -- harpoon's own order, which is the order you arranged it in.
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        map({ 'i', 'n' }, UNPIN_KEY, function()
          local state = require 'telescope.actions.state'
          local picker = state.get_current_picker(prompt_bufnr)

          -- Honours a Tab multi-selection, falling back to the highlighted row when
          -- nothing is ticked -- otherwise Tab would appear to do nothing here.
          local removed = {}
          for _, entry in ipairs(picker:get_multi_selection()) do
            removed[#removed + 1] = entry.value
          end

          if #removed == 0 then
            local entry = state.get_selected_entry()
            if not entry then return end
            removed = { entry.value }
          end

          remove(list(), removed)
          -- Refreshed in place rather than closing, so several passes are possible.
          -- The prompt is left alone so a filter you typed still applies.
          picker:refresh(finder(), { reset_prompt = false })
          vim.notify(string.format('Unpinned %d file(s)', #removed), vim.log.levels.INFO, { title = 'Harpoon' })
        end)

        return true
      end,
    })
    :find()
end

return M
