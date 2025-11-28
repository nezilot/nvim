local vim = vim

vim.call('plug#begin', '~/.config/nvim/plugged')

-- Основные
vim.fn['plug#']('rose-pine/neovim')
vim.fn['plug#']('kyazdani42/nvim-tree.lua')
vim.fn['plug#']('nvim-tree/nvim-web-devicons')
vim.fn['plug#']('romgrk/barbar.nvim')
vim.fn['plug#']('nvim-lualine/lualine.nvim')
vim.fn['plug#']('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
vim.fn['plug#']('echasnovski/mini.nvim')
vim.fn['plug#']('neoclide/coc.nvim', { ['branch'] = 'release' })
vim.fn['plug#']('f-person/git-blame.nvim')
vim.fn['plug#']('numToStr/Comment.nvim')
vim.fn['plug#']('ethanholz/nvim-lastplace')
vim.fn['plug#']('tpope/vim-fugitive')
vim.fn['plug#']('norcalli/nvim-colorizer.lua')

-- debug
vim.fn['plug#']('mfussenegger/nvim-dap')
vim.fn['plug#']('mxsdev/nvim-dap-vscode-js')
vim.fn['plug#']('rcarriga/nvim-dap-ui')
vim.fn['plug#']('nvim-neotest/nvim-nio')

-- mason
vim.fn['plug#']('williamboman/mason.nvim')

-- theme

vim.fn['plug#']('yorumicolors/yorumi.nvim')

-- Telescope
vim.fn['plug#']('nvim-lua/plenary.nvim')
vim.fn['plug#']('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.4' })
vim.fn['plug#']('ibhagwan/fzf-lua', { ['branch'] = 'main' })

-- json / xml
vim.fn['plug#']('LunarVim/bigfile.nvim') -- САМЫЙ ВАЖНЫЙ для больших файлов

-- Быстрый просмотр JSON без лагов
vim.fn['plug#']('gennaro-tedesco/nvim-jqx')

-- Легковесная навигация по структуре
vim.fn['plug#']('stevearc/aerial.nvim')

vim.call('plug#end')

home = os.getenv("HOME")
package.path = home .. "/.config/nvim/config/?.lua;" .. package.path

require "vimtree"
require "theme"
require "common"
require "wbarbar"
require "lua_line"
require "treesitter"
require "coclsp"
require "comment-config"
require "keymaps"
require "telescope_config"
require "mini_config"
require "lastplace"
require "options"
require "snippets"
require "colorize"
require "uptimaze"
require "masonn"
require "dapp"
