return function()
  local telescope = safe_require("telescope")
  if not telescope then
    return
  end

  local actions = require("telescope.actions")
  telescope.setup({
    defaults = {
      layout_config = { horizontal = { preview_width = 0.5 } },
      file_ignore_patterns = { "node_modules/.*" },
      color_devicons = true,
      mappings = {
        i = {
          ["<C-c>"] = actions.close,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<CR>"] = actions.select_default,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-v>"] = actions.select_vertical,
          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
        },
        n = {
          ["<CR>"] = actions.select_default,
          ["j"] = actions.move_selection_next,
          ["k"] = actions.move_selection_previous,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-v>"] = actions.select_vertical,
          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
        },
      },
    },
    pickers = {
      help_tags = {
        theme = "dropdown",
      },
      current_buffer_fuzzy_find = {
        previewer = false,
      },
      find_files = {
        layout_strategy = "vertical",
        layout_config = {
          preview_cutoff = 0,
          preview_height = 0.7,
        },
      },
      git_files = {
        layout_strategy = "vertical",
        layout_config = {
          preview_cutoff = 0,
          preview_height = 0.7,
        },
      },
      buffers = {
        previewer = false,
        layout_config = {
          height = 0.5,
          width = 0.5,
        },
      },
    },
  })
end
