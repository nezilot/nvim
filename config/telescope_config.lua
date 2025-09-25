-- Use vim.keymap.set instead of vim.api.nvim_set_keymap
local keymap = vim.keymap.set

-- Map <leader>f to fzf-lua's file search (открывать в текущем буфере)
keymap("n", "<leader>f", function()
  require("fzf-lua").files({ 
    actions = {
      ["default"] = require("fzf-lua.actions").file_edit,
    }
  })
end, { desc = "Fzf files" })

-- Map <leader>g to fzf-lua's live grep (открывать файл на строке с результатом)
keymap("n", "<leader>g", function()
  require("fzf-lua").live_grep({ 
    actions = {
      ["default"] = require("fzf-lua.actions").file_edit,
    }
  })
end, { desc = "Fzf live grep" })
