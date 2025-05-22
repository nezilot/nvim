local vim = vim

vim.call('plug#begin', '~/.config/nvim/plugged')

-- Плагины
vim.fn['plug#']('rose-pine/neovim')
vim.fn['plug#']('kyazdani42/nvim-tree.lua')
vim.fn['plug#']('nvim-tree/nvim-web-devicons')
vim.fn['plug#']('romgrk/barbar.nvim')
vim.fn['plug#']('nvim-lualine/lualine.nvim')
vim.fn['plug#']('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
-- Для coc.nvim указываем так:
vim.fn['plug#']('neoclide/coc.nvim', { ['branch'] = 'release' })
vim.fn['plug#']('f-person/git-blame.nvim')
vim.fn['plug#']('numToStr/Comment.nvim')

vim.call('plug#end')

home=os.getenv("HOME")
package.path = home .. "/.config/nvim/?.lua;" .. package.path

require"vimtree"
require"theme"
require"common"
require"barbar"
require"lua_line"
require"treesitter"
require"coclsp"
require('comment-config')
require('shortcut')
