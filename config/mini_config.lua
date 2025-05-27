-- ~/.config/nvim/lua/mini.lua
-- Автозакрытие скобок, кавычек и тегов (mini.pairs)
require('mini.pairs').setup({
  -- Режимы, где работает автозакрытие (нормальный/визуальный/командный)
  modes = { insert = true, command = false, delete = false },

  -- Настройки для каждого символа
  mappings = {
    -- Скобки
    ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].', register = { cr = false } },
    ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].', register = { cr = false } },
    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].', register = { cr = false } },

    -- Кавычки (только если следующий символ не пробел/конец строки)
    ['"'] = { action = 'open', pair = '""', neigh_pattern = '[^%s\\].', register = { cr = false } },
    ["'"] = { action = 'open', pair = "''", neigh_pattern = '[^%s\\].', register = { cr = false } },
    ['`'] = { action = 'open', pair = '``', neigh_pattern = '[^%s\\].', register = { cr = false } },

    -- HTML-теги (работает в файлах html/xml/jsx)
    ['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^%s\\].', register = { cr = false } },
  },

  -- Отключение автозакрытия при нажатии Enter внутри скобок
  options = {
    ignore_blank_line = true,  -- Игнорировать пустые строки
    disable_in_insert = false, -- Всегда активно в insert-режиме
  }
})
