-- [ Перемещение по буферам ]

 -- Tab для следующего буфера

vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true }) 

-- Shift+Tab для предыдущего буфера

vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true })  


-- [ Работа с файлами ]
		
-- Сохранение файла
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { desc = 'Save file in insert mode' })

-- [ Работа со строками ]

-- На строчку ниже
vim.keymap.set('i', '<C-j>', '<Esc>:move .+1<CR>==gi', { desc = 'Move line down' })

-- На строчку выше
vim.keymap.set('i', '<C-k>', '<Esc>:move .-2<CR>==gi', { desc = 'Move line up' })

-- Свернуть блок кода 
vim.keymap.set('n', '<C-[>', 'zc', { desc = 'Fold current block' })

-- Развернуть блок кода 
vim.keymap.set('n', '<C-]>', 'zo', { desc = 'Unfold current block' })
