-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- setup with options
require("nvim-tree").setup({
    -- Сортировка файлов в NvimTree
    sort = {
        sorter = "case_sensitive",  -- Сортировка с учётом регистра
    },

    -- Окно просмотра
    view = {
        side = 'left',  -- Открывать NvimTree слева
        cursorline = true,
        float = {
            quit_on_focus_loss = true,  -- закрытие при потере фокуса
            open_win_config = {
                relative = "editor",  -- относительно редактора
                border = "rounded",  -- закругленные края
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
    min = vim.diagnostic.severity.ERROR,  -- только ошибки
    max = vim.diagnostic.severity.ERROR,
  },
},

    -- Работа с Git
    git = {
        enable = true,  -- Включить поддержку Git
        ignore = false,  -- Не игнорировать файлы, находящиеся под версионным контролем
    },

    -- Отображение дерева
    renderer = {
        group_empty = true,  -- Группировать пустые папки
        highlight_opened_files = "name",  -- Подсветка открытого файла
        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
            },
        },
    },

    -- Обновление текущего файла
    update_focused_file = {
        enable = true,  -- Фокус на текущем файле
        update_root = false,  -- Не менять корень проекта при фокусировке
        ignore_list = {},  -- Игнорируемые файлы
    },

    -- Фильтры
    filters = {
        dotfiles = false,  -- Показывать dot-файлы
    },

    -- Действия с файлами
    actions = {
        open_file = {
            quit_on_open = false,  -- Не закрывать NvimTree при открытии файла
        },
        change_dir = {
            enable = true,  -- Возможность менять директорию
            global = false,  -- Локальная смена директории для каждого окна
        },
    },

    -- Настройки автозапуска NvimTree при старте
    auto_reload_on_write = true,  -- Перезагружать дерево при изменении файлов
    disable_netrw = true,  -- Отключить netrw, чтобы использовать только NvimTree
})-- Smart toggle/focus/close NvimTree with Ctrl+\
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

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'NvimTree',
    callback = function()
        local api = require('nvim-tree.api')

        -- Функция для выполнения команды Git
        local function run_git_command(command, file_path)
            local cmd = "git " .. command .. " " .. file_path
            vim.cmd("!" .. cmd)
        end

        -- Настроим клавишу g для выбора действия
        vim.keymap.set('n', 'g', function()
            local node = api.tree.get_node_under_cursor()

            if not node then
                vim.notify("Not in nvim-tree", vim.log.levels.WARN)
                return
            end

            local file_path = node.absolute_path or node.link_to
            local is_directory = node.nodes ~= nil and #node.nodes > 0

            -- Запрашиваем действие через vim.ui.input
            vim.ui.select({ "git add", "git commit", "git push" }, {
                prompt = "Выберите действие для Git:",
            }, function(choice)
                if choice == "git add" then
                    if is_directory then
                        -- Если это папка, добавляем все файлы в папке
                        local files = api.fs.get_nodes_in_dir(file_path)
                        for _, file in ipairs(files) do
                            run_git_command("add", file.absolute_path)
                        end
                        vim.notify("Все файлы в папке добавлены в Git", vim.log.levels.INFO)
                    else
                        -- Если это файл, добавляем только его
                        run_git_command("add", file_path)
                        vim.notify("Файл добавлен в Git: " .. file_path, vim.log.levels.INFO)
                    end
                elseif choice == "git commit" then
                    -- Открываем команду git commit
                    vim.ui.input({ prompt = "Введите сообщение коммита: " }, function(msg)
                        if msg then
                            run_git_command("commit -m \"" .. msg .. "\"", "")
                            vim.notify("Коммит выполнен", vim.log.levels.INFO)
                        end
                    end)
                elseif choice == "git push" then
                    -- Выполняем git push
                    run_git_command("push", "")
                    vim.notify("Изменения отправлены на сервер", vim.log.levels.INFO)
                end
            end)
        end, { noremap = true, silent = true, desc = "Git actions in NvimTree" })
    end
})
