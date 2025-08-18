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
    
    -- Быстрые команды Git
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

    -- Быстрые маппинги
    vim.keymap.set('n', 'ga', ':GitAdd<CR>', { buffer = true, desc = 'Git add' })
    vim.keymap.set('n', 'gc', ':GitCommit ', { buffer = true, desc = 'Git commit' })
    vim.keymap.set('n', 'gp', ':GitPush<CR>', { buffer = true, desc = 'Git push' })
  end
})
