-- Плагин barbar.nvim (если используешь lazy.nvim или packer — подключай его отдельно)
-- Настройка:
require'barbar'.setup {
    animation = true,
    clickable = true,
    insert_at_end = true,
    focus_on_close = 'left',  -- можно поменять на 'previous'
    exclude_ft = {'javascript'},
    exclude_name = {'package.json'},
    highlight_inactive_file_icons = false,
    highlight_visible = true,
    maximum_padding = 1,
    minimum_padding = 1,
    maximum_length = 30,
    minimum_length = 0,
    semantic_letters = true,
    no_name_title = nil,
    sidebar_filetypes = {
        NvimTree = true,
        undotree = {text = 'undotree'},
        ['neo-tree'] = {event = 'BufWipeout'},
        Outline = {event = 'BufWinLeave', text = 'symbols-outline'},
    },
    letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',

    icons = {
        buffer_index = false,
        buffer_number = false,
        button = '',
        diagnostics = {
            [vim.diagnostic.severity.ERROR] = {enabled = true, icon = 'ﬀ'},
            [vim.diagnostic.severity.WARN] = {enabled = false},
            [vim.diagnostic.severity.INFO] = {enabled = false},
            [vim.diagnostic.severity.HINT] = {enabled = true},
        },
        gitsigns = {
            added = {enabled = true, icon = '+'},
            changed = {enabled = true, icon = '~'},
            deleted = {enabled = true, icon = '-'},
        },
        filetype = {
            custom_colors = false,
            enabled = true,
        },
        separator = {left = '▎', right = ''},
        separator_at_end = true,
        modified = {button = '●'},
        pinned = {button = '', filename = true},
        preset = 'default',
        alternate = {filetype = {enabled = false}},
        current = {buffer_index = true},
        inactive = {button = '×'},
        visible = {modified = {buffer_number = false}},
    },
}

-- 🔁 Ключи для последовательного переключения буферов
vim.api.nvim_set_keymap('n', '<TAB>', ':BufferNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-TAB>', ':BufferPrevious<CR>', { noremap = true, silent = true })

-- 🧹 Сброс сортировки на буферный порядок (по умолчанию)
vim.api.nvim_set_keymap('n', '<leader>bs', ':BufferSortByBufferNumber<CR>', { noremap = true, silent = true })

-- 🗑 Закрыть текущий буфер
vim.api.nvim_set_keymap('n', '<leader>bd', ':BufferClose<CR>', { noremap = true, silent = true })
