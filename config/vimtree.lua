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

			-- Ask for the name and type of creation
			vim.ui.input({ prompt = "Путь и имя (файл или папка): " }, function(name)
				if name then
					local node = api.tree.get_node_under_cursor()
					local path = node.absolute_path or node.link_to or vim.fn.getcwd()
					local full_path = path .. "/" .. name

					-- Create file or folder based on the name
					local ok, err
					if name:match("%.") then
						-- Create file if name contains a dot (i.e., file extension)
						ok, err = pcall(function()
							local file = io.open(full_path, "w")
							if file then file:close() end
						end)
					else
						-- Create directory if name does not contain a dot
						ok, err = pcall(vim.fn.mkdir, full_path, "p")
					end
					
					if ok then
						api.tree.reload()
						vim.notify((name:match("%.") and "Файл" or "Папка") .. " создана: " .. full_path, vim.log.levels.INFO)
					else
						vim.notify((name:match("%.") and "Ошибка создания файла: " or "Ошибка создания папки: ") .. err, vim.log.levels.ERROR)
					end
				end
			end)
		end, { desc = "Меню создания файла/папки" })

		-- Quick actions
		vim.keymap.set('n', 'd', api.fs.remove, opts("Удалить"))
		vim.keymap.set('n', 'r', api.fs.rename, opts("Переименовать"))
		vim.keymap.set('n', 'y', api.fs.copy.node, opts("Копировать"))
		vim.keymap.set('n', 'x', api.fs.cut, opts("Вырезать"))
		vim.keymap.set('n', 'p', api.fs.paste, opts("Вставить"))
	end
})
