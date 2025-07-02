-- Отключаем netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Включаем 24-битные цвета (для корректного отображения темы)
vim.opt.termguicolors = true

-- Локальная переменная для отслеживания состояния NvimTree
local nvim_tree_visible = false

-- Оптимизированная функция обновления подсветки (работает только когда дерево видимо)
local function update_nvim_tree_highlight()
  if not nvim_tree_visible then return end
  
  local ok, api = pcall(require, 'nvim-tree.api')
  if ok and api.tree.is_visible() then
    api.tree.find_file(vim.api.nvim_buf_get_name(0), false)
  end
end

-- Настройка NvimTree (оптимизированная версия)
require("nvim-tree").setup({
  view = {
    width = 30,
    cursorline = true,
    -- Отключаем ненужные функции
    relativenumber = false,
    number = false,
    preserve_window_proportions = false,
  },
  renderer = {
    highlight_opened_files = "icon",
    indent_markers = {
      enable = true,
    },
    icons = {
      webdev_colors = false, -- Используем цвета темы
      show = {
        git = true,
        file = true,
        folder = true,
        folder_arrow = false, -- Убираем стрелки для минимализма
      },
    },
    -- Оптимизации рендеринга
    add_trailing = false,
    highlight_git = false,
    highlight_modified = "none",
    root_folder_modifier = ":~",
  },
  -- Отключаем ненужные функции
  filters = {
    dotfiles = false,
    custom = {},
    exclude = {},
  },
  actions = {
    change_dir = {
      enable = false, -- Убираем автоматическое изменение директории
    },
    open_file = {
      quit_on_open = false,
      window_picker = {
        enable = false, -- Убираем выбор окна (для производительности)
      },
    },
  },
  -- Минималистичная настройка обновлений
  update_focused_file = {
    enable = true,
    update_root = false,
    update_cwd = false,
  },
})


vim.api.nvim_create_autocmd('FileType', {
  pattern = 'NvimTree',
  callback = function()
    -- Делаем курсор полностью прозрачным
    vim.opt_local.guicursor = "a:ver1-Cursor/lCursor-blinkon0"
    
    -- Альтернативный вариант (для некоторых терминалов)
    vim.cmd([[highlight Cursor guifg=bg guibg=bg]])
    
    -- Улучшаем подсветку строки
    vim.cmd([[
      highlight NvimTreeCursorLine guibg=#3a3a3a gui=none
    ]])
    
    -- Дополнительные настройки для лучшего вида
    vim.opt_local.signcolumn = "no"
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end
})

-- Восстанавливаем курсор при выходе из NvimTree
vim.api.nvim_create_autocmd('BufLeave', {
  pattern = 'NvimTree_*',
  callback = function()
    vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
    vim.cmd([[highlight Cursor guifg=NONE guibg=NONE]])
  end
})

-- Умное переключение NvimTree с отслеживанием состояния
vim.keymap.set('n', '<C-\\>', function()
  local api = require('nvim-tree.api')
  nvim_tree_visible = not api.tree.is_visible()
  
  if nvim_tree_visible then
    api.tree.open()
    -- Небольшая задержка для стабильности
    vim.defer_fn(update_nvim_tree_highlight, 50)
  else
    api.tree.close()
  end
end, { noremap = true, silent = true, desc = "Toggle NvimTree" })

-- Автоматическое обновление только при видимом дереве
local nvim_tree_group = vim.api.nvim_create_augroup("NvimTree", { clear = true })
vim.api.nvim_create_autocmd({'BufEnter', 'WinEnter'}, {
  group = nvim_tree_group,
  callback = function()
    if nvim_tree_visible then
      update_nvim_tree_highlight()
    end
  end
})

-- Настройки только для буфера NvimTree (загружаются при открытии)
vim.api.nvim_create_autocmd('FileType', {
  group = nvim_tree_group,
  pattern = 'NvimTree',
  callback = function()
    local api = require('nvim-tree.api')
    local function opts(desc)
      return { buffer = true, noremap = true, silent = true, nowait = true, desc = desc }
    end

    -- Минималистичное меню действий
    vim.keymap.set('n', 'n', function()
      vim.ui.select(
        { "Создать", "Удалить", "Переименовать", "Копировать" },
        { prompt = "Действия:" },
        function(choice)
          if choice == "Создать" then api.fs.create() end
          if choice == "Удалить" then api.fs.remove() end
          if choice == "Переименовать" then api.fs.rename() end
          if choice == "Копировать" then api.fs.copy.node() end
        end
      )
    end, opts("Меню действий"))

    -- Быстрые действия (только основные)
    vim.keymap.set('n', 'a', api.fs.create, opts("Создать файл"))
    vim.keymap.set('n', 'd', api.fs.remove, opts("Удалить"))
    vim.keymap.set('n', 'r', api.fs.rename, opts("Переименовать"))
  end
})
