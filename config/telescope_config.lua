require('telescope').setup {
	defaults = {
		prompt_prefix = "🔍 ",
		selection_caret = ":D ",

		file_ignore_patterns = {
			"node_modules",
			".git",
			".next",
			".cache",
			"pnpm-lock.yaml",
		},

		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
		},

		mappings = {
			i = {
				["<C-h>"] = "which_key",
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
			}
		}
	},
	pickers = {
			},
	extensions = {}
}


vim.keymap.set('n', '\\f', require('telescope.builtin').find_files, { desc = "Find files" })

vim.keymap.set('n', '\\h', require('telescope.builtin').help_tags, { desc = "Help tags" })
vim.keymap.set('n', '\\r', require('telescope.builtin').oldfiles, { desc = "Recent files" })
