require'nvim-treesitter.configs'.setup {
    ensure_installed = { "go", "lua" },  -- Указываем только нужные языки
    highlight = { enable = true },
    incremental_selection = { enable = true },
    textobjects = { enable = true },
}
