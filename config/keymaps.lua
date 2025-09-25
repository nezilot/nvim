vim.keymap.set('n', 'q', '<Cmd>bd<CR>', { desc = 'close current buffer' })

vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>', { desc = 'Save file and exit insert mode' })

vim.keymap.set('i', '[', '<Esc>:move .+1<CR>==gi', { desc = 'Move line down' })

vim.keymap.set('i', ']', '<Esc>:move .-2<CR>==gi', { desc = 'Move line up' })

vim.keymap.set('i', '<C-h>', '<Left>', { desc = 'Move left' })
vim.keymap.set('i', '<C-j>', '<Down>', { desc = 'Move down' })
vim.keymap.set('i', '<C-k>', '<Up>', { desc = 'Move up' })
vim.keymap.set('i', '<C-l>', '<Right>', { desc = 'Move right' })


vim.keymap.set('i', '<C-a>', '<Home>', { desc = 'Move to beginning of line' })
 vim.keymap.set('i', '<C-e>', '<End>', { desc = 'Move to end of line' })


vim.keymap.set('i', '<C-f>', '<C-o>b', { desc = 'Move one word left' })
vim.keymap.set('i', '<C-d>', '<C-o>w', { desc = 'Move one word right' })


