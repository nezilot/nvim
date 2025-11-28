-- Функция для вставки шаблона
local function insert_html_template()
    local template_path = '/home/kitty/.config/nvim/templates/html.tpl'
    if vim.fn.filereadable(template_path) == 1 then
        -- Читаем файл и фильтруем пустые строки
        local template = vim.fn.readfile(template_path)
        local filtered_template = {}
        for _, line in ipairs(template) do
            if line:match('%S') then  -- если строка не пустая
                table.insert(filtered_template, line)
            end
        end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, filtered_template)
    end
end

vim.api.nvim_create_autocmd('BufRead', {
    pattern = '*.html',
    callback = function()
        -- Проверяем что файл пустой (только что создан) и не является помощью и т.д.
        local bufname = vim.fn.bufname()
        if not bufname:match('^%a+://') and vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
            insert_html_template()
        end
    end
})
