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
-- Telescope
vim.fn['plug#']('nvim-lua/plenary.nvim')
vim.fn['plug#']('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.4' })
vim.fn['plug#']('ibhagwan/fzf-lua', { ['branch'] = 'main' })

vim.call('plug#end')

home=os.getenv("HOME")
package.path = home .. "/.config/nvim/config/?.lua;" .. package.path

require"vimtree"
require"theme"
require"common"
require"barbar"
require"lua_line"
require"treesitter"
require"coclsp"
require"comment-config"
require"keymaps"
require"telescope_config"
require"mini_config"
require"lastplace"
require"options"
