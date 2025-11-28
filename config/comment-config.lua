require('Comment')

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascriptreact', 'typescriptreact' },
    callback = function()
        vim.bo.commentstring = '{/* %s */}'
    end,
})
