require('mini.pairs').setup({
  modes = { insert = true, command = false, delete = false },
  mappings = {
    -- Скобки (оставляем как было)
    ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].', register = { cr = false } },
    ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].', register = { cr = false } },
    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].', register = { cr = false } },

    -- Кавычки: закрываются только после пробела/начала строки/не буквы
    ['"'] = { action = 'open', pair = '""', neigh_pattern = '[^%w_].', register = { cr = false } },
    ["'"] = { action = 'open', pair = "''", neigh_pattern = '[^%w_].', register = { cr = false } },
    ['`'] = { action = 'open', pair = '``', neigh_pattern = '[^%w_].', register = { cr = false } },

    -- HTML-теги (оставляем как было)
    ['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^%s\\].', register = { cr = false } },
  },
  options = {
    ignore_blank_line = true,
    disable_in_insert = false,
  }
})
