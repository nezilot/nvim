local saveAutoFormat = function()
	local success, _ = pcall(vim.fn.CocAction, 'format')

	if success then
		vim.cmd("write")
	else
		vim.cmd("write")
	end

	if vim.api.nvim_get_mode().mode == 'i' then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
	end
end

vim.keymap.set('n', 'qq', '<Cmd>bd!<CR>', { desc = 'close current buffer' })

-- save buffer and exit
-- vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>', { desc = 'save file and exit' })

vim.keymap.set('i', '<C-s>', saveAutoFormat, { desc = 'save file and exit' })

-- move line down
vim.keymap.set('i', '[', '<Esc>:move .+1<CR>==gi', { desc = 'down' })

-- move line -up
vim.keymap.set('i', ']', '<Esc>:move .-2<CR>==gi', { desc = 'up' })

-- moving in i moder
vim.keymap.set('i', '<C-h>', '<Left>', { desc = 'left' })
vim.keymap.set('i', '<C-j>', '<Down>', { desc = 'down' })
vim.keymap.set('i', '<C-k>', '<Up>', { desc = 'up' })
vim.keymap.set('i', '<C-l>', '<Right>', { desc = 'right' })

-- moving cursor
vim.keymap.set('i', '<C-a>', '<Home>', { desc = 'move to beginning ' })
vim.keymap.set('i', '<C-e>', '<End>', { desc = 'move to end of line' })

-- moving row
vim.keymap.set('i', '<C-f>', '<C-o>b', { desc = 'move one word left' })
vim.keymap.set('i', '<C-d>', '<C-o>w', { desc = 'move one word right' })

-- terminal

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.api.nvim_set_keymap('n', 't', ':terminal<CR>', { noremap = true, silent = true, desc = 'Open terminal in split' })

vim.opt.langmap = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
