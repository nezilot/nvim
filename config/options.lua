-- Определение Wayland через переменные окружения
local is_wayland = false
if vim.env.WAYLAND_DISPLAY and vim.env.WAYLAND_DISPLAY ~= '' then
    is_wayland = true
elseif vim.env.XDG_SESSION_TYPE and vim.env.XDG_SESSION_TYPE == 'wayland' then
    is_wayland = true
end


if vim.fn.has('win32') == 1 then
    -- Для Windows
    vim.g.clipboard = {
        name = 'win32yank',
        copy = {
            ["+"] = 'win32yank.exe -i --crlf',
            ["*"] = 'win32yank.exe -i --crlf',
        },
        paste = {
            ["+"] = 'win32yank.exe -o --lf',
            ["*"] = 'win32yank.exe -o --lf',
        },
        cache_enabled = true,
    }
elseif vim.fn.has('mac') == 1 then
    -- Для macOS
    vim.g.clipboard = {
        name = 'macOS',
        copy = {
            ["+"] = 'pbcopy',
            ["*"] = 'pbcopy',
        },
        paste = {
            ["+"] = 'pbpaste',
            ["*"] = 'pbpaste',
        },
        cache_enabled = true,
    }
elseif is_wayland then
    -- Wayland
    vim.g.clipboard = {
        name = 'wl-clipboard',
        copy = {
            ["+"] = 'wl-copy --foreground --type text/plain',
            ["*"] = 'wl-copy --primary --foreground --type text/plain',
        },
        paste = {
            ["+"] = 'wl-paste --no-newline',
            ["*"] = 'wl-paste --primary --no-newline',
        },
        cache_enabled = true,
    }
else
    -- X11
    vim.g.clipboard = {
        name = 'xclip',
        copy = {
            ["+"] = 'xclip -selection clipboard',
            ["*"] = 'xclip -selection primary',
        },
        paste = {
            ["+"] = 'xclip -selection clipboard -o',
            ["*"] = 'xclip -selection primary -o',
        },
        cache_enabled = true,
    }
end

-- Настройка поведения по умолчанию
vim.opt.clipboard = 'unnamedplus'

-- Дополнительные маппинги для удобства
vim.keymap.set({ 'n', 'v' }, 'y', '"+y', { desc = 'Копировать в системный буфер' })
vim.keymap.set({ 'n', 'v' }, 'p', '"+p', { desc = 'Вставить из системного буфера' })
vim.keymap.set({ 'n', 'v' }, 'P', '"+P', { desc = 'Вставить до курсора из буфера' })
