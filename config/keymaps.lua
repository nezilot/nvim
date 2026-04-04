local saveAutoFormat = function()
	-- 1. Выходим из режима вставки
	if vim.api.nvim_get_mode().mode == 'i' then
		vim.cmd('stopinsert')
	end

	-- 2. Запускаем формат асинхронно
	vim.fn.CocActionAsync('format', function(err)
		-- 3. Сохраняем БЕЗ вызова автокоманд (чтобы не триггерить lualine/barbar/git)
		-- 'update' сохранит только если текст реально изменился после формата
		vim.cmd("silent! noautocmd update")

		-- 4. Опционально: если хочешь, чтобы lualine все-таки обновился,
		-- делаем это через микро-паузу, когда nvim уже "отвис"
		vim.schedule(function()
			vim.cmd("checktime") -- Синхронизирует состояние буфера
		end)
	end)
end

-- vim.keymap.set('n', 'qq', '<Cmd>bd!<CR>', { desc = 'close current buffer' })

local smart_close = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local buf_type = vim.bo[bufnr].buftype

	if buf_type == 'terminal' then
		-- Терминал закрываем принудительно, сплит под ним обычно должен схлопнуться
		-- (так как терминал — это процесс)
		vim.cmd('bdelete!')
	else
		-- Для обычных файлов:
		-- 1. Пробуем переключиться на предыдущий буфер ВНУТРИ этого окна
		-- 2. Затем удаляем (bd) предыдущий активный буфер (#)
		local success, _ = pcall(vim.cmd, 'bp | bd #')

		if not success then
			-- Если bp не сработал (один файл в списке), просто чистим буфер
			vim.cmd('bdelete')
		end
	end
end

vim.keymap.set('n', 'qq', smart_close, { desc = 'Close buffer, keep layout' })

vim.keymap.set('n', 'qq', smart_close, { desc = 'Close buffer but keep split alive' })
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

vim.api.nvim_create_autocmd("TermOpen", {
	command = "setlocal winfixheight"
})

-- terminal

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.api.nvim_set_keymap('n', 't', ':terminal<CR>', { noremap = true, silent = true, desc = 'Open terminal in split' })

vim.opt.langmap =
'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz'
