vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

local function safe_del(mode, lhs, opts)
	pcall(vim.keymap.del, mode, lhs, opts)
end

local function async_remove()
	local api = require("nvim-tree.api")
	local node = api.tree.get_node_under_cursor()
	if not node then return end

	local path = node.absolute_path or node.link_to
	local escaped_path = vim.fn.shellescape(path)
	local is_folder = node.type == "directory"

	vim.ui.input({
		prompt = (is_folder and "Удалить папку? y/n: " or "Удалить файл? y/n: "),
	}, function(input)
		if not input or not input:lower():match("^y") then return end

		local cmd = is_folder
			and ("rm -rf " .. escaped_path)
			or ("rm " .. escaped_path)

		vim.fn.jobstart(cmd, {
			on_exit = function(_, code)
				vim.schedule(function()
					if code == 0 then
						api.tree.reload()
						vim.notify("Удалено", vim.log.levels.INFO)
					else
						vim.notify("Ошибка удаления", vim.log.levels.ERROR)
					end
				end)
			end,
		})
	end)
end


local function attach(bufnr)
	local api = require("nvim-tree.api")

	-- 🔥 ПЕРЕОПРЕДЕЛЯЕМ ТОЛЬКО delete
	safe_del("n", "d", { buffer = bufnr })
	vim.keymap.set("n", "d", async_remove, {
		buffer = bufnr,
		desc = "Async delete",
	})

	vim.keymap.set("n", "<C-k>", api.node.show_info_popup, {
		buffer = bufnr,
		desc = "File info",
	})

	-- 📁 Enter — открыть файл / раскрыть папку
	vim.keymap.set("n", "<CR>", api.node.open.edit, {
		buffer = bufnr,
		desc = "Open",
	})

	-- ✏️ r — rename
	vim.keymap.set("n", "r", api.fs.rename, {
		buffer = bufnr,
		desc = "Rename",
	})

	-- ➕ n — создать файл/папку
	vim.keymap.set("n", "n", api.fs.create, {
		buffer = bufnr,
		desc = "Create",
	})
end


require("nvim-tree").setup({
	on_attach = attach,
	sort = {
		sorter = "case_sensitive",
	},

	view = {
		side = 'left',
		cursorline = true,
		float = {
			quit_on_focus_loss = true,
			open_win_config = {
				relative = "editor",
				border = "rounded",
				width = 30,
				height = 30,
				row = 1,
				col = 1,
			}
		},
	},

	diagnostics = {
		enable = true,
		show_on_dirs = true,
		show_on_open_dirs = true,
		debounce_delay = 50,
		severity = {
			min = vim.diagnostic.severity.ERROR,
			max = vim.diagnostic.severity.ERROR,
		},
	},

	git = {
		enable = true,
		ignore = false,
	},

	renderer = {
		group_empty = false,
		highlight_opened_files = "name",
		icons = {
			show = {
				file = true,
				folder = true,
				folder_arrow = true,
			},
		},
	},

	update_focused_file = {
		enable = true,
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

	auto_reload_on_write = true,
	disable_netrw = true,
})



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

-- vim.api.nvim_create_autocmd('FileType', {
-- 	pattern = 'NvimTree',
-- 	callback = function()
-- 		local api = require('nvim-tree.api')
-- 		local function opts(desc)
-- 			return { buffer = true, noremap = true, silent = true, nowait = true, desc = desc }
-- 		end
--
-- 		vim.keymap.set('n', 'n', function()
-- 			local api = require('nvim-tree.api')
-- 			local node = api.tree.get_node_under_cursor()
--
-- 			if not node then
-- 				vim.notify("Not in nvim-tree", vim.log.levels.WARN)
-- 				return
-- 			end
--
-- 			vim.ui.input({ prompt = "Путь и имя (файл или папка): " }, function(name)
-- 				if name then
-- 					local node = api.tree.get_node_under_cursor()
-- 					local path = node.absolute_path or node.link_to or vim.fn.getcwd()
-- 					local full_path = path .. "/" .. name
--
-- 					-- Create file or folder based on the name
-- 					local ok, err
-- 					if name:match("%.") then
-- 						-- Create file if name contains a dot (i.e., file extension)
-- 						ok, err = pcall(function()
-- 							local file = io.open(full_path, "w")
-- 							if file then file:close() end
-- 						end)
-- 					else
-- 						-- Create directory if name does not contain a dot
-- 						ok, err = pcall(vim.fn.mkdir, full_path, "p")
-- 					end
--
-- 					if ok then
-- 						api.tree.reload()
-- 						vim.notify((name:match("%.") and "Файл" or "Папка") .. " создана: " .. full_path,
-- 							vim.log.levels.INFO)
-- 					else
-- 						vim.notify((name:match("%.") and "Ошибка создания файла: " or "Ошибка создания папки: ") .. err,
-- 							vim.log.levels.ERROR)
-- 					end
-- 				end
-- 			end)
-- 		end, { desc = "Меню создания файла/папки" })
--
-- 		-- Quick actions
-- 		vim.keymap.set('n', 'p', api.fs.remove, opts("Удалить "))
-- 		vim.keymap.set('n', 'r', api.fs.rename, opts("Переименовать"))
-- 		vim.keymap.set('n', 'y', api.fs.copy.node, opts("Копировать"))
-- 		vim.keymap.set('n', 'x', api.fs.cut, opts("Вырезать"))
-- 		vim.keymap.set('n', 'p', api.fs.paste, opts("Вставить"))
-- 	end
-- })

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'NvimTree',
	callback = function()
		local api = require('nvim-tree.api')

		vim.api.nvim_buf_create_user_command(0, 'GitAdd', function()
			local node = api.tree.get_node_under_cursor()
			if node then
				vim.fn.jobstart('git add ' .. vim.fn.shellescape(node.absolute_path or node.link_to), {
					on_exit = function(_, code)
						print(code == 0 and "✓ Added" or "✗ Error")
					end
				})
			end
		end, { desc = 'Stage current file/dir' })

		vim.api.nvim_buf_create_user_command(0, 'GitCommit', function(opts)
			vim.fn.jobstart('git commit -m ' .. vim.fn.shellescape(opts.args), {
				on_exit = function(_, code)
					print(code == 0 and "✓ Committed" or "✗ Error")
				end
			})
		end, { desc = 'Commit with message', nargs = 1 })

		vim.api.nvim_buf_create_user_command(0, 'GitPush', function()
			vim.fn.jobstart('git push', {
				on_exit = function(_, code)
					print(code == 0 and "✓ Pushed" or "✗ Error")
				end
			})
		end, { desc = 'Push changes' })

		vim.keymap.set('n', 'ga', ':GitAdd<CR>', { buffer = true, desc = 'Git add' })
		vim.keymap.set('n', 'gc', ':GitCommit ', { buffer = true, desc = 'Git commit' })
		vim.keymap.set('n', 'gp', ':GitPush<CR>', { buffer = true, desc = 'Git push' })
	end
})
