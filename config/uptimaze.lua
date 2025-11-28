

-- КРИТИЧЕСКИЕ настройки против лагов
vim.cmd('set noswapfile')
vim.cmd('set nobackup') 
vim.cmd('set nowritebackup')
vim.cmd('set lazyredraw')
vim.cmd('set synmaxcol=500')

-- Настройка bigfile (главное!)
require('bigfile').setup({
  filesize = 1, -- 1MB
  pattern = {"*"},
  features = {
    "indent_blankline",
    "illuminate",
    "lsp", 
    "treesitter",
    "syntax",
    "matchparen",
    "vimopts",
    "filetype",
  }
})

-- Автоотключение синтаксиса для ОЧЕНЬ больших файлов
vim.cmd([[
  autocmd BufReadPre * if getfsize(expand("%")) > 5000000 | set syntax=OFF | endif
]])
