-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- setup with options

require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
		highlight_opened_files = "name", -- 🔥 это подсветка текущего файла
	},
	update_focused_file = {
		enable = true, -- 🔥 это фокусировка на текущем буфере
		update_root = false,
		ignore_list = {},
	},
	filters = {
		dotfiles = false,
	},
	actions = {
		open_file = {
			quit_on_open = false,
		},
		change_dir = {
			enable = true,
			global = false,
		},
	},
})

-- Smart toggle/focus/close NvimTree with Ctrl+\
vim.keymap.set('n', '<C-\\>', function()
	local nvim_tree = require('nvim-tree.api')
	local is_open = nvim_tree.tree.is_visible()

	if is_open then
		local is_focused = vim.fn.winnr() == vim.fn.bufwinnr('NvimTree_' .. vim.api.nvim_get_current_tabpage())
		if is_focused then
			nvim_tree.tree.close()
		else
			nvim_tree.tree.focus()
		end
	else
		nvim_tree.tree.open()
	end
end, { noremap = true, silent = true, desc = "Toggle NvimTree" })

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'NvimTree',
	callback = function()
		local api = require('nvim-tree.api')
		local function opts(desc)
			return { buffer = true, noremap = true, silent = true, nowait = true, desc = desc }
		end

		-- Main menu on 'n'
		vim.keymap.set('n', 'n', function()
	local api = require('nvim-tree.api')
	local node = api.tree.get_node_under_cursor()
	
	if not node then
		vim.notify("Not in nvim-tree", vim.log.levels.WARN)
		return
	end

	vim.ui.select(
		{
			"Создать файл",
			"Создать папку",
			"Удалить",
			"Переименовать",
			"Копировать",
			"Вырезать",
			"Вставить"
		},
		{ 
			prompt = "Действия с файлом:",
			format_item = function(item)
				return " " .. item
			end
		},
		function(choice)
			if not choice then return end

			if choice == "Создать файл" then
				vim.ui.input({ prompt = "Имя файла: " }, function(filename)
					if filename then
						local node = api.tree.get_node_under_cursor()
						local path = node.absolute_path or node.link_to or vim.fn.getcwd()
						local full_path = path .. "/" .. filename
						
						local ok, err = pcall(function()
							local file = io.open(full_path, "w")
							if file then file:close() end
						end)
						
						if ok then
							api.tree.reload()
							vim.notify("Файл создан: " .. full_path, vim.log.levels.INFO)
						else
							vim.notify("Ошибка создания файла: " .. err, vim.log.levels.ERROR)
						end
					end
				end)
			elseif choice == "Создать папку" then
				vim.ui.input({ prompt = "Имя папки: " }, function(folder_name)
					if folder_name then
						local node = api.tree.get_node_under_cursor()
						local path = node.absolute_path or node.link_to or vim.fn.getcwd()
						local full_path = path .. "/" .. folder_name
						
						local ok, err = pcall(vim.fn.mkdir, full_path, "p")
						if ok then
							api.tree.reload()
							vim.notify("Папка создана: " .. full_path, vim.log.levels.INFO)
						else
							vim.notify("Ошибка создания папки: " .. err, vim.log.levels.ERROR)
						end
					end
				end)
			elseif choice == "Удалить" then
				api.fs.remove()
			elseif choice == "Переименовать" then
				api.fs.rename()
			elseif choice == "Копировать" then
				api.fs.copy.node()
			elseif choice == "Вырезать" then
				api.fs.cut()
			elseif choice == "Вставить" then
				api.fs.paste()
			end
		end
	)
end, { desc = "Меню действий с файлом" })

		-- Quick actions
		vim.keymap.set('n', 'a', api.fs.create, opts("Создать файл"))
		vim.keymap.set('n', 'A', function() 
			api.fs.create({ type = "directory" })
		end, opts("Создать папку"))
		vim.keymap.set('n', 'd', api.fs.remove, opts("Удалить"))
		vim.keymap.set('n', 'r', api.fs.rename, opts("Переименовать"))
		vim.keymap.set('n', 'y', api.fs.copy.node, opts("Копировать"))
		vim.keymap.set('n', 'x', api.fs.cut, opts("Вырезать"))
		vim.keymap.set('n', 'p', api.fs.paste, opts("Вставить"))
	end
})
