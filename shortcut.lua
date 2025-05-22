-- Перемещение по буферам
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true })  -- Tab для следующего буфера
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true })  -- Shift+Tab для предыдущего буфера
