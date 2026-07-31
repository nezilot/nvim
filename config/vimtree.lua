vim.g.loaded_netrw = 1

vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

-- ПРОСТАЯ НАСТРОЙКА NEO-TREE
require("neo-tree").setup({
    window = {
        position = "float",
        width = 60,
        height = 40,
        border = "rounded",
    },
    
    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
        },
        follow_current_file = {
            enabled = true,
        },
    },
    
    git = {
        enabled = true,
    },
    
    default_component_configs = {
        icon = {
            folder_closed = "📁",
            folder_open = "📂",
            folder_empty = "📭",
            default = "📄",
        },
    },
})

-- vim.keymap.set('n', 'n', 'a', { buffer = bufnr, remap = true, desc = 'Create file' })
-- vim.keymap.set('n', 'N', 'A', { buffer = bufnr, remap = true, desc = 'Create folder' })
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'neo-tree',
    callback = function(ev)
        -- Этот маппинг работает ТОЛЬКО в окне neo-tree
        vim.keymap.set('n', 'N', 'A', { buffer = ev.buf, remap = true, desc = 'Create folder' })
    end
})

-- Функция для закрытия плавающего окна
local function close_neo_tree()
    -- Ищем окно neo-tree
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
        if ft == 'neo-tree' then
            vim.api.nvim_win_close(win, true)
            return true
        end
    end
    return false
end

-- Функция для проверки открыто ли neo-tree
local function is_neo_tree_open()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
        if ft == 'neo-tree' then
            return true
        end
    end
    return false
end

-- КЛАВИША ДЛЯ ОТКРЫТИЯ/ЗАКРЫТИЯ
vim.keymap.set('n', '<C-\\>', function()
    if is_neo_tree_open() then
        close_neo_tree()
    else
        require("neo-tree.command").execute({ 
            action = "focus", 
            source = "filesystem" 
        })
    end
end, { noremap = true, silent = true, desc = "Toggle Neo-tree" })

-- ЗАКРЫТИЕ ПО ESC
vim.keymap.set('n', '<Esc>', function()
    close_neo_tree()
end, { noremap = true, silent = true, desc = "Close Neo-tree" })

-- Git команды для neo-tree
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'neo-tree',
    callback = function(ev)
        local bufnr = ev.buf
        
        -- Переназначение клавиш для создания файлов/папок
        vim.keymap.set('n', 'n', 'a', { buffer = bufnr, remap = true, desc = 'Create file' })
        vim.keymap.set('n', 'N', 'A', { buffer = bufnr, remap = true, desc = 'Create folder' })
        
        -- Функция для получения текущего узла
        local function get_current_node()
            -- Получаем список всех окон
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
                if ft == 'neo-tree' then
                    -- Пробуем получить данные из буфера
                    local ok, result = pcall(vim.api.nvim_buf_get_var, buf, 'neo_tree_state')
                    if ok and result then
                        return result
                    end
                end
            end
            return nil
        end

        -- Git Add
        vim.keymap.set('n', 'ga', function()
            local state = get_current_node()
            if state and state.tree then
                local node = state.tree:get_node()
                if node and node.path then
                    vim.fn.jobstart('git add ' .. vim.fn.shellescape(node.path), {
                        on_exit = function(_, code)
                            vim.schedule(function()
                                if code == 0 then
                                    vim.notify("✓ Added", vim.log.levels.INFO)
                                    require("neo-tree.command").execute({ action = "refresh" })
                                else
                                    vim.notify("✗ Error", vim.log.levels.ERROR)
                                end
                            end)
                        end
                    })
                end
            end
        end, { buffer = bufnr, desc = 'Git add' })

        -- Git Commit
        vim.keymap.set('n', 'gc', function()
            local state = get_current_node()
            if state and state.tree then
                local node = state.tree:get_node()
                if node and node.path then
                    vim.ui.input({ prompt = "Commit message: " }, function(msg)
                        if msg and msg ~= "" then
                            vim.fn.jobstart('git commit -m ' .. vim.fn.shellescape(msg), {
                                on_exit = function(_, code)
                                    vim.schedule(function()
                                        if code == 0 then
                                            vim.notify("✓ Committed", vim.log.levels.INFO)
                                            require("neo-tree.command").execute({ action = "refresh" })
                                        else
                                            vim.notify("✗ Error", vim.log.levels.ERROR)
                                        end
                                    end)
                                end
                            })
                        end
                    end)
                end
            end
        end, { buffer = bufnr, desc = 'Git commit' })

        -- Git Push
        vim.keymap.set('n', 'gp', function()
            local state = get_current_node()
            if state and state.tree then
                local node = state.tree:get_node()
                if node and node.path then
                    vim.fn.jobstart('git push', {
                        on_exit = function(_, code)
                            vim.schedule(function()
                                if code == 0 then
                                    vim.notify("✓ Pushed", vim.log.levels.INFO)
                                else
                                    vim.notify("✗ Error", vim.log.levels.ERROR)
                                end
                            end)
                        end
                    })
                end
            end
        end, { buffer = bufnr, desc = 'Git push' })
    end
})

-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
--
-- vim.opt.termguicolors = true
--
-- local function safe_del(mode, lhs, opts)
-- 	pcall(vim.keymap.del, mode, lhs, opts)
-- end
--
-- local function async_remove()
-- 	local api = require("nvim-tree.api")
-- 	local node = api.tree.get_node_under_cursor()
-- 	if not node then return end
--
-- 	local path = node.absolute_path or node.link_to
-- 	local escaped_path = vim.fn.shellescape(path)
-- 	local is_folder = node.type == "directory"
--
-- 	vim.ui.input({
-- 		prompt = (is_folder and "Удалить папку? y/n: " or "Удалить файл? y/n: "),
-- 	}, function(input)
-- 		if not input or not input:lower():match("^y") then return end
--
-- 		local cmd = is_folder
-- 			and ("rm -rf " .. escaped_path)
-- 			or ("rm " .. escaped_path)
--
-- 		vim.fn.jobstart(cmd, {
-- 			on_exit = function(_, code)
-- 				vim.schedule(function()
-- 					if code == 0 then
-- 						api.tree.reload()
-- 						vim.notify("Удалено", vim.log.levels.INFO)
-- 					else
-- 						vim.notify("Ошибка удаления", vim.log.levels.ERROR)
-- 					end
-- 				end)
-- 			end,
-- 		})
-- 	end)
-- end
--
--
-- local function attach(bufnr)
-- 	local api = require("nvim-tree.api")
--
-- 	safe_del("n", "d", { buffer = bufnr })
--
-- 	vim.keymap.set("n", "l", api.tree.change_root_to_node, {
-- 		buffer = bufnr,
-- 		desc = "CD into directory"
-- 	})
--
-- 	vim.keymap.set("n", "h", api.tree.change_root_to_parent, {
-- 		buffer = bufnr,
-- 		desc = "CD up"
-- 	})
--
-- 	vim.keymap.set("n", "d", async_remove, {
-- 		buffer = bufnr,
-- 		desc = "Async delete",
-- 	})
--
-- 	vim.keymap.set("n", "<C-k>", api.node.show_info_popup, {
-- 		buffer = bufnr,
-- 		desc = "File info",
-- 	})
--
-- 	vim.keymap.set("n", "<CR>", api.node.open.edit, {
-- 		buffer = bufnr,
-- 		desc = "Open",
-- 	})
--
-- 	vim.keymap.set("n", "r", api.fs.rename, {
-- 		buffer = bufnr,
-- 		desc = "Rename",
-- 	})
--
-- 	vim.keymap.set("n", "n", api.fs.create, {
-- 		buffer = bufnr,
-- 		desc = "Create",
-- 	})
--
--
-- 	vim.keymap.set("n", "c", api.fs.copy.node, {
-- 		buffer = bufnr,
-- 		desc = "Copy",
-- 	})
--
--
-- 	vim.keymap.set("n", "p", function()
-- 		require("nvim-tree.api").fs.paste() -- функция сама по себе
-- 		require("nvim-tree.api").tree.reload() -- обновляем дерево
-- 	end, {
-- 		buffer = bufnr,
-- 		desc = "Paste",
-- 	})
-- end
--
-- require("nvim-tree").setup({
-- 	on_attach = attach,
--
-- 	sort = {
-- 		sorter = "case_sensitive",
-- 	},
--
-- 	view = {
-- 		side = 'left',
-- 		width = 50,
-- 		cursorline = true,
-- 		preserve_window_proportions = true
-- 	},
--
-- 	git = {
-- 		enable = true,
-- 		ignore = false,
-- 	},
--
-- 	renderer = {
-- 		group_empty = false,
-- 		highlight_opened_files = "name",
-- 		icons = {
-- 			show = {
-- 				file = true,
-- 				folder = true,
-- 				folder_arrow = true,
-- 			},
-- 		},
-- 	},
--
-- 	update_focused_file = {
-- 		enable = true,
-- 		update_root = false,
-- 		ignore_list = {},
-- 	},
--
-- 	filters = {
-- 		dotfiles = false,
-- 	},
--
-- 	actions = {
-- 		open_file = {
-- 			quit_on_open = false,
-- 		},
-- 		change_dir = {
-- 			enable = true,
-- 			global = false,
-- 		},
-- 	},
--
-- 	auto_reload_on_write = true,
-- 	disable_netrw = true,
-- })
--
-- vim.keymap.set('n', '<C-\\>', function()
-- 	local nvim_tree = require('nvim-tree.api')
-- 	local is_open = nvim_tree.tree.is_visible()
--
-- 	if is_open then
-- 		local is_focused = vim.fn.winnr() == vim.fn.bufwinnr('NvimTree_' .. vim.api.nvim_get_current_tabpage())
-- 		if is_focused then
-- 			nvim_tree.tree.close()
-- 		else
-- 			nvim_tree.tree.focus()
-- 		end
-- 	else
-- 		nvim_tree.tree.open()
-- 	end
-- end, { noremap = true, silent = true, desc = "Toggle NvimTree" })
--
-- vim.api.nvim_create_autocmd('FileType', {
-- 	pattern = 'NvimTree',
-- 	callback = function()
-- 		local api = require('nvim-tree.api')
--
-- 		vim.api.nvim_buf_create_user_command(0, 'GitAdd', function()
-- 			local node = api.tree.get_node_under_cursor()
-- 			if node then
-- 				vim.fn.jobstart('git add ' .. vim.fn.shellescape(node.absolute_path or node.link_to), {
-- 					on_exit = function(_, code)
-- 						print(code == 0 and "✓ Added" or "✗ Error")
-- 					end
-- 				})
-- 			end
-- 		end, { desc = 'Stage current file/dir' })
--
-- 		vim.api.nvim_buf_create_user_command(0, 'GitCommit', function(opts)
-- 			vim.fn.jobstart('git commit -m ' .. vim.fn.shellescape(opts.args), {
-- 				on_exit = function(_, code)
-- 					print(code == 0 and "✓ Committed" or "✗ Error")
-- 				end
-- 			})
-- 		end, { desc = 'Commit with message', nargs = 1 })
--
-- 		vim.api.nvim_buf_create_user_command(0, 'GitPush', function()
-- 			vim.fn.jobstart('git push', {
-- 				on_exit = function(_, code)
-- 					print(code == 0 and "✓ Pushed" or "✗ Error")
-- 				end
-- 			})
-- 		end, { desc = 'Push changes' })
--
-- 		vim.keymap.set('n', 'ga', ':GitAdd<CR>', { buffer = true, desc = 'Git add' })
-- 		vim.keymap.set('n', 'gc', ':GitCommit ', { buffer = true, desc = 'Git commit' })
-- 		vim.keymap.set('n', 'gp', ':GitPush<CR>', { buffer = true, desc = 'Git push' })
-- 	end
-- })
