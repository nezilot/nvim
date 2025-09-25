require'nvim-treesitter.configs'.setup {
    ensure_installed = { "go", "lua", "c" },
    highlight = { enable = true },
    incremental_selection = { enable = true },
    textobjects = {
        enable = true,
    },
}
